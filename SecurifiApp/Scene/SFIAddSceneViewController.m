//
//  SFIAddSceneViewController.m
//  Scenes
//
//  Created by Admin on 5/1/15.
//  Copyright (c) 2015 MagicDevs. All rights reserved.
//

#import "SFIAddSceneViewController.h"
#import "SFIAddSceneTableViewCell.h"
#import "AlmondPlusConstants.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "MBProgressHUD.h"
#import "UIFont+Securifi.h"
#import "UIImage+Securifi.h"
#import "SFIDeviceIndex.h"
#import "Colours.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]//MD01

@interface SFIAddSceneViewController ()<UITextFieldDelegate,SFIAddSceneTableViewCellDelegate> {
    
    //Saving Inf
    NSMutableArray * sceneEntryList;
    NSMutableArray *cellsInfoArray;
    NSString * sceneName;
    UITextField * activeTextField;
    NSInteger randomMobileInternalIndex;
    CGRect originalTableViewFrame;
}

@property(nonatomic, readonly) SFIAlmondPlus *almond;
@property(nonatomic, readonly) NSArray *deviceList;
@property(nonatomic, readonly) NSDictionary *deviceIndexTable; // device ID :: table cell row
@property(nonatomic, readonly) NSDictionary *deviceValueTable;
@property(nonatomic, readonly) NSString *almondMac;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly) BOOL isHudHidden;
@property(nonatomic) BOOL isViewControllerDisposed;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SFIAddSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sceneInfo = [self.originalSceneInfo copy];
    
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"scene.button.Save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"scene.button.Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    
    
    
    
    // Ensure values have at least an empty list
    cellsInfoArray = [NSMutableArray new];
    sceneEntryList = [NSMutableArray new];
    self.deviceList = @[];
    [self setDeviceValues:@[]];
    
    // Do any additional setup after loading the view.
    [self initializeNotifications];
    [self initializeAlmondData];
}
#pragma mark
- (void)viewWillAppear:(BOOL)animated
{
    randomMobileInternalIndex = arc4random() % 10000;
    if (self.sceneInfo) {
        sceneName = [self.sceneInfo valueForKey:@"Name"];
        self.title = sceneName;
    }else{
        self.title = NSLocalizedString(@"scene.title.New Scene", @"New Scene");
    }
    originalTableViewFrame = self.tableView.frame;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        self.isViewControllerDisposed = YES;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //    [self calculateScrollViewSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnCancelTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onDeviceListDidChange:)
                   name:kSFIDidChangeDeviceList
                 object:nil];
    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
    [center addObserver:self
               selector:@selector(gotResponseFor1064:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDeviceValueListDidChange:)
                   name:kSFIDidChangeDeviceValueList
                 object:nil];
}

- (void)onDeviceListDidChange:(id)sender {
    NSLog(@"Sensors: did receive device list change");
    if (!self) {
        return;
    }
    if (self.isViewControllerDisposed) {
        return;
    }
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    NSString *cloudMAC = [data valueForKey:@"data"];
    if (![self isSameAsCurrentMAC:cloudMAC]) {
        // An Almond not currently being views was changed
        return;
    }
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSArray *newDeviceList = [toolkit deviceList:cloudMAC];
    if (newDeviceList == nil) {
        newDeviceList = @[];
    }
    //    [self removeExpandedCellForMissingDevices:newDeviceList];
    
    NSArray *newDeviceValueList = [toolkit deviceValuesList:cloudMAC];
    
    
    
    // Push changes to the UI
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.isViewControllerDisposed) {
            return;
        }
        if ([self isSameAsCurrentMAC:cloudMAC]) {
            self.deviceList = newDeviceList;///ste
            if (newDeviceValueList) {
                [self setDeviceValues:newDeviceValueList];
            }
            [self.tableView reloadData];
        }
        
        [self.HUD hide:YES afterDelay:1.5];
    });
}

- (void)onDeviceValueListDidChange:(id)sender {
    DLog(@"Sensors: did receive device values list change");
    
    if (!self) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.isViewControllerDisposed) {
            return;
        }
        [self.HUD hide:YES];
    });
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    NSString *cloudMAC = [data valueForKey:@"data"];
    if (![self isSameAsCurrentMAC:cloudMAC]) {
        DLog(@"Sensors: ignore device values list change, c:%@, m:%@", self.almondMac, cloudMAC);
        // An Almond not currently being viewed was changed
        return;
    }
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSArray *newDeviceList = [toolkit deviceList:cloudMAC];
    if (newDeviceList == nil) {
        DLog(@"Device list is empty: %@", cloudMAC);
        newDeviceList = @[];
        //        [self clearAllDeviceUpdatingState];
    }
    //    [self removeExpandedCellForMissingDevices:newDeviceList];
    
    NSArray *newDeviceValueList = [toolkit deviceValuesList:cloudMAC];
    if (newDeviceValueList == nil) {
        newDeviceValueList = @[];
    }
    
    if (newDeviceList.count != newDeviceValueList.count) {
        ELog(@"Warning: device list and values lists are incongruent, d:%ld, v:%ld", (unsigned long) newDeviceList.count, (unsigned long) newDeviceValueList.count);
    }
    
    //    DLog(@"Changing device value list: %@", newDeviceValueList);
    
    // Restore isExpanded state and clear 'updating' state
    NSArray *oldDeviceList = self.deviceList;
    for (SFIDevice *newDevice in newDeviceList) {
        for (SFIDevice *oldDevice in oldDeviceList) {
            if (newDevice.deviceID == oldDevice.deviceID) {
                //                [self clearDeviceUpdatingState:oldDevice];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.isViewControllerDisposed) {
            return;
        }
        
        if (![self isSameAsCurrentMAC:cloudMAC]) {
            return;
        }
        
        //        [self.refreshControl endRefreshing];
        
        [self setDeviceList:newDeviceList];
        [self setDeviceValues:newDeviceValueList];
        
        // defer showing changes when a sensor is being edited (name, location, etc.)
        //        if (!self.isUpdatingDeviceSettings) {
        //            [self.tableView reloadData];
        //        }
    });
}

