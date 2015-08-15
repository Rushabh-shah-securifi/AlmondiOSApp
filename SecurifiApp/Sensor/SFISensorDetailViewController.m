//
//  SFISensorDetailViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 14.08.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
#define AVENIR_HEAVY @"Avenir-Heavy"
#define AVENIR_ROMAN @"Avenir-Roman"
#define AVENIR_LIGHT @"Avenir-Light"


#import "SFISensorDetailViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "SFINotificationsViewController.h"
#import "SFIDeviceProprtyEditViewController.h"
#import "MBProgressHUD.h"

@interface SFISensorDetailViewController ()<SFIDeviceProprtyEditViewControllerDelegate>{
    IBOutlet UIView *viewTypeSelection;
    
    IBOutlet UIView *mainBGView;
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblStatus;
    
    NSArray * propertyNames;
    
    NSInteger randomMobileInternalIndex;
    IBOutlet UIImageView *imgIcon;
    IBOutlet UITableView *tblDeviceProperties;
    NSArray * notifyMe_items;
    UIFont *cellFont;
    IBOutlet UILabel *lblThemperatureMain;
}
@property(nonatomic, readonly) MBProgressHUD *HUD;

@end

@implementation SFISensorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lblDeviceName.text = self.device.deviceName;
    lblStatus.text = @"ok";
    cellFont = [UIFont fontWithName:AVENIR_ROMAN size:17];
    if (self.device.deviceType==SFIDeviceType_NestThermostat_57) {
        imgIcon.image = nil;
        
        CGRect fr = lblThemperatureMain.frame;
        fr.size = CGSizeMake(90, 90);
        fr.origin.x = 0;
        fr.origin.y = 0;
        lblThemperatureMain.frame = fr;
        
        lblThemperatureMain.textAlignment = NSTextAlignmentCenter;
        lblThemperatureMain.textColor = [UIColor whiteColor];
        
        SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_TEMPERATURE];
        NSString * curTemp = currentDeviceValue.value;
        
        NSString *strTopTitleLabelText = [curTemp stringByAppendingString:@"°"];
        
        NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
        
        [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:36.0f]} range:NSMakeRange(0,curTemp.length)];
        [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:27.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(curTemp.length,@"°".length)];
        
        [lblThemperatureMain setAttributedText:strTemp];
        propertyNames = @[@"Name",@"Location",@"Humidity",@"Away Mode",@"Mode",@"Target Range",@"Fan",@"Notify me",@""];
    }
    if (self.device.deviceType==SFIDeviceType_NestSmokeDetector_58) {
        
        
        UIImage* image = [UIImage imageNamed:@"nest_58_icon"];
        imgIcon.image = image;
        CGRect fr = imgIcon.frame;
        fr.size = image.size;
        fr.origin.x = (90-fr.size.width)/2;
        fr.origin.y = (90-fr.size.height)/2;
        imgIcon.frame = fr;
        propertyNames = @[@"Name",@"Location",@"Away Mode",@"CO Level",@"Smoke Level",@"Notify me",@""];
    }
    
    mainBGView.backgroundColor = self.cellColor;
    notifyMe_items = @[
                       NSLocalizedString(@"sensor.notificaiton.segment.Always", @"Always"),
                       NSLocalizedString(@"sensor.notificaiton.segment.Away", @"Away"),
                       NSLocalizedString(@"sensor.notificaiton.segment.Off", @"Off"),
                       ];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)initializeNotifications {
    //    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //    [center addObserver:self
    //               selector:@selector(onWiFiClientsUpdateResponseCallback:)
    //                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
    //                 object:nil];//md01
    //
    //    [center addObserver:self
    //               selector:@selector(onClientPreferenceUpdateResponse:)
    //                   name:NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER
    //                 object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return propertyNames.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    float propertyRowCellHeight = 44.0f;
    static NSString *MyIdentifier = @"deviceProperty";
    
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
    for (UIView *c in cell.subviews) {
        if ([c isKindOfClass:[UILabel class]] || [c isKindOfClass:[UIButton class]]) {
            [c removeFromSuperview];
        }
    }
    
    
    UIView * bgView = [[UIView alloc] init];
    
    
    bgView.frame = CGRectMake(0, 0, tblDeviceProperties.frame.size.width, propertyRowCellHeight);
    bgView.backgroundColor = self.cellColor;
    bgView.tag = 66;
    [cell addSubview:bgView];
    
    bgView.frame = CGRectMake(0, 0, tblDeviceProperties.frame.size.width, propertyRowCellHeight);
    
    
    CGSize textSize = [propertyNames[indexPath.row] sizeWithFont:cellFont constrainedToSize:CGSizeMake(200, 50)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, textSize.width + 5, propertyRowCellHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.tag = 66;
    label.text = propertyNames[indexPath.row];
    label.numberOfLines = 1;
    [cell addSubview:label];
    //propertyNames = @[@"Name",@"Location",@"Away Mode",@"CO Level",@"Smoke Level",@"Notify me",@""];
    //propertyNames = @[@"Name",@"Location",@"Humidity",@"Away Mode",@"Mode",@"Target Range",@"Fan",@"Notify me",@""];
    switch (indexPath.row) {
        case 0://Name
        {
            [self configureNameCell:cell];
            break;
        }
        case 1://Location
        {
            [self configureLocationCell:cell];
            break;
        }
        case 2:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self configureHumidityCell:cell];
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self configureAwayModeCell:cell];
                    break;
                default:
                    break;
            }
            break;
        }
        case 3:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self configureAwayModeCell:cell];
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self configureCOLevelCell:cell];
                    break;
                default:
                    break;
            }
            break;
        }
        case 4:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self configureModeCell:cell];
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self configureSmokeLevelCell:cell];
                    break;
                default:
                    break;
            }
            
            break;
        }
        case 5://Notify me
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self configureTargetRangeCell:cell];
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self configureNotifyMeCell:cell];
                    break;
                default:
                    break;
            }
            break;
        }
        case 6:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self configureFanCell:cell];
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self configureDeviceHistoryCell:cell];
                    break;
                default:
                    break;
            }
            break;
        }
        case 7:
        {
            [self configureNotifyMeCell:cell];
            break;
        }
        case 8:
        {
            [self configureDeviceHistoryCell:cell];
            break;
        }
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
            //        case 0://Name
            //        {
            //            [self configureNameCell:cell];
            //            break;
            //        }
            //        case 1://Location
            //        {
            //            [self configureLocationCell:cell];
            //            break;
            //        }
        case 2:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    //[self configureHumidityCell:cell];
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self editProperty:3];//Home Away
                    break;
                default:
                    break;
            }
            break;
        }
        case 3:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self editProperty:3];//Home Away
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    //[self configureCOLevelCell:cell];
                    break;
                default:
                    break;
            }
            break;
        }
        case 4:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self editProperty:4];//mode
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    //[self configureSmokeLevelCell:cell];
                    break;
                default:
                    break;
            }
            
            break;
        }
        case 5://Notify me
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self editProperty:5];//TargetRange
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self editProperty:1];//Notify me
                    break;
                default:
                    break;
            }
            break;
        }
        case 6:
        {
            switch (self.device.deviceType) {
                case SFIDeviceType_NestThermostat_57:
                    [self editProperty:2];//Fan On/Off
                    break;
                case SFIDeviceType_NestSmokeDetector_58:
                    [self showSensorLogs];
                    break;
                default:
                    break;
            }
            break;
        }
        case 7:
        {
            [self editProperty:1];//Notify me
            break;
        }
        case 8:
        {
            [self showSensorLogs];
            break;
        }
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0000001;
}

