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

@interface IoTDevicesListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *ioTdevicetable;
@property (weak, nonatomic) IBOutlet UIImageView *backArrIcon;
@property (nonatomic) NSMutableArray *scannedDeviceList;
@property (nonatomic) NSArray *excludedDevices;
@property (weak, nonatomic) IBOutlet UILabel *no_scanDevice_label;
@property (weak, nonatomic) IBOutlet UILabel *lastScan_label;
@property (weak, nonatomic) IBOutlet UILabel *blinking_lbl;
@property (weak, nonatomic) IBOutlet UIButton *scannowBtn;


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
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
    {   if(self.scannedDeviceList.count == 0)
        return 1;
        
        return self.scannedDeviceList.count;
    }
    else
        return self.excludedDevices.count;
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
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[self getClientName:iotDevice[@"MAC"]],[self getIsVulnableText:iotDevice]];
        NSString *iconName = [self getIcon:iotDevice[@"MAC"]];
        UIColor *color = [self getColor:iotDevice];
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:color];
        cell.detailTextLabel.text = [self getLabelText:iotDevice];
    }
    else{
        NSString *iotDeviceMAC = [self.excludedDevices objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[self getClientName:iotDeviceMAC]];
        NSString *iconName = [self getIcon:iotDeviceMAC];
        
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:[SFIColors ruleGraycolor]];
        // cell.detailTextLabel.text = [self getLabelText:iotDevice];
    }
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont securifiFont:14];
    cell.detailTextLabel.textColor = [SFIColors ruleGraycolor];
    cell.detailTextLabel.font = [UIFont securifiFont:12];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 45;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSLog(@"view for header: %ld", (long)section);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    if (section >0) {
        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
        CGRect sepFrame = CGRectMake(0, 0, 415, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:1.0];
        [foot addSubview:seperatorView];
    }
    NSString *string;
    if(section == 0){
        string = @"SCAN RESULTS";
    }
    else{
        string = @"EXCLUDED DEVICES";
    }
    
    
    label.text = string;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.scannedDeviceList.count == 0)
        return;
    if (indexPath.section == 0) {
        NSDictionary *iotDevice = [self.scannedDeviceList objectAtIndex:indexPath.row];
        
        IoTDeviceViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
        newWindow.iotDevice = iotDevice;
        newWindow.hideTable = NO;
        newWindow.hideMiddleView = YES;
        
        NSLog(@"IoTDevicesListViewController IF");
        [self.navigationController pushViewController:newWindow animated:YES];
    }
    else{
        NSString *iotDeviceMAc = [self.excludedDevices objectAtIndex:indexPath.row];
        
        NSDictionary *iotDevice = [self.scannedDeviceList objectAtIndex:indexPath.row];
    }
    
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSString *)getLabelText:(NSDictionary *)returnDict{
    int flags = 0;
    
    NSString *displayText;
    
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"])
            flags++;
    }
    
    if(flags>1)
        displayText = @"Multiple risks identified";
    else
    {
        for(NSString *key in returnDict.allKeys){
            if([key isEqualToString:@"MAC"])
                continue;
            NSDictionary *dict = returnDict[key];
            if([dict[@"P"]isEqualToString:@"1"])
                displayText = [CommonMethods type:dict[@"Tag"]];
        }
        displayText = @"Your device is at risk";
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
                return @"may be vulnerable";
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
    [self.scannowBtn setTitle:@"scanning" forState:UIControlStateNormal];
    SFIAlmondPlus *currentAlmond = [AlmondManagement currentAlmond];
    NSString* amac = currentAlmond.almondplusMAC;
    NSDictionary *commandInfo = @{@"CommandType":@"ScanNow",
                                  @"AlmondMAC":amac,
                                  @"MobileInternalIndex":@(mii).stringValue
                                  };
    
    GenericCommand *cloudCommand = [GenericCommand jsonStringPayloadCommand:commandInfo commandType:CommandType_UPDATE_REQUEST];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
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
        self.blinking_lbl.hidden = YES;
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        self.scannedDeviceList = toolkit.iotScanResults[@"scanDevice"];
        self.excludedDevices = toolkit.iotScanResults[@"scanExclude"];
        NSDate *dat = [NSDate dateWithTimeIntervalSince1970:[toolkit.iotScanResults[@"scanTime"] intValue]];
        NSString *lastScanYtime = [dat stringFromDateAMPM];
        
        self.no_scanDevice_label.text = [NSString stringWithFormat:@"%ld  Devices scanned",self.scannedDeviceList.count];
        
        self.lastScan_label.text = [NSString stringWithFormat:@"Last scanned at %@",lastScanYtime];
        if(self.scannedDeviceList.count == 0){
            self.no_scanDevice_label.text = @"No Device scanned";
            self.lastScan_label.hidden = YES;
            self.ioTdevicetable.hidden = YES;
        }
        [self.ioTdevicetable reloadData];

    });
    }

@end