- (void)onAlmondListDidChange:(id)sender {
    NSLog(@"Sensors: did receive Almond List change");
    
    if (!self) {
        return;
    }
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    SFIAlmondPlus *plus = [data valueForKey:@"data"];
    
    if (plus != nil && [self isSameAsCurrentMAC:plus.almondplusMAC]) {
        // No reason to alert user
        return;
    }
    
    // If plus is nil, then there are no almonds attached, and the UI needs to deal with it.
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (!self.isViewLoaded) {
            return;
        }
        if (self.isViewControllerDisposed) {
            return;
        }
        
        [self.HUD show:YES];
        
        [self initializeAlmondData];
        [self.tableView reloadData];
        
        [self.HUD hide:YES afterDelay:1.5];
    });
}


- (void)initializeAlmondData {
    // 2014-11-08 sinclair added due to late reports from QA noticing keyboard can be still up over layed over sensors.
    // I think this is caused by bug in new Accounts code that has been fixed, but am adding this anyway
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    _almond = plus;
    
    NSString *const mac = (plus == nil) ? NO_ALMOND : plus.almondplusMAC;
    //    [self markAlmondMac:mac];
    
    //    self.isUpdatingDeviceSettings = NO;
    
    if ([self isNoAlmondMAC]) {
        self.navigationItem.title = NSLocalizedString(@"scene.title.Get Started", @"Get Started");
        self.deviceList = @[];
        [self setDeviceValues:@[]];
    }
    else {
        
        self.navigationItem.title = plus.almondplusName;
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [self setDeviceValues:[toolkit deviceValuesList:mac]];
        self.deviceList = [toolkit deviceList:_almond.almondplusMAC];
        
        if (self.deviceList.count == 0) {
            DLog(@"Sensors: requesting device list on empty list");
            [self showHudWithTimeout];
            
            //            [toolkit asyncRequestDeviceList:mac];
        }
        else if (self.deviceValueTable.count == 0) {
            DLog(@"Sensors: requesting device values on empty list");
            [self showHudWithTimeout];
            [toolkit tryRequestDeviceValueList:mac];
        }
        else if ([toolkit tryRequestDeviceValueList:mac]) {
            [self showHudWithTimeout];
            DLog(@"Sensors: requesting device values on new connection");
        }
        
        //        [toolkit asyncRequestNotificationPreferenceList:mac];
        
        //        [self initializeColors:plus];
    }
    
    //    self.enableDrawer = YES;
    
}

- (BOOL)isSameAsCurrentMAC:(NSString *)aMac {
    if (aMac == nil) {
        return NO;
    }
    
    NSString *current = self.almondMac;
    if (current == nil) {
        return NO;
    }
    
    return [current isEqualToString:aMac];
}

// calls should be coordinated on the main queue
- (void)setDeviceValues:(NSArray *)values {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    for (SFIDeviceValue *value in values) {
        NSNumber *key = @(value.deviceID);
        table[key] = value;
    }
    _deviceValueTable = [NSDictionary dictionaryWithDictionary:table];
}

