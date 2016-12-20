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

#define ADVANCED_SETTINGS @"advance_settings"
#define ADVANCE_ROUTER @"advance_router"


static const int headerHeight = 90;
static const int footerHeight = 10;

@interface AdvanceRouterSettingsController ()<AdvRouterTableViewCellDelegate>
@property (nonatomic) NSMutableArray *sectionsArray;
@end

@implementation AdvanceRouterSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Advanced_Features", @"");
    [self initializeSectionsArray];
    NSLog(@"router array: %@", self.sectionsArray);
 
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
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

    //[self hideHUDDelegate];
    
    if(isSuccessful){
        
    }else{
        
    }
}

-(void)onDynamicAlmondPropertyResponse:(id)sender{
    NSLog(@"onDynamicAlmondPropertyResponse");
    
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
-(void)onSwitchTapDelegate:(AdvCellType)type value:(BOOL)value{
    switch (type) {
        case Adv_LocalWebInterface:{
            
        }
            break;
        case Adv_UPnP:{
            NSLog(@"upnp");
        }
            break;
        case Adv_AlmondScreenLock:{
            
        }
            break;
            
        default:
            break;
    }
}

-(void)onDoneTapDelegate:(AdvCellType)type value:(NSString *)values{
    
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
    AlmondProperties *almondProperty = [AlmondProperties getTestAlmondProperties];
    //web interface
    self.sectionsArray = [NSMutableArray new];
    
    NSMutableArray *cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Local Web Interface" value:almondProperty.webAdminEnable]];
    [cellsArray addObject:[self getCellDict:@"Login" value:@"admin"]];
    [cellsArray addObject:[self getCellDict:@"Password" value:almondProperty.webAdminPassword]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_LocalWebInterface]];
    
    
    //upnp
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"UPnP" value:almondProperty.upnp]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_UPnP]];
    
    //screen lock
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Almond Screen Lock" value:almondProperty.screenLock]];
    [cellsArray addObject:[self getCellDict:@"Pin" value:almondProperty.screenPIN]];
    [cellsArray addObject:[self getCellDict:@"Sleep After" value:almondProperty.screenTimeout]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_AlmondScreenLock]];
    
    //diagnostics
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Diagnostic Settings" value:@""]];
    [cellsArray addObject:[self getCellDict:@"Ping IP" value:almondProperty.checkInternetIP]];
    [cellsArray addObject:[self getCellDict:@"Fall Back URL" value:almondProperty.URL]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_DiagnosticSettings]];
    
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

@end
