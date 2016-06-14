//
//  SettingsViewController.m
//  Dashbord
//
//  Created by Securifi Support on 21/03/16.
//  Copyright © 2016 Securifi. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController (){
    NSString *Name;
    NSArray *NetworkConfig,*NetworkConfig1;
    NSArray *Preferences, *Preferences1;
    NSArray *Notifications;
    
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
//    [Scroller setScrollEnabled:YES];
//    [Scroller setContentSize:CGSizeMake(320, 1000)];
//    
//    self.title = @"Almond Settings";
//    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//    
//    NetworkConfig = [[NSArray alloc] initWithObjects:@"DeviceMode",@"MasterDevice", nil];
//    NetworkConfig1 = [[NSArray alloc] initWithObjects:@"Slave",@"Almond_0d24", nil];
//    Preferences = [[NSArray alloc] initWithObjects:@"Language",@"TimeZone",@"Location",@"ShowTemperature", nil];
//    Preferences1 = [[NSArray alloc] initWithObjects:@"English",@"Bucharest",@"Timisoara,Romania",@"ºC", nil];
//    Notifications = [[NSArray alloc] initWithObjects:@"NetworkDevices",@"Smart home Device", nil];
//    Name = @"Almond_1880";
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
       return 1;
    if (section == 1)
        return 2;
    if (section == 2)
        return 4;
    if (section == 3)
        return 2;
    else
        return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myTableCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:@"myTableCell"];
    }
    cell.textLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:16];
    cell.detailTextLabel.font =[UIFont fontWithName:@"AvenirLTStd-Light" size:16];
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Name";
        cell.detailTextLabel.text = Name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[NetworkConfig objectAtIndex:indexPath.row]];
        cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",[NetworkConfig1 objectAtIndex:indexPath.row]];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 2) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[Preferences objectAtIndex:indexPath.row]];
        cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",[Preferences1 objectAtIndex:indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 3) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[Notifications objectAtIndex:indexPath.row]];
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchview;
        [switchview setOn:YES animated:NO];
    }
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 2.0f);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string;
    switch (section) {
        case 0:
            string = @" ";
            break;
        case 1:
            string = @"NETWORK CONFIGURATION";
            break;
        case 2:
            string = @"PREFERENCES";
            break;
        case 3:
            string = @"NOTIFICATIONS";
            break;
        default:
            break;
    }
    label.textColor = [UIColor grayColor];
    [label setText:string];
    [view addSubview:label];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [tableView numberOfSections] - 1) {
        return 10.0;
    } else {
        return 0.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    UILabel *explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 10, 80)];
    explanationLabel.textColor = [UIColor grayColor];
    explanationLabel.font = [UIFont fontWithName:@"AvenirLTStd-Medium" size:12];
    explanationLabel.numberOfLines = 0;
    explanationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    explanationLabel.text = @"Notify me when new network device join the network, or when smart home device change states.";
    [footerView addSubview:explanationLabel];
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 1.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 0, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        }
        else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        }
        else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        //set the border color
        layer.strokeColor = [UIColor lightGrayColor].CGColor;
        //set the border width
        layer.lineWidth = 1;
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.0f].CGColor;
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }
}



@end



































