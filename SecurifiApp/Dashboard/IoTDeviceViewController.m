//
//  IoTDeviceViewController.m
//  
//
//  Created by Securifi-Mac2 on 07/12/16.
//
//

#import "IoTDeviceViewController.h"
#import "BrowsingHistoryViewController.h"
#import "CommonMethods.h"
#import "Client.h"
#import "ClientPayload.h"
#import "UIColor+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"

@interface IoTDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISwitch *iotSwitch;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;
@property (weak, nonatomic) IBOutlet UIView *middleView;

@property (weak, nonatomic) IBOutlet UIImageView *clientImg;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *learnMore;
@property (nonatomic )NSMutableArray *warningLables;
@property (nonatomic) Client *client;


@end

@implementation IoTDeviceViewController
 int mii;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.middleView.hidden = _hideMiddleView;
    self.tableView.hidden = _hideTable;
    self.learnMore.hidden = _hideTable;
    self.iotSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
    self.client = [Client getClientByMAC:self.iotDevice[@"MAC"]];
    NSString *TypeImg = [self.client iconName];
    self.clientImg.image = [UIImage imageNamed:TypeImg];
    self.clientName.text = self.client.name;
    [self getDescriptionLables:self.iotDevice];
    [self setAllowAndBlock];
//       self.topView.backgroundColor = [self getolor:self.iotDevice];
    NSString *displayText = [self getDescripTionText:self.iotDevice];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",displayText,@"Learn More"] attributes:nil];
    NSRange linkRange = NSMakeRange(displayText.length, @"Learn More".length); // for the word "link" in the string above
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
    [attributedString setAttributes:linkAttributes range:linkRange];
    
