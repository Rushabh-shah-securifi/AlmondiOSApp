//
//  UseAsPresenseViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "UseAsPresenseViewController.h"
#import "UICommonMethods.h"
#import "DevicePropertyTableViewCell.h"
#import "PickerComponentView.h"
#import "GenericIndexUtil.h"
#import "RulesTableViewController.h"
#import "DevicePayload.h"
#import "AlmondManagement.h"
#import "iToast.h"
#import "ClientPayload.h"



@interface UseAsPresenseViewController ()<UITableViewDataSource,UITableViewDelegate,DevicePropertyTableViewCellDelegate,PickerComponentViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *sectionArr;
@property (nonatomic) NSArray *genericIndexes ;
@property (strong, nonatomic) NSIndexPath *indexPath;


@end

@implementation UseAsPresenseViewController
static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;
static const int normalheaderheight = 2;
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionArr = [NSMutableArray new];
    [self getSectionForTable];
    [self.tableView reloadData];
    NSLog(@"navigate items %@",self.genericIndexValue.genericIndex.navigateElements);
    [self initSection];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initSection{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
}
-(void)getSectionForTable{
    [self.sectionArr removeAllObjects];
    NSArray *genericIndexes = [GenericIndexUtil getDetailForNavigationItems:self.genericIndexValue.genericIndex.navigateElements clientID:@(self.genericIndexValue.deviceID).stringValue];
    self.genericIndexes = genericIndexes;
    for (GenericIndexValue *gIndexVal in genericIndexes) {
        GenericIndexClass *gClass = gIndexVal.genericIndex;
        [self.sectionArr addObject:gClass];
    }
    
    
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat kExpandedCellHeight = 160;
    CGFloat kNormalCellHeigh = 40;
    GenericIndexValue *gValue = [self.genericIndexes objectAtIndex:indexPath.row];
    
    if (self.indexPath == indexPath && !gValue.genericIndex.readOnly)
    {
        return kExpandedCellHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
    //return defRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    NSLog(@"gclass.header %@",gclass.header);
    if(gclass.header != nil)
        return defHeaderHeight + defHeaderLableHt;
    
    return normalheaderheight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    int viewHt;
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    if(gclass.header != nil)
    {
        viewHt = defHeaderHeight + defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
        [UICommonMethods setLableProperties:label text:gclass.header textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:18 alignment:NSTextAlignmentLeft];
        label.text = [gclass.header uppercaseString];
        [view addSubview:label];
    }
    else{
        viewHt = normalheaderheight;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), normalheaderheight)];
    }
    
    view.backgroundColor = [UIColor whiteColor];
    [UICommonMethods addLineSeperator:view yPos:viewHt-1];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    NSLog(@"footer  :: %@",gclass.footer);
    if(gclass.footer != nil)
        return defHeaderHeight + defHeaderLableHt;
    return normalheaderheight;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view;
    int viewHt;
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    if(gclass.footer != nil)
    {
        viewHt = defHeaderHeight + defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 10, viewHt)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(view.frame), viewHt)];
        
        [UICommonMethods setLableProperties:label text:NSLocalizedString(gclass.footer,@"") textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:13 alignment:NSTextAlignmentLeft];
        
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 3;
        [view addSubview:label];
    }
    else{
        viewHt = normalheaderheight;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), normalheaderheight)];
    }
    
    view.backgroundColor = [UIColor whiteColor];
    //    [UICommonMethods addLineSeperator:view yPos:viewHt-1];
    return view;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"devicepropertycell";
    
    DevicePropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DevicePropertyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    GenericIndexValue *gValue = [self.genericIndexes objectAtIndex:indexPath.section];
    NSString *leftlabel = gValue.genericIndex.groupLabel;
    NSString *property = gValue.genericIndex.property;
    NSString *rightlabel = gValue.genericValue.displayText?gValue.genericValue.displayText:gValue.genericValue.value;
    if(rightlabel == nil){
        rightlabel = @"";
    }
    
    NSDictionary *cellDict = @{@"leftLabel":leftlabel,
                               @"rightLabel":rightlabel};
    
    [cell setUpCell:cellDict property:property genericValue:gValue];
    
    NSDictionary *values = gValue.genericIndex.values;
    
    for(UIView *picView in cell.contentView.subviews){
        if([picView isKindOfClass:[PickerComponentView class]])
            [picView removeFromSuperview];
    }
    if (self.indexPath == indexPath && !gValue.genericIndex.readOnly)
    {
        
        NSDictionary *values = gValue.genericIndex.values;
        NSMutableArray *displayArr = [NSMutableArray new];
        NSMutableArray *ValueArr = [NSMutableArray new];
        NSLog(@"values button %@",values);
        if (gValue.genericIndex.formatter != nil) {
            [self getValueArrfromMin:gValue.genericIndex.formatter.min max:gValue.genericIndex.formatter.max displayArr:displayArr valueArr:ValueArr];
        }
        else{
            [self getGenericValVsDispDict:gValue.genericIndex.values displayArr:displayArr valueArr:ValueArr];
        }
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 160) displayList:displayArr valueList:ValueArr genericIndexValue:gValue];
       
        pickerView.delegate = self;
        //pickerView.center = self.view.center;
        pickerView.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.center.y);
        [cell.contentView addSubview:pickerView];
    }
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GenericIndexValue *gValue = [self.genericIndexes objectAtIndex:indexPath.section];
    NSString *leftlabel = gValue.genericIndex.groupLabel?:@"";
    NSString *property = gValue.genericIndex.property;
    if([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-38"]){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
        RulesTableViewController *viewController = [storyBoard   instantiateViewControllerWithIdentifier:@"RulesTableViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        //        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        if(self.indexPath == indexPath)
            self.indexPath = nil;
        else
            self.indexPath = indexPath;
        [tableView beginUpdates]; // Animate the height change
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
    }
}
-(void)getGenericValVsDispDict:(NSDictionary *)value displayArr:(NSMutableArray *)displayArr valueArr:(NSMutableArray *)valueArr{
    for (NSString *val in value) {
        GenericValue *gval = value[val];
        [displayArr addObject:gval.displayText];
        [valueArr addObject:val];
    }
}
-(void)getValueArrfromMin:(int)min max:(int)max displayArr:(NSMutableArray *)displayArr valueArr:(NSMutableArray *)valueArr {
    for(NSUInteger i=min;i<=max;i++){
        [displayArr addObject:@(i).stringValue];
        [valueArr addObject:@(i).stringValue];
    }
    
}
#pragma mark pickerView Delegate
-(void )pickerViewSelectedValue:(NSString *)value genericIndexValue:(GenericIndexValue *)genericIndexValue{
     mii = arc4random()%10000;
    Client *client = [[Client findClientByID:@(self.genericIndexValue.deviceID).stringValue] copy];
    [Client getOrSetValueForClient:client genericIndex:self.genericIndexValue.index newValue:value ifGet:NO];
    
    [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];
    [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:value];
}
-(void)deviceOnOffSwitchUpdate:(NSString *)status genericIndexValue:(GenericIndexValue *)genericIndexValue{
    [self pickerViewSelectedValue:status genericIndexValue:genericIndexValue];
    if ([status isEqualToString:@"ON"]) {
        [self getSectionForTable];
        [self reloadTable];
    }
    else{
        [self.sectionArr removeObjectAtIndex:2];
        [self.sectionArr removeObjectAtIndex:1];
         [self reloadTable];
    }
}
-(void)reloadTable{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}
#pragma mark command responses
-(void)onCommandResponse:(id)sender{ //mobile command sensor and client 1064
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    
    if (dataInfo==nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    
    if(local){
        payload = dataInfo[@"data"];
    }else{
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
    //    if (self.miiTable[payload[@"MobileInternalIndex"]] == nil || payload[@"MobileInternalIndex"] == nil) {
    //        return;
    //    }
    
    NSLog(@"payload mobile command: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if(isSuccessful == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
            [self reloadTable];
        });
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        iToast *toast = [iToast makeText:msg];
        toast = [toast setGravity:iToastGravityBottom];
        toast = [toast setDuration:2000];
        [toast show:iToastTypeWarning];
    });
}
@end