//#pragma mark tableview cell delegates
//- (IBAction)btnSelectTypeTapped:(SFIWiFiDeviceTypeSelectionCell *)cell Info:(NSDictionary *)cellInfo {
//    switch (self.editFieldIndex) {
//        case 1:
//            for (NSMutableDictionary * dict in deviceTypes) {
//                [dict setValue:@0 forKey:@"selected"];
//            }
//            [cellInfo setValue:@1 forKey:@"selected"];
//            [tblTypes reloadData];
//            selectedDeviceType = [cellInfo valueForKey:@"name"];
//
//            break;
//        case 4:
//            for (NSMutableDictionary * dict in connectionTypes) {
//                [dict setValue:@0 forKey:@"selected"];
//            }
//            [cellInfo setValue:@1 forKey:@"selected"];
//            [tblTypes reloadData];
//            selectedConnectionType = [cellInfo valueForKey:@"name"];
//            break;
//        case 6:
//            for (NSMutableDictionary * dict in notifyTypes) {
//                [dict setValue:@0 forKey:@"selected"];
//            }
//            [cellInfo setValue:@1 forKey:@"selected"];
//            [tblTypes reloadData];
//            self.selectedNotificationType = [self.connectedDevice getNotificationTypeByName:[cellInfo valueForKey:@"name"]];
//            break;
//
//        default:
//            break;
//    }
//
//
//}
//
//#pragma mark - HUD mgt
//
//- (void)showHudWithTimeout {
//    dispatch_async(dispatch_get_main_queue(), ^() {
//        [self.HUD show:YES];
//        [self.HUD hide:YES afterDelay:5];
//    });
//}
//- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
//    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
//}
//
//#pragma mark - Cloud command senders and handlers
//
//- (void)onWiFiClientsUpdateResponseCallback:(id)sender {
//
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = [notifier userInfo];
//    if (data == nil) {
//        return;
//    }
//    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
//
//    NSLog(@"%@",mainDict);
//
//    if ([[mainDict valueForKey:@"MobileInternalIndex"] integerValue]!=randomMobileInternalIndex) {
//        return;
//    }
//    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
//        self.connectedDevice.deviceType = selectedDeviceType;
//        self.connectedDevice.deviceUseAsPresence = btnUsePresence.selected;
//        self.connectedDevice.name = txtName.text;
//        self.connectedDevice.deviceConnection = selectedConnectionType;
//        [self.delegate updateDeviceInfo:self.connectedDevice];
//
//        dispatch_async(dispatch_get_main_queue(), ^() {
//            if (!self) {
//                return;
//            }
//
//
//            [self.HUD hide:YES];
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//
//        return;
//    }
//}
//
//- (void)onClientPreferenceUpdateResponse:(id)sender {
//
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = [notifier userInfo];
//    if (data == nil) {
//        return;
//    }
//    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
//
//    NSLog(@"%@",mainDict);
//
//    if ([[mainDict valueForKey:@"MobileInternalIndex"] integerValue]!=randomMobileInternalIndex) {
//        return;
//    }
//    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
//        dispatch_async(dispatch_get_main_queue(), ^() {
//            if (!self) {
//                return;
//            }
//
//
//            [self.HUD hide:YES];
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//
//        return;
//    }
//}

