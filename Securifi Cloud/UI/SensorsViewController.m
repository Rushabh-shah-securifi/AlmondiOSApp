//
//  SensorsViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SensorsViewController.h"
#import "BVReorderTableView.h"
#import "SFIParser.h"
#import "SFIColors.h"
#import "SFIConstants.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "AlmondPlusConstants.h"
//#import "SFIDeviceListViewController.h"
#import "SFIOfflineDataManager.h"
#import "SNLog.h"
#import "SFIReachabilityManager.h"
#import "Reachability.h"

@interface SensorsViewController () {
    NSMutableArray *_objects;
}
@end

@implementation SensorsViewController
//@synthesize sampleItems;
@synthesize sensors, sensorsCopy;
@synthesize checkHeight;
@synthesize changeBrightness;
@synthesize baseBrightness;
@synthesize changeSaturation;
@synthesize changeHue;
@synthesize baseHue;
@synthesize prevObject;
@synthesize moveCount, startIndex;
@synthesize isReverseMove;
@synthesize listAvailableColors;
@synthesize currentColor;
@synthesize currentColorIndex;

@synthesize currentMAC;
@synthesize deviceList;
@synthesize deviceValueList;
@synthesize offlineHash;
@synthesize isEmpty;
@synthesize mobileCommandTimer, sensorChangeCommandTimer, sensorDataCommandTimer;
@synthesize isMobileCommandSuccessful, isSensorChangeCommandSuccessful; // isSensorDataCommandSuccessful;
@synthesize expandedRowHeight;
@synthesize isSliderExpanded, isEditing;
@synthesize sensorTable;
@synthesize txtInvisible;
@synthesize isCloudOnline;

@synthesize currentChangedLocation, currentChangedName;

static NSString *simpleTableIdentifier = @"SensorCell";

#pragma mark - View Related
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    //self.sampleItems = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.checkHeight = -1;
    
    //PY 041013 - To fix: Reverese order move from Add symbol
    moveCount = -1;
    
    self.tableView.autoresizingMask= UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews= YES;
    //self.tableView.backgroundColor = [UIColor blackColor];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Display Drawer Gesture
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealTab:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:showMenuSwipe];
    
    ////    //Display Tab Gesture
    //    UISwipeGestureRecognizer *showTabSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealTab:)];
    //    showTabSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    //    [self.tableView addGestureRecognizer:showTabSwipe];
    
    //PY 111013 - Integration with new UI
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];
    NSString *currentMACName  = [prefs objectForKey:CURRENT_ALMOND_MAC_NAME];
    NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
    if (self.currentMAC == nil){
        if([almondList count]!=0){
            SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
            self.currentMAC = currentAlmond.almondplusMAC;
            currentMACName = currentAlmond.almondplusName;
            [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
            [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
            if(currentMACName!=nil){
                self.navigationItem.title = currentMACName; //[NSString stringWithFormat:@"Sensors at %@", self.currentMAC];
            }
            
        }else{
            self.currentMAC = NO_ALMOND;
            self.navigationItem.title = @"Get Started";
        }
    }else{
        if([almondList count] == 0){
            self.currentMAC = NO_ALMOND;
            self.navigationItem.title = @"Get Started";
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    
    listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSString *colorCode = [prefs stringForKey:COLORCODE];
    
    if(colorCode!=nil){
        currentColor = [listAvailableColors objectAtIndex:[colorCode integerValue]];
    }else{
        currentColor = [listAvailableColors objectAtIndex:self.currentColorIndex];
    }
    baseBrightness = currentColor.brightness;
    changeHue = currentColor.hue;
    changeSaturation = currentColor.saturation;
    
    expandedRowHeight = 200;
    
    
    
    
    
    //Set title
    //    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    //    NSString *currentMAC = [standardUserDefaults objectForKey:@"CurrentMAC"];
    
    //    sensors = [[NSMutableArray alloc]init];
    //    sensors = [[SFIParser alloc] loadDataFromXML:@"sensordata"];
    //// NSLog(@"Data: %lu", (unsigned long)[sensors count]);
    
    
    
    
    
    
    //    //Call command : Get HASH - Command 74 - Match if list is upto date
    //    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    HUD.dimBackground = YES;
    //    HUD.labelText = @"Loading sensor data.";
    //[self getDeviceHash];
    
    isCloudOnline = TRUE;
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //PY 111013 - Integration with new UI
    NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
    if([almondList count] == 0){
        self.currentMAC = NO_ALMOND;
        self.navigationItem.title = @"Get Started";
        [self.deviceList removeAllObjects];
        [self.deviceValueList removeAllObjects];
        [self.tableView reloadData];
    }else{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];
        NSString *currentMACName  = [prefs objectForKey:CURRENT_ALMOND_MAC_NAME];
        self.navigationItem.title = currentMACName;
        
        self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
        self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
        self.offlineHash = [SFIOfflineDataManager readHashList:self.currentMAC];
        
        [self initiliazeImages];
        
        //Call command : Get HASH - Command 74 - Match if list is upto date
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;
        HUD.labelText = @"Loading sensor data.";
        [self getDeviceHash];
        
        //PY 311013 - Timeout for Sensor Command
        sensorDataCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                              target:self
                                                            selector:@selector(cancelSensorCommand:)
                                                            userInfo:nil
                                                             repeats:NO];

    }
    
    
    
    
    //PY 111013 - Integration with new UI
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HashResponseCallback:)
                                                 name:HASH_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DeviceListResponseCallback:)
                                                 name:DEVICE_DATA_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DeviceValueListResponseCallback:)
                                                 name:DEVICE_VALUE_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MobileCommandResponseCallback:)
                                                 name:MOBILE_COMMAND_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DeviceDataCloudResponseCallback:)
                                                    name:DEVICE_DATA_CLOUD_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DeviceCloudValueListResponseCallback:)
                                                    name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListAddCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListDeleteCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(SensorChangeCallback:)
                                                    name:SENSOR_CHANGE_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDownNotifier:)
                                                 name:NETWORK_DOWN_NOTIFIER
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkUpNotifier:)
                                                 name:NETWORK_UP_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondNameChangeCallback:)
                                                    name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification object:nil];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HASH_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEVICE_DATA_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEVICE_VALUE_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MOBILE_COMMAND_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DEVICE_DATA_CLOUD_NOTIFIER
                                                     object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                     object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                     object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                     object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:SENSOR_CHANGE_NOTIFIER
                                                     object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_UP_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_DOWN_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
    
}

#pragma mark - Reconnection

-(void)networkUpNotifier:(id)sender
{
    [SNLog Log:@"Method Name: %s Sensor controller :In networkUP notifier", __PRETTY_FUNCTION__];
    isCloudOnline = TRUE;
    [self.tableView reloadData];
}


-(void)networkDownNotifier:(id)sender
{
    [SNLog Log:@"Method Name: %s Sensor controller :In network down notifier", __PRETTY_FUNCTION__];
    isCloudOnline = FALSE;
    [self.tableView reloadData];
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    if (![SFIReachabilityManager isReachable]) {
        NSLog(@"Unreachable");
        isCloudOnline = FALSE;
        [self.tableView reloadData];
    }
}

#pragma mark - Table View
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(isCloudOnline){
        return 0;
    }else{
        return 35;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(isCloudOnline){
        return nil;
    }else{
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    header.backgroundColor = [UIColor clearColor];// [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,(LEFT_LABEL_WIDTH)+(self.tableView.frame.size.width-LEFT_LABEL_WIDTH-25)+1,30)];
    backgroundLabel.backgroundColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1.0];
    
    
    UILabel *lblOffline = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,30)];
    lblOffline.backgroundColor = [UIColor clearColor];
    lblOffline.text = CLOUD_OFFLINE;
    lblOffline.textColor = [UIColor whiteColor];
    lblOffline.textAlignment = NSTextAlignmentCenter;
    [lblOffline setFont:[UIFont fontWithName:@"Avenir-Roman" size:12]];
    [backgroundLabel addSubview:lblOffline];
    [header addSubview:backgroundLabel];
    return header;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //PY 031013 - +1 is for the Add symbol
    if([self.currentMAC isEqualToString:NO_ALMOND]){
        // NSLog(@"No Almond - Number of Rows");
        return 1;
    }
    if([self.deviceList count] == 0){
        self.isEmpty = TRUE;
        return 1; //No results found
    }
    self.isEmpty = FALSE;
    return [self.deviceList count]; //No add symbol for sensors + 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //    if (self.checkHeight == indexPath.row)
    //        return 185;
    //    else
    if([currentMAC isEqualToString:NO_ALMOND]){
        return 400;
    }
    
    if(isEmpty){
        return 400;
    }
    if(indexPath.row != [self.deviceList count]){
        SFIDevice *currentSensor = [self.deviceList objectAtIndex:indexPath.row];
        //        cell.textLabel.text = currentDevice.deviceName;
        //        SFISensor *currentSensor = [self.deviceList objectAtIndex:indexPath.row];
        if(currentSensor.isExpanded){
            switch(currentSensor.deviceType){
                case 1:
                    //Switch - 2 values
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    break;
                case 2:
                    //Multilevel switch - 3 values
                    expandedRowHeight = 270;
                    break;
                case 3:
                    //Sensor - 3 values
                    expandedRowHeight = 260;
                    break;
                case 4:
                    expandedRowHeight = 270;
                    break;
                case 7:
                    expandedRowHeight = 455;
                    break;
                case 11:
                    if(currentSensor.isTampered){
                        expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                        
//                        if(currentSensor.isBatteryLow){
//                            expandedRowHeight+= 20;
//                        }
                    }else{
                        expandedRowHeight = EXPANDED_ROW_HEIGHT;
//                        if(currentSensor.isBatteryLow){
//                            expandedRowHeight+= 30;
//                        }
                    }
                    break;
                case 12:
                    if(currentSensor.isTampered){
                        expandedRowHeight = 270;
                    }else{
                        expandedRowHeight = 230;
                    }
                    break;
                case 13:
                case 14:
                case 15:
                case 17:
                case 19:
                    if(currentSensor.isTampered){
                        expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    }else{
                        expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    }
                    break;
                case 22:
                    //Multilevel switch - 5 values
                    expandedRowHeight = 320;
                    break;
                default:
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    break;
            }
            return expandedRowHeight;
        }
        return SENSOR_ROW_HEIGHT;
    }
    return SENSOR_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"In CELL CREATION");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    //No add symbol for sensors
    //    if(indexPath.row == [self.deviceList  count]){
    //        cell = [self createAddSymbolCell:cell];
    //        return cell;
    //    }
    
    //    if(indexPath.row == 0){
    //        self.changeBrightness = 98;
    //    }
    if([currentMAC isEqualToString:NO_ALMOND]){
        cell = [self createNoAlmondCell:cell];
        return cell;
    }
    if (self.isEmpty){
        cell = [self createEmptyCell:cell];
        return cell;
    }
    
    cell = [self createColoredListCell:cell listRow:indexPath.row];
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.deviceList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = _objects[indexPath.row];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}


// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object;
    // NSLog(@"Saved Object Index: %ld", (long)indexPath.row);
    //    if(indexPath.row == [self.deviceList  count]){
    //        //Add row
    //        object = nil;
    //    }else{
    object = [self.deviceList  objectAtIndex:indexPath.row];
    //}
    
    SFIDevice *dummySensor = [[SFIDevice alloc] init];
    dummySensor.deviceName = @"";
    //    dummySensor.status = 0;
    
    //[sensors replaceObjectAtIndex:indexPath.row withObject:dummySensor];
    return object;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    id object;
    object = [self.deviceList objectAtIndex:fromIndexPath.row];
    [self.deviceList removeObjectAtIndex:fromIndexPath.row];
    [self.deviceList insertObject:object atIndex:toIndexPath.row];
    
    self.sensorTable.deviceList = self.deviceList;
    // self.sensorTable.currentMAC = self.currentMAC;
    
    //    moveCount = moveCount + 1;
    //    if (moveCount == 0)
    //    {
    //        startIndex = fromIndexPath.row;
    //        sensorsCopy= [self.deviceList copy];
    //    }
    //    // NSLog(@"From: %ld to: %ld sensor count: %d Start Index %d", (long)fromIndexPath.row, (long)toIndexPath.row, [sensors count], startIndex);
    //
    //    //Trying to move the plus symbol
    //    //Do nothing
    //    if(startIndex != [self.deviceList count]){
    //        int intToIndexPath = (int)toIndexPath.row;
    //        int intFromIndexPath = (int)fromIndexPath.row;
    //        if(intFromIndexPath == [self.deviceList count]){
    //            prevObject = [sensorsCopy objectAtIndex:startIndex];
    //            object = [self.deviceList objectAtIndex:intFromIndexPath-1];
    //            isReverseMove = TRUE;
    //            SFIDevice *prevSensor = (SFIDevice *)self.prevObject;
    //            // NSLog(@"Reverese Move Prev Object: Name %@", prevSensor.deviceName);
    //            SFIDevice *curSensor = (SFIDevice *)object;
    //            // NSLog(@"Reverese Move Current Object: Name %@", curSensor.deviceName);
    //            [self.deviceList removeObjectAtIndex:intFromIndexPath-1];
    //            [self.deviceList insertObject:object atIndex:toIndexPath.row];
    //        }else{
    //            object = [self.deviceList objectAtIndex:fromIndexPath.row];
    //            prevObject = [self.deviceList objectAtIndex:startIndex];
    //            if(intToIndexPath == [self.deviceList count]){
    //                //Add row
    //                SFIDevice *prevSensor = (SFIDevice *)self.prevObject;
    //                // NSLog(@"Move Prev Object: Name %@", prevSensor.deviceName);
    //                SFIDevice *curSensor = (SFIDevice *)object;
    //                // NSLog(@"Move Current Object: Name %@", curSensor.deviceName);
    //                // NSLog(@"From: %ld", (long)fromIndexPath.row);
    //                [self.deviceList removeObjectAtIndex:fromIndexPath.row];
    //                [self.deviceList insertObject:prevObject atIndex:[self.deviceList count]];
    //            }else{
    //                //object = [sensors objectAtIndex:fromIndexPath.row];
    //                [self.deviceList removeObjectAtIndex:fromIndexPath.row];
    //                [self.deviceList insertObject:object atIndex:toIndexPath.row];
    //
    //            }
    //        }
    //    }
    
    
    //[sensors removeObjectAtIndex:fromIndexPath.row];
    
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    // NSLog(@"Finish Object Index: %ld", (long)indexPath.row);
    if(object!=nil){
        [self.deviceList replaceObjectAtIndex:indexPath.row withObject:object];
        //        if(!isReverseMove){
        //            if(indexPath.row == [sensors count]){
        //                //Add row
        //
        //                SFIDevice *prevSensor = (SFIDevice *)object;
        //                // NSLog(@"Finish Object: Name %@", prevSensor.deviceName);
        //                [self.deviceList replaceObjectAtIndex:[self.deviceList count]-1 withObject:object];
        //            }
        //            else{
        //                [self.deviceList replaceObjectAtIndex:indexPath.row withObject:object];
        //            }
        //        }else{
        //            SFIDevice *prevSensor = (SFIDevice *)object;
        //            // NSLog(@"Finish Object: Name %@", prevSensor.deviceName);
        //            [self.deviceList replaceObjectAtIndex:[self.deviceList count]-1 withObject:object];
        //        }
    }
    //    startIndex = 0;
    //    moveCount =  -1;
    
    
    // do any additional cleanup here
}