- (void)setDeviceList:(NSArray *)devices {
    //    if (devices.count==0) {
    //        return;
    //    }
    
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    NSMutableArray * actuators = [NSMutableArray array];;
    [cellsInfoArray removeAllObjects];
    
    
    
    if (self.sceneInfo) {
        //TEST
        if ([self.sceneInfo[@"SceneEntryList"] isKindOfClass:[NSArray class]]) {
            sceneEntryList = [[NSMutableArray arrayWithArray:self.sceneInfo[@"SceneEntryList"]] mutableCopy];
        }else{
            NSString * strSceneEntryList = self.sceneInfo[@"SceneEntryList"];
            strSceneEntryList = [strSceneEntryList stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            NSData * data = [strSceneEntryList dataUsingEncoding:NSUTF8StringEncoding] ;
            sceneEntryList = [[NSMutableArray arrayWithArray:[data objectFromJSONData]] mutableCopy];
        }
    }
    
    //add zero device for Home/Awway buttons
    SFIDevice * zeroDevice = [[SFIDevice alloc] init];
    zeroDevice.deviceID = 0;
    zeroDevice.deviceType = SFIDeviceType_BinarySwitch_0;
    zeroDevice.almondMAC = self.almondMac;
    zeroDevice.deviceName = @"";
    
    NSNumber *key = @(0);
    NSMutableDictionary *cellDict = [NSMutableDictionary new];
    [cellDict setValue:@(0) forKey:@"DeviceID"];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    NSMutableDictionary * indexDict = [NSMutableDictionary new];
    
    [indexDict setValue:[NSNumber numberWithInt:SFIDevicePropertyType_SWITCH_BINARY] forKey:@"valueType"];
    [indexDict setValue:@1 forKey:@"indexID"];
    [indexDict setValue:@"home_icon" forKey:@"onImage"];
    [indexDict setValue:@"HOME" forKey:@"onTitle"];
    [indexDict setValue:@"away_icon" forKey:@"offImage"];
    [indexDict setValue:@"AWAY" forKey:@"offTitle"];
    [indexDict setValue:@"away" forKey:@"offValue"];
    [indexDict setValue:@"home" forKey:@"onValue"];
    
    [arr addObject:indexDict];
    [cellDict setValue:arr forKey:@"deviceIndexes"];
    [cellDict setValue:zeroDevice forKey:@"device"];
    
    [cellDict setValue:[self getExistingValues:0] forKey:@"existingValues"];
    [cellsInfoArray addObject:cellDict];
    
    [actuators addObject:zeroDevice];
    table[key] = @(0);
    
    int row = 1;
    for (SFIDevice *device in devices) {
        NSNumber *key = @(device.deviceID);
        
        if (![device isActuator]) {
            continue;
        }
        
        NSMutableDictionary *cellDict = [NSMutableDictionary new];
        [cellDict setValue:[NSNumber numberWithInt:device.deviceID] forKey:@"DeviceID"];
        
        SensorIndexSupport *index = [SensorIndexSupport new];
        NSArray * deviceIndexes = [index getIndexesFor:device.deviceType];
        
        
        NSMutableArray * arr = [NSMutableArray new];
        
        switch (device.deviceType) {
            case SFIDeviceType_NestThermostat_57:
            {
                NSMutableDictionary * indexDict = [NSMutableDictionary new];
                
                [indexDict setValue:[NSNumber numberWithInt:SFIDevicePropertyType_SWITCH_BINARY] forKey:@"valueType"];
                [indexDict setValue:@1 forKey:@"indexID"];
                [indexDict setValue:@"home_icon" forKey:@"onImage"];
                [indexDict setValue:@"HOME" forKey:@"onTitle"];
                [indexDict setValue:@"away_icon" forKey:@"offImage"];
                [indexDict setValue:@"AWAY" forKey:@"offTitle"];
                [indexDict setValue:@"away" forKey:@"offValue"];
                [indexDict setValue:@"home" forKey:@"onValue"];
                
                [arr addObject:indexDict];
                
            }
                break;
            case SFIDeviceType_HueLamp_48:
            {
                NSMutableDictionary * indexDict = [NSMutableDictionary new];
                
                [indexDict setValue:[NSNumber numberWithInt:SFIDevicePropertyType_SWITCH_BINARY] forKey:@"valueType"];
                [indexDict setValue:@2 forKey:@"indexID"];
                [indexDict setValue:@"imgLightOff" forKey:@"offImage"];
                [indexDict setValue:@"OFF" forKey:@"offTitle"];
                [indexDict setValue:@"imgLightOn" forKey:@"onImage"];
                [indexDict setValue:@"ON" forKey:@"onTitle"];
                [arr addObject:indexDict];
                
                //
                NSMutableDictionary * indexDict1 = [NSMutableDictionary new];
                [indexDict1 setValue:[NSNumber numberWithInt:SFIDevicePropertyType_COLOR_HUE] forKey:@"valueType"];
                [indexDict1 setValue:@3 forKey:@"indexID"];
                
                [arr addObject:indexDict1];
                
                //
                NSMutableDictionary * indexDict2 = [NSMutableDictionary new];
                [indexDict2 setValue:[NSNumber numberWithInt:SFIDevicePropertyType_SATURATION] forKey:@"valueType"];
                [indexDict2 setValue:@4 forKey:@"indexID"];
                
                [arr addObject:indexDict2];
                
                //
                NSMutableDictionary * indexDict3 = [NSMutableDictionary new];
                [indexDict3 setValue:[NSNumber numberWithInt:SFIDevicePropertyType_BRIGHTNESS] forKey:@"valueType"];
                [indexDict3 setValue:@5 forKey:@"indexID"];
                
                [arr addObject:indexDict3];
                
            }
                break;
            case SFIDeviceType_MultiLevelOnOff_4:
            {
                NSMutableDictionary * indexDict = [NSMutableDictionary new];
                [indexDict setValue:[NSNumber numberWithInt:SFIDevicePropertyType_SWITCH_MULTILEVEL] forKey:@"valueType"];
                [indexDict setValue:[NSNumber numberWithInt:-1] forKey:@"indexID"];
                
                
                [indexDict setValue:@0 forKey:@"Value"];
                [indexDict setValue:@"imgLightOff" forKey:@"offImage"];
                [indexDict setValue:@"OFF" forKey:@"offTitle"];
                [indexDict setValue:@"imgLightOn" forKey:@"onImage"];
                [indexDict setValue:@"ON" forKey:@"onTitle"];
                [indexDict setValue:@"DIM" forKey:@"dimTitle"];
                [indexDict setValue:@"%" forKey:@"dimPrefix"];
                [indexDict setValue:@"false" forKey:@"offValue"];
                [indexDict setValue:@"true" forKey:@"onValue"];
                
                [indexDict setValue:@2 forKey:@"onIndex"];
                [indexDict setValue:@2 forKey:@"offIndex"];
                [indexDict setValue:@1 forKey:@"dimIndex"];
                
                
                [arr addObject:indexDict];            }
                break;
            default:
            {
                for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
                    NSMutableDictionary * indexDict = [NSMutableDictionary new];
                    
                    
                    [indexDict setValue:[NSNumber numberWithInt:deviceIndex.valueType] forKey:@"valueType"];
                    [indexDict setValue:[NSNumber numberWithInt:deviceIndex.indexID] forKey:@"indexID"];
                    
                    switch (deviceIndex.valueType) {
                        case SFIDevicePropertyType_SWITCH_BINARY:
                        {
                            for (IndexValueSupport * iVal in deviceIndex.indexValues) {
                                @try
                                {
                                    
                                    if ([iVal.matchData isEqualToString:@"false"]) {
                                        [indexDict setValue:iVal.iconName forKey:@"offImage"];
                                        [indexDict setValue:@"OFF" forKey:@"offTitle"];
                                    }
                                    if ([iVal.matchData isEqualToString:@"true"]) {
                                        [indexDict setValue:iVal.iconName forKey:@"onImage"];
                                        [indexDict setValue:@"ON" forKey:@"onTitle"];
                                    }
                                }
                                @catch (NSException *ex) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error111" message:[NSString stringWithFormat:@"%@",ex]
                                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                    [alert show];
                                }
                                
                            }
                            break;
                        }
                        case SFIDevicePropertyType_LOCK_STATE:
                        {
                            @try {
                                for (IndexValueSupport * iVal in deviceIndex.indexValues) {
                                    if ([iVal.matchData isEqualToString:@"0"]) {
                                        [indexDict setValue:iVal.iconName forKey:@"offImage"];
                                        [indexDict setValue:@"Unlocked" forKey:@"offTitle"];
                                    }
                                    if ([iVal.matchData isEqualToString:@"255"] || [iVal.matchData isEqualToString:@"1"] ) {
                                        [indexDict setValue:iVal.iconName forKey:@"onImage"];
                                        [indexDict setValue:@"Locked" forKey:@"onTitle"];
                                    }
                                }
                            }
                            @catch (NSException *ex) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error222" message:[NSString stringWithFormat:@"%@",ex]
                                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert show];
                            }
                            break;
                        }
                        case SFIDevicePropertyType_BASIC:
                        case SFIDevicePropertyType_ALARM_STATE:
                        case SFIDevicePropertyType_SENSOR_BINARY:
                        {
                            @try{
                                for (IndexValueSupport * iVal in deviceIndex.indexValues) {
                                    if ([iVal.matchData isEqualToString:@"0"] || [iVal.matchData isEqualToString:@"false"]) {
                                        [indexDict setValue:iVal.iconName forKey:@"offImage"];
                                        [indexDict setValue:@"Silent" forKey:@"offTitle"];
                                    }
                                    if ([iVal.matchData isEqualToString:@"255"] || [iVal.matchData isEqualToString:@"true"]) {
                                        [indexDict setValue:iVal.iconName forKey:@"onImage"];
                                        [indexDict setValue:@"Ringing" forKey:@"onTitle"];
                                    }
                                }
                            }
                            @catch (NSException *ex) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error333" message:[NSString stringWithFormat:@"%@",ex]
                                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert show];
                            }
                            break;
                        }
                        case SFIDevicePropertyType_SWITCH_MULTILEVEL:
                        {
                            
                            [indexDict setValue:@"imgLightOff" forKey:@"offImage"];
                            [indexDict setValue:@"OFF" forKey:@"offTitle"];
                            [indexDict setValue:@"imgLightOn" forKey:@"onImage"];
                            [indexDict setValue:@"ON" forKey:@"onTitle"];
                            [indexDict setValue:@"DIM" forKey:@"dimTitle"];
                            [indexDict setValue:@"%" forKey:@"dimPrefix"];
                            //                                        [indexDict setValue:@"°F" forKey:@"dimPrefix"];
                            [indexDict setValue:@"0" forKey:@"offValue"];
                            [indexDict setValue:@"100" forKey:@"onValue"];
                            [indexDict setValue:[NSNumber numberWithInt:deviceIndex.indexID] forKey:@"onIndex"];
                            [indexDict setValue:[NSNumber numberWithInt:deviceIndex.indexID] forKey:@"offIndex"];
                            [indexDict setValue:[NSNumber numberWithInt:deviceIndex.indexID] forKey:@"dimIndex"];
                        }
                            break;
                            
                        default:{
                            
                        }
                    }
                    
                    
                    [arr addObject:indexDict];
                }
            }
                break;
        }
        
        [cellDict setValue:arr forKey:@"deviceIndexes"];
        [cellDict setValue:device forKey:@"device"];
        
        [cellDict setValue:[self getExistingValues:(NSInteger)device.deviceID] forKey:@"existingValues"];
        [cellsInfoArray addObject:cellDict];
        
        [actuators addObject:device];
        table[key] = @(row);
        row++;
    }
    
    
    
    
    _deviceList = actuators;
    _deviceIndexTable = [NSDictionary dictionaryWithDictionary:table];
    [self configuresCeneEntryListForUI];
}

