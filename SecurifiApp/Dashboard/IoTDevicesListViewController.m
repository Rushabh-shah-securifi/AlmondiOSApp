//
//  IoTDevicesListViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "IoTDevicesListViewController.h"
#import "IoTDeviceViewController.h"
#import "CommonMethods.h"
#import "SFIColors.h"
#import "Client.h"
#import "UIFont+Securifi.h"
#import "MySubscriptionsViewController.h"
#import "AlmondManagement.h"
#import "AlmondPlan.h"

@interface IoTDevicesListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *ioTdevicetable;
@property (weak, nonatomic) IBOutlet UIImageView *backArrIcon;
@property (nonatomic) NSMutableArray *scannedDeviceList;
@property (nonatomic) NSArray *healthyDEviceArr;
@property (nonatomic) NSArray *excludedDevices;
@property (weak, nonatomic) IBOutlet UILabel *no_scanDevice_label;
@property (weak, nonatomic) IBOutlet UILabel *lastScan_label;
@property (weak, nonatomic) IBOutlet UILabel *blinking_lbl;
@property (weak, nonatomic) IBOutlet UIButton *scannowBtn;
@property (weak, nonatomic) IBOutlet UIView *bottoMView;
@property (nonatomic)NSString *lastScanTime;


@end

@implementation IoTDevicesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.scannedDeviceList = [[NSMutableArray alloc]init];
    [self iotScanresultsCallBackController:nil];
    self.backArrIcon.image = [CommonMethods imageNamed:@"back_icon" withColor:[UIColor lightGrayColor]];
    SFIAlmondPlus *currentAlmond = [AlmondManagement currentAlmond];
    BOOL hasSubscribe = [AlmondPlan hasSubscription:currentAlmond.almondplusMAC];
    
    if(hasSubscribe){
        self.bottoMView.hidden = NO;
        self.scannowBtn.hidden = NO;
    }
    else{
        self.bottoMView.hidden = YES;
        self.scannowBtn.hidden = YES;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(iotScanresultsCallBackController:)
                   name:NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER
                 object:nil];

    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark tableviewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
    {   if(self.scannedDeviceList.count == 0)
        return 1;
        
        return self.scannedDeviceList.count;
    }
    else if(section == 1)
        return self.healthyDEviceArr.count;
    else{
        NSLog(@"self.excludedDevices.count %ld",self.excludedDevices.count);
        return self.excludedDevices.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
    if(indexPath.section == 0){
        if(self.scannedDeviceList.count == 0){
            cell = [self everyThingsFineLabel:cell];
            return cell;
        }
        NSDictionary *iotDevice = [self.scannedDeviceList objectAtIndex:indexPath.row];
        NSLog(@"iotDevice = %@",iotDevice);
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[self getClientName:iotDevice[@"MAC"]],[self getIsVulnableText:iotDevice]];
        NSString *iconName = [self getIcon:iotDevice[@"MAC"]];
        UIColor *color = [self getColor:iotDevice];
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:color];
        cell.detailTextLabel.text = [self getLabelText:iotDevice];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.section == 1){
        
        NSDictionary *iotDevice = [self.healthyDEviceArr objectAtIndex:indexPath.row];
        NSLog(@"iotDevice = %@",iotDevice);
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[self getClientName:iotDevice[@"MAC"]]];
        NSString *iconName = [self getIcon:iotDevice[@"MAC"]];
        UIColor *color = [SFIColors clientGreenColor];
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:color];
        cell.detailTextLabel.text = [self getLabelText:iotDevice];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        NSString *iotDeviceMAC = [self.excludedDevices objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[self getClientName:iotDeviceMAC]];
        NSString *iconName = [self getIcon:iotDeviceMAC];
        
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:[SFIColors ruleGraycolor]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // cell.detailTextLabel.text = [self getLabelText:iotDevice];
    }
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont securifiFont:16];
    cell.detailTextLabel.textColor = [SFIColors ruleGraycolor];
    cell.detailTextLabel.font = [UIFont securifiFont:14];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSLog(@"view for header: %ld", (long)section);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 25)];
    [label setFont:[UIFont securifiBoldFont:17]];
    if (section >0) {
        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
        CGRect sepFrame = CGRectMake(0, 0, 415, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:1.0];
        [foot addSubview:seperatorView];
    }
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont securifiLightFont:12],
                               NSForegroundColorAttributeName : [UIColor lightGrayColor]
                               };
    NSDictionary *attrDict1 = @{
                               NSForegroundColorAttributeName : [UIColor grayColor]
                               };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]init];
    NSAttributedString *attr = [[NSAttributedString alloc]initWithString:@"Vulnerable Devices " attributes:attrDict1];
    self.lastScanTime  = self.lastScanTime ?[NSString stringWithFormat:@"(Last Scan: %@)",self.lastScanTime]:@"";
    NSAttributedString *attr1 = [[NSAttributedString alloc]initWithString:self.lastScanTime attributes:attrDict];
    
    [attrStr appendAttributedString:attr];
    [attrStr appendAttributedString:attr1];
    
    NSString *string;
    if(section == 0){
        
//        string = @"VULNERABLE DEVICES";
        label.attributedText = attrStr;;
    }
    else if(section == 1){
        string = @"Healthy Devices";
        label.text = string;
        label.textColor = [UIColor grayColor];
    }
    else{
        string = @"Excluded Devices";
        label.text = string;
        label.textColor = [UIColor grayColor];
    }
    
    
    
    [view addSubview:label];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if(self.scannedDeviceList.count == 0){
            return;
        }
        
        if(self.scannedDeviceList.count < indexPath.row)
            return;
        NSDictionary *iotDevice = [self.scannedDeviceList objectAtIndex:indexPath.row];
        
        IoTDeviceViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
        newWindow.iotDevice = iotDevice;
        newWindow.hideTable = NO;
        newWindow.hideMiddleView = YES;
        
        NSLog(@"IoTDevicesListViewController IF");
        [self.navigationController pushViewController:newWindow animated:YES];
    }
    else if(indexPath.section == 1){
        if(self.healthyDEviceArr.count < indexPath.row)
            return;
        NSString *iotDeviceMAc = [self.healthyDEviceArr objectAtIndex:indexPath.row];
//        NSDictionary *iotDevice = @{@"MAC":iotDeviceMAc};
        NSDictionary *iotDevice = [self.healthyDEviceArr objectAtIndex:indexPath.row];
        
        IoTDeviceViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
        newWindow.iotDevice = iotDevice;
        newWindow.hideTable = NO;
        newWindow.hideMiddleView = YES;
        newWindow.sectionType = healthy_section;
        NSLog(@"IoTDevicesListViewController IF");
        [self.navigationController pushViewController:newWindow animated:YES];
    }
    else{
        if(self.excludedDevices.count < indexPath.row)
            return;
        NSString *iotDeviceMAc = [self.excludedDevices objectAtIndex:indexPath.row];
        NSDictionary *iotDevice = @{@"MAC":iotDeviceMAc};
        IoTDeviceViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
        newWindow.iotDevice = iotDevice;
        newWindow.hideTable = NO;
        newWindow.hideMiddleView = YES;
        NSLog(@"IoTDevicesListViewController IF");
        [self.navigationController pushViewController:newWindow animated:YES];
    }
    
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSString *)getLabelText:(NSDictionary *)returnDict{
    int redflags = 0;
    int orangeflags = 0;
    NSLog(@"return dict == %@",returnDict);
    
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"Tag"]isEqualToString:@"1"] || [dict[@"Tag"]isEqualToString:@"3"]){
            if([dict[@"P"]isEqualToString:@"1"])
                redflags++;
        }
        else{
            if([dict[@"P"]isEqualToString:@"1"])
                orangeflags++;
        }
    }
    NSLog(@"red = %d,orange %d",redflags,orangeflags);
    NSMutableString *displayText = [[NSMutableString alloc]init];
    
    if(redflags == 1)
    {
        [displayText appendString:[NSString stringWithFormat:@"%d vulnerability",redflags]];
    }
    else if(redflags > 1)
    {
        [displayText appendString:[NSString stringWithFormat:@"%d vulnerabilities",redflags]];
    }
    if(redflags > 0)
        [displayText appendString:@", "];
    
    
    if(orangeflags == 1)
    {
        [displayText appendString:[NSString stringWithFormat:@"%d warning",orangeflags]];
    }
    else if(orangeflags > 1)
    {
        [displayText appendString:[NSString stringWithFormat:@"%d warnings",orangeflags]];
    }
    
    return displayText;
}
-(NSString *)getClientName:(NSString *)mac{
    NSLog(@"mac = %@",mac);
    Client *client = [Client getClientByMAC:mac];
    return client.name;
}
-(NSString *)getIcon:(NSString *)mac{
    Client *client = [Client getClientByMAC:mac];
    NSLog(@"[client iconName] %@",[client iconName]);
    return [client iconName];
}
-(UIColor *)getColor:(NSDictionary *)returnDict{
    UIColor *color;
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"]){
            if([dict[@"Tag"]isEqualToString:@"1"] || [dict[@"Tag"]isEqualToString:@"3"]){
                color = [UIColor redColor];
                break;
            }
            else
                color = [UIColor orangeColor];
            continue;
        }
    }
    return color;
}
-(NSString*)getIsVulnableText:(NSDictionary*)returnDict{
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        NSLog(@"returnDict %@",returnDict);
        if([dict[@"P"]isEqualToString:@"1"]){
            if([dict[@"Tag"]isEqualToString:@"1"] || [dict[@"Tag"]isEqualToString:@"3"]){
                return @"is vulnerable";
            }
            else
                return @"needs attention";
        }
    }
    return @"";
}
-(UITableViewCell *)everyThingsFineLabel:(UITableViewCell *)cell{
    cell.imageView.image = [UIImage imageNamed:@"ic_check_circle_green"];
    cell.textLabel.text = @"Everything looks good";
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont securifiFont:12];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}
- (IBAction)scanNowRequest:(id)sender {
    NSInteger mii = arc4random()%10000;
    self.lastScan_label.hidden = YES;
    [self.scannowBtn setTitle:@"Scanning" forState:UIControlStateNormal];
    SFIAlmondPlus *currentAlmond = [AlmondManagement currentAlmond];
    NSString* amac = currentAlmond.almondplusMAC;
    NSDictionary *commandInfo = @{@"CommandType":@"ScanNow",
                                  @"AlmondMAC":amac,
                                  @"MobileInternalIndex":@(mii).stringValue
                                  };
    
    GenericCommand *cloudCommand = [GenericCommand jsonStringPayloadCommand:commandInfo commandType:CommandType_UPDATE_REQUEST];
    NSInteger systemTime = round([[NSDate date] timeIntervalSince1970]);
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    toolkit.lastScanTime = systemTime;
    [toolkit asyncSendToNetwork:cloudCommand];
    self.blinking_lbl.hidden = NO;
    self.blinking_lbl.alpha = 0;
    [UIView animateWithDuration:1.0 delay:0.2 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        self.blinking_lbl.alpha = 1;
    } completion:nil];
}
- (IBAction)launchMySubscription:(id)sender {
    MySubscriptionsViewController *ctrl = [self getStoryBoardController:@"SiteMapStoryBoard" ctrlID:@"MySubscriptionsViewController"];
    [self pushViewController:ctrl];
}
-(id)getStoryBoardController:(NSString *)storyBoardName ctrlID:(NSString*)ctrlID{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    id controller = [storyboard instantiateViewControllerWithIdentifier:ctrlID];
    return controller;
}