#pragma mark - Table View Cell Creation

-(UITableViewCell*) createAddSymbolCell: (UITableViewCell*)cell{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    UIImageView *imgAddDevice =[[UIImageView alloc]initWithFrame:CGRectMake(110, 10, 80,SENSOR_ROW_HEIGHT-10)];
    imgAddDevice.userInteractionEnabled = YES;
    imgAddDevice.image = [UIImage imageNamed:@"add_new.png"];
    
    UIButton *btnAddDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddDevice.frame = imgAddDevice.bounds;
    btnAddDevice.backgroundColor = [UIColor clearColor];
    [btnAddDevice addTarget:self action:@selector(onAddDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgAddDevice addSubview:btnAddDevice];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell addSubview:imgAddDevice];
    return cell;
}

-(UITableViewCell*) createEmptyCell: (UITableViewCell*)cell{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//    cell.textLabel.text = @"No sensors found";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(0,40,self.tableView.frame.size.width, 30)];
    lblNoSensor.textAlignment = NSTextAlignmentCenter;
    [lblNoSensor setFont:[UIFont fontWithName:@"Avenir-Light" size:20]];
    lblNoSensor.text = @"You don't have any sensors yet.";
    lblNoSensor.textColor = [UIColor grayColor];
    [cell addSubview:lblNoSensor];
    
    UIImageView *imgRouter = [[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2 - 50, 95, 86,60)];
    imgRouter.userInteractionEnabled = NO;
    [imgRouter setImage:[UIImage imageNamed:@"router_1.png"]];
    imgRouter.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:imgRouter];
    
    UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(0,180,self.tableView.frame.size.width, 30)];
    lblAddSensor.textAlignment = NSTextAlignmentCenter;
    [lblAddSensor setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblAddSensor.text = @"Add a sensor from your Almond.";
    lblAddSensor.textColor = [UIColor grayColor];
    [cell addSubview:lblAddSensor];
    return cell;
}

-(UITableViewCell*) createNoAlmondCell: (UITableViewCell*)cell{
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for(UIView *currentView in cell.contentView.subviews){
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    //    cell.textLabel.text = @"No almond is linked to your account";
    //    cell.textLabel.numberOfLines = 2;
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imgGettingStarted;
    UIButton *btnAddAlmond;
    
    imgGettingStarted = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width,400)];
    imgGettingStarted.userInteractionEnabled = YES;
    [imgGettingStarted setImage:[UIImage imageNamed:@"getting_started.png"]];
    imgGettingStarted.contentMode = UIViewContentModeScaleAspectFit;
    
    btnAddAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddAlmond.frame = imgGettingStarted.bounds;
    btnAddAlmond.backgroundColor = [UIColor clearColor];
    [btnAddAlmond addTarget:self action:@selector(onAddAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgGettingStarted addSubview:btnAddAlmond];
    
    [cell addSubview:imgGettingStarted];
    
    return cell;
}

-(UITableViewCell*) createColoredListCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    
    int positionIndex = indexPathRow % 15;
    if(positionIndex < 7) {
        changeBrightness = baseBrightness - (positionIndex * 10);
    }else{
        changeBrightness = (baseBrightness - 70) + ((positionIndex - 7) * 10);
    }
    
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:indexPathRow];
    // Get Device Type
    int currentDeviceType = currentSensor.deviceType;
    
    UIImageView *imgDevice;
    UILabel *lblDeviceValue;
    UILabel *lblDecimalValue;
    UILabel *lblDegree;
    UILabel *lblDeviceName;
    UILabel *lblDeviceStatus;
    UIImageView *imgSettings;
    UIButton *btnDevice;
    UIButton *btnDeviceImg;
    UIButton *btnSettings;
    UILabel *leftBackgroundLabel;
    UILabel *rightBackgroundLabel;
    UIButton *btnSettingsCell;
    
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for(UIView *currentView in cell.contentView.subviews){
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];

    
    //Left Square - Creation
    leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,5,LEFT_LABEL_WIDTH,SENSOR_ROW_HEIGHT-10)];
    leftBackgroundLabel.userInteractionEnabled = YES;
    leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
    [cell addSubview:leftBackgroundLabel];
    
    btnDeviceImg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeviceImg.backgroundColor = [UIColor clearColor];
    [btnDeviceImg addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if(currentDeviceType == 7){
        //Incase of thermostat show value instead of image
        //For Integer Value
        lblDeviceValue = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH/5, 12, 60, 70)];
        lblDeviceValue.backgroundColor = [UIColor clearColor];
        lblDeviceValue.textColor = [UIColor whiteColor];
         lblDeviceValue.textAlignment = NSTextAlignmentCenter;
        [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:45]];
        [lblDeviceValue addSubview:btnDeviceImg];
        //For Decimal Value
        lblDecimalValue = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH-10, 40, 20, 30)];
        lblDecimalValue.backgroundColor = [UIColor clearColor];
        lblDecimalValue.textColor = [UIColor whiteColor];
        lblDecimalValue.textAlignment = NSTextAlignmentCenter;
        [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:18]];
        //For Degree
        lblDegree = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH-10, 25, 20, 20)];
        lblDegree.backgroundColor = [UIColor clearColor];
        lblDegree.textColor = [UIColor whiteColor];
        lblDegree.textAlignment = NSTextAlignmentCenter;
        [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:18]];
        lblDegree.text = @"°";
        [cell addSubview:lblDeviceValue];
        [cell addSubview:lblDecimalValue];
        [cell addSubview:lblDegree];
    }else{
        imgDevice = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_LABEL_WIDTH/3, 12, 53,70)];
        imgDevice.userInteractionEnabled = YES;
        [imgDevice addSubview:btnDeviceImg];
        btnDeviceImg.frame = imgDevice.bounds;
        [cell addSubview:imgDevice];
    }
    
   
   
    
    btnDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDevice.frame = leftBackgroundLabel.bounds;
    btnDevice.backgroundColor = [UIColor clearColor];
    [btnDevice addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:btnDevice];
  
    
    
    //Right Rectangle - Creation
    rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH+11,5,self.tableView.frame.size.width - LEFT_LABEL_WIDTH - 25,SENSOR_ROW_HEIGHT-10)];
    rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
    [cell addSubview:rightBackgroundLabel];
    
    lblDeviceName = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, (self.tableView.frame.size.width - LEFT_LABEL_WIDTH - 90), 30)];
    lblDeviceName.backgroundColor = [UIColor clearColor];
    lblDeviceName.textColor = [UIColor whiteColor];
    [lblDeviceStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    [rightBackgroundLabel addSubview:lblDeviceName];
    
    lblDeviceStatus = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, 180, 60)];
    lblDeviceStatus.backgroundColor = [UIColor clearColor];
    lblDeviceStatus.textColor = [UIColor whiteColor];
    lblDeviceStatus.numberOfLines = 2;
    [lblDeviceStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    [rightBackgroundLabel addSubview:lblDeviceStatus];
    
    imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 37, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;
    
    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];
    
    btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(self.tableView.frame.size.width-80, 5, 60, 80);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnSettingsCell];
   

    //Fill values
    lblDeviceName.text = currentSensor.deviceName;
    
    //Set values according to device type
    int currentDeviceId = currentSensor.deviceID;
    int deviceValueID;
    NSMutableArray *currentKnownValues = nil;
    SFIDeviceKnownValues *currentDeviceValue;
    //Pass current device info in map
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            currentKnownValues = currentDeviceValue.knownValues;
        }
    }
    
    //Get the value to be displayed on right rectangle
    NSString *currentValue;
    NSString *currentStateValue;
    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = [currentKnownValues objectAtIndex:0];
            currentValue = currentDeviceValue.value;
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            if(currentDeviceValue.isUpdating){
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }else{
                if([currentValue isEqualToString:@"true"]){
                    lblDeviceStatus.text = @"ON";
                }else if([currentValue isEqualToString:@"false"]){
                    lblDeviceStatus.text = @"OFF";
                }else{
                    if(currentValue==nil){
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }else{
                        lblDeviceStatus.text = currentValue;
                    }
                }
            }
            break;
            
        case 2:
        {
             //Multilevel switch
            
//            //Get State
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;
            
            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
            NSString *currentLevel = currentLevelKnownValue.value;
            
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            
            //PY 291113
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if(currentSensor.imageName == nil){
                imgDevice.image = [UIImage imageNamed:DT2_MULTILEVEL_SWITCH_TRUE];
            }
            
            if(currentDeviceValue.isUpdating){
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }else{
                if(![currentLevel isEqualToString:@""]){
                    if([currentLevel isEqualToString:@"0"]){
                        lblDeviceStatus.text =  @"OFF";
                    }else{
                        lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
                    }
                }else{
                    lblDeviceStatus.text =  @"Could not update sensor\ndata.";
                }
            }
                
                
                
                
//                if([currentStateValue isEqualToString:@"true"]){
//                    if(![currentLevel isEqualToString:@""]){
//                        lblDeviceStatus.text =  [NSString stringWithFormat:@"ON, %@%%", currentLevel];
//                    }else{
//                        lblDeviceStatus.text =  @"ON";
//                    }
//                }else if([currentStateValue isEqualToString:@"false"]){
//                    if(![currentLevel isEqualToString:@""]){
//                        lblDeviceStatus.text = [NSString stringWithFormat:@"OFF, %@%%", currentLevel];
//                    }else{
//                        lblDeviceStatus.text =  @"OFF";
//                    }
//                }else{
//                    if(currentStateValue==nil){
//                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
//                        if(currentDeviceValue == nil){
//                            if(![currentLevel isEqualToString:@""]){
//                                lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
//                            }else{
//                                lblDeviceStatus.text =  @"Dimmable";
//                            }
//                        }
//                    }else{
//                        if(![currentLevel isEqualToString:@""]){
//                            lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
//                        }else{
//                            lblDeviceStatus.text =  @"Dimmable";
//                        }
//                    }
//                }
//            }
            
            break;
        }
        case 3:
            //Binary Sensor
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY 291113 - Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT3_BINARY_SENSOR_TRUE];
                lblDeviceStatus.text = @"OPEN";
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT3_BINARY_SENSOR_FALSE];
                lblDeviceStatus.text = @"CLOSED";
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            
            //            if([currentSensor.mostImpValueName isEqualToString:TAMPER]){
            //                // imgDevice.frame = CGRectMake(25, 15, 53,60);
            //                lblDeviceStatus.text = @"TAMPERED";
            //                if([currentStateValue isEqualToString:@"false"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_off_tamper.png"];
            //                }else if([currentStateValue isEqualToString:@"true"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_on_tamper.png"];
            //                }
            //            }else if([currentSensor.mostImpValueName isEqualToString:@"LOW BATTERY"]){
            //                //imgDevice.frame = CGRectMake(25, 15, 53,60);
            //                lblDeviceStatus.text = @"LOW BATTERY";
            //                if([currentStateValue isEqualToString:@"false"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_off_battery.png"];
            //                }
            //            }else{
            //                //Check OPEN CLOSE State
            //                currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
            //                currentValue = currentDeviceValue.value;
            //                if([currentValue isEqualToString:@"true"]){
            //                    // imgDevice.frame = CGRectMake(30, 20, 40.5,60);
            //                    lblDeviceStatus.text = @"OPEN";
            //                }else if([currentValue isEqualToString:@"false"]){
            //                    //imgDevice.frame = CGRectMake(30, 15, 40.5,60);
            //                    lblDeviceStatus.text = @"CLOSED";
            //                }else{
            //                    if(currentValue==nil){
            //                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
            //                    }else{
            //                        lblDeviceStatus.text = currentValue;
            //                    }
            //                }
            //            }
            
            
            
            //            currentDeviceValue = [currentKnownValues objectAtIndex:0];
            //            currentValue = currentDeviceValue.value;
            //            if([currentValue isEqualToString:@"true"]){
            //                imgDevice.frame = CGRectMake(30, 20, 40.5,60);
            //                lblDeviceStatus.text = @"OPEN";
            //            }else{
            //                imgDevice.frame = CGRectMake(30, 15, 40.5,60);
            //                lblDeviceStatus.text = @"CLOSED";
            //            }
            //            imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;
            
        case 4:
//            //Level Control
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;
//            //PY - Show only State
//            if([currentStateValue isEqualToString:@"true"]){
//                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_TRUE];
//                lblDeviceStatus.text = @"ON";
//            }else if([currentStateValue isEqualToString:@"false"]){
//                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_FALSE];
//                lblDeviceStatus.text = @"OFF";
//            }else{
//                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                if(currentStateValue==nil){
//                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
//                }else{
//                    lblDeviceStatus.text = currentValue;
//                }
//            }
        {
            
            //Get State
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            
            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
            NSString *currentLevel = currentLevelKnownValue.value;
            
            float intLevel = [currentLevel floatValue];
            intLevel = intLevel/256 * 100;
            
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if(currentSensor.imageName == nil){
                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_TRUE];
            }
            if(currentDeviceValue.isUpdating){
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }else{
                if([currentStateValue isEqualToString:@"true"]){
                    if(![currentLevel isEqualToString:@""]){
                        lblDeviceStatus.text =  [NSString stringWithFormat:@"ON, %.0f%%", intLevel];
                    }else{
                        lblDeviceStatus.text =  @"ON";
                    }
                }else if([currentStateValue isEqualToString:@"false"]){
                    if(![currentLevel isEqualToString:@""]){
                        lblDeviceStatus.text = [NSString stringWithFormat:@"OFF, %.0f%%", intLevel];
                    }else{
                        lblDeviceStatus.text =  @"OFF";
                    }
                }else{
                    if(currentStateValue==nil){
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                        if(currentDeviceValue == nil){
                            if(![currentLevel isEqualToString:@""]){
                                lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                            }else{
                                lblDeviceStatus.text =  @"Dimmable";
                            }
                        }
                    }else{
                        if(![currentLevel isEqualToString:@""]){
                            lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                        }else{
                            lblDeviceStatus.text =  @"Dimmable";
                        }
                    }
                }
                
                //TODO: Remove later - For testing
//                lblDeviceStatus.numberOfLines = 2;
//                lblDeviceStatus.text =  [NSString stringWithFormat:@"ON, %.0f%%\nLOW BATTERY", intLevel];
                
            }

            break;
        }
        case 5:
            //Door Lock
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT5_DOOR_LOCK_TRUE];
                lblDeviceStatus.text = @"LOCKED";
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT5_DOOR_LOCK_FALSE];
                lblDeviceStatus.text = @"UNLOCKED";
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        case 6:
            //Alarm
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - TODO: Change later
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT6_ALARM_TRUE];
                lblDeviceStatus.text = @"ON";
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT6_ALARM_FALSE];
                lblDeviceStatus.text = @"OFF";
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        case 7:
        {
            //Thermostat
            NSString *strValue = @"";
            
            
            NSString *strStatus;
            NSString *strOperatingMode;
            NSString *heatingSetpoint;
            NSString *coolingSetpoint;
            
            for(SFIDeviceKnownValues *currentKnownValue in currentKnownValues){
                if([currentKnownValue.valueName isEqualToString:@"SENSOR MULTILEVEL"]){
                    strValue = currentKnownValue.value;
                    //lblDeviceValue.text = [NSString stringWithFormat:@"%@°",currentKnownValue.value] ;
                }else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]){
                    heatingSetpoint = [NSString stringWithFormat:@" HI %@°", currentKnownValue.value];
                }else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]){
                    coolingSetpoint = [NSString stringWithFormat:@" LO %@°", currentKnownValue.value];
                }else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]){
                    strOperatingMode = currentKnownValue.value;
                }
            }
            
            strStatus = [NSString stringWithFormat:@"%@, %@, %@", strOperatingMode, coolingSetpoint, heatingSetpoint];
            
            //Calculate values
            NSArray *thermostatValues = [strValue componentsSeparatedByString:@"."];
            
            
            NSString *strIntegerValue = [thermostatValues objectAtIndex:0];
            NSString *strDecimalValue = @"";
            if([thermostatValues count]==2){
                strDecimalValue = [thermostatValues objectAtIndex:1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@",strDecimalValue];
            }
            
            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1){
                lblDecimalValue.frame = CGRectMake((self.tableView.frame.size.width/4)-25, 40, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH-25, 25, 20, 20);
            }else if([strIntegerValue length] == 3){
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:30]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH-10, 38, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH-10, 30, 20, 20);
            }else if([strIntegerValue length] == 4){
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH-12, 35, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH-12, 30, 20, 20);
            }
            

            
            
            lblDeviceStatus.text = strStatus;
            break;
        }
        case 11:
        {
            //Motion Sensor
            NSMutableString *strStatus = [[NSMutableString alloc]init];
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.25, 12, 53,70);
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT11_MOTION_SENSOR_TRUE];
                [strStatus appendString:@"MOTION DETECTED"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT11_MOTION_SENSOR_FALSE];
                [strStatus appendString:@"NO MOTION"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 12:
        {
            //ContactSwitch
            NSMutableString *strStatus= [[NSMutableString alloc]init];
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT12_CONTACT_SWITCH_TRUE];
                [strStatus appendString:@"OPEN"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT12_CONTACT_SWITCH_FALSE];
                [strStatus appendString:@"CLOSED"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 13:
        {
            //Fire Sensor
            NSMutableString *strStatus= [[NSMutableString alloc]init];
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT13_FIRE_SENSOR_TRUE];
                [strStatus appendString:@"ALARM: FIRE DETECTED"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT13_FIRE_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 14:
            //Water Sensor
        {
//            NSString *text = @"89";
//            UIGraphicsBeginImageContext(CGSizeMake(53, 70));
//            [text drawAtPoint:CGPointMake(0, 0)
//                     withFont:[UIFont fontWithName:@"Avenir-Heavy" size:36]];
//            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            imgDevice.image = result;
            
            NSMutableString *strStatus= [[NSMutableString alloc]init];
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT14_WATER_SENSOR_TRUE];
                [strStatus appendString:@"FLOODED"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT14_WATER_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            
            break;
        }
        case 15:
        {
            //Gas Sensor
            NSMutableString *strStatus= [[NSMutableString alloc]init];
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT15_GAS_SENSOR_TRUE];
                [strStatus appendString:@"ALARM: GAS DETECTED"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT15_GAS_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 17:
        {
            //Vibration Sensor
            NSMutableString *strStatus = [[NSMutableString alloc]init];
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT17_VIBRATION_SENSOR_TRUE];
                [strStatus appendString:@"VIBRATION DETECTED"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT17_VIBRATION_SENSOR_FALSE];
                [strStatus appendString:@"NO VIBRATION"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 19:
        {
            //Keyfob
            NSMutableString *strStatus = [[NSMutableString alloc]init];
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT19_KEYFOB_TRUE];
                [strStatus appendString:@"LOCKED"];
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT19_KEYFOB_FALSE];
                [strStatus appendString:@"UNLOCKED"];
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            
            if(currentSensor.isBatteryLow){
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }else{
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 22:
            //Electric Measurement Switch - AC
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 10, 53,70);
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if(currentDeviceValue.isUpdating){
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }else{
                if([currentStateValue isEqualToString:@"true"]){
                    lblDeviceStatus.text = @"ON";
                }else if([currentStateValue isEqualToString:@"false"]){
                    lblDeviceStatus.text = @"OFF";
                }else{
                    if(currentStateValue==nil){
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }else{
                        lblDeviceStatus.text = currentValue;
                    }
                }
            }
            break;
        case 23:
            //Electric Measurement Switch - DC
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if(currentDeviceValue.isUpdating){
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }else{
                if([currentStateValue isEqualToString:@"true"]){
                    lblDeviceStatus.text = @"ON";
                }else if([currentStateValue isEqualToString:@"false"]){
                    lblDeviceStatus.text = @"OFF";
                }else{
                    if(currentStateValue==nil){
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }else{
                        lblDeviceStatus.text = currentValue;
                    }
                }
            }
            break;
        case 27:
            //Temperature Sensor
        {
            NSString *strValue = @"";
            
            for(SFIDeviceKnownValues *currentKnownValue in currentKnownValues){
                if([currentKnownValue.valueName isEqualToString:@"MEASURED_VALUE"]){
                    strValue = currentKnownValue.value;
                }else if ([currentKnownValue.valueName isEqualToString:@"TOLERANCE"]){
                   lblDeviceStatus.text = [NSString stringWithFormat:@"Tolerance: %@", currentKnownValue.value];
                }
            }
 
            //Calculate values
            NSArray *temperatureValues = [strValue componentsSeparatedByString:@"."];
            
            
            NSString *strIntegerValue = [temperatureValues objectAtIndex:0];
            NSString *strDecimalValue = @"";
            if([temperatureValues count]==2){
                strDecimalValue = [temperatureValues objectAtIndex:1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@",strDecimalValue];
            }
            
            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1){
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH-25, 40, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH-25, 25, 20, 20);
            }else if([strIntegerValue length] == 3){
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:30]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH-10, 38, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH-10, 30, 20, 20);
            }else if([strIntegerValue length] == 4){
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH-12, 35, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH-12, 30, 20, 20);
            }
            
            break;
        }
        case 34:
            //Keyfob
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT34_SHADE_TRUE];
                lblDeviceStatus.text = @"OPEN";
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT34_SHADE_FALSE];
                lblDeviceStatus.text = @"CLOSED";
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        default:
            imgDevice.frame = CGRectMake(LEFT_LABEL_WIDTH/3.5, 12, 53,70);
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            break;
    }
    

    btnDevice.tag = indexPathRow;
    btnDeviceImg.tag = indexPathRow;
    btnSettings.tag = indexPathRow;
    btnSettingsCell.tag = indexPathRow;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Expanded View
    if(currentSensor.isExpanded){
//        [[self view] endEditing:YES];
        //Settings icon - white
        imgSettings.alpha = 1.0;
        
        //Show values also
        UILabel *belowBackgroundLabel = [[UILabel alloc] init];
        belowBackgroundLabel.userInteractionEnabled = YES;
        belowBackgroundLabel.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
        
        
        UILabel *expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10,10,299,30)];
        float baseYCordinate = -20;
        //expandedLblText.backgroundColor = [UIColor greenColor];
        switch (currentDeviceType) {
            case 1:
                expandedRowHeight = EXPANDED_ROW_HEIGHT;
                baseYCordinate = baseYCordinate+25;
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //               currentDeviceValue = [currentKnownValues objectAtIndex:0];
//                //                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                //Display Location - PY 291113
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            case 2:
            {
                expandedRowHeight = 270;
                baseYCordinate+=35;
                UIImageView *minImage = [[UIImageView alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 24,24)];
                [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
                [belowBackgroundLabel addSubview:minImage];
                
                //Display slider
                UISlider *slider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate, self.tableView.frame.size.width - 110, 10.0);
                } else {
                    // code for 3.5-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate-10, (self.tableView.frame.size.width - 110), 10.0);
                }
                
//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, baseYCordinate-10, (self.tableView.frame.size.width - 110), 10.0)];
                slider.tag = indexPathRow;
                slider.minimumValue = 0;
                slider.maximumValue = 99;
                [slider addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)] ;
                [slider addGestureRecognizer:tapSlider];
                
                
                //Set slider value
                float currentSliderValue = 0.0;
                
                for(int i =0; i < [currentKnownValues count]; i++){
                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
                    //Get slider value
                    if([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]){
                        currentSliderValue = [currentDeviceValue.value floatValue];
                        break;
                    }
                }
                
                [slider setValue:currentSliderValue animated:YES];
                
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:slider];
                
                UIImageView *maxImage = [[UIImageView alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width - 110) + 50, baseYCordinate-5, 24,24)];
                [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
                [belowBackgroundLabel addSubview:maxImage];
                
                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];
                
                baseYCordinate = baseYCordinate+5;
                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //Display Location
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 3:
            {
                expandedRowHeight = 260;
                //Do not display the most important one
                for(int i =0; i < [currentKnownValues count]; i++){
                    // if(i!= currentSensor.mostImpValueIndex ){
                    
                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
                    //Display only battery - PY 291113
                    NSString *batteryStatus;
                    if([currentDeviceValue.valueName isEqualToString:@"BATTERY"]){
                        expandedLblText = [[UILabel alloc]init];
                        [expandedLblText setBackgroundColor:[UIColor clearColor]];
                        //Check the status of value
                        if([currentValue isEqualToString:@"1"]){
                            //Battery Low
                            batteryStatus = @"Low Battery";
                        }else{
                            //Battery OK
                            batteryStatus = @"Battery OK";
                        }
                        expandedLblText.text = batteryStatus;
                        expandedLblText.textColor = [UIColor whiteColor];
                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                        baseYCordinate = baseYCordinate+25;
                        //// NSLog(@"Y Cordinate %f", baseYCordinate);
                        expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                        [belowBackgroundLabel addSubview:expandedLblText];
                    }
                    //                    expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
                    
                    // }
                }
                
                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];
                
                baseYCordinate = baseYCordinate+5;
                
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                //Display Location - PY 291113
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 4:{
                //Level Control
                expandedRowHeight = 270;
                baseYCordinate+=35;
                UIImageView *minImage = [[UIImageView alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 24,24)];
                [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
                [belowBackgroundLabel addSubview:minImage];
                
                //Display slider
                UISlider *slider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate, self.tableView.frame.size.width - 110, 10.0);
                } else {
                    // code for 3.5-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate-10, (self.tableView.frame.size.width - 110), 10.0);
                }
                
