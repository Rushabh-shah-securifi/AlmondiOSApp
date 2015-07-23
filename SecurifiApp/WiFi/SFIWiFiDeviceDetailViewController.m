//
//  SFIWiFiDeviceDetailViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 11.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
#define AVENIR_HEAVY @"Avenir-Heavy"
#define AVENIR_ROMAN @"Avenir-Roman"
#define AVENIR_LIGHT @"Avenir-Light"

#import "SFIWiFiDeviceDetailViewController.h"
#import "SFIWiFiDeviceProprtyEditViewController.h"
#import "UIFont+Securifi.h"

@interface SFIWiFiDeviceDetailViewController ()<SFIWiFiDeviceProprtyEditViewDelegate>{
    
    IBOutlet UITableView *tblDeviceProperties;
    NSArray * propertyNames;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblStatus;
    
    IBOutlet UIImageView *imgIcon;
}

@end

@implementation SFIWiFiDeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblDeviceName.text = self.connectedDevice.name;
    if (self.connectedDevice.isActive) {
        lblStatus.text = @"CONNECTED";
    }else{
        lblStatus.text = @"NOT CONNECTED";
    }
    propertyNames = @[@"Name",@"Type",@"MAC Address",@"Last Known IP",@"Connection",@"Use as Presence Sensor"];
    UIImage* image = [UIImage imageNamed:[self.connectedDevice iconName]];
    imgIcon.image = image;
    CGRect fr = imgIcon.frame;
    fr.size = image.size;
    fr.origin.x = (90-fr.size.width)/2;
    fr.origin.y = (90-fr.size.height)/2;
    imgIcon.frame = fr;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [tblDeviceProperties reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return propertyNames.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"deviceProperty";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    for (UIView *c in cell.subviews) {
        if (c.tag==66) {
            [c removeFromSuperview];
        }
    }
    UIFont *font = [UIFont fontWithName:AVENIR_ROMAN size:17];
    CGSize textSize = [propertyNames[indexPath.row] sizeWithFont:font constrainedToSize:CGSizeMake(200, 50)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, textSize.width + 5, cell.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = font;
                label.tag = 66;
    label.text = propertyNames[indexPath.row];
    label.numberOfLines = 1;
    [cell addSubview:label];
    
    switch (indexPath.row) {
        case 0://Name
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, cell.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = font;
            label.text = self.connectedDevice.name;
            label.numberOfLines = 1;
                        label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1://Type
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 200, 0, 170, cell.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = font;
            label.text = self.connectedDevice.deviceType;
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
                        label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2://MAC Address
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 215, 0, 200, cell.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = self.connectedDevice.deviceMAC;
            label.numberOfLines = 1;
                        label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            break;
        }
        case 3://IP Address
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 215, 0, 200, cell.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = self.connectedDevice.deviceIP;
            label.numberOfLines = 1;
                        label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            break;
        }
        case 4://Connection
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, cell.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = self.connectedDevice.deviceConnection;
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
                        label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 5://Use as presence Sensor
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, cell.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = font;
            if (self.connectedDevice.deviceUseAsPresence) {
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
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0://Name
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.editFieldIndex = 0;
            viewController.delegate = self;
            viewController.connectedDevice = self.connectedDevice;
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 1://Type
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = 1;
            viewController.connectedDevice = self.connectedDevice;
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
            viewController.connectedDevice = self.connectedDevice;
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 5://Use as presence Sensor
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
                   viewController.delegate = self;
            viewController.editFieldIndex = 5;
            viewController.connectedDevice = self.connectedDevice;
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

#pragma mark
- (void)updateDeviceInfo:(SFIConnectedDevice *)deviceInfo{
    self.connectedDevice = deviceInfo;
    lblDeviceName.text = self.connectedDevice.name;
    if (self.connectedDevice.isActive) {
        lblStatus.text = @"CONNECTED";
    }else{
        lblStatus.text = @"NOT CONNECTED";
    }
    UIImage* image = [UIImage imageNamed:[self.connectedDevice iconName]];
    imgIcon.image = image;
    CGRect fr = imgIcon.frame;
    fr.size = image.size;
    fr.origin.x = (90-fr.size.width)/2;
    fr.origin.y = (90-fr.size.height)/2;
    imgIcon.frame = fr;

    [tblDeviceProperties reloadData];
}

#pragma mark
- (IBAction)btnRemoveClientTap:(id)sender {
    [self.delegate removeClientTapped:self.connectedDevice];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