- (NSInteger)deviceCellRow:(int)deviceId {
    NSNumber *key = @(deviceId);
    NSNumber *row = self.deviceIndexTable[key];
    return [row integerValue];
}

#pragma mark - Sensor Values

- (SFIDeviceValue *)tryCurrentDeviceValues:(int)deviceId {
    return self.deviceValueTable[@(deviceId)];
}


- (void)btnSaveTap:(id)sender {
    
    [activeTextField resignFirstResponder];
    if (sceneName.length == 0) {
        [self showMessageBox:@"Please select Scene Name"];
        return;
    }
    
    
    
    if (sceneEntryList.count==0) {
        [self showMessageBox:NSLocalizedString(@"scene.msg.You have to select at least 1 value", @"You have to select at least 1 value")];
        return;
    }
    
    NSMutableDictionary *newSceneInfo = [NSMutableDictionary new];
    NSMutableDictionary *payloadDict = [NSMutableDictionary new];
    if (self.sceneInfo) {
        [payloadDict setValue:@"UpdateScene" forKey:@"CommandType"];
        [newSceneInfo setValue:[self.sceneInfo valueForKey:@"ID"] forKey:@"ID"];
        
    }else{
        [payloadDict setValue:@"AddScene" forKey:@"CommandType"];
    }
    
    [payloadDict setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    [newSceneInfo setValue:sceneName forKey:@"Name"];
    [payloadDict setValue:_almond.almondplusMAC forKey:@"AlmondMAC"];
    [self configuresCeneEntryListForSave];
    [newSceneInfo setValue:sceneEntryList forKey:@"SceneEntryList"];
    
    [payloadDict setValue:newSceneInfo forKey:@"Scenes"];
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [payloadDict JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"scenes.hud.creatingScene", @"Creating Scene...");
    
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:cloudCommand];
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}