//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, baseYCordinate-10, self.tableView.frame.size.width - 110, 10.0)];
                slider.tag = indexPathRow;
                slider.minimumValue = 0;
                slider.maximumValue = 255;
                [slider addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)] ;
                [slider addGestureRecognizer:tapSlider];
                
                
                //Set slider value
                float currentSliderValue = 0.0;
                
                for(int i =0; i < [currentKnownValues count]; i++){
                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
                    //Get slider value
                    if([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]){
                        currentSliderValue = [currentDeviceValue.value floatValue];
                        break;
                    }
                }
                
                [slider setValue:currentSliderValue animated:YES];
                
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:slider];
                
                UIImageView *maxImage = [[UIImageView alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width - 110) + 50, baseYCordinate-5, 24,24)];
                [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
                [belowBackgroundLabel addSubview:maxImage];
                
                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];
                
                baseYCordinate = baseYCordinate+5;
                break;
            }
            case 5:{
                //Door Lock
                expandedRowHeight = EXPANDED_ROW_HEIGHT;
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 6:{
                //Alarm
                expandedRowHeight = EXPANDED_ROW_HEIGHT;
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 7:{
                //Thermostat
                expandedRowHeight = 455;
                baseYCordinate+=40;
                
                //Heating Setpoint
                UILabel *lblHeating = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 60, 30)];
                lblHeating.textColor = [UIColor whiteColor];
                [lblHeating setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblHeating.text = @"Heating";
                [belowBackgroundLabel addSubview:lblHeating];
                
//                UIImageView *minHeatImage = [[UIImageView alloc]initWithFrame:CGRectMake(80.0, baseYCordinate-3, 24,24)];
//                [minHeatImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
//                [belowBackgroundLabel addSubview:minHeatImage];
                UILabel *lblMinHeat = [[UILabel alloc]initWithFrame:CGRectMake(70.0, baseYCordinate-3, 30,24)];
                [lblMinHeat setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMinHeat.text = @"35°";
                lblMinHeat.textColor = [UIColor whiteColor];
                lblMinHeat.textAlignment = NSTextAlignmentCenter;
                lblMinHeat.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMinHeat];
                
                //Display heating slider
                UISlider *heatSlider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    heatSlider.frame = CGRectMake(100.0, baseYCordinate, self.tableView.frame.size.width - 160, 10.0);
                } else {
                    // code for 3.5-inch screen
                    heatSlider.frame = CGRectMake(100.0, baseYCordinate-10, self.tableView.frame.size.width - 160, 10.0);
                }
//                UISlider *heatSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0, baseYCordinate-10, self.tableView.frame.size.width - 160, 10.0)];
                heatSlider.tag = indexPathRow;
                heatSlider.minimumValue = 35;
                heatSlider.maximumValue = 95;
                [heatSlider addTarget:self action:@selector(heatingSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(heatingSliderTapped:)] ;
                [heatSlider addGestureRecognizer:tapSlider];
                
                [heatSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [heatSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [heatSlider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [heatSlider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:heatSlider];
                
                UILabel *lblMaxHeat = [[UILabel alloc]initWithFrame:CGRectMake(100 + (self.tableView.frame.size.width - 160), baseYCordinate-3, 30,24)];
                [lblMaxHeat setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMaxHeat.text = @"95°";
                lblMaxHeat.textColor = [UIColor whiteColor];
                lblMaxHeat.textAlignment = NSTextAlignmentCenter;
                lblMaxHeat.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMaxHeat];
                
//                UIImageView *maxHeatImage = [[UIImageView alloc]initWithFrame:CGRectMake(100 + (self.tableView.frame.size.width - 160), baseYCordinate-3, 24,24)];
//                [maxHeatImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
//                [belowBackgroundLabel addSubview:maxHeatImage];
                
                baseYCordinate+=40;
                //PY 170114
//                UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine1.image = [UIImage imageNamed:@"line.png"];
//                imgLine1.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine1];
//                
//                baseYCordinate = baseYCordinate+10;
                
                //Cooling Setpoint
                UILabel *lblCooling = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 60, 30)];
                lblCooling.textColor = [UIColor whiteColor];
                [lblCooling setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblCooling.text = @"Cooling";
                [belowBackgroundLabel addSubview:lblCooling];
                
//                UIImageView *minCoolingImage = [[UIImageView alloc]initWithFrame:CGRectMake(80.0, baseYCordinate-3, 24,24)];
//                [minCoolingImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
//                [belowBackgroundLabel addSubview:minCoolingImage];
                
                UILabel *lblMinCool = [[UILabel alloc]initWithFrame:CGRectMake(70.0, baseYCordinate-3, 30,24)];
                [lblMinCool setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMinCool.text = @"35°";
                lblMinCool.textColor = [UIColor whiteColor];
                lblMinCool.textAlignment = NSTextAlignmentCenter;
                lblMinCool.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMinCool];

                
                //Display Cooling slider
                UISlider *coolSlider = [[UISlider alloc] init];
                //CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    coolSlider.frame = CGRectMake(100.0, baseYCordinate, self.tableView.frame.size.width - 160, 10.0);
                } else {
                    // code for 3.5-inch screen
                    coolSlider.frame = CGRectMake(100.0, baseYCordinate-10, self.tableView.frame.size.width - 160, 10.0);
                }
//                UISlider *coolSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0, baseYCordinate-10, self.tableView.frame.size.width - 160, 10.0)];
                coolSlider.tag = indexPathRow;
                coolSlider.minimumValue = 35;
                coolSlider.maximumValue = 95;
                [coolSlider addTarget:self action:@selector(coolingSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *coolTapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coolingSliderTapped:)] ;
                [coolSlider addGestureRecognizer:coolTapSlider];
                
                [coolSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [coolSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [coolSlider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [coolSlider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:coolSlider];
                
//                UIImageView *maxCoolImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 160 + 100, baseYCordinate-3, 24,24)];
//                [maxCoolImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
//                [belowBackgroundLabel addSubview:maxCoolImage];
                
                UILabel *lblMaxCool = [[UILabel alloc]initWithFrame:CGRectMake(100 + (self.tableView.frame.size.width - 160), baseYCordinate-3, 30,24)];
                [lblMaxCool setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMaxCool.text = @"95°";
                lblMaxCool.textColor = [UIColor whiteColor];
                lblMaxCool.textAlignment = NSTextAlignmentCenter;
                lblMaxCool.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMaxCool];

                
                baseYCordinate+=30;
                UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine2.image = [UIImage imageNamed:@"line.png"];
                imgLine2.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine2];
                
                baseYCordinate = baseYCordinate+10;
                
                //Mode
                UILabel *lblMode = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 100, 30)];
                lblMode.textColor = [UIColor whiteColor];
                [lblMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMode.text = @"Thermostat";
                [belowBackgroundLabel addSubview:lblMode];
                
                //Font for segment control
                UIFont *font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
                NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                       forKey:NSFontAttributeName];
                
                NSArray *modeItemArray = [NSArray arrayWithObjects: @"Auto", @"Heat", @"Cool", @"Off",nil];
                UISegmentedControl *scMode = [[UISegmentedControl alloc] initWithItems:modeItemArray];
                scMode.frame = CGRectMake(self.tableView.frame.size.width - 220, baseYCordinate, 180, 20);
                scMode.tag = indexPathRow;
                scMode.tintColor = [UIColor whiteColor];
                [scMode addTarget:self
                              action:@selector(modeSelected:)
                    forControlEvents:UIControlEventValueChanged];
                [scMode setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:scMode];
                
                baseYCordinate+=30;
                UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine3.image = [UIImage imageNamed:@"line.png"];
                imgLine3.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine3];
                
                baseYCordinate = baseYCordinate+10;
                
                //Fan Mode
                UILabel *lblFanMode = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 60, 30)];
                lblFanMode.textColor = [UIColor whiteColor];
                [lblFanMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblFanMode.text = @"Fan";
                [belowBackgroundLabel addSubview:lblFanMode];
                
                NSArray *fanItemArray = [NSArray arrayWithObjects: @"Auto Low", @"On Low",nil];
                UISegmentedControl *scFanMode = [[UISegmentedControl alloc] initWithItems:fanItemArray];
                scFanMode.frame = CGRectMake(self.tableView.frame.size.width - 190, baseYCordinate, 150, 20);
                scFanMode.tag = indexPathRow;
                
                [scFanMode setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];
                [scFanMode addTarget:self
                                     action:@selector(fanModeSelected:)
                           forControlEvents:UIControlEventValueChanged];
                scFanMode.tintColor = [UIColor whiteColor];
                [belowBackgroundLabel addSubview:scFanMode];

                
                baseYCordinate+=30;
                UIImageView *imgLine4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine4.image = [UIImage imageNamed:@"line.png"];
                imgLine4.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine4];
                
                baseYCordinate = baseYCordinate+5;
                
                
                //Status
                UILabel *lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate, 60, 30)];
                lblStatus.textColor = [UIColor whiteColor];
                [lblStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblStatus.text = @"Status";
                
                [belowBackgroundLabel addSubview:lblStatus];
                
                //baseYCordinate+=25;
                
                //Operating state
                UILabel *lblOperatingState = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, baseYCordinate, 220, 30)];
                lblOperatingState.textColor = [UIColor whiteColor];
                lblOperatingState.backgroundColor = [UIColor clearColor];
                [lblOperatingState setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblOperatingState.textAlignment = NSTextAlignmentRight;
                [belowBackgroundLabel addSubview:lblOperatingState];
                
                baseYCordinate+=25;
//                UIImageView *imgLine5 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine5.image = [UIImage imageNamed:@"line.png"];
//                imgLine5.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine5];
//                
//                baseYCordinate = baseYCordinate+10;
                
//                //Fan State
//                UILabel *lblFanState = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 200, 30)];
//                lblFanState.textColor = [UIColor whiteColor];
//                [lblFanState setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:lblFanState];
//                
//                baseYCordinate+=25;
//                UIImageView *imgLine6 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine6.image = [UIImage imageNamed:@"line.png"];
//                imgLine6.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine6];
//                
//                baseYCordinate = baseYCordinate+10;
                
                //Battery
                UILabel *lblBattery = [[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, baseYCordinate-5, 220, 30)];
                lblBattery.textColor = [UIColor whiteColor];
                [lblBattery setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                [lblBattery setBackgroundColor:[UIColor clearColor]];
                lblBattery.textAlignment = NSTextAlignmentRight;
                [belowBackgroundLabel addSubview:lblBattery];
                
                baseYCordinate+=25;
                UIImageView *imgLine7 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine7.image = [UIImage imageNamed:@"line.png"];
                imgLine7.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine7];
                
                baseYCordinate = baseYCordinate+5;
                
                //Set slider value
                float currentHeatingSliderValue = 0.0;
                float currentCoolingSliderValue = 0.0;
                
                NSMutableString *strState = [[NSMutableString alloc]init];
                
                for(int i =0; i < [currentKnownValues count]; i++){
                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
                    //Get slider value
                    if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]){
                        currentHeatingSliderValue = [currentDeviceValue.value floatValue];
                    }else if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]){
                        currentCoolingSliderValue = [currentDeviceValue.value floatValue];
                    }else if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT MODE"]){
                        if([currentDeviceValue.value isEqualToString:@"Auto"]){
                            scMode.selectedSegmentIndex = 0;
                        }else if([currentDeviceValue.value isEqualToString:@"Heat"]){
                            scMode.selectedSegmentIndex = 1;
                        }else if([currentDeviceValue.value isEqualToString:@"Cool"]){
                            scMode.selectedSegmentIndex = 2;
                        }else if([currentDeviceValue.value isEqualToString:@"Off"]){
                            scMode.selectedSegmentIndex = 3;
                        }
                    }else if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]){
//                        lblOperatingState.text = [NSString stringWithFormat:@"Operating State is %@", currentDeviceValue.value];
                        [strState appendString:[NSString stringWithFormat:@"Thermostat is %@. ", currentDeviceValue.value]];
                    }else if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN MODE"]){
                        if([currentDeviceValue.value isEqualToString:@"Auto Low"]){
                            scFanMode.selectedSegmentIndex = 0;
                        }else{
                            scFanMode.selectedSegmentIndex = 1;
                        }
//                        lblFanMode.text = [NSString stringWithFormat:@"Fan Mode %@", currentDeviceValue.value];
                    }else if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN STATE"]){
//                        lblFanState.text = [NSString stringWithFormat:@"Fan State is %@", currentDeviceValue.value];
                        [strState appendString:[NSString stringWithFormat:@"Fan is %@.", currentDeviceValue.value]];
                    }else if([currentDeviceValue.valueName isEqualToString:@"BATTERY"]){
                        lblBattery.text = [NSString stringWithFormat:@"Battery is at %@%%.", currentDeviceValue.value];
                    }

                }
                
                lblOperatingState.text = strState;
                
                [heatSlider setValue:currentHeatingSliderValue animated:YES];
                [coolSlider setValue:currentCoolingSliderValue animated:YES];
                
                break;
            }
            case 11:{
                //Motion Sensor
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                action:@selector(dismissTamper:)
                      forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                    
//                    if (currentSensor.isBatteryLow){
//                        //baseYCordinate = baseYCordinate+25;
//                        expandedRowHeight = expandedRowHeight + 20;
//                        expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate-5, 200, 30)];
//                        expandedLblText.text = BATTERY_IS_LOW;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                        
//                        baseYCordinate+=25;
//                        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                        imgLine.image = [UIImage imageNamed:@"line.png"];
//                        imgLine.alpha = 0.5;
//                        [belowBackgroundLabel addSubview:imgLine];
//                        
//                        baseYCordinate = baseYCordinate+5;
//                    }
                }
                else{
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    baseYCordinate = baseYCordinate+25;
//                    if (currentSensor.isBatteryLow){
//                        //baseYCordinate = baseYCordinate+25;
//                        expandedRowHeight = expandedRowHeight + 40;
//                        expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate-5, 200, 30)];
//                        expandedLblText.text = BATTERY_IS_LOW;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                        
//                        baseYCordinate+=25;
//                        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                        imgLine.image = [UIImage imageNamed:@"line.png"];
//                        imgLine.alpha = 0.5;
//                        [belowBackgroundLabel addSubview:imgLine];
//                        
//                        baseYCordinate = baseYCordinate+5;
//                    }
                }
                break;
            }
            case 12:
            {
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = 270;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(dismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                }else{
                    expandedRowHeight = 230;
                    baseYCordinate = baseYCordinate+25;
                }
                //Do not display the most important one
//                for(int i =0; i < [currentKnownValues count]; i++){
//                    // if(i!= currentSensor.mostImpValueIndex ){
//                    
//                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
//                    //Display only battery - PY 291113
//                    NSString *batteryStatus;
//                    if([currentDeviceValue.valueName isEqualToString:@"LOW BATTERY"]){
//                        expandedLblText = [[UILabel alloc]init];
//                        [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                        //Check the status of value
//                        if([currentValue isEqualToString:@"1"]){
//                            //Battery Low
//                            batteryStatus = @"Low Battery";
//                        }else{
//                            //Battery OK
//                            batteryStatus = @"Battery OK";
//                        }
//                        expandedLblText.text = batteryStatus;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        
//                        //// NSLog(@"Y Cordinate %f", baseYCordinate);
//                        expandedLblText.frame = CGRectMake(10,baseYCordinate-5,299,30);
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                    }
//                    
//                    
//                    //                    expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                    
//                    // }
//                }
                
//                baseYCordinate+=25;
//                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine.image = [UIImage imageNamed:@"line.png"];
//                imgLine.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine];
//                
//                baseYCordinate = baseYCordinate+5;
                
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                //Display Location - PY 291113
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 13:{
                //Fire Sensor
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(dismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                }else{
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    baseYCordinate = baseYCordinate+25;
                }
                break;
            }
            case 14:{
                //Water Sensor
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(dismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                     [btnDismiss setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
//                    [[btnDismiss layer] setBorderWidth:1.0f];
//                    [[btnDismiss layer] setBorderColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6].CGColor];
                    
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                }else{
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    baseYCordinate = baseYCordinate+25;
                }
                break;
            }
            case 15:{
                //Gas Sensor
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(dismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                }else{
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    baseYCordinate = baseYCordinate+25;
                }
                break;
            }
            case 17:{
                //Vibration Sensor
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(dismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                }else{
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    baseYCordinate = baseYCordinate+25;
                }
                break;
            }
            case 19:{
                //KeyFob
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedRowHeight = EXPANDED_ROW_HEIGHT + 50;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];
                    
                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(dismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];
                    
                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];
                    
                    baseYCordinate = baseYCordinate+5;
                }else{
                    expandedRowHeight = EXPANDED_ROW_HEIGHT;
                    baseYCordinate = baseYCordinate+25;
                }
                break;
            }
            case 22:
            {
                //Show values and calculations
                //Calculate values
                unsigned int activePower = 0;
                unsigned int acPowerMultiplier = 0;
                unsigned int acPowerDivisor  = 0;
                unsigned int rmsVoltage = 0;
                unsigned int acVoltageMultipier = 0;
                unsigned int acVoltageDivisor = 0;
                unsigned int rmsCurrent = 0;
                unsigned int acCurrentMultipier = 0;
                unsigned int acCurrentDivisor = 0;
                NSString *currentDeviceTypeName;
                NSString *hexString;
                if(currentKnownValues!=nil){
                    for(int i = 0; i < [currentKnownValues count]; i++){
                        SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                        currentDeviceTypeName = curDeviceValues.valueName;
                        hexString = curDeviceValues.value;
                        //                          NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[currentDevice.deviceIP integerValue]];
                        //							hexString = hexString.substring(2);
                        // NSLog(@"HEX STRING: %@", hexString);
                        NSScanner *scanner = [NSScanner scannerWithString:hexString];
                        
                        if([currentDeviceTypeName isEqualToString:@"ACTIVE_POWER"]){
                            [scanner scanHexInt:&activePower];
                            //activePower = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"AC_POWERMULTIPLIER"]){
                            [scanner scanHexInt:&acPowerMultiplier];
                            //acPowerMultiplier = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"AC_POWERDIVISOR"]){
                            [scanner scanHexInt:&acPowerDivisor];
                            //acPowerDivisor = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"RMS_VOLTAGE"]){
                            [scanner scanHexInt:&rmsVoltage];
                            //rmsVoltage = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"AC_VOLTAGEMULTIPLIER"]){
                            [scanner scanHexInt:&acVoltageMultipier];
                            //acVoltageMultipier = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"AC_VOLTAGEDIVISOR"]){
                            [scanner scanHexInt:&acVoltageDivisor];
                            //acVoltageDivisor = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"RMS_CURRENT"]){
                            [scanner scanHexInt:&rmsCurrent];
                            //rmsCurrent = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"AC_CURRENTMULTIPLIER"]){
                            [scanner scanHexInt:&acCurrentMultipier];
                            //acCurrentMultipier = Integer.parseInt(hexString, 16);
                        }else if([currentDeviceTypeName isEqualToString:@"AC_CURRENTDIVISOR"]){
                            [scanner scanHexInt:&acCurrentDivisor];
                            //acCurrentDivisor = Integer.parseInt(hexString, 16);
                        }
                    }
                }
                
                float power = (float)activePower * acPowerMultiplier/acPowerDivisor;
                float voltage = (float)rmsVoltage * acVoltageMultipier / acVoltageDivisor;
                float current = (float)rmsCurrent * acCurrentMultipier / acCurrentDivisor;
                
                // NSLog(@"Power %f Voltage %f Current %f", power, voltage, current);
                
                expandedRowHeight = 320;
                
                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                
                //Display Power
                expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];
                
                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                
                //Display Voltage
                expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];
                
                
                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                
                
                
                //Display Current
                expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];
                
                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];
                
                baseYCordinate = baseYCordinate+5;
                
