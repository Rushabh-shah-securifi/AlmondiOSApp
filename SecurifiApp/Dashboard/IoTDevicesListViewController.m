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

@interface IoTDevicesListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *ioTdevicetable;
@property (weak, nonatomic) IBOutlet UIImageView *backArrIcon;
@property (nonatomic) NSMutableArray *scannedDeviceList;
@property (nonatomic) NSArray *excludedDevices;

@end

@implementation IoTDevicesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scannedDeviceList = [[NSMutableArray alloc]init];
    NSDictionary *response  = @{
                                @"AlmondMAC": @"251176220100108",
                                @"ScanTime": @"1481196280",
                                @"ExcludedDevices":@[@"14:30:c6:46:b7:15", @"d4:0b:1a:3a:ed:74"],
                                @"Devices": @[@{
                                                  @"Ports": @[],
                                                  @"MAC": @"a0:86:c6:4d:96:59",
                                                  @"Telnet": @"0",
                                                  @"Http": @"0",
                                                  @"ForwardRules": @[@{
                                                                         @"IP": @"10.10.1.100",
                                                                         @"Ports": @"12112:50000",
                                                                         @"Protocol": @"udp",
                                                                         @"Target": @"DNAT"
                                                                         }],
                                                  @"UpnpRules": @[@{
                                                                      @"IP": @"10.10.1.100",
                                                                      @"Ports": @"61555",
                                                                      @"Protocol": @"udp",
                                                                      @"Target": @"DNAT"
                                                                      }]
                                                  }, @{
                                                  @"Ports": @[],
                                                  @"MAC": @"1c:87:2c:9d:21:65",
                                                  @"Telnet": @"0",
                                                  @"Http": @"0",
                                                  @"ForwardRules": @[@{
                                                                         @"IP": @"10.10.1.101",
                                                                         @"Ports": @"2222",
                                                                         @"Protocol": @"tcp",
                                                                         @"Target": @"DNAT"
                                                                         }, @{
                                                                         @"IP": @"10.10.1.101",
                                                                         @"Ports": @"2222",
                                                                         @"Protocol": @"udp",
                                                                         @"Target": @"DNAT"
                                                                         }],
                                                  @"UpnpRules": @[]
                                                  }, @{
                                                  @"Ports": @[@80, @111, @45187],
                                                  @"MAC": @"ac:ee:9e:90:f3:37",
                                                  @"Telnet": @"1",
                                                  @"Http": @"0",
                                                  @"ForwardRules": @[],
                                                  @" ": @[]
                                                  }]
                                };
    for (NSDictionary *dict in response[@"Devices"]) {
        NSDictionary *iotDeviceObj = [self iotDeviceObj:dict];
        [self.scannedDeviceList addObject:iotDeviceObj];
    }
    self.excludedDevices = response[@"ExcludedDevices"];
    
    
}
-(NSDictionary *)iotDeviceObj:(NSDictionary *)deviceDict{
    NSArray *ports = deviceDict[@"Ports"];
    NSString *telnet = deviceDict[@"Telnet"];
    NSString *Http = deviceDict[@"Http"];
    NSArray *ForwardRules = deviceDict[@"ForwardRules"];
    NSArray *UpnpRules = deviceDict[@"UpnpRules"];
    NSDictionary *returnDict = @{@"Telnet":@{@"P":[telnet isEqualToString:@"0"]?@"0":@"1",
                                             @"Tag":@"1"},
                                 @"Ports":@{@"P":ports.count?@"0":@"1",
                                            @"Tag":@"2"},
                                 @"Http":@{@"P":[Http isEqualToString:@"0"]?@"0":@"1",
                                           @"Tag":@"3"},
                                 @"ForwardRules":@{@"P":ForwardRules.count?@"0":@"1",
                                                   @"Tag":@"4"},
                                 @"UpnpRules":@{@"P":UpnpRules.count?@"0":@"1",
                                                @"Tag":@"5"},
                                 @"MAC":deviceDict[@"MAC"]
                                 };
    
    
    return  returnDict;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.backArrIcon.image = [CommonMethods imageNamed:@"back_icon" withColor:[UIColor lightGrayColor]];
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
    NSDictionary *iotDevice = [self.scannedDeviceList objectAtIndex:indexPath.row];
    
    IoTDeviceViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
    newWindow.iotDevice = iotDevice;
     newWindow.hideTable = NO;
    newWindow.hideMiddleView = YES;
    
    NSLog(@"IoTDevicesListViewController IF");
    [self.navigationController pushViewController:newWindow animated:YES];
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
    NSDictionary *commandInfo = @{@"CommandType":@"IOT Scan Results",
                                  @"AlmondMAC":@"23232323"                        };
    GenericCommand *cloudCommand = [GenericCommand jsonStringPayloadCommand:commandInfo commandType:CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncSendToNetwork:cloudCommand];
}


@end