#pragma mark

- (void)showMessageBox:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Scenes" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"scene.cancel-title.OK", @"OK") otherButtonTitles:nil];
        [alert show];
        alert = nil;
    });
}

#pragma mark Drawer management

- (void)markAlmondMac:(NSString *)almondMac {
    _almondMac = [almondMac copy];
    //    dispatch_async(dispatch_get_main_queue(), ^() {
    //        [self markCloudStatusIcon];
    //    });
}

- (void)showHUD:(NSString *)text {
    _isHudHidden = NO;
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)showLoadingRouterDataHUD {
    [self showHUD:NSLocalizedString(@"scene.hud.Loading router data", @"Loading router data")];
}

- (void)showLoadingSensorDataHUD {
    [self showHUD:NSLocalizedString(@"scene.hud.Loading sensor data", @"Loading sensor data")];
}

- (void)showUpdatingSettingsHUD {
    [self showHUD:NSLocalizedString(@"hud.Updating settings...", @"Updating settings...")];
}

- (void)setEnableDrawer:(BOOL)enableDrawer {
    //    _enableDrawer = enableDrawer;
    self.navigationItem.leftBarButtonItem.enabled = enableDrawer;
}


#pragma mark UITableView Delegate Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width-20, 100)];
    lbl.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:15.0f];
    lbl.textColor = [UIColor colorFromHexString:@"8f8f8f"];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor colorFromHexString:@"EEEEEE"];
    lbl.numberOfLines = 0;
    lbl.text = NSLocalizedString(@"scene.text.Choose one or more Actions", @"Select all the actions that should be executed as part of this scene. Every gray icon below represents an action.");
    return lbl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.deviceList.count>0) {
        return 100;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0000001;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return 400;
    }
    
    if ([self isDeviceListEmpty]) {
        return 400;
    }
    
    if (indexPath.row==self.deviceList.count) {
        return 200;
    }
    SFIDevice *device = [self tryGetDevice:indexPath.row];
    
    SensorIndexSupport *index = [SensorIndexSupport new];
    NSArray * deviceIndexes = [index getIndexesFor:device.deviceType];
    
    float currentHeight = 30;
    switch (device.deviceType){
        case SFIDeviceType_MultiLevelOnOff_4:
            currentHeight+=98;
            break;
        case SFIDeviceType_BinarySwitch_0:
            currentHeight+=114;//home/away
            break;
        case SFIDeviceType_NestThermostat_57:{
            NSArray *existingValues  = [self getExistingValues:(NSInteger)device.deviceID];
            NSString *ahco = @"";
            for (NSDictionary * dict in existingValues) {
                if ([[dict valueForKey:@"Index"] integerValue]==2) {
                    ahco = [dict valueForKey:@"Value"];
                    break;
                }
            }
            SFIDevice *device = [self tryGetDevice:indexPath.row];
            SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:device.deviceID];
            SFIDeviceKnownValues *currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            BOOL canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            BOOL canHeat = [currentDeviceValue boolValue];
            currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_HAS_FAN];
            
            BOOL hasFan = [currentDeviceValue boolValue];
            
            
            
            if ([ahco isEqualToString:@"off"] || (!canHeat && !canCool)) {
                currentHeight+=280;
            }else{
                currentHeight+=380;
            }
            
            if (!hasFan) {
                currentHeight-=100;
            }
            break;
        }
        case SFIDeviceType_Thermostat_7:
            currentHeight+=290;
            break;
        case SFIDeviceType_HueLamp_48:
        {
            
            NSArray *existingValues  = [self getExistingValues:(NSInteger)device.deviceID];
            BOOL hueOn = NO;
            for (NSDictionary * dict in existingValues) {
                if ([[dict valueForKey:@"Index"] integerValue]==2) {
                    if ([[dict valueForKey:@"Value"] isEqualToString:@"true"]) {
                        hueOn = YES;
                    }
                    break;
                }
            }
            if (hueOn) {
                currentHeight+=464;
            }else{
                currentHeight+=114;
            }
            
            break;
        }
        default:
            for (SFIDeviceIndex *indexValue in deviceIndexes) {
                switch (indexValue.valueType) {
                    case SFIDevicePropertyType_SWITCH_BINARY:
                    case SFIDevicePropertyType_LOCK_STATE:
                    case SFIDevicePropertyType_BASIC:
                    case SFIDevicePropertyType_ALARM_STATE:
                    case SFIDevicePropertyType_SENSOR_BINARY:
                        currentHeight+=115;
                        break;
                    case SFIDevicePropertyType_SWITCH_MULTILEVEL:
                        currentHeight+=98;
                        break;
                    case SFIDevicePropertyType_SATURATION:
                    case SFIDevicePropertyType_BRIGHTNESS:
                    case SFIDevicePropertyType_COLOR_HUE:
                        currentHeight+=100;
                        break;
                    default:
                        break;
                }
            }
            break;
    }
    
    
    return currentHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellsInfoArray.count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return [self createNoAlmondCell:tableView];
    }
    
    //    if ([self isDeviceListEmpty]) {
    //        return [self createEmptyCell:tableView];
    //    }
    if (indexPath.row==cellsInfoArray.count) {
        return [self createSceneProperiesCell:tableView listRow:(NSUInteger) indexPath.row];
    }
    return [self createSensorCell:tableView listRow:(NSUInteger) indexPath.row];
}