//                expandedLblText =[[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //Display Location
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 23:
            {
                //Electric Measure - DC
                //Show values and calculations
                //Calculate values
                unsigned int dcPower = 0;
                unsigned int dcPowerMultiplier = 0;
                unsigned int dcPowerDivisor  = 0;
                unsigned int dcVoltage = 0;
                unsigned int dcVoltageMultipier = 0;
                unsigned int dcVoltageDivisor = 0;
                unsigned int dcCurrent = 0;
                unsigned int dcCurrentMultipier = 0;
                unsigned int dcCurrentDivisor = 0;
                NSString *currentDeviceTypeName;
                NSString *hexString;
                if(currentKnownValues!=nil){
                    for(int i = 0; i < [currentKnownValues count]; i++){
                        SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                        currentDeviceTypeName = curDeviceValues.valueName;
                        hexString = curDeviceValues.value;

                        NSScanner *scanner = [NSScanner scannerWithString:hexString];
                        
                        if([currentDeviceTypeName isEqualToString:@"DC_POWER"]){
                            [scanner scanHexInt:&dcPower];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_POWERMULTIPLIER"]){
                            [scanner scanHexInt:&dcPowerMultiplier];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_POWERDIVISOR"]){
                            [scanner scanHexInt:&dcPowerDivisor];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_VOLTAGE"]){
                            [scanner scanHexInt:&dcVoltage];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEMULTIPLIER"]){
                            [scanner scanHexInt:&dcVoltageMultipier];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEDIVISOR"]){
                            [scanner scanHexInt:&dcVoltageDivisor];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_CURRENT"]){
                            [scanner scanHexInt:&dcCurrent];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_CURRENTMULTIPLIER"]){
                            [scanner scanHexInt:&dcCurrentMultipier];
                        }else if([currentDeviceTypeName isEqualToString:@"DC_CURRENTDIVISOR"]){
                            [scanner scanHexInt:&dcCurrentDivisor];
                        }
                    }
                }
                
                float power = (float)dcPower * dcPowerMultiplier/dcPowerDivisor;
                float voltage = (float)dcVoltage * dcVoltageMultipier / dcVoltageDivisor;
                float current = (float)dcCurrent * dcCurrentMultipier / dcCurrentDivisor;
                
                // NSLog(@"Power %f Voltage %f Current %f", power, voltage, current);
                
                expandedRowHeight = 320;
                
                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                
                //Display Power
                expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];
                
                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                
                //Display Voltage
                expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];
                
                
                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                
                
                
                //Display Current
                expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];
                
                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];
                
                baseYCordinate = baseYCordinate+5;
                
                break;
            }
            case 26:{
                //Window Covering
                expandedRowHeight = EXPANDED_ROW_HEIGHT;
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 27:{
                //Temperature Sensor
                expandedRowHeight = EXPANDED_ROW_HEIGHT;
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 34:{
                //Shade
                expandedRowHeight = EXPANDED_ROW_HEIGHT;
                baseYCordinate = baseYCordinate+25;
                break;
            }
            default:
                baseYCordinate+=25;
//                expandedRowHeight = 160;
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //               currentDeviceValue = [currentKnownValues objectAtIndex:0];
//                //                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                //Display Location - PY 291113
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
        }
        
        //Settings for all the sensors
        expandedLblText = [[UILabel alloc]init];
        [expandedLblText setBackgroundColor:[UIColor clearColor]];
        expandedLblText.textColor = [UIColor whiteColor];
        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];

        expandedLblText.frame = CGRectMake(10,baseYCordinate-5,299,30);
        expandedLblText.text = [NSString stringWithFormat:@"SENSOR SETTINGS"];
        [belowBackgroundLabel addSubview:expandedLblText];
        
        baseYCordinate = baseYCordinate+25;
        
        UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine1.image = [UIImage imageNamed:@"line.png"];
        imgLine1.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine1];
        
        //Display Name
        expandedLblText = [[UILabel alloc]init];
        expandedLblText.text = @"Name";
        [expandedLblText setBackgroundColor:[UIColor clearColor]];
        expandedLblText.textColor = [UIColor whiteColor];
        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
        baseYCordinate = baseYCordinate+5;
        expandedLblText.frame = CGRectMake(10,baseYCordinate,100,30);
        [belowBackgroundLabel addSubview:expandedLblText];
        
//        baseYCordinate = baseYCordinate+25;
        UITextField *tfName = [[UITextField alloc] initWithFrame:CGRectMake(110, baseYCordinate, self.tableView.frame.size.width - 150, 30)];
        tfName.text = currentSensor.deviceName;
        tfName.textAlignment = NSTextAlignmentRight;
        tfName.textColor = [UIColor whiteColor];
        //tfName.delegate = self;
        [tfName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
         tfName.tag = indexPathRow;
        [tfName addTarget:self action:@selector(tfNameDidChange:) forControlEvents:UIControlEventEditingChanged];
        //[tfName resignFirstResponder];
        [tfName setReturnKeyType:UIReturnKeyDone];
        [tfName addTarget:self
                action:@selector(tfNameFinished:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
        [belowBackgroundLabel addSubview:tfName];
    
        
        baseYCordinate = baseYCordinate+25;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line.png"];
        imgLine2.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine2];
        
        //Display Location - PY 291113
        expandedLblText = [[UILabel alloc]init];
        [expandedLblText setBackgroundColor:[UIColor clearColor]];
        expandedLblText.text = @"Located at";
        expandedLblText.textColor = [UIColor whiteColor];
        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
        baseYCordinate = baseYCordinate+5;
        expandedLblText.frame = CGRectMake(10,baseYCordinate,100,30);
        [belowBackgroundLabel addSubview:expandedLblText];
        
        //baseYCordinate = baseYCordinate+25;
        UITextField *tfLocation = [[UITextField alloc] initWithFrame:CGRectMake(110, baseYCordinate, self.tableView.frame.size.width - 150, 30)];
        tfLocation.text = currentSensor.location;
        tfLocation.textAlignment = NSTextAlignmentRight;
        tfLocation.textColor = [UIColor whiteColor];
        [tfLocation resignFirstResponder];
        tfLocation.delegate = self;
        [tfLocation setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
        [tfLocation addTarget:self action:@selector(tfLocationDidChange:) forControlEvents:UIControlEventEditingChanged];
         tfLocation.tag = indexPathRow;
        [tfLocation setReturnKeyType:UIReturnKeyDone];
        [tfLocation addTarget:self
                   action:@selector(tfLocationFinished:)
         forControlEvents:UIControlEventEditingDidEndOnExit];
        [belowBackgroundLabel addSubview:tfLocation];
        
        baseYCordinate = baseYCordinate+25;
        UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine3.image = [UIImage imageNamed:@"line.png"];
        imgLine3.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine3];
        
        baseYCordinate = baseYCordinate+10;
        UIButton *btnSave = [[UIButton alloc]init];
        btnSave.backgroundColor = [UIColor whiteColor];
        [btnSave addTarget:self
                   action:@selector(saveSensorData:)
         forControlEvents:UIControlEventTouchDown];
        [btnSave setTitle:@"Save" forState:UIControlStateNormal];
        [btnSave setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
        [btnSave.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
        btnSave.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate, 65,30);
        btnSave.tag = indexPathRow;
        [belowBackgroundLabel addSubview:btnSave];
        
        
        belowBackgroundLabel.frame = CGRectMake(10,86,(LEFT_LABEL_WIDTH)+(self.tableView.frame.size.width-LEFT_LABEL_WIDTH-25)+1,expandedRowHeight-SENSOR_ROW_HEIGHT);
        [cell addSubview:belowBackgroundLabel];
        
        
    }
    [cell addSubview:imgSettings];
    
    return cell;
    
}


#pragma mark - Class Methods



- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)revealTab:(id)sender
{
    //    // NSLog(@"Reveal Tab: Sensor View");
    //    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
    //    [self.slidingViewController resetTopView];
    //    }];
    
    if(!isSliderExpanded){
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    // NSLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}
-(void)initiliazeImages{
    int currentDeviceType;
    NSMutableArray *currentKnownValues;
    SFIDeviceKnownValues *currentDeviceValue;
    NSString *currentValue;
    NSString *currentDeviceTypeName;
    int deviceValueID;
    int currentDeviceId;
    BOOL isImpFlagSet = FALSE;
    for(SFIDevice *currentSensor in self.deviceList){
        isImpFlagSet = FALSE;
        currentDeviceType = currentSensor.deviceType;
        currentDeviceId = currentSensor.deviceID;
        // NSLog(@"Device Type: %d", currentDeviceType);
        for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
            deviceValueID = currentDeviceValue.deviceID;
            if(currentDeviceId == deviceValueID){
                // //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
                currentKnownValues = currentDeviceValue.knownValues;
                break;
            }
        }
        switch (currentDeviceType) {
            case 1:
                currentDeviceValue = [currentKnownValues objectAtIndex:0];
                currentValue = currentDeviceValue.value;
                // NSLog(@"Case1 : Device Value: %@", currentValue);
                if([currentValue isEqualToString:@"true"]){
                    currentSensor.imageName = DT1_BINARY_SWITCH_TRUE;
                }else if([currentValue isEqualToString:@"false"]){
                    currentSensor.imageName = DT1_BINARY_SWITCH_FALSE;
                }else{
                    currentSensor.imageName = @"Reload_icon.png";
                }
                break;
            case 2:
                //Multilevel switch
                // NSLog(@"Case2 : Device Value Count %d", [currentKnownValues count]);
                
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case2 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"SWITCH MULTILEVEL"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"0"]){
                            currentSensor.imageName = DT4_LEVEL_CONTROL_FALSE;
                        }else {
                            currentSensor.imageName = DT4_LEVEL_CONTROL_TRUE;
                        }
                        
                    }
                }
                
//                if([currentKnownValues count] == 0){
//                    currentSensor.imageName = @"Reload_icon.png";
//                }
//                for(int i = 0; i < [currentKnownValues count]; i++){
//                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
//                    currentDeviceTypeName = curDeviceValues.valueName;
//                    currentValue = curDeviceValues.value;
//                    // NSLog(@"Case2 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
//                    if([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]){
//                        currentSensor.stateIndex = i;
//                        
//                        // // NSLog(@"State %@", currentValue);
//                        //                        currentSensor.mostImpValueIndex = i;
//                        //                        currentSensor.mostImpValueName = currentDeviceTypeName;
//                        
//                        if([currentValue isEqualToString:@"true"]){
//                            currentSensor.imageName = DT2_MULTILEVEL_SWITCH_TRUE;
//                        }else if([currentValue isEqualToString:@"false"]){
//                            currentSensor.imageName = DT2_MULTILEVEL_SWITCH_FALSE;
//                        }else{
//                            currentSensor.imageName = @"Reload_icon.png";
//                        }
//                        
//                    }else if ([currentDeviceTypeName isEqualToString:@"SWITCH MULTILEVEL"]){
//                        currentSensor.mostImpValueIndex = i;
//                        currentSensor.mostImpValueName = currentDeviceTypeName;
//                    }
//                }
                break;
            case 3:
                // NSLog(@"Case3 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case3 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"SENSOR BINARY"]){
                        currentSensor.stateIndex = i;
                        
                        // // NSLog(@"State %@", currentValue);
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT3_BINARY_SENSOR_TRUE;
                        }else {
                            currentSensor.imageName = DT3_BINARY_SENSOR_FALSE;
                        }
                        
                    }
                    //                    if([currentDeviceTypeName isEqualToString:TAMPER]){
                    //                        //// NSLog(@"Type: %@ Value: %@", currentDeviceTypeName, currentValue);
                    //                        if([currentValue isEqualToString:@"true"]){
                    //                            //  // NSLog(@"Tamper ON");
                    //                            currentSensor.mostImpValueIndex = i;
                    //                            currentSensor.mostImpValueName = currentDeviceTypeName;
                    //                            currentSensor.imageName = @"door_on_tamper.png";
                    //                            isImpFlagSet = TRUE;
                    //                        }
                    //                    }else if([currentDeviceTypeName isEqualToString:@"LOW BATTERY"]){
                    //                        //// NSLog(@"Type: %@ Value: %@", currentDeviceTypeName, currentValue);
                    //                        if([currentValue isEqualToString:@"1"] &&  !isImpFlagSet){
                    //                            //  // NSLog(@"Battery Low");
                    //                            currentSensor.mostImpValueIndex = i;
                    //                            currentSensor.mostImpValueName = currentDeviceTypeName;
                    //                            currentSensor.imageName = @"door_on_battery.png";
                    //                            isImpFlagSet = TRUE;
                    //                        }
                    //                    }else if([currentDeviceTypeName isEqualToString:@"STATE"]){
                    //                        currentSensor.stateIndex = i;
                    //                        if(!isImpFlagSet){
                    //                            // // NSLog(@"State %@", currentValue);
                    //                            currentSensor.mostImpValueIndex = i;
                    //                            currentSensor.mostImpValueName = currentDeviceTypeName;
                    //
                    //                            if([currentValue isEqualToString:@"true"]){
                    //                                currentSensor.imageName = @"door_on.png";
                    //                            }else {
                    //                                currentSensor.imageName = @"door_off.png";
                    //                            }
                    //                        }
                    //                    }
                }
                //                currentDeviceValue = [currentKnownValues objectAtIndex:0];
                //                currentValue = currentDeviceValue.value;
                //                if([currentValue isEqualToString:@"true"]){
                //                    currentSensor.imageName = @"door_on.png";
                //                }else{
                //                    currentSensor.imageName = @"door_off.png";
                //                }
                break;
            case 4:
                //Level Control
                // NSLog(@"Case4 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case4 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]){
                        currentSensor.stateIndex = i;
                        
                        // // NSLog(@"State %@", currentValue);
                        //                        currentSensor.mostImpValueIndex = i;
                        //                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT2_MULTILEVEL_SWITCH_TRUE;
                        }else if([currentValue isEqualToString:@"false"]){
                            currentSensor.imageName = DT2_MULTILEVEL_SWITCH_FALSE;
                        }else{
                            currentSensor.imageName = @"Reload_icon.png";
                        }
                        
                    }else if ([currentDeviceTypeName isEqualToString:@"SWITCH MULTILEVEL"]){
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                    }
                }
                
                
                break;
            case 5:
                //Door Lock
                // NSLog(@"Case5 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case5 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"DOOR LOCK "]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT5_DOOR_LOCK_TRUE;
                        }else if([currentValue isEqualToString:@"false"]){
                            currentSensor.imageName = DT5_DOOR_LOCK_FALSE;
                        }else{
                            currentSensor.imageName = @"Reload_icon.png";
                        }
                        
                    }
                }
                break;
            case 6:
                //Alarm : TODO Later
                // NSLog(@"Case6 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case6 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"LOCK_STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT6_ALARM_TRUE;
                        }else {
                            currentSensor.imageName = DT6_ALARM_FALSE;
                        }
                        
                    }
                }
                break;
            case 11:
                //Motion Sensor
                // NSLog(@"Case11 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case11 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT11_MOTION_SENSOR_TRUE;
                        }else {
                            currentSensor.imageName = DT11_MOTION_SENSOR_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                        currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;
            case 12:
                //Contact Switch
                // NSLog(@"Case12 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case12 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        
                        // // NSLog(@"State %@", currentValue);
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT12_CONTACT_SWITCH_TRUE;
                        }else {
                            currentSensor.imageName = DT12_CONTACT_SWITCH_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                            
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                        currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;
            case 13:
                //Fire Sensor
                // NSLog(@"Case13 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case13 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT13_FIRE_SENSOR_TRUE;
                        }else {
                            currentSensor.imageName = DT13_FIRE_SENSOR_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                           
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                         currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;
            case 14:
                //Water Sensor
                // NSLog(@"Case14 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case14 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT14_WATER_SENSOR_TRUE;
                        }else {
                            currentSensor.imageName = DT14_WATER_SENSOR_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                            
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                        currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;
            case 15:
                //Gas Sensor
                // NSLog(@"Case15 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case15 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT15_GAS_SENSOR_TRUE;
                        }else {
                            currentSensor.imageName = DT15_GAS_SENSOR_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                            
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                        currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;

            case 17:
                //Vibration Sensor
                // NSLog(@"Case17 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case17 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT17_VIBRATION_SENSOR_TRUE;
                        }else {
                            currentSensor.imageName = DT17_VIBRATION_SENSOR_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                            
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                        currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;
            case 19:
                //Keyfob
                // NSLog(@"Case19 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case19 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"STATE"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT19_KEYFOB_TRUE;
                        }else {
                            currentSensor.imageName = DT19_KEYFOB_FALSE;
                        }
                        
                    }
                    //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isTampered = TRUE;
                            
                        }else{
                            currentSensor.isTampered = FALSE;
                        }
                        currentSensor.tamperValueIndex = i;
                    }
                    //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]){
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.isBatteryLow = TRUE;
                        }else{
                            currentSensor.isBatteryLow = FALSE;
                        }
                    }
                }
                break;
            case 22:
                //Electric Measurement switch - AC
                // NSLog(@"Case22 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case22 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]){
                        currentSensor.stateIndex = i;
                        
                        // // NSLog(@"State %@", currentValue);
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT22_AC_SWITCH_TRUE;
                        }else if([currentValue isEqualToString:@"false"]){
                            currentSensor.imageName = DT22_AC_SWITCH_FALSE;
                        }else{
                            currentSensor.imageName = @"Reload_icon.png";
                        }
                        
                    }
                }
                break;
            case 23:
                //Electric Measurement switch - DC
                // NSLog(@"Case23 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case23 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT23_DC_SWITCH_TRUE;
                        }else if([currentValue isEqualToString:@"false"]){
                            currentSensor.imageName = DT23_DC_SWITCH_FALSE;
                        }else{
                            currentSensor.imageName = @"Reload_icon.png";
                        }
                        
                    }
                }
                break;
            case 34:
                //Shade
                // NSLog(@"Case34 : Device Value Count %d", [currentKnownValues count]);
                if([currentKnownValues count] == 0){
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for(int i = 0; i < [currentKnownValues count]; i++){
                    SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case34 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]){
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        
                        if([currentValue isEqualToString:@"true"]){
                            currentSensor.imageName = DT34_SHADE_TRUE;
                        }else if([currentValue isEqualToString:@"false"]){
                            currentSensor.imageName = DT34_SHADE_FALSE;
                        }else{
                            currentSensor.imageName = @"Reload_icon.png";
                        }
                        
                    }
                }
                break;
            default:
                currentSensor.imageName = @"default_device.png";
                break;
        }
    }
}

