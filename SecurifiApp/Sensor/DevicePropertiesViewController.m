//
//  DevicePropertiesViewController.m
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DevicePropertiesViewController.h"
#import "DeviceHeaderView.h"
#import "CommonMethods.h"
#import "UICommonMethods.h"
#import "DevicePropertyTableViewCell.h"
#import "UICommonMethods.h"
#import "PickerComponentView.h"
#import "DeviceNotificationViewController.h"
#import "GenericIndexUtil.h"
#import "DevicePayload.h"
#import "SFIScenesTableViewController.h"
#import "RulesTableViewController.h"
#import "ClientTableViewController.h"
#import "UseAsPresenseViewController.h"
#import "Slider.h"
#import "SFIColors.h"
#import "HueColorPicker.h"
#import "AdvanceInformationViewController.h"
#import "GenericDeviceClass.h"
#import "TextInput.h"
#import "AlmondManagement.h"
#import "iToast.h"
#import "ClientPayload.h"

#define DEVICE_PROPERTY_CELL @"devicepropertycell"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;
static const int normalheaderheight = 2;

@interface DevicePropertiesViewController () <DeviceHeaderViewDelegate,PickerComponentViewDelegate,DevicePropertyTableViewCellDelegate,SliderViewDelegate,HueColorPickerDelegate,UIGestureRecognizerDelegate,TextInputDelegate>{
int mii;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;

@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceHeaderView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property BOOL is_Expanded;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property NSInteger deviceId;
@property BOOL isSensor;
@property (nonatomic) CGRect ViewFrame;
@property (nonatomic) NSInteger touchComp;
@property (nonatomic )NSMutableDictionary *miiTable ;


@property (nonatomic) NSMutableArray *sectionArr;


@end

@implementation DevicePropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ViewFrame = self.view.frame;
    
    
    
}

