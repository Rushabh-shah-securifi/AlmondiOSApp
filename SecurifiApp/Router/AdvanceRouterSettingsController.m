//
//  AdvanceRouterSettingsController.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvanceRouterSettingsController.h"
#import "AdvRouterTableViewCell.h"
#import "AdvRouterHelpController.h"
#import "CommonMethods.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "SFIColors.h"
#import "RouterPayload.h"
#import "NSData+Securifi.h"
#import "AlmondManagement.h"
#import "UIViewController+Securifi.h"
#import "MBProgressHUD.h"

#define ADVANCED_SETTINGS @"advance_settings"
#define ADVANCE_ROUTER @"advance_router"


static const int headerHeight = 90;
static const int footerHeight = 10;

@interface AdvanceRouterSettingsController ()<AdvRouterTableViewCellDelegate, MBProgressHUDDelegate>
@property (nonatomic) NSMutableArray *sectionsArray;
@property(nonatomic) MBProgressHUD *HUD;
@end

@implementation AdvanceRouterSettingsController
int mii;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Advanced_Features", @"");
    [self initializeSectionsArray];
    [self setUpHUD];
    NSLog(@"router array: %@", self.sectionsArray);
 
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    
    [self initializeNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onAlmondPropertyResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil]; //1064 response
    
    [center addObserver:self selector:@selector(onDynamicAlmondPropertyResponse:) name:NOTIFICATION_ALMOND_PROPERTIES_PARSED object:nil]; //list and each property change
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = NO;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}

#pragma mark command response
-(void)onAlmondPropertyResponse:(id)sender{
    NSLog(@"onAlmondPropertyResponse");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NSDictionary *payload;
    if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"payload: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    
    if(isSuccessful){
//        [self showToast:@"Successfully Updated!"];
    }else{
        [self showToast:@"Sorry! Could not update"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.HUD hide:YES];
        });
    }
}