-(void)pushViewController:(UIViewController *)viewCtrl{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewCtrl animated:YES];
    });
}
-(void)iotScanresultsCallBackController:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkForLastScanTime];
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        self.scannedDeviceList = toolkit.iotScanResults[@"scanDevice"];
        self.healthyDEviceArr = toolkit.iotScanResults[@"HealthyDevice"];
        self.excludedDevices = toolkit.iotScanResults[@"scanExclude"];
        NSDate *dat = [NSDate dateWithTimeIntervalSince1970:[toolkit.iotScanResults[@"scanTime"] longLongValue]];
        NSString *lastScanYtime = [dat stringFromDateAMPM];
        self.lastScanTime = [dat stringFromDateAMPM];
        NSString *no_deviceScanned  = toolkit.iotScanResults[@"scanCount"]?toolkit.iotScanResults[@"scanCount"]:@"0";
        self.no_scanDevice_label.text = [NSString stringWithFormat:@"%@  Devices scanned",no_deviceScanned];
        
        self.lastScan_label.text = [NSString stringWithFormat:@"Last scanned at %@",lastScanYtime];
        if([toolkit.iotScanResults[@"scanCount"] isEqualToString:@"0"] || toolkit.iotScanResults[@"scanCount"] == nil){
            self.no_scanDevice_label.text = @"No Device scanned";
            self.lastScan_label.hidden = YES;
//            self.ioTdevicetable.hidden = YES;
        }
        [self.ioTdevicetable reloadData];

    });
    }
-(void)checkForLastScanTime{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSLog(@"toolkit.lastScanTime = %ld, toolkit.iotScanResults %lld",toolkit.lastScanTime,[toolkit.iotScanResults[@"scanTime"] longLongValue]);
   NSInteger lastScan =  [toolkit.iotScanResults[@"scanTime"] longLongValue];
    if(lastScan>=toolkit.lastScanTime){
        [self.scannowBtn setTitle:@"Scan Now" forState:UIControlStateNormal];
        self.blinking_lbl.hidden = YES;
        self.lastScan_label.hidden = NO;
    }
    else {
        [self.scannowBtn setTitle:@"Scanning" forState:UIControlStateNormal];
        self.blinking_lbl.hidden = NO;
        self.lastScan_label.hidden = YES;
        self.blinking_lbl.alpha = 0;
        [UIView animateWithDuration:1.0 delay:0.2 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            self.blinking_lbl.alpha = 1;
        } completion:nil];
    }
}
@end