-(void)onSettingClicked:(id)sender {
    //// NSLog(@"%@", [gestureRecognizer view]);
    UIButton *btn = (UIButton*) sender;
    
    //    if(self.checkHeight == btn.tag){
    //        // NSLog(@"Clicked Again");
    //        self.checkHeight = -1;
    //        //[self.sensorTableView reloadData];
    //    }else{
    //        self.checkHeight = btn.tag;
    // NSLog(@"Settings Index Clicked: %ld", (long)btn.tag);
    //    }
    //
    //
    //  NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    //  NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    //    changeBrightness = 98;
    //    [self.sensorTableView reloadData];
    
    //Get the sensor for which setting was clicked
    SFIDevice *currentSensor = [self.deviceList objectAtIndex:btn.tag];
    if(!currentSensor.isExpanded){
        //Expand it
        //Remove the long press for reordering when expanded sensor has slider
        //Device type 2 - 4 - 7
        switch (currentSensor.deviceType) {
            case 2:
            case 4:
            case 7:
                isSliderExpanded = TRUE;
                self.sensorTable.canReorder = FALSE;
                break;
                
            default:
                break;
        }
//        if(currentSensor.deviceType == 2){
//            isSliderExpanded = TRUE;
//            self.sensorTable.canReorder = FALSE;
//        }
        currentSensor.isExpanded = TRUE;
    }else{
        //Enable the long press for reordering
        //Device type 2 - 4 - 7
        switch (currentSensor.deviceType) {
            case 2:
            case 4:
            case 7:
                isSliderExpanded = FALSE;
                self.sensorTable.canReorder = TRUE;
                break;
                
            default:
                break;
        }
        
//        if(currentSensor.deviceType == 2){
//            isSliderExpanded = FALSE;
//            self.sensorTable.canReorder = TRUE;
//        }
        currentSensor.isExpanded = FALSE;
    }
     NSLog(@"Current Type: %d", currentSensor.deviceType);
    [self.tableView reloadData];
    // [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:FALSE];
    
}

-(void) onAddAlmondClicked:(id) sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView {
//    [[self view] endEditing:YES];
//}


-(void)dismissTamper:(id)sender {
    // NSLog(@"Dismiss Tamper");
    UIButton *btn = (UIButton*) sender;
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:btn.tag];
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    SFIDeviceKnownValues *currentDeviceValue;
    currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.tamperValueIndex];
    currentDeviceValue.value = @"false";
    self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
    self.currentIndexID = currentDeviceValue.index;
    self.currentValue = currentDeviceValue.value;
    [self sendMobileCommand];

}


-(void)onDeviceClicked:(id)sender {
    //// NSLog(@"%@", [gestureRecognizer view]);
    UIButton *btn = (UIButton*) sender;
    
    [SNLog Log:@"Method Name: %s Device Clicked: TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent()];
    
    // NSLog(@"Device Index Clicked: %ld", (long)btn.tag);
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:btn.tag];
    int currentDeviceType = currentSensor.deviceType;
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //[SNLog Log:@"Method Name: %s ID Match: Selected currentDeviceType is @%d", __PRETTY_FUNCTION__,currentDeviceType];
    
    SFIDeviceKnownValues *currentDeviceValue;
    NSString *currentValue;
    NSString * mostImpIndexName;
    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = [currentKnownValues objectAtIndex:0];
            currentValue = currentDeviceValue.value;
            currentDeviceValue.isUpdating = true;
            if([currentValue isEqualToString:@"true"]){
                // NSLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                //currentSensor.imageName = @"switch_off.png";
                //imgDevice.image = [UIImage imageNamed:@"bulb_on.png"];
                self.currentValue = @"false";
            }else if([currentValue isEqualToString:@"false"]){
                // NSLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                //currentSensor.imageName = @"switch_on.png";
                //imgDevice.frame = CGRectMake(35, 25, 27,42);
                //imgDevice.image = [UIImage imageNamed:@"bulb_off.png"];
                self.currentValue = @"true";
            }else{
                return;
            }
            //currentDeviceValue.value = @"Updating sensor data.\nPlease wait.";
            
            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = 1;
            
            [self sendMobileCommand];
            [self.tableView reloadData];
            break;
        case 2:
            //Multilevel switch
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
            currentValue = currentDeviceValue.value;
            //Do not wait for response from Cloud
            currentDeviceValue.isUpdating = true;
            if([currentValue isEqualToString:@"0"]){
                // NSLog(@"Change to ON - Set value as 99");
                currentDeviceValue.value = @"99";
                self.currentValue = @"99";
            }else{
                // NSLog(@"Change to OFF - Set value as 0");
                currentDeviceValue.value = @"0";
                self.currentValue = @"0";
            }
//            }else if([currentValue isEqualToString:@"false"]){
//                // NSLog(@"Change to ON");
//                currentDeviceValue.value = @"true";
//                self.currentValue = @"true";
//            }
//            else{
//                return;
//            }
            
            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // NSLog(@"Index ID %d", self.currentIndexID);
            [self sendMobileCommand];
            [self.tableView reloadData];
            break;
        case 3:
            //Sensor
            mostImpIndexName = currentSensor.mostImpValueName;
            if([mostImpIndexName isEqualToString:TAMPER]){
                currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
                //Do not wait for response from Cloud
                currentDeviceValue.value = @"false";
                //currentDeviceValue.value = @"Updating sensor data. Please wait.";
                self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
                self.currentIndexID = currentDeviceValue.index;
                self.currentValue = currentDeviceValue.value;
                [self sendMobileCommand];
                [self initiliazeImages];
                // [[self view] endEditing:YES];
                [self.tableView reloadData];
            }
            //imgDevice.frame = CGRectMake(25, 20, 40.5,60);
            //imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;
        case 4:
            //Level Control
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentValue = currentDeviceValue.value;
            //Do not wait for response from Cloud
            currentDeviceValue.isUpdating = true;
            if([currentValue isEqualToString:@"true"]){
                // NSLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                self.currentValue = @"false";
            }else if([currentValue isEqualToString:@"false"]){
                // NSLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                self.currentValue = @"true";
            }else{
                return;
            }
            
            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // NSLog(@"Index ID %d", self.currentIndexID);
            [self sendMobileCommand];
            [self.tableView reloadData];
            break;

        case 22:
            //Sensor
            //            mostImpIndexName = currentSensor.mostImpValueName;
            //            if([mostImpIndexName isEqualToString:TAMPER]){
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentValue = currentDeviceValue.value;
            //Do not wait for response from Cloud
            currentDeviceValue.isUpdating = true;
            if([currentValue isEqualToString:@"true"]){
                // NSLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                self.currentValue = @"false";
            }else if([currentValue isEqualToString:@"false"]){
                // NSLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                self.currentValue = @"true";
            }else{
                return;
            }
            
            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // NSLog(@"Index ID %d", self.currentIndexID);
            [self sendMobileCommand];
            // [[self view] endEditing:YES];
            [self.tableView reloadData];
            
            //            }
            //imgDevice.frame = CGRectMake(25, 20, 40.5,60);
            //imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;
        default:
            //imgDevice.frame = CGRectMake(25, 20, 50,50);
            //imgDevice.image = [UIImage imageNamed:@"dimmer.png"];
            //imgDevice.frame = CGRectMake(25, 12.5, 53,60);
            //imgDevice.image = [UIImage imageNamed:@"door_tamper.png"];
            break;
    }
    
    
}



-(void)onAddDeviceClicked:(id)sender {
    // NSLog(@"Add Device action");
}






-(void) refreshDataForAlmond{
    if([self.currentMAC isEqualToString:NO_ALMOND]){
        return;
    }
    self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
    self.offlineHash = [SFIOfflineDataManager readHashList:self.currentMAC];
    //Call command : Get HASH - Command 74 - Match if list is upto date
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading sensor data.";
    [self getDeviceHash];
    
    //PY 311013 - Timeout for Sensor Command
    sensorDataCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                              target:self
                                                            selector:@selector(cancelSensorCommand:)
                                                            userInfo:nil
                                                             repeats:NO];
    
    [self initiliazeImages];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    
    listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    currentColor = [listAvailableColors objectAtIndex:0];
    
    baseBrightness = currentColor.brightness;
    changeHue = currentColor.hue;
    changeSaturation = currentColor.saturation;
}

#pragma mark - Sliding controls
- (void)sliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    // NSLog(@"Send mobile command - Tapped");
    UISlider* slider = (UISlider*)gestureRecognizer.view;
    if (slider.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint pt = [gestureRecognizer locationInView: slider];
    CGFloat percentage = pt.x / slider.bounds.size.width;
    CGFloat delta = percentage * (slider.maximumValue - slider.minimumValue);
    CGFloat value = slider.minimumValue + delta;
    // NSLog(@"Tapped Value: %f", value);
    // NSLog(@"Device Index Clicked: %ld", (long)slider.tag);
    [slider setValue:value animated:YES];
    
    //Send value to cloud
    int sliderValue=(int)value;
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:slider.tag];
    //int currentDeviceType = currentSensor.deviceType;
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //[SNLog Log:@"Method Name: %s ID Match: Selected currentDeviceType is @%d", __PRETTY_FUNCTION__,currentDeviceType];
    
    SFIDeviceKnownValues *currentDeviceValue;
    NSString * mostImpIndexName;
    
    mostImpIndexName = currentSensor.mostImpValueName;
    if([mostImpIndexName isEqualToString:@"SWITCH MULTILEVEL"]){
        currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
        //Do not wait for response from Cloud
        currentDeviceValue.value = [NSString stringWithFormat:@"%d",sliderValue];
        self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
        self.currentIndexID = currentDeviceValue.index;
        self.currentValue = currentDeviceValue.value;
        [self sendMobileCommand];
        [self initiliazeImages];
        //  [[self view] endEditing:YES];
        [self.tableView reloadData];
    }
}


- (IBAction)sliderDidEndSliding:(id)sender {
    // NSLog(@"Send mobile command");
    UISlider *slider=(UISlider *)sender;
    int sliderValue=(int)(slider.value);
    // NSLog(@"sliderValue = %d",sliderValue);
    
    // NSLog(@"Device Index Clicked: %ld", (long)slider.tag);
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:slider.tag];
    //int currentDeviceType = currentSensor.deviceType;
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //[SNLog Log:@"Method Name: %s ID Match: Selected currentDeviceType is @%d", __PRETTY_FUNCTION__,currentDeviceType];
    
    SFIDeviceKnownValues *currentDeviceValue;
    NSString * mostImpIndexName;
    
    mostImpIndexName = currentSensor.mostImpValueName;
    if([mostImpIndexName isEqualToString:@"SWITCH MULTILEVEL"]){
        currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
        //Do not wait for response from Cloud
        currentDeviceValue.value = [NSString stringWithFormat:@"%d",sliderValue];
        self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
        self.currentIndexID = currentDeviceValue.index;
        self.currentValue = currentDeviceValue.value;
        [self sendMobileCommand];
        [self initiliazeImages];
        // [[self view] endEditing:YES];
        [self.tableView reloadData];
    }
}

- (void)coolingSliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    // NSLog(@"Send mobile command - Tapped");
    UISlider* slider = (UISlider*)gestureRecognizer.view;
    if (slider.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint pt = [gestureRecognizer locationInView: slider];
    CGFloat percentage = pt.x / slider.bounds.size.width;
    CGFloat delta = percentage * (slider.maximumValue - slider.minimumValue);
    CGFloat value = slider.minimumValue + delta;
    // NSLog(@"Tapped Value: %f", value);
    // NSLog(@"Device Index Clicked: %ld", (long)slider.tag);
    [slider setValue:value animated:YES];
    
    //Send value to cloud
    int sliderValue=(int)value;
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:slider.tag];
    //int currentDeviceType = currentSensor.deviceType;
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //Change value locally and send mobile command
    for(SFIDeviceKnownValues *currentDeviceValue in currentKnownValues){
        if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]){
            //Do not wait for response from Cloud
            currentDeviceValue.value = [NSString stringWithFormat:@"%d",sliderValue];
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            self.currentValue = currentDeviceValue.value;
            [self sendMobileCommand];
            [self initiliazeImages];
            [self.tableView reloadData];
            break;
        }
    }
}


- (IBAction)coolingSliderDidEndSliding:(id)sender {
    // NSLog(@"Send mobile command");
    UISlider *slider=(UISlider *)sender;
    int sliderValue=(int)(slider.value);
    // NSLog(@"sliderValue = %d",sliderValue);
    
    // NSLog(@"Device Index Clicked: %ld", (long)slider.tag);
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:slider.tag];
    //int currentDeviceType = currentSensor.deviceType;
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //Change value locally and send mobile command
    for(SFIDeviceKnownValues *currentDeviceValue in currentKnownValues){
        if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]){
            //Do not wait for response from Cloud
            currentDeviceValue.value = [NSString stringWithFormat:@"%d",sliderValue];
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            self.currentValue = currentDeviceValue.value;
            [self sendMobileCommand];
            [self initiliazeImages];
            [self.tableView reloadData];
            break;
        }
    }

}