#pragma mark - Table View Cell Helpers
- (UITableViewCell *)createSceneProperiesCell:(UITableView *)tableView listRow:(NSUInteger)indexPathRow {
    
    SFIAddSceneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIAddSceneTableViewCell"];//
    if (cell == nil) {
        cell = [[SFIAddSceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SFIAddSceneTableViewCell"];
    }
    cell.isSceneProperiesCell = YES;
    cell.tag = indexPathRow;
    //    cell.cellColor = [self.almondColor makeGradatedColorForPositionIndex:indexPathRow];
    cell.delegate = self;
    cell.sceneName = [self.sceneInfo valueForKey:@"Name"];
    cell.showDeleteButton = NO;
    if (self.sceneInfo) {
        cell.showDeleteButton = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    static NSString *empty_cell_id = @"EmptyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:empty_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.tableView.frame.size.width, 30)];
        lblNoSensor.textAlignment = NSTextAlignmentCenter;
        [lblNoSensor setFont:[UIFont securifiLightFont:20]];
        lblNoSensor.text = NSLocalizedString(@"sensors.no-sensors.label.You don't have any sensors yet.", @"You don't have any sensors yet.");
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];
        
        UIImageView *imgRouter = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 - 50, 95, 86, 60)];
        imgRouter.userInteractionEnabled = NO;
        [imgRouter setImage:[UIImage imageNamed:@"router_1.png"]];
        imgRouter.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:imgRouter];
        
        UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, self.tableView.frame.size.width, 30)];
        lblAddSensor.textAlignment = NSTextAlignmentCenter;
        [lblAddSensor setFont:[UIFont standardUILabelFont]];
        lblAddSensor.text = NSLocalizedString(@"router.no-sensors.label.Add a sensor from your Almond.", @"Add a sensor from your Almond.");
        lblAddSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblAddSensor];
    }
    
    return cell;
}

- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    static NSString *no_almond_cell_id = @"NoAlmondCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 400)];
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage assetImageNamed:@"getting_started"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [cell addSubview:imageView];
    }
    
    return cell;
}