-(void)getSectionForTable{
    GenericParams *gparams = self.genericParams;
    self.deviceId = gparams.headerGenericIndexValue.deviceID;
    self.isSensor = gparams.isSensor;
    
    NSLog(@"Index value arr %@",gparams.indexValueList);
    for(NSDictionary *dict in gparams.indexValueList){
        GenericIndexClass *gClass = dict[@"generic_index"];
        [self.sectionArr addObject:gClass];
    }

}
-(NSArray *)getRowforSection:(NSInteger)sectionNumber{
    GenericParams *gparams = self.genericParams;
    NSDictionary *dict = [gparams.indexValueList objectAtIndex:sectionNumber];
     NSArray *genericIndexValueArr = dict[@"generic_inxex_values_array"];
    return [self getRowFortable:genericIndexValueArr];
}
-(NSArray *)getRowFortable:(NSArray *)genericIndexValueArr{
     NSMutableArray *rowArr = [NSMutableArray new];
    for (GenericIndexValue *gIndexVal in genericIndexValueArr) {
        NSLog(@"gIndexVal in %@",gIndexVal);
        [rowArr addObject:gIndexVal];
    }
    return rowArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    self.miiTable = [NSMutableDictionary new];
    [self  initSection];
    [self setUpDevicePropertyEditHeaderView];
    [self getSectionForTable];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
     [self.miiTable removeAllObjects];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)initSection{
    self.sectionArr = [NSMutableArray new];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
    
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
    [center addObserver:self //common dynamic reponse handler for sensor and clients
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
}

-(void)setUpDevicePropertyEditHeaderView{
    if(self.genericParams.isSensor){
        [self.deviceHeaderView initialize:self.genericParams cellType:SensorEdit_Cell isSiteMap:NO];
    }
    else{
        [self.deviceHeaderView initialize:self.genericParams cellType:ClientEditProperties_cell isSiteMap:NO];
    }
    self.deviceHeaderView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowCountForSection = [self getRowforSection:section];
    return rowCountForSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat kExpandedCellHeight = 160;
    CGFloat kNormalCellHeigh = 40;
     GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
    
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
-(UIView *)tableHeaderViewForSection:(NSInteger)section fontSize:(NSInteger)fontSize title:(NSString *)title height:(NSInteger )height{
    
    UIView *view;
    int viewHt;
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    if(gclass.header != nil)
    {
//        viewHt = defHeaderHeight + defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.tableView.frame) -10, height)];
        view.backgroundColor = [UIColor greenColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 17, CGRectGetWidth(view.frame), defHeaderLableHt)];
        
        [UICommonMethods setLableProperties:label text:gclass.header textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:fontSize alignment:NSTextAlignmentLeft];
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    int viewHt;
     viewHt = defHeaderHeight + defHeaderLableHt;
    return  [self tableHeaderViewForSection:section fontSize:18 title:@"" height:viewHt];
//    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
//    if(gclass.header != nil)
//    {
//        viewHt = defHeaderHeight + defHeaderLableHt;
//        view = [[UIView alloc]initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.tableView.frame) -10, viewHt)];
//        view.backgroundColor = [UIColor greenColor];
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 17, CGRectGetWidth(view.frame), defHeaderLableHt)];
//        
//        [UICommonMethods setLableProperties:label text:gclass.header textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:18 alignment:NSTextAlignmentLeft];
//        label.text = [gclass.header uppercaseString];
//        [view addSubview:label];
//    }
//    else{
//        viewHt = normalheaderheight;
//        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), normalheaderheight)];
//    }
//    
//    view.backgroundColor = [UIColor whiteColor];
//    [UICommonMethods addLineSeperator:view yPos:viewHt-1];
//    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    NSLog(@"footer  :: %@",gclass.footer);
    if(gclass.footer != nil)
        return defHeaderHeight + defHeaderLableHt;
    return normalheaderheight;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    int viewHt;
    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
    viewHt = defHeaderHeight + defHeaderLableHt;
    return  [self tableHeaderViewForSection:section fontSize:13 title:NSLocalizedString(gclass.footer,@"") height:viewHt];
//    GenericIndexClass *gclass = [self.sectionArr objectAtIndex:section];
//    if(gclass.footer != nil)
//    {
//        viewHt = defHeaderHeight + defHeaderLableHt;
//        view = [[UIView alloc]initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.tableView.frame) - 10, viewHt)];
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, CGRectGetWidth(view.frame), viewHt)];
//        
//        [UICommonMethods setLableProperties:label text:NSLocalizedString(gclass.footer,@"") textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:13 alignment:NSTextAlignmentLeft];
//        
//        label.lineBreakMode = NSLineBreakByWordWrapping;
//        label.numberOfLines = 3;
//        [view addSubview:label];
//    }
//    else{
//        viewHt = normalheaderheight;
//        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), normalheaderheight)];
//    }
//    
//    view.backgroundColor = [UIColor whiteColor];
////    [UICommonMethods addLineSeperator:view yPos:viewHt-1];
//    return view;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= DEVICE_PROPERTY_CELL;
    
    DevicePropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DevicePropertyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    
    GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
    
    GenericValue *genericvalue = gValue.genericIndex.values[gValue.genericValue.value];
    
    NSDictionary *cellDict = [self getcellDictGenericIndexValue:genericvalue genericIndexValue:gValue];
    
    NSString *property = gValue.genericIndex.property;
    
    if([property isEqualToString:@"displayHere"] && ([gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] || [gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW"])){
        property = @"EditText";
    }
   
    [cell setUpCell:cellDict property:property genericValue:gValue];
   
    for(UIView *picView in cell.contentView.subviews){
        if([picView isKindOfClass:[PickerComponentView class]] || [picView isKindOfClass:[Slider class]])
            [picView removeFromSuperview];
    }
    if (self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"MULTI_BUTTON"] || [gValue.genericIndex.layoutType isEqualToString:@"LIST"] || [gValue.genericIndex.layoutType isEqualToString:@"SINGLE_TEMP"]))
    {
        [self addPickerComponent:gValue tableCell:cell];
    }
    else if(self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"SLIDER_ICON"] || [gValue.genericIndex.layoutType isEqualToString:@"SLIDER"])){
        [self addSlider:gValue tableCell:cell];
    }
    else if(self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"HUE"])){
        [self addHueComponent:gValue tableCell:cell];
    }
    else if(self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] || [gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW"])){
        [self addEditText:gValue tableCell:cell];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *property = gValue.genericIndex.property;
    
    if([property isEqualToString:@"navigate"] && ([gValue.genericIndex.ID isEqualToString:@"-3"] || [gValue.genericIndex.ID isEqualToString:@"-2"])){
        DeviceNotificationViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"DeviceNotificationViewController"];
        viewController.genericIndexValue = gValue;
        
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if ([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-12"]){
        
        ClientTableViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"ClientTableViewController"];
        viewController.genericIndexValue = gValue;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    else if ([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-17"]){
        
        UseAsPresenseViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"UseAsPresenseViewController"];
        viewController.genericIndexValue = gValue;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    else if([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-38"]){
       
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
        RulesTableViewController *viewController = [storyBoard   instantiateViewControllerWithIdentifier:@"RulesTableViewController"];
        viewController.doDeviceFiltering = YES;
        viewController.deviceID = gValue.deviceID;
        [self.navigationController pushViewController:viewController animated:YES];
//        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-37"]){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
        SFIScenesTableViewController *viewController = [storyBoard   instantiateViewControllerWithIdentifier:@"SFIScenesTableViewController"];
        viewController.doDeviceFiltering = YES;
        viewController.deviceID = gValue.deviceID;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    else if([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-41"]){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
        AdvanceInformationViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"AdvanceInformationViewController"];
        viewController.genericIndexValue = gValue;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    else{
        if(self.indexPath == indexPath)
            self.indexPath = nil;
        else
            self.indexPath = indexPath;
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [tableView beginUpdates];
            [tableView endUpdates];
        } completion:nil];
//        [tableView beginUpdates]; // Animate the height change
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
//
//        [tableView endUpdates];
    }
}
-(UIViewController *)getViewcontrollerID:(NSString *)identifier viewControllerName:(UIViewController *)vc{
    
    
    
    return vc;
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


#pragma mark action
- (IBAction)onDoneBtnTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getDeviceLayoutArray{
    NSArray *sectionArrRef = @[@"-1",@"-2",@"10000",@"-42",@"-43"];
    NSMutableArray *sectionArr = [[NSMutableArray alloc]init];
    for(GenericIndexValue *genericIndexValue in self.genericParams.indexValueList)
    {
        GenericIndexClass *genericIndexObj = genericIndexValue.genericIndex;
        NSLog(@"group lbl and ID %@ ,%@",genericIndexObj.groupLabel,genericIndexObj.ID);
        if([genericIndexObj.ID isEqualToString:@"-1"]){
            NSDictionary *NameDict = [[NSDictionary alloc]init];
            
        }
    }
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
    GenericIndexValue *genIndexVal = self.miiTable[payload[@"MobileInternalIndex"]];
    int dType = [Device getTypeForID:genIndexVal.deviceID];
    if(self.genericParams.isSensor){
        NSLog(@"sensor");
        if(isSuccessful == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
            });
        }
        else {
        dispatch_async(dispatch_get_main_queue(), ^{
                [self repaintHeader:genIndexVal];
            });
        }
}
}
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
    
    if(self.genericParams.isSensor){
        NSLog(@"device edit - dynamic response - currently handling only mobile response in controller");
        //perhaps you have to check device id of dynamic response and pop if matches, perhaps
        
    }
    [self reloadTable];
}
-(void)reloadTable{
     dispatch_async(dispatch_get_main_queue(), ^() {
          self.indexPath = nil;
          [self.tableView reloadData];
     });
}
-(void)repaintHeader:(GenericIndexValue*)genIndexVal{
    NSLog(@"repaintHeader");
    Device *device = [Device getDeviceForID:genIndexVal.deviceID];
    GenericIndexValue *headerGenIndexVal = [GenericIndexUtil getHeaderGenericIndexValueForDevice:device];
    self.genericParams.headerGenericIndexValue = headerGenIndexVal;
    self.genericParams.deviceName = device.name;
    
    [self.deviceHeaderView resetHeaderView];
    [self.deviceHeaderView initialize:self.genericParams cellType:SensorEdit_Cell isSiteMap:NO];
    NSLog(@"resetHeader: %f",self.deviceHeaderView.frame.origin.y);
}
- (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        iToast *toast = [iToast makeText:msg];
        toast = [toast setGravity:iToastGravityBottom];
        toast = [toast setDuration:2000];
        [toast show:iToastTypeWarning];
    });
}
#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)toggle:(GenericIndexValue *)headerGenericIndexValue{
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    mii = arc4random()%10000;
    
    headerGenericIndexValue = [GenericIndexValue getLightCopy:headerGenericIndexValue];
    headerGenericIndexValue.currentValue = headerGenericIndexValue.genericValue.toggleValue;
    headerGenericIndexValue.clickedView = nil;
    
    [self.miiTable setValue:headerGenericIndexValue forKey:@(mii).stringValue];
    [DevicePayload getSensorIndexUpdate:headerGenericIndexValue mii:mii];
}
#pragma mark pickerView Delegate
-(void )pickerViewSelectedValue:(NSString *)value genericIndexValue:(GenericIndexValue *)genericIndexValue{
    [self reloadTable];
    [self save:value forGenericIndexValue:genericIndexValue currentView:nil];
    }