- (void)heatingSliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    // NSLog(@"Send mobile command - Tapped");
    UISlider* slider = (UISlider*)gestureRecognizer.view;
    if (slider.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint pt = [gestureRecognizer locationInView: slider];
    CGFloat percentage = pt.x / slider.bounds.size.width;
    CGFloat delta = percentage * (slider.maximumValue - slider.minimumValue);
    CGFloat value = slider.minimumValue + delta;
    // NSLog(@"Tapped Value: %f", value);
    // NSLog(@"Device Index Clicked: %ld", (long)slider.tag);
    [slider setValue:value animated:YES];
    
    //Send value to cloud
    int sliderValue=(int)value;
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:slider.tag];
    //int currentDeviceType = currentSensor.deviceType;
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //Change value locally and send mobile command
    for(SFIDeviceKnownValues *currentDeviceValue in currentKnownValues){
        if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]){
            //Do not wait for response from Cloud
            currentDeviceValue.value = [NSString stringWithFormat:@"%d",sliderValue];
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            self.currentValue = currentDeviceValue.value;
            [self sendMobileCommand];
            [self initiliazeImages];
            [self.tableView reloadData];
            break;
        }
    }
}


- (IBAction)heatingSliderDidEndSliding:(id)sender {
    // NSLog(@"Send mobile command");
    UISlider *slider=(UISlider *)sender;
    int sliderValue=(int)(slider.value);
    // NSLog(@"sliderValue = %d",sliderValue);
    
    // NSLog(@"Device Index Clicked: %ld", (long)slider.tag);
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:slider.tag];
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //Change value locally and send mobile command
    for(SFIDeviceKnownValues *currentDeviceValue in currentKnownValues){
        if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]){
            //Do not wait for response from Cloud
            currentDeviceValue.value = [NSString stringWithFormat:@"%d",sliderValue];
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            self.currentValue = currentDeviceValue.value;
            [self sendMobileCommand];
            [self initiliazeImages];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - Segment Control Method
-(void)modeSelected:(id)sender{
   UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
   NSString *strModeValue = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
   NSLog(@"Mode Selected title %@",strModeValue);

    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:segmentedControl.tag];
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //Change value locally and send mobile command
    for(SFIDeviceKnownValues *currentDeviceValue in currentKnownValues){
        if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT MODE"]){
            //Do not wait for response from Cloud
            currentDeviceValue.value = strModeValue;
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            self.currentValue = currentDeviceValue.value;
            [self sendMobileCommand];
            [self initiliazeImages];
            [self.tableView reloadData];
            break;
        }
    }
}

-(void)fanModeSelected:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *strFanModeValue = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    NSLog(@"Fan Mode Selected title %@",strFanModeValue);
    
    int deviceValueID;
    int currentDeviceId;
    NSMutableArray *currentKnownValues;
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:segmentedControl.tag];
    currentDeviceId = currentSensor.deviceID;
    for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if(currentDeviceId == deviceValueID){
            //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            currentKnownValues = currentDeviceValue.knownValues;
            break;
        }
    }
    
    //Change value locally and send mobile command
    for(SFIDeviceKnownValues *currentDeviceValue in currentKnownValues){
        if([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN MODE"]){
            //Do not wait for response from Cloud
            currentDeviceValue.value = strFanModeValue;
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            self.currentValue = currentDeviceValue.value;
            [self sendMobileCommand];
            [self initiliazeImages];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - Keyboard methods

-(BOOL) textFieldShouldReturn: (UITextField *) textField{
    //[[self view] endEditing:YES];
    // NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

-(void)tfNameDidChange:(UITextField *)tfName{
    NSLog(@"tfName for device: %ld Value: %@", (long)tfName.tag, tfName.text);
    self.currentChangedName = tfName.text;
    
}

-(void)tfLocationDidChange:(UITextField *)tfLocation{
    NSLog(@"tfLocation for device: %ld Value: %@", (long)tfLocation.tag, tfLocation.text);
    self.currentChangedLocation = tfLocation.text;
    
}

-(void)tfNameFinished:(UITextField *)tfName{
    NSLog(@"tfName for device: %ld Value: %@", (long)tfName.tag, tfName.text);
    self.currentChangedName = tfName.text;
    [tfName resignFirstResponder];
}


-(void)tfLocationFinished:(UITextField *)tfLocation{
    NSLog(@"tfLocation for device: %ld Value: %@", (long)tfLocation.tag, tfLocation.text);
    self.currentChangedLocation = tfLocation.text;
    [tfLocation resignFirstResponder];
}

#pragma mark - Cloud Commands and Handlers
-(void)getDeviceHash{
    if([self.currentMAC isEqualToString:NO_ALMOND]){
        [HUD hide:YES];
        return;
    }
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    DeviceDataHashRequest *deviceHashCommand = [[DeviceDataHashRequest alloc] init];
    deviceHashCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICEDATA_HASH;
    cloudCommand.command=deviceHashCommand;
    @try {
        //[SNLog Log:@"Method Name: %s Before Writing to socket -- DeviceHash Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            //[SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        //[SNLog Log:@"Method Name: %s After Writing to socket -- DeviceHash Command", __PRETTY_FUNCTION__];
        
    }
    @catch (NSException *exception) {
        //[SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    deviceHashCommand=nil;
    
}

-(void)HashResponseCallback:(id)sender
{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received Device Hash response", __PRETTY_FUNCTION__];
        
        NSString *currentHash;
        
        DeviceDataHashResponse *obj = [[DeviceDataHashResponse alloc] init];
        obj = (DeviceDataHashResponse *)[data valueForKey:@"data"];
        
        if(obj.isSuccessful){
            //Hash Present
            currentHash = obj.almondHash;
            //[SNLog Log:@"Method Name: %s Current Hash ==> @%@ Offline Hash ==> @%@",__PRETTY_FUNCTION__,currentHash, self.offlineHash];
            if(![currentHash isEqualToString:@""] && currentHash!=nil){
                if(![currentHash isEqualToString:@"null"]){
                    if([currentHash isEqualToString:self.offlineHash]){
                        //[SNLog Log:@"Method Name: %s Hash Match: Get Device Values", __PRETTY_FUNCTION__];
                        //Get Device Values
                        [self loadDeviceValue];
                        
                        
                    }else{
                        //[SNLog Log:@"Method Name: %s Hash MisMatch: Get Device Values", __PRETTY_FUNCTION__];
                        //Save hash in file for each almond
                        [SFIOfflineDataManager writeHashList:currentHash currentMAC:self.currentMAC];
                        //Get Device List
                        [self loadDeviceList];
                        
                    }
                }
                else{
                    
                    //Hash sent by cloud as null - No Device
                    HUD.hidden = YES;
                    
                    //Open next activity with blank view
                    //                    [HUD hide:YES];
                    //                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                    //                    SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
                    //                    //Remove later - when stored in file
                    //                    // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
                    //                    //                    deviceListView.deviceList = self.deviceList;
                    //                    //                    deviceListView.deviceValueList = self.deviceValueList;
                    //                    [self.navigationController pushViewController:deviceListView animated:YES];
                }
            }
            else{
                //No Hash from cloud
                HUD.hidden = YES;
                //Open next activity with blank view
                //                [HUD hide:YES];
                //                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                //                SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
                //                //Remove later - when stored in file
                //                // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
                //                //                deviceListView.deviceList = self.deviceList;
                //                //                deviceListView.deviceValueList = self.deviceValueList;
                //                [self.navigationController pushViewController:deviceListView animated:YES];
            }
        }else{
            //success = false
            NSString *reason = obj.reason;
            [SNLog Log:@"Method Name: %s Hash Not Found Reason: @%@", __PRETTY_FUNCTION__,reason];
        }
        
    }
}

-(void)loadDeviceList{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    DeviceListRequest *deviceListCommand = [[DeviceListRequest alloc] init];
    deviceListCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICEDATA;
    cloudCommand.command=deviceListCommand;
    @try {
        //[SNLog Log:@"Method Name: %s Before Writing to socket -- Device List Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            //[SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        //[SNLog Log:@"Method Name: %s After Writing to socket -- Device List Command", __PRETTY_FUNCTION__];
        
    }
    @catch (NSException *exception) {
        //[SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    deviceListCommand=nil;
    
}

-(void)DeviceListResponseCallback:(id)sender
{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received Device List response", __PRETTY_FUNCTION__];
        
        DeviceListResponse *obj = [[DeviceListResponse alloc] init];
        obj = (DeviceListResponse *)[data valueForKey:@"data"];
        
        self.deviceList= [[NSMutableArray alloc]init];
        //[SNLog Log:@"Method Name: %s List size : %d",__PRETTY_FUNCTION__,[obj.deviceList count]];
        self.deviceList = obj.deviceList;
        
        //Write offline
        [SFIOfflineDataManager writeDeviceList:self.deviceList currentMAC:self.currentMAC];
        //If count of devicelist is == 0, donot get device value
        //HUD.hidden = YES;
        if([self.deviceList count] == 0){
            return;
        }
        //Get Device Value
        [self loadDeviceValue];
    }
    
}

-(void)loadDeviceValue{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    DeviceValueRequest *deviceValueListCommand = [[DeviceValueRequest alloc] init];
    deviceValueListCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICE_VALUE;
    cloudCommand.command=deviceValueListCommand;
    @try {
        
        //[SNLog Log:@"Method Name: %s Before Writing to socket -- Device Value Command", __PRETTY_FUNCTION__];
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            //[SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        //[SNLog Log:@"Method Name: %s After Writing to socket -- Device Value Command", __PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
        //[SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    deviceValueListCommand=nil;
    
}

-(void)DeviceValueListResponseCallback:(id)sender
{
    HUD.hidden = YES;
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received Device Value List response", __PRETTY_FUNCTION__];
        
        DeviceValueResponse *obj = [[DeviceValueResponse alloc] init];
        obj = (DeviceValueResponse *)[data valueForKey:@"data"];
        
        self.deviceValueList= [[NSMutableArray alloc]init];
        //[SNLog Log:@"Method Name: %s List size : %d",__PRETTY_FUNCTION__,[obj.deviceValueList count]];
        self.deviceValueList = obj.deviceValueList;
        
        //Write offline
        [SFIOfflineDataManager writeDeviceValueList:self.deviceValueList currentMAC:self.currentMAC];
        
        //Reload table
        [self initiliazeImages];
        // [[self view] endEditing:YES];
        //To remove text fields keyboard. It was throwing error when it was being called from the background thread
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];
        
        
        //TODO: If count of devicevaluelist is < 0, display a message
        
        //        //Display next screen
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        //        SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
        //        [self.navigationController pushViewController:deviceListView animated:YES];
    }
    
}


-(void)sendMobileCommand{
    //[SNLog Log:@"Method Name: %s sendMobileCommand", __PRETTY_FUNCTION__];
    
    
    //Generate internal index between 1 to 100
    self.currentInternalIndex = (arc4random() % 100) + 1;
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    MobileCommandRequest *mobileCommand = [[MobileCommandRequest alloc] init];
    mobileCommand.almondMAC = self.currentMAC;
    mobileCommand.deviceID = self.currentDeviceID;
    mobileCommand.indexID = [NSString stringWithFormat:@"%d",self.currentIndexID];
    mobileCommand.changedValue = self.currentValue;
    mobileCommand.internalIndex = [NSString stringWithFormat:@"%d",self.currentInternalIndex];
    
    cloudCommand.commandType=MOBILE_COMMAND;
    cloudCommand.command=mobileCommand;
    @try {
        //[SNLog Log:@"Method Name: %s Before Writing to socket -- MobileCommandRequest Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            //[SNLog Log:@"Method Name: %s Main APP Error %@",__PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        //[SNLog Log:@"Method Name: %s After Writing to socket -- MobileCommandRequest Command",__PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
        //[SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    //PY 311013 - Timeout for Mobile Command
    mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                          target:self
                                                        selector:@selector(cancelMobileCommand:)
                                                        userInfo:nil
                                                         repeats:NO];
    isMobileCommandSuccessful = FALSE;
    
    cloudCommand=nil;
    mobileCommand=nil;
    
}

//PY 311013 - Timeout for Mobile Command
-(void)cancelMobileCommand:(id)sender{
    [mobileCommandTimer invalidate];
    //// NSLog(@"cancelMobileCommand %@", isMobileCommandSuccessful);
    if(!isMobileCommandSuccessful){
        //Cancel the mobile event - Revert back
        //// NSLog(@"Change the state back");
        self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
        [self initiliazeImages];
        // [[self view] endEditing:YES];
        [self.tableView reloadData];
    }
}

//PY 311013 - Timeout for loading sensor data Command
-(void)cancelSensorCommand:(id)sender{
    [sensorDataCommandTimer invalidate];
    [HUD hide:YES];
}

-(void)MobileCommandResponseCallback:(id)sender
{
    //PY 311013 - Timeout for Mobile Command
    [mobileCommandTimer invalidate];
    isMobileCommandSuccessful = TRUE;
    
    //[SNLog Log:@"Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received MobileCommandResponse",__PRETTY_FUNCTION__];
        
        MobileCommandResponse *obj = [[MobileCommandResponse alloc] init];
        obj = (MobileCommandResponse *)[data valueForKey:@"data"];
        
        BOOL isSuccessful = obj.isSuccessful;
        if(isSuccessful){
            //Command updated values
            //update offline storage
            NSMutableArray *mobileDeviceValueList;
            mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            int deviceValueID;
            NSMutableArray *currentKnownValues;
            
            for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
                deviceValueID = currentDeviceValue.deviceID;
                if([self.currentDeviceID integerValue] == deviceValueID){
                    // //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
                    currentKnownValues = currentDeviceValue.knownValues;
                }
            }
            
            
            //To save on the offline list
            //[SNLog Log:@"Method Name: %s Update Offline List before 82 triggers", __PRETTY_FUNCTION__];
            NSMutableArray * mobileDeviceKnownValues;
            if(mobileDeviceValueList!=nil)
            {
                for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList){
                    //[SNLog Log:@"Method Name: %s Mobile DeviceID: %d" , __PRETTY_FUNCTION__,currentMobileValue.deviceID];
                    if(currentMobileValue.deviceID == [self.currentDeviceID integerValue]){
                        //[SNLog Log:@"Method Name: %s Device found in list: %@" , __PRETTY_FUNCTION__,self.currentDeviceID];
                        mobileDeviceKnownValues = currentMobileValue.knownValues;
                        for(SFIDeviceKnownValues *currentMobileKnownValue in mobileDeviceKnownValues){
                            //[SNLog Log:@"Method Name: %s Mobile Device Known Value Index: %d" , __PRETTY_FUNCTION__,currentMobileKnownValue.index];
                            
                            for(SFIDeviceKnownValues *currentLocalKnownValue in currentKnownValues){
                                //[SNLog Log:@"Method Name: %s Activity Local Device Known Value Index: %d " , __PRETTY_FUNCTION__,currentLocalKnownValue.index];
                                if(currentMobileKnownValue.index == currentLocalKnownValue.index){
                                    //Update Value
                                    //[SNLog Log:@"Method Name: %s BEFORE update => Cloud: %@ Mobile: %@" , __PRETTY_FUNCTION__,currentLocalKnownValue.value , currentMobileKnownValue.value];
                                    [currentMobileKnownValue setValue:currentLocalKnownValue.value];
                                    //[SNLog Log:@"Method Name: %s AFTER update => Cloud: %@ Mobile: %@" , __PRETTY_FUNCTION__,currentLocalKnownValue.value , currentMobileKnownValue.value];
                                    currentMobileKnownValue.isUpdating = false;
                                    break;
                                }
                            }
                        }
                        [currentMobileValue setKnownValues:mobileDeviceKnownValues];
                    }
                    
                }
                //Write to local database
                [SFIOfflineDataManager writeDeviceValueList:mobileDeviceValueList currentMAC:self.currentMAC];
            }else{
                //[SNLog Log:@"Method Name: %s Error in retreiving device list", __PRETTY_FUNCTION__];
            }
            
        }else{
            //TODO: Display message
            // NSLog(@"Reason: %@", obj.reason);
        }
        
    }
    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
    [self initiliazeImages];
    // [[self view] endEditing:YES];
    //To remove text fields keyboard. It was throwing error when it was being called from the background thread
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
    [SNLog Log:@"Method Name: %s Response on UI: TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent()];
    
}

-(void)DeviceDataCloudResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        DeviceListResponse *obj = [[DeviceListResponse alloc] init];
        obj = (DeviceListResponse *)[data valueForKey:@"data"];
        BOOL isCurrentMAC = FALSE;
        NSString *cloudMAC = obj.almondMAC;
        [SNLog Log:@"Method Name: %s Current MAC ==> @%@ Cloud MAC ==> @%@ DEVICE DATA LIST SIZE: ",__PRETTY_FUNCTION__,currentMAC, cloudMAC, [obj.deviceList count]];
        if([cloudMAC isEqualToString:self.currentMAC]){
            
            //Save isExpanded
            for(SFIDevice *currentCloudDevice in obj.deviceList){
                //[SNLog Log:@"Method Name: %s Cloud DeviceID: %d" , __PRETTY_FUNCTION__,currentCloudDevice.deviceID];
                for(SFIDevice *currentMobileDevice in self.deviceList){
                    //[SNLog Log:@"Method Name: %s Mobile DeviceID: %d" , __PRETTY_FUNCTION__,currentMobileDevice.deviceID];
                    if(currentCloudDevice.deviceID == currentMobileDevice.deviceID){
                        //[SNLog Log:@"Method Name: %s Device ID Match - Update isExpanded" , __PRETTY_FUNCTION__];
                        currentCloudDevice.isExpanded = currentMobileDevice.isExpanded;
                    }
                }
            }
            
            //self.deviceList = obj.deviceList;
            //            if([self.deviceList count] == 0){
            //                self.isEmpty = TRUE;
            //            }else{
            //                self.isEmpty = FALSE;
            //            }
            isCurrentMAC = TRUE;
            [SFIOfflineDataManager writeDeviceList:obj.deviceList currentMAC:self.currentMAC];
            
        }
        
        //TODO: get only hash and update it
        //[self getDeviceHash];
        
        //Run in background
        //        dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
        //        dispatch_async(queue, ^{
        //            [self getDeviceHash];
        //        });
        
        //Update UI
        if(isCurrentMAC){
            self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
            
            //Compare the list with device value list size and correct the list accordingly if any device was deleted
            //Compare the size
            if([self.deviceList count] < [self.deviceValueList count]){
                // NSLog(@"Sensor View: Some device was deleted!");
                //Reload Device Value List which was updated by Offline Data Manager
                self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            }
            
            [self initiliazeImages];
            // [[self view] endEditing:YES];
            //To remove text fields keyboard. It was throwing error when it was being called from the background thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:NO];
        }
        
    }
}