//    self.explanationLable.userInteractionEnabled = YES;
//    [self.explanationLable addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
//    // Assign attributedText to UILabel
//    self.explanationLable.attributedText = attributedString;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [self initializeNotifications];
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    [center addObserver:self //mobile response 1525 - client notification
               selector:@selector(onClientPreferenceUpdateResponse:)
                   name:NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER
                 object:nil];
    [center addObserver:self //common dynamic reponse handler for sensor and clients
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
   

    
  
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)getDescripTionText:(NSDictionary*)returnDict{
    NSString *displayText;
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"])
            displayText = [CommonMethods type:dict[@"Tag"]];
    }
    return displayText;
}
-(void)setAllowAndBlock{
    NSLog(@"client.deviceAllowedType %d",self.client.deviceAllowedType);
    dispatch_async(dispatch_get_main_queue(), ^() {
    if(self.client.deviceAllowedType == 0){
        self.blockLabel.text = @"Blocked";
        
        [self.blockButton setTitle:@"Allow Device" forState:UIControlStateNormal];
        self.topView.backgroundColor = [UIColor lightGrayColor];
        self.blockButton.backgroundColor = [UIColor securifiScreenGreen];
    }
    else{
        self.blockLabel.text = @"Active";
        [self.blockButton setTitle:@"Block Device" forState:UIControlStateNormal];
        self.topView.backgroundColor = [self getColor:self.iotDevice];
        self.blockButton.backgroundColor = [UIColor lightGrayColor];
    }
    });

}
-(void)getDescriptionLables:(NSDictionary*)returnDict{
    self.warningLables = [[NSMutableArray alloc]init];
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"]){
            NSDictionary *LabelsDict = @{@"Label":[CommonMethods type:dict[@"Tag"]],
                                         @"Tag":dict[@"Tag"]
                                   };
            
            [self.warningLables addObject: LabelsDict];
        }
    }

}
-(UIColor *)getolor:(NSDictionary *)returnDict{
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"]){
            if([dict[@"Tag"]isEqualToString:@"1"] || [dict[@"Tag"]isEqualToString:@"3"]){
                return [UIColor redColor];
            }
            else
                return [UIColor orangeColor];
        }
    }
    return [UIColor grayColor];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)setExplanationText:(NSString *)type{
    if([type isEqualToString:@"1"])
        return @"Your device  has an open telnet (port:80) and uses a weak username and password. Telnet enabled devices are highly vulnerable to Mirai Botnet attacks. We suggest you block this device or create a strong username and password if you can access the telnet. Contact your device vendor for more assistance.Learn More ";
    else if([type isEqualToString:@"2"])
        return @"Your device has open ports. These ports may be used by some applications for allowing remote access of your system. If you do not use this device for such applications,it may be vulnerable. We suggest you block this device or contact your device vendor Learn More ";
    else if([type isEqualToString:@"3"])
        return @"The local web interface for this device uses a weak username and password. We suggest you block the device or change the password. Typically, settings can be accessed by entering the ip address of the device in your web browser. Contact your device vendor for more assistance.Learn More";
    else if([type isEqualToString:@"4"])
        return @"Your device is being used for port forwarding. Port forwarding is usually enabled manually for gaming applications and for remote access of cameras and DVRs. If you are not aware of port forwarding for this device, we suggest you block this device or contact your device vendor.Learn More";
    else
        return @"UPnP is a protocol that applications use to automatically set up port forwarding in the router. Viruses and Malwares can use UPnP in devices to gain remote access of your network. You can disable UPnP on your Almond from the Wifi tab.Learn More";
}
-(void)handleTapOnLabel:(id)sender{
//    NSLog(@"hyper link pressed");NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.uriDict[@"hostName"]]];
//    [[UIApplication sharedApplication] openURL:url];
}
#pragma mark tableDelege

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return self.warningLables.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
        NSDictionary *dict = [self.warningLables objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.text = dict[@"Label"];
        NSString *iconName = @"tamper";
        UIColor *color;
    NSLog(@"dict tag %@ ",dict[@"Tag"]);
        if([dict[@"Tag"] isEqualToString:@"1"]||[dict[@"Tag"] isEqualToString:@"3"])
            color = [UIColor redColor];
        else
            color = [UIColor orangeColor];
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:color];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 40;
}
- (IBAction)blockClientRequest:(id)sender {
     mii = arc4random()%10000;
    if(self.client.deviceAllowedType == 0){
        self.client.deviceAllowedType = 1;
        
    }
    else {
        self.client.deviceAllowedType = 0;
    }
    
    [ClientPayload getUpdateClientPayloadForClient:self.client mobileInternalIndex:mii];
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

-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
    

        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *dataInfo = [notifier userInfo];
        if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
            return;
        }
        NSDictionary *payload = dataInfo[@"data"];
        NSString *commandType = payload[COMMAND_TYPE];
    
         //checking if response is of only that particular client, only then pop
    NSLog(@"payload:: %@",payload);
        if(payload[CLIENTS]){
            SecurifiToolkit *toolkit =[SecurifiToolkit sharedInstance];
        NSDictionary *clientPayload = payload[CLIENTS];
        NSString *clientID = clientPayload.allKeys.firstObject;
            NSDictionary *clientDict = clientPayload[clientID];
            NSLog(@"clientDict = %@",clientDict);
            
            for(Client *client in toolkit.clients){
                if([clientID isEqualToString:client.deviceID]){
                    // need to work on Block property
                    NSString *newValue ;
                    if([clientDict[BLOCK] isEqualToString:@"1"]){
                        client.deviceAllowedType = 1;
                        self.client.deviceAllowedType = 1;
                    }
                    else{
                         client.deviceAllowedType = 0;
                    self.client.deviceAllowedType = 0;
                    }
                    
                    [self setAllowAndBlock];
                    
                }
                
                
        }
        }
}
-(void)onClientPreferenceUpdateResponse:(id)sender{//client individual 1525
    NSLog(@"device edit - onClientPreferenceUpdateResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    if ([mainDict[@"MobileInternalIndex"] integerValue]!=mii) {
        return;
    }
    if ([mainDict[@"Success"] boolValue] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            //[self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }
    else{
        //[self showToast:NSLocalizedString(@"successfully_updated", @"")];
    }
}
-(void)onCommandResponse:(id)sender{
   
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    
    if (dataInfo==nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    payload = [dataInfo[@"data"] objectFromJSONData];
   
    NSLog(@"onCommandResponse %@",payload);
}
- (IBAction)viewHistoryButtonClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    BrowsingHistoryViewController *newWindow = [storyboard   instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
    newWindow.is_IotType = YES;
    NSLog(@"instantiateViewControllerWithIdentifier IF");
    newWindow.client = self.client;
    [self.navigationController pushViewController:newWindow animated:YES];
    
}

@end