#pragma mark Cofigure Cells
- (void)configureHumidityCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_HUMIDITY];
    label.text = [currentDeviceValue.value stringByAppendingString:@"%"];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureAwayModeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureCOLevelCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CO_ALARM_STATE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureSmokeLevelCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SMOKE_ALARM_STATE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
- (void)configureNameCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.text = self.device.deviceName;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureFanCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureModeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureLocationCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.text = self.device.location;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureTargetRangeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue1 = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW];
    SFIDeviceKnownValues *currentDeviceValue2 = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH];
    label.text = [NSString stringWithFormat:@"%@ - %@° F",currentDeviceValue1.value,currentDeviceValue2.value];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureDeviceHistoryCell:(UITableViewCell*)cell{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    label.attributedText = [[NSAttributedString alloc] initWithString:@"View Device History"
                                                           attributes:underlineAttribute];
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureNotifyMeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    switch (self.device.notificationMode) {
        case SFINotificationMode_always:
            label.text =notifyMe_items[0];
            break;
        case SFINotificationMode_away:
            label.text =notifyMe_items[1];
            break;
        case SFINotificationMode_off:
            label.text =notifyMe_items[2];
            break;
        default:
            break;
    }
    
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)showSensorLogs{
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.deviceID = self.device.deviceID;
    ctrl.almondMac = self.device.almondMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}

- (void)editProperty:(int)propertyNumber{
    SFIDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceProprtyEditViewController"];
    viewController.delegate = self;
    viewController.editFieldIndex = propertyNumber;
    viewController.device = self.device;
    viewController.deviceValue = self.deviceValue;
    viewController.cellColor = self.cellColor;
    [self.navigationController pushViewController:viewController animated:YES];
}





@end