-(void)DeviceCloudValueListResponseCallback:(id)sender
{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received DeviceValueListResponse",__PRETTY_FUNCTION__];
        
        DeviceValueResponse *obj = [[DeviceValueResponse alloc] init];
        obj = (DeviceValueResponse *)[data valueForKey:@"data"];
        
        
        BOOL isCurrentMAC = FALSE;
        BOOL isDeviceValueChanged = FALSE;
        NSString *cloudMAC = obj.almondMAC;
        //[SNLog Log:@"Method Name: %s Update Offline Storage - Sensor DEVICE VALUE LIST SIZE: %d",__PRETTY_FUNCTION__, [obj.deviceValueList count]];
        
        if([cloudMAC isEqualToString:self.currentMAC]){
            
            isCurrentMAC = TRUE;
            //Match values and update the exact known value for the device
            
            NSMutableArray *cloudDeviceValueList;
            NSMutableArray *mobileDeviceValueList;
            //  NSMutableArray *mobileDeviceKnownValues;
            NSMutableArray *cloudDeviceKnownValues;
            
            cloudDeviceValueList = obj.deviceValueList;
            mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            
            int deviceValueID;
            NSMutableArray *currentKnownValues;
            
            for(SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
                deviceValueID = currentDeviceValue.deviceID;
                if([self.currentDeviceID integerValue] == deviceValueID){
                    // //[SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
                    currentKnownValues = currentDeviceValue.knownValues;
                }
            }
            
            if(mobileDeviceValueList!=nil)
            {
                BOOL isDeviceFound = FALSE;
                for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList){
                    //[SNLog Log:@"Method Name: %s Mobile DeviceID: %d ", __PRETTY_FUNCTION__,currentMobileValue.deviceID];
                    for(SFIDeviceValue *currentCloudValue in cloudDeviceValueList){
                        //[SNLog Log:@"Method Name: %s Cloud DeviceID:  %d ", __PRETTY_FUNCTION__, currentCloudValue.deviceID];
                        if(currentMobileValue.deviceID == currentCloudValue.deviceID){
                            isDeviceFound = TRUE;
                            currentCloudValue.isPresent = TRUE;
                            //[SNLog Log:@"Method Name: %s Current Device Value Changed - Update", __PRETTY_FUNCTION__];
                            //mobileDeviceKnownValues = currentMobileValue.knownValues;
                            cloudDeviceKnownValues = currentCloudValue.knownValues;
                            for(SFIDeviceKnownValues *currentMobileKnownValue in currentKnownValues){
                                //[SNLog Log:@"Method Name: %s Mobile Device Known Value Index: %d " , __PRETTY_FUNCTION__,currentMobileKnownValue.index];
                                for(SFIDeviceKnownValues *currentCloudKnownValue in cloudDeviceKnownValues){
                                    //[SNLog Log:@"Method Name: %s Cloud Device Known Value Index: %d " , __PRETTY_FUNCTION__,currentCloudKnownValue.index];
                                    if(currentMobileKnownValue.index == currentCloudKnownValue.index){
                                        //Update Value
                                        //[SNLog Log:@"Method Name: %s BEFORE update => Cloud: %@  Mobile: %@" , __PRETTY_FUNCTION__,currentCloudKnownValue.value , currentMobileKnownValue.value];
                                        [currentMobileKnownValue setValue:currentCloudKnownValue.value];
                                        //[SNLog Log:@"Method Name: %s AFTER update => Cloud: %@  Mobile: %@" ,__PRETTY_FUNCTION__, currentCloudKnownValue.value , currentMobileKnownValue.value];
                                        
                                        break;
                                    }
                                }
                                //self.deviceKnownValues = mobileDeviceKnownValues;
                            }
                            isDeviceValueChanged = TRUE;
                        }
                    }
                }
                //Compare size of device value from cloud and offline
                if(!isDeviceFound){
                    // NSLog(@"SENSOR - New Value Added!");
                    //Traverse the list and add the new value to offline list
                    for(SFIDeviceValue *currentCloudValue in cloudDeviceValueList){
                        if(!currentCloudValue.isPresent){
                            [mobileDeviceValueList addObject:currentCloudValue];
                        }
                    }
                }
                self.deviceValueList = mobileDeviceValueList;
            }
            
            if(isCurrentMAC){// && isDeviceValueChanged){
                //[SNLog Log:@"Method Name: %s Value Changed - Refresh",__PRETTY_FUNCTION__];
                [self initiliazeImages];
                //To remove text fields keyboard. It was throwing error when it was being called from the background thread
                [self.tableView performSelectorOnMainThread:@selector(reloadData)
            withObject:nil
            waitUntilDone:NO];
                //[self.tableView reloadData];
            }
        }
        
        
    }
    
    
}


-(void)DynamicAlmondListAddCallback:(id)sender{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received DynamicAlmondListAddCallback", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *)[data valueForKey:@"data"];
        
        
        
        if(obj.isSuccessful){
            //[SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
            //When previously no almonds were there
            //[SNLog Log:@"Method Name: %s Current MAC : %@", __PRETTY_FUNCTION__,self.currentMAC];
            if([self.currentMAC isEqualToString:NO_ALMOND]){
                //[SNLog Log:@"Method Name: %s Previously no almond", __PRETTY_FUNCTION__];
                NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
                NSString *currentMACName;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                if([almondList count]!=0){
                    SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
                    self.currentMAC = currentAlmond.almondplusMAC;
                    currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs synchronize];
                    self.navigationItem.title = currentMACName;
                    [self refreshDataForAlmond];
                }else{
                    self.currentMAC = NO_ALMOND;
                    self.navigationItem.title = @"Get Started";
                    [self.deviceList removeAllObjects];
                    [self.deviceValueList removeAllObjects];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                    [prefs synchronize];
                   //  [[self view] endEditing:YES];
                    //To remove text fields keyboard. It was throwing error when it was being called from the background thread
                    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                     withObject:nil
                                                  waitUntilDone:NO];
                }
                
                
            }
        }
        
    }
}

-(void)DynamicAlmondListDeleteCallback:(id)sender{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        //[SNLog Log:@"Method Name: %s Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *)[data valueForKey:@"data"];
        
        
        if(obj.isSuccessful){
            
            //[SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
            
            SFIAlmondPlus *deletedAlmond = [obj.almondPlusMACList objectAtIndex:0];
            if([self.currentMAC isEqualToString:deletedAlmond.almondplusMAC]){
                //[SNLog Log:@"Method Name: %s Remove this view", __PRETTY_FUNCTION__];
                NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
                NSString *currentMACName;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                if([almondList count]!=0){
                    SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
                    self.currentMAC = currentAlmond.almondplusMAC;
                    currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs setObject:0 forKey:COLORCODE];
                    [prefs synchronize];
                    self.navigationItem.title = currentMACName;
                    [self refreshDataForAlmond];
                }else{
                    self.currentMAC = NO_ALMOND;
                    self.navigationItem.title = @"Get Started";
                    [self.deviceList removeAllObjects];
                    [self.deviceValueList removeAllObjects];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                    [prefs removeObjectForKey:COLORCODE];
                    [prefs synchronize];
                    // [[self view] endEditing:YES];
                    //To remove text fields keyboard. It was throwing error when it was being called from the background thread
                    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                     withObject:nil
                                                  waitUntilDone:NO];
                }
                
                
            }
            
        }
        
    }
}


- (IBAction)refreshSensorData:(id)sender{
    // NSLog(@"Refresh Sensor Data");
    if([self.currentMAC isEqualToString:NO_ALMOND]){
        return;
    }
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    SensorForcedUpdateRequest *forcedUpdateCommand = [[SensorForcedUpdateRequest alloc] init];
    forcedUpdateCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICE_DATA_FORCED_UPDATE_REQUEST;
    cloudCommand.command=forcedUpdateCommand;
    @try {
        //[SNLog Log:@"Method Name: %s Before Writing to socket -- Sensor Forced Update Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            //[SNLog Log:@"Method Name: %s Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        //[SNLog Log:@"Method Name: %s After Writing to socket -- Sensor Forced Update Command", __PRETTY_FUNCTION__];
        
    }
    @catch (NSException *exception) {
        //[SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    forcedUpdateCommand=nil;
}



-(void)saveSensorData:(id)sender{
    if([self.currentMAC isEqualToString:NO_ALMOND]){
        return;
    }
    
    UIButton *btnObj = (UIButton*) sender;
    NSLog(@"Save button clicked for device: %ld", (long)btnObj.tag);
    SFIDevice *currentSensor =[self.deviceList objectAtIndex:btnObj.tag];
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    SensorChangeRequest *sensorChangeCommand = [[SensorChangeRequest alloc] init];
    sensorChangeCommand.almondMAC = self.currentMAC;
    sensorChangeCommand.deviceID = [NSString stringWithFormat:@"%d", currentSensor.deviceID];
    if(currentChangedName == nil && currentChangedLocation == nil){
        return;
    }
    if(currentChangedName!=nil){
        NSLog(@"Name changed!");
        sensorChangeCommand.changedName = currentChangedName;
        currentSensor.deviceName = currentChangedName;
    }
    if(currentChangedLocation!=nil){
        NSLog(@"Location changed!");
        sensorChangeCommand.changedLocation = currentChangedLocation;
        currentSensor.location = currentChangedLocation;
    }
    sensorChangeCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d",(arc4random() % 10000) + 1];
    
    
    cloudCommand.commandType=SENSOR_CHANGE_REQUEST;
    cloudCommand.command=sensorChangeCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Sensor Forced Update Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Sensor Forced Update Command", __PRETTY_FUNCTION__];
        
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    //PY 230114 - Timeout for Sensor Change Command
    sensorChangeCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                          target:self
                                                        selector:@selector(cancelSensorChangeCommand:)
                                                        userInfo:nil
                                                         repeats:NO];
    isSensorChangeCommandSuccessful = FALSE;
    
    cloudCommand=nil;
    sensorChangeCommand=nil;
    currentChangedName = nil;
    currentChangedLocation = nil;
    
}

//PY 311013 - Timeout for Sensor Change Command
-(void)cancelSensorChangeCommand:(id)sender{
    [sensorChangeCommandTimer invalidate];
    //NSLog(@"cancelSensorChangeCommand %@", isSensorChangeCommandSuccessful);
    if(!isSensorChangeCommandSuccessful){
        //Cancel the event - Revert back
        //// NSLog(@"Change the state back");
        self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
        [self initiliazeImages];
        // [[self view] endEditing:YES];
        [self.tableView reloadData];
    }
}


-(void)SensorChangeCallback:(id)sender{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        isSensorChangeCommandSuccessful = TRUE;
        [SNLog Log:@"Method Name: %s Received SensorChangeCallback", __PRETTY_FUNCTION__];
        
        SensorChangeResponse *obj = [[SensorChangeResponse alloc] init];
        obj = (SensorChangeResponse *)[data valueForKey:@"data"];
        
        
        if(obj.isSuccessful){
             [SNLog Log:@"Method Name: %s Sensor Data Changed Successfully", __PRETTY_FUNCTION__];
        }else{
            //TODO: Later
            [SNLog Log:@"Method Name: %s Could not update data, Revert to old value", __PRETTY_FUNCTION__];
            self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
            [self initiliazeImages];
            //To remove text fields keyboard. It was throwing error when it was being called from the background thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:NO];
            
        }
    }
}

-(void)DynamicAlmondNameChangeCallback:(id)sender
{
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        // [SNLog Log:@"Method Name: %s Received DynamicAlmondNameChangeCallback", __PRETTY_FUNCTION__];
        
        DynamicAlmondNameChangeResponse *obj = [[DynamicAlmondNameChangeResponse alloc] init];
        obj = (DynamicAlmondNameChangeResponse *)[data valueForKey:@"data"];
//        NSMutableArray *offlineAlmondList = [SFIOfflineDataManager readAlmondList];
//        for(SFIAlmondPlus *currentOfflineAlmond in offlineAlmondList){
            if([self.currentMAC isEqualToString:obj.almondplusMAC]){
                //Change the name of the current almond in the offline list
                 NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:obj.almondplusName forKey:CURRENT_ALMOND_MAC_NAME];
                self.navigationItem.title = obj.almondplusName; //[NSString stringWithFormat:@"Sensors at %@", self.currentMAC];

//                break;
//            }
        }

    }
}


@end