#pragma mark cell delegate methods
-(void)deviceNameUpdate:(NSString *)name genericIndexValue:(GenericIndexValue*)genericIndexValue{
    [self save:name forGenericIndexValue:genericIndexValue currentView:nil];
}
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue currentView:(UIView*)currentView{
    [self reloadTable];
   
    mii = arc4random()%10000;
    [self.miiTable setValue:genericIndexValue forKey:@(mii).stringValue];
    if(self.genericParams.isSensor){
        [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:newValue];
    }
    else{
        Client *client = [[Client findClientByID:@(genericIndexValue.deviceID).stringValue] copy];
        [Client getOrSetValueForClient:client genericIndex:genericIndexValue.index newValue:newValue ifGet:NO];
        
        [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];
    }

}
-(void)linkToNextScreen:(GenericIndexValue *)genericIndexValue{
    // link to notification screen
    if([genericIndexValue.genericIndex.ID isEqualToString:@"-40"]){
        
        DeviceNotificationViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"DeviceNotificationViewController"];
        viewController.genericIndexValue = genericIndexValue;
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
}
#pragma mark slider delegate
-(void)deviceOnOffSwitchUpdate:(NSString *)status genericIndexValue:(GenericIndexValue*)genericIndexValue{
    
}
-(void)blinkNew:(NSString *)newValue{
    
}
#pragma mark gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)tapTest:(UITapGestureRecognizer *)sender {
    self.touchComp = [sender locationInView:self.view].y;
}
#pragma  mark uiwindow delegate methods
- (void)onKeyboardDidShow:(id)notification {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(self.touchComp  > keyboardSize.height){
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect f = self.view.frame;
            CGFloat y = -keyboardSize.height ;
            f.origin.y =  y + 80;
            self.view.frame = f;
            //        NSLog(@"keyboard frame %@",NSStringFromCGRect(self.parentView.frame));
        }];
    }
}