- (UITableViewCell *)createSensorCell:(UITableView *)tableView listRow:(NSUInteger)indexPathRow {
    SFIDevice *device = [self tryGetDevice:indexPathRow];
    SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:device.deviceID];
    device.almondMAC = self.almondMac;
    
    SFIAddSceneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIAddSceneTableViewCell"];//
    if (cell == nil) {
        cell = [[SFIAddSceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SFIAddSceneTableViewCell"];
    }
    cell.parentViewController = self;
    cell.isSceneProperiesCell = NO;
    cell.tag = indexPathRow;
    cell.device = device;
    cell.delegate = self;
    cell.cellInfo = cellsInfoArray[indexPathRow];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.deviceValue = deviceValue;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark cell delegates
- (void)deleteSceneDidTapped:(SFIAddSceneTableViewCell*)cell{
    if (!self.sceneInfo) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        NSMutableDictionary *payloadDict = [NSMutableDictionary new];
        
        [payloadDict setValue:@"RemoveScene" forKey:@"CommandType"];
        [payloadDict setValue:@{@"ID":[self.sceneInfo valueForKey:@"ID"]} forKey:@"Scenes"];
        [payloadDict setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
        [payloadDict setValue:_almond.almondplusMAC forKey:@"AlmondMAC"];
        
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payloadDict JSONString];
        
        // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.removeFromSuperViewOnHide = NO;
        _HUD.labelText = NSLocalizedString(@"scenes.hud.deletingScene", @"Deleting Scene...");
        _HUD.dimBackground = YES;
        [self.navigationController.view addSubview:_HUD];
        [self showHudWithTimeout];
        
        [self asyncSendCommand:cloudCommand];
    }
}

- (void)sceneNameDidChange:(SFIAddSceneTableViewCell*)cell SceneName:(NSString*)name ActiveField:(UITextField*)textField{
    sceneName = name;
    activeTextField = textField;
}

- (void)tableViewCellValueDidChange:(SFIAddSceneTableViewCell*)cell CellInfo:(NSDictionary*)cellInfo Index:(int)index Value:(id)value{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    BOOL found = NO;
    NSMutableDictionary *edit_entryDict = [NSMutableDictionary new];
    
    for (NSMutableDictionary *entryDict in sceneEntryList) {
        if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[cellInfo valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==index) {
            edit_entryDict = entryDict;
            found = YES;
            break;
        }
    }
    BOOL removed = NO;
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"remove_from_entry_list"] && found) {
            [sceneEntryList removeObject:edit_entryDict];
            removed = YES;
        }
    }
    if (!removed) {
        [edit_entryDict setValue:[cellInfo valueForKey:@"DeviceID"] forKey:@"DeviceID"];
        [edit_entryDict setValue:[NSNumber numberWithInt:index] forKey:@"Index"];
        [edit_entryDict setValue:value forKey:@"Value"];
        
        
        if (!found) {
            [sceneEntryList addObject:edit_entryDict];
        }
    }
    ///
    
    
    
    //need to change value in main sceneInfo
    NSMutableArray *existingValues  = [[self getExistingValues:[[cellInfo valueForKey:@"DeviceID"] integerValue]] mutableCopy];
    [cellInfo setValue:existingValues forKey:@"existingValues"];
    
    
    //if device o HueLamp_48, and it has been toned off, we need to clear up values for all other indexes
    SFIDevice * device = [cellInfo valueForKey:@"device"];
    if (device.deviceType == SFIDeviceType_HueLamp_48) {
        
        BOOL hueOn = NO;
        for (NSDictionary * dict in existingValues) {
            if ([[dict valueForKey:@"Index"] integerValue]==2) {
                if ([[dict valueForKey:@"Value"] isEqualToString:@"true"]) {
                    hueOn = YES;
                }
                break;
            }
        }
        if (!hueOn) {
            for (NSDictionary * dict in existingValues) {
                if ([[dict valueForKey:@"Index"] integerValue]!=2) {
                    
                    for (NSMutableDictionary *entryDict in sceneEntryList) {
                        if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                            [sceneEntryList removeObject:entryDict];
                            break;
                        }
                    }
                }
            }
            
            existingValues  = [[self getExistingValues:[[cellInfo valueForKey:@"DeviceID"] integerValue]] mutableCopy];
            
        }
        [cellInfo setValue:existingValues forKey:@"existingValues"];
        
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (device.deviceType == SFIDeviceType_NestThermostat_57) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [cellsInfoArray[indexPath.row] setValue:existingValues forKey:@"existingValues"];
}


#pragma mark - State

- (BOOL)isDeviceListEmpty {
    // don't show any tiles until there are values for the devices; no values == no way to fetch from almond
    return self.deviceList.count == 0;// || self.deviceValueTable.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.almondMac isEqualToString:NO_ALMOND];
}

#pragma mark
- (SFIDevice *)tryGetDevice:(NSInteger)index {
    NSUInteger uIndex = (NSUInteger) index;
    
    NSArray *list = self.deviceList;
    if (uIndex < list.count) {
        return list[uIndex];
    }
    return nil;
}
#pragma mark
- (void)gotResponseFor1064:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    NSLog(@"%@",mainDict);
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }
    
    [self.HUD hide:YES];
    NSString * success = [mainDict valueForKey:@"Success"];
    if (![success isEqualToString:@"true"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scene.alert-title.Oops", @"Oops") message:NSLocalizedString(@"scene.alert-msg.Sorry, There was some problem with this request, try later!", @"Sorry, There was some problem with this request, try later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        self.originalSceneInfo = [self.sceneInfo copy];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

#pragma mark - Keyboard handler

- (void)onKeyboardDidShow:(id)notification {
    if (originalTableViewFrame.size.height!= self.tableView.frame.size.height) {
        return;
    }
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect fr = self.tableView.frame;
    fr.size.height = fr.size.height - kbSize.height+44;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = fr;
    }completion:^(BOOL finished) {
    }];
    
}