-(void)onDynamicAlmondPropertyResponse:(id)sender{
    NSLog(@"onDynamicAlmondPropertyResponse");
    //don't reload the dictionary will have old values
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    
    [self showToast:@"Successfully Updated!"];
    [self initializeSectionsArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionDict  = self.sectionsArray[section];
    return [sectionDict[CELLS] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    NSDictionary *sectionDict  = self.sectionsArray[section];
    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    if(type == Adv_Help)
        return footerHeight;
    else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    NSDictionary *sectionDict  = self.sectionsArray[section];
    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    if(type == Adv_Help)
        return [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), footerHeight)];
    else
        return [[UIView alloc]initWithFrame:CGRectZero];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSDictionary *sectionDict  = self.sectionsArray[section];
    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    if(type == Adv_Help)
        return headerHeight;
    else
        return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *sectionDict  = self.sectionsArray[section];
    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    if(type == Adv_Help){
        //no matter what xy you give it stars form 0,0
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), headerHeight)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(headerView.frame)-10, headerHeight-5)];
        [CommonMethods setLableProperties:label text:NSLocalizedString(@"adv_feature_alert", @"") textColor:[UIColor blackColor] fontName:@"Avenir-Roman" fontSize:18 alignment:NSTextAlignmentCenter];
        [headerView addSubview:label];
        label.backgroundColor = [SFIColors lineColor];
        return headerView;
    }
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= ADVANCED_SETTINGS;

    AdvRouterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[AdvRouterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    NSDictionary *sectionDict  = self.sectionsArray[indexPath.section];
    [cell setUpSection:sectionDict indexPath:indexPath];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionDict  = self.sectionsArray[indexPath.section];
    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    if(type == Adv_Help){
        AdvRouterHelpController *ctrl = [AdvRouterHelpController new];
        ctrl.helpType = indexPath.row;
        self.navigationController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}
#pragma mark delegate methods
- (void)onSwitchTapDelegate:(AdvCellType)type value:(BOOL)value{
    [self showHudWithTimeoutMsg:@"Please Wait!" time:15];
    NSString *strValue = value? @"true": @"false";
    switch (type) {
        case Adv_LocalWebInterface:{
            [RouterPayload requestAlmondPropertyChange:mii action:@"WebAdminEnable" value:strValue uptime:nil];
        }
            break;
        case Adv_UPnP:{
            NSLog(@"upnp");
            [RouterPayload requestAlmondPropertyChange:mii action:@"Upnp" value:strValue uptime:nil];
        }
            break;
        case Adv_AlmondScreenLock:{
            [RouterPayload requestAlmondPropertyChange:mii action:@"ScreenLock" value:strValue uptime:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)onDoneTapDelegate:(AdvCellType)type value:(NSString *)value isSecureFld:(BOOL)isSecureFld row:(NSInteger)row{
    [self showHudWithTimeoutMsg:@"Please Wait!" time:15];
    AlmondProperties *almondProperty = [SecurifiToolkit sharedInstance].almondProperty;
    switch (type) {
        case Adv_LocalWebInterface:{
            NSLog(@"local web interface");
            if(isSecureFld){
                NSString *encryptedBase64 = [AlmondProperties getBase64EncryptedSting:[AlmondManagement currentAlmond].almondplusMAC uptime:almondProperty.uptime password:value];
                NSLog(@"encrypted base 64: %@", encryptedBase64);
                
                NSLog(@"decrypted password: %@", [self getDecryptedPass:encryptedBase64]);
                [RouterPayload requestAlmondPropertyChange:mii action:@"WebAdminPassword" value:encryptedBase64 uptime:almondProperty.uptime];
            }else{
                //non editable
            }
        }
            break;

        case Adv_AlmondScreenLock:{
            if(isSecureFld){
                NSString *encryptedBase64 = [AlmondProperties getBase64EncryptedSting:[AlmondManagement currentAlmond].almondplusMAC uptime:almondProperty.uptime password:value];
                NSLog(@"encrypted base 64: %@", encryptedBase64);
                
                NSLog(@"decrypted password: %@", [self getDecryptedPass:encryptedBase64]);
                [RouterPayload requestAlmondPropertyChange:mii action:@"ScreenPIN" value:encryptedBase64 uptime:almondProperty.uptime];
            }else{
                [RouterPayload requestAlmondPropertyChange:mii action:@"ScreenTimeout" value:value uptime:nil];
            }
        }
            break;
            
        case Adv_DiagnosticSettings:{
            NSLog(@"diagnostic");
            if(row == 1){
                NSLog(@"row 1");
                [RouterPayload requestAlmondPropertyChange:mii action:@"CheckInternetIP" value:value uptime:nil];
            }
            
            else if(row == 2)
                [RouterPayload requestAlmondPropertyChange:mii action:@"CheckInternetURL" value:value uptime:nil];
        }
            break;
        case Adv_Language:{
            //non editable
        }
            break;
            
        default:
            break;
    }
}

- (void)showMidToastDelegate:(NSString *)msg{
    [self showMidToast:msg];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//    });
}
#pragma mark hud methods
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg time:(NSTimeInterval)sec{
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:sec];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

#pragma mark Initialization
- (void)initializeSectionsArray{
    //example dictionar struct
    /*
     [
         {
         "CellType":"abcd",
         "Cells":[
             {
             "label":"",
             "value":""
             },
             {
             "label":"",
             "value":""
             }
         ]
         },
     ....]
*/
    AlmondProperties *almondProperty = [SecurifiToolkit sharedInstance].almondProperty;
    if(almondProperty.webAdminPassword == nil)//when you either have no response or response has no data
        almondProperty = [AlmondProperties getEmptyAlmondProperties];
        
    self.sectionsArray = [NSMutableArray new];
    NSString *decrytedPass;
    //web interface
    NSMutableArray *cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Local Web Interface" value:almondProperty.webAdminEnable]];
    [cellsArray addObject:[self getCellDict:@"Login" value:@"admin"]];
    decrytedPass = [self getDecryptedPass:almondProperty.webAdminPassword];
    [cellsArray addObject:[self getCellDict:@"Password" value:decrytedPass]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_LocalWebInterface]];
    
    //screen lock
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Almond Screen Lock" value:almondProperty.screenLock]];
    decrytedPass = [self getDecryptedPass:almondProperty.screenPIN];
    [cellsArray addObject:[self getCellDict:@"Pin" value:decrytedPass]];
    [cellsArray addObject:[self getCellDict:@"Sleep After" value:almondProperty.screenTimeout]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_AlmondScreenLock]];
    
    //diagnostics
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Diagnostic Settings" value:@""]];
    [cellsArray addObject:[self getCellDict:@"Ping IP" value:almondProperty.checkInternetIP]];
    [cellsArray addObject:[self getCellDict:@"Fall Back URL" value:almondProperty.checkInternetURL]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_DiagnosticSettings]];
    
    //upnp
    if([self isAL3]){
        cellsArray = [NSMutableArray new];
        [cellsArray addObject:[self getCellDict:@"UPnP" value:almondProperty.upnp]];
        [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_UPnP]];
    }
    
    //language
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Language" value:almondProperty.language]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_Language]];
    
    //help sections
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Port Forwarding" value:@""]];
    [cellsArray addObject:[self getCellDict:@"DNS" value:@""]];
    [cellsArray addObject:[self getCellDict: @"Static IP Settings" value:@""]];
    [cellsArray addObject:[self getCellDict: @"UPnP" value:@""]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_Help]];
    
}

- (NSDictionary *)getCellDict:(NSString *)label value:(NSString *)value{
    NSMutableDictionary *muDict = [NSMutableDictionary new];
    [muDict setObject:label forKey:LABEL];
    [muDict setObject:value forKey:VALUE];
    return muDict;
}

- (NSDictionary *)getAdvFeatures:(NSArray *)cells cellType:(AdvCellType)cellType{
    NSMutableDictionary *muDict = [NSMutableDictionary new];
    [muDict setObject:cells forKey:CELLS];
    [muDict setObject:[NSNumber numberWithInt:cellType] forKey:CELL_TYPE];
    return muDict;
}

#pragma mark helper methods
- (NSString *)getDecryptedPass:(NSString *)encryptedPass{
    if(encryptedPass.length == 0)
        return @"";
    AlmondProperties *almondProp = [SecurifiToolkit sharedInstance].almondProperty;
    NSData *payload = [[NSData alloc] initWithBase64EncodedString:encryptedPass options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [payload securifiDecryptPasswordForAlmond:[AlmondManagement currentAlmond].almondplusMAC almondUptime:almondProp.uptime];
}

-(BOOL)isAL3{
    return [[AlmondManagement currentAlmond].firmware hasPrefix:@"AL3-"];
}
@end
