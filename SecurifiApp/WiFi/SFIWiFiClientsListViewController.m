//
//  SFIWiFiClientsListViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 21.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIWiFiClientsListViewController.h"
#import "SFIWiFiClientListCell.h"
#import "SFIWiFiDeviceProprtyEditViewController.h"
#import "MBProgressHUD.h"
#import "MDJSON.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"

#define AVENIR_HEAVY @"Avenir-Heavy"
#define AVENIR_ROMAN @"Avenir-Roman"
#define AVENIR_LIGHT @"Avenir-Light"

@interface SFIWiFiClientsListViewController ()<SFIWiFiDeviceProprtyEditViewDelegate,SKSTableViewDelegate>{
    NSInteger randomMobileInternalIndex;
    IBOutlet SKSTableView *tblDevices;
    SFIConnectedDevice * currentDevice;
    NSIndexPath * currentIndexPath;
    NSArray * propertyNames;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;

@end


@implementation SFIWiFiClientsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentIndexPath = nil;
    randomMobileInternalIndex = arc4random() % 10000;
    tblDevices.SKSTableViewDelegate = self;
    tblDevices.shouldExpandOnlyOneCell = YES;
    propertyNames = @[@"Name",@"Type",@"MAC Address",@"Last Known IP",@"Connection",@"Use as Presence Sensor",@"Remove"];
    [self initializeNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(gotCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.connectedDevices count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;// [propertyNames count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return propertyNames.count;//[self.contents[indexPath.section][indexPath.row] count] - 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 90.0f;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SFIWiFiClientListCell";
    
    SFIWiFiClientListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SFIWiFiClientListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell createClientCell:self.connectedDevices[indexPath.section]];
    //    if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 0)) || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 2)))
    cell.expandable = YES;
    //    else
    //        cell.expandable = NO;
    
    return cell;
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    float propertyRowCellHeight = 44.0f;
    float removeRowCellHeight = 90.0f;
    static NSString *MyIdentifier = @"deviceProperty";
    SFIConnectedDevice * connectedDevice = self.connectedDevices[indexPath.section];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    //    }
    for (UIView *c in cell.subviews) {
        if ([c isKindOfClass:[UILabel class]] || [c isKindOfClass:[UIButton class]]) {
            [c removeFromSuperview];
        }
    }
    NSInteger subRowIndex = indexPath.subRow-1;
    
    UIView * bgView = [[UIView alloc] init];
    UIFont *font = [UIFont fontWithName:AVENIR_ROMAN size:17];
    
    if (subRowIndex!=6) {
        bgView.frame = CGRectMake(0, 0, tblDevices.frame.size.width, propertyRowCellHeight);
    }else{
        bgView.frame = CGRectMake(0, 0, tblDevices.frame.size.width, removeRowCellHeight-10);
    }
    bgView.backgroundColor = [UIColor colorWithRed:75/255.0f green:174/255.0f blue:79/255.0f alpha:1];
    bgView.tag = 66;
    [cell addSubview:bgView];
    
    if (subRowIndex!=6) {
        bgView.frame = CGRectMake(0, 0, tblDevices.frame.size.width, propertyRowCellHeight);
        
        
        CGSize textSize = [propertyNames[subRowIndex] sizeWithFont:font constrainedToSize:CGSizeMake(200, 50)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, textSize.width + 5, propertyRowCellHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = font;
        label.tag = 66;
        label.text = propertyNames[subRowIndex];
        label.numberOfLines = 1;
        [cell addSubview:label];
    }
    
    
    switch (subRowIndex) {
        case 0://Name
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = font;
            label.text = connectedDevice.name;
            label.numberOfLines = 1;
            label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1://Type
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 200, 0, 170, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = font;
            label.text = connectedDevice.deviceType;
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2://MAC Address
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 215, 0, 200, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = connectedDevice.deviceMAC;
            label.numberOfLines = 1;
            label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:label];
            break;
        }
        case 3://IP Address
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 215, 0, 200, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = connectedDevice.deviceIP;
            label.numberOfLines = 1;
            label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:label];
            break;
        }
        case 4://Connection
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];//colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = connectedDevice.deviceConnection;
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 5://Use as presence Sensor
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = font;
            if (connectedDevice.deviceUseAsPresence) {
                label.text = @"Yes";
            }else{
                label.text = @"No";
            }
            label.tag = 66;
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 6://Remove button
        {
            UIButton * btnRemove = [[UIButton alloc] init];
            btnRemove.frame = CGRectMake(tblDevices.frame.size.width / 2 - 70, 23, 140, 44);
            btnRemove.backgroundColor = [UIColor whiteColor];
            [btnRemove setTitle:NSLocalizedString(@"wifi.button.deleteClient", @"Remove") forState:UIControlStateNormal];
            [btnRemove setTitleColor:[UIColor colorWithRed:74/255.0f green:175/255.0f blue:79/255.0f alpha:1] forState:UIControlStateNormal];
            [btnRemove.titleLabel setFont:[UIFont fontWithName:AVENIR_ROMAN size:17]];
            [btnRemove addTarget:self action:@selector(btnRemoveTap:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btnRemove];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.subRow==7) {
        return 90.0f;
    }
    return 44.0f;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath == currentIndexPath) {
         return YES;
    }
    return NO;
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger subRowIndex = indexPath.subRow-1;
    switch (subRowIndex) {
        case 0://Name
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.editFieldIndex = 0;
            viewController.delegate = self;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 1://Type
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = 1;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 2://MAC Address
        {
            
            break;
        }
        case 3://IP Address
        {
            break;
        }
        case 4://Connection
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = 4;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 5://Use as presence Sensor
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = 5;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndexPath = indexPath;
    currentDevice = self.connectedDevices[indexPath.section];
    return;
}

#pragma mark Detail View Delegates
-(IBAction)btnRemoveTap:(id)sender{
    currentIndexPath = nil;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *commandInfo = [NSMutableDictionary new];
    
    [commandInfo setValue:@"RemoveClient" forKey:@"CommandType"];
    
    NSInteger randomNumber = arc4random() % 10000;
    [commandInfo setValue:@(randomNumber) forKey:@"MobileInternalIndex"];
    
    [commandInfo setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [commandInfo setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    
    
    NSArray * clients = @[@{@"ID":currentDevice.deviceID,@"MAC":currentDevice.deviceMAC}];
    
    [commandInfo setValue:clients forKey:@"Clients"];
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [commandInfo JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"wifi.hud.removeClient", @"Deleting wifi client...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [self asyncSendCommand:cloudCommand];
    
}

#pragma mark
- (void)gotCommandResponse:(id)sender {
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Sorry, There was some problem with this request, try later!"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.connectedDevices removeObject:currentDevice];
            //            [tblDevices reloadData];
            [tblDevices refreshData];
        });
    }
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
#pragma mark Edit View delegates
- (void)updateDeviceInfo:(SFIConnectedDevice *)deviceInfo{
    [tblDevices refreshDataWithScrollingToIndexPath:currentIndexPath];
}
@end