- (void)onKeyboardDidHide:(id)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect fr = self.tableView.frame;
    fr.size.height = fr.size.height + kbSize.height-44;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = fr;
    }completion:^(BOOL finished) {
    }];
}

- (NSArray*)getExistingValues:(NSInteger)deviceID{
    NSMutableArray *eArray = [NSMutableArray new];
    for (NSDictionary *dict in sceneEntryList) {
        if ([[dict valueForKey:@"DeviceID"] integerValue] == deviceID) {
            [eArray addObject:dict];
        }
    }
    return eArray;
}

#pragma mark
- (void)configuresCeneEntryListForSave{
    for (NSDictionary * dict in cellsInfoArray) {
        SFIDevice *tmpDevice = [dict valueForKey:@"device"];
        if (tmpDevice.deviceType == SFIDeviceType_NestThermostat_57) {
            SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:tmpDevice.deviceID];
            SFIDeviceKnownValues *currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            BOOL canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            BOOL canHeat = [currentDeviceValue boolValue];
            if (!canCool || !canHeat) {
                continue;
            }
            NSArray *existingValues  = [self getExistingValues:(NSInteger)tmpDevice.deviceID];
            NSString *ahco = @"";
            for (NSDictionary * dict in existingValues) {
                if ([[dict valueForKey:@"Index"] integerValue]==2) {
                    ahco = [dict valueForKey:@"Value"];
                    break;
                }
            }
            
            if ([ahco isEqualToString:@"heat"]) {
                for (NSDictionary * dict in existingValues) {
                    if ([[dict valueForKey:@"Index"] integerValue]==5) {
                        //removing cool value if any
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [sceneEntryList removeObject:entryDict];
                                break;
                            }
                        }
                    }
                    if ([[dict valueForKey:@"Index"] integerValue]==6) {
                        //replaceing with real index
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [entryDict setValue:@"3" forKey:@"Index"];
                                break;
                            }
                        }
                    }
                }
            }
            if ([ahco isEqualToString:@"cool"]) {
                for (NSDictionary * dict in existingValues) {
                    if ([[dict valueForKey:@"Index"] integerValue]==6) {
                        //removing heat value if any
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [sceneEntryList removeObject:entryDict];
                                break;
                            }
                        }
                    }
                    if ([[dict valueForKey:@"Index"] integerValue]==5) {
                        //replaceing with real index
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [entryDict setValue:@"3" forKey:@"Index"];
                                break;
                            }
                        }
                    }
                }
                
            }
            
            if ([ahco isEqualToString:@"off"]) {
                for (NSDictionary * dict in existingValues) {
                    if ([[dict valueForKey:@"Index"] integerValue]==6 || [[dict valueForKey:@"Index"] integerValue]==5) {
                        //removing heat value if any
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [sceneEntryList removeObject:entryDict];
                            }
                        }
                    }
                }
            }
        }
    }
    NSLog(@"%@",sceneEntryList);
}

- (void)configuresCeneEntryListForUI{
    for (NSDictionary * dict in cellsInfoArray) {
        SFIDevice *tmpDevice = [dict valueForKey:@"device"];
        if (tmpDevice.deviceType == SFIDeviceType_NestThermostat_57) {
            SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:tmpDevice.deviceID];
            SFIDeviceKnownValues *currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            BOOL canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            BOOL canHeat = [currentDeviceValue boolValue];
            if (!canCool || !canHeat) {
                continue;
            }
            NSArray *existingValues  = [self getExistingValues:(NSInteger)tmpDevice.deviceID];
            NSString *ahco = @"";
            for (NSDictionary * dict in existingValues) {
                if ([[dict valueForKey:@"Index"] integerValue]==2) {
                    ahco = [dict valueForKey:@"Value"];
                    break;
                }
            }
            
            if ([ahco isEqualToString:@"heat"]) {
                for (NSDictionary * dict in existingValues) {
                    if ([[dict valueForKey:@"Index"] integerValue]==3) {
                        //replaceing with real index
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [entryDict setValue:@"6" forKey:@"Index"];
                                break;
                            }
                        }
                    }
                }
            }
            if ([ahco isEqualToString:@"cool"]) {
                for (NSDictionary * dict in existingValues) {
                    if ([[dict valueForKey:@"Index"] integerValue]==3) {
                        //removing heat value if any
                        for (NSMutableDictionary *entryDict in sceneEntryList) {
                            if ([[entryDict valueForKey:@"DeviceID"] intValue]==[[dict valueForKey:@"DeviceID"] intValue] && [[entryDict valueForKey:@"Index"] intValue]==[[dict valueForKey:@"Index"] intValue]) {
                                [entryDict setValue:@"5" forKey:@"Index"];
                                break;
                            }
                        }
                    }
                }
                
            }
        }
    }
    NSLog(@"%@",sceneEntryList);
}
@end