-(void)onKeyboardDidHide:(id)notice {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = self.ViewFrame.origin.y;
        self.view.frame = f;
    }];
}
-(void)delegateDeviceEditSettingClick{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)delegateClientPropertyEditSettingClick{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark tabelcell bhelper methods

-(NSDictionary *)getcellDictGenericIndexValue:(GenericValue *)gval genericIndexValue:(GenericIndexValue *)gValue{
    
    NSString *leftLbl = gValue.genericIndex.groupLabel;
    
     NSString *rightlabel = gValue.genericValue.displayText?gValue.genericValue.displayText:gval.displayText;

    if(!self.isSensor){
        rightlabel = gval.displayText;
        if([gValue.genericIndex.ID isEqualToString:@"-11"])
            rightlabel = gValue.genericValue.displayText;
    }
    else{
        if([gValue.genericIndex.ID isEqualToString:@"-1"] || [gValue.genericIndex.ID isEqualToString:@"-2"])
            rightlabel = gValue.genericValue.value;
        NSLog(@"genericvalue.value %@",gValue.genericValue.value);
    }
    if(rightlabel == nil){
        rightlabel = gValue.genericValue.value;
        rightlabel = @"";
    }
    

    NSString *deviceTypeString = @([Device getTypeForID:gValue.deviceID]).stringValue;
    GenericDeviceClass *genericDevice = [SecurifiToolkit sharedInstance].genericDevices[deviceTypeString];
    NSDictionary *cellDict = @{@"leftLabel":leftLbl,
                               @"rightLabel":rightlabel,
                               @"icon":genericDevice.defaultIcon
                               };
    return cellDict;
}
-(void)addPickerComponent:(GenericIndexValue *)gValue tableCell:(UITableViewCell *)cell{
    NSMutableArray *displayArr = [NSMutableArray new];
    NSMutableArray *ValueArr = [NSMutableArray new];
    
    if(gValue.genericIndex.values) {
        [self getGenericValVsDispDict:gValue.genericIndex.values displayArr:displayArr valueArr:ValueArr];
    }
    else{
        [self getValueArrfromMin:gValue.genericIndex.formatter.min max:gValue.genericIndex.formatter.max displayArr:displayArr valueArr:ValueArr];
    }
    PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 160) displayList:displayArr valueList:ValueArr genericIndexValue:gValue];
    pickerView.delegate = self;
    //pickerView.center = self.view.center;
    pickerView.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.center.y);
    [cell.contentView addSubview:pickerView];
}
-(void)addSlider:(GenericIndexValue *)gValue tableCell:(UITableViewCell *)cell{
     NSString* value = [Device getValueForIndex:gValue.index deviceID:gValue.deviceID];
    Slider *horzView = [[Slider alloc]initWithFrame:CGRectMake(0, 60, cell.contentView.frame.size.width, 40) color:self.genericParams.color genericIndexValue:gValue];
    horzView.delegate = self;
    [horzView setSliderValue:[[gValue.genericIndex.formatter transformValue:value] intValue]];
    [cell.contentView addSubview:horzView];

}
-(void)addEditText:(GenericIndexValue *)gValue tableCell:(UITableViewCell *)cell{
    TextInput *textInputView = [[TextInput alloc]initWithFrame:CGRectMake(15, 60, cell.contentView.frame.size.width -15, 40)  color:[SFIColors ruleBlueColor] genericIndexValue:gValue isSensor:YES];
    textInputView.delegate = self;
    [cell.contentView addSubview:textInputView];
}
-(void)addHueComponent:(GenericIndexValue *)gValue tableCell:(UITableViewCell *)cell{
    HueColorPicker *horzView = [[HueColorPicker alloc]initWithFrame:CGRectMake(0, 60, cell.contentView.frame.size.width, 40) color:[SFIColors ruleBlueColor] genericIndexValue:gValue];
    horzView.delegate = self;
    [cell.contentView addSubview:horzView];
}

@end
