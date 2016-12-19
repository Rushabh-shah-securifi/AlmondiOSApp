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

#define ADVANCED_SETTINGS @"advance_settings"
#define ADVANCE_ROUTER @"advance_router"


static const int headerHeight = 90;
static const int footerHeight = 10;

@interface AdvanceRouterSettingsController ()
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width-10, headerHeight)];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight-1)];
        [CommonMethods setLableProperties:label text:NSLocalizedString(@"adv_feature_alert", @"") textColor:[UIColor blackColor] fontName:@"Avenir-Roman" fontSize:18 alignment:NSTextAlignmentCenter];

        [headerView addSubview:label];
        [CommonMethods addLineSeperator:headerView yPos:headerView.frame.size.height-1];
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


#pragma mark Initialization
- (void)initializeSectionsArray{
    //example dictionar struct
    /*
     [{
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
     }]*/
    //web interface
    self.sectionsArray = [NSMutableArray new];
    
    NSMutableArray *cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Local Web Interface" value:@"true"]];
    [cellsArray addObject:[self getCellDict:@"Login" value:@"admin"]];
    [cellsArray addObject:[self getCellDict:@"Password" value:@"password"]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_LocalWebInterface]];
    
    
    //upnp
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"UPnP" value:@"true"]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_UPnP]];
    
    //screen lock
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Almond Screen Lock" value:@"false"]];
    [cellsArray addObject:[self getCellDict:@"Pin" value:@"1234"]];
    [cellsArray addObject:[self getCellDict:@"Sleep After" value:@"20"]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_AlmondScreenLock]];
    
    //diagnostics
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Diagnostic Settings" value:@""]];
    [cellsArray addObject:[self getCellDict:@"Ping IP" value:@"10.10.10.10"]];
    [cellsArray addObject:[self getCellDict:@"Fall Back URL" value:@"www.fallback.com"]];
    [_sectionsArray addObject:[self getAdvFeatures:cellsArray cellType:Adv_DiagnosticSettings]];
    
    //language
    cellsArray = [NSMutableArray new];
    [cellsArray addObject:[self getCellDict:@"Language" value:@"English"]];
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
