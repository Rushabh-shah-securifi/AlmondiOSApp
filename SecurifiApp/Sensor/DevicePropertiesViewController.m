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


#define DEVICE_PROPERTY_CELL @"devicepropertycell"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;
static const int normalheaderheight = 2;

@interface DevicePropertiesViewController () <DeviceHeaderViewDelegate,PickerComponentViewDelegate,DevicePropertyTableViewCellDelegate,SliderViewDelegate,HueColorPickerDelegate,UIGestureRecognizerDelegate>{
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


@property (nonatomic) NSMutableArray *sectionArr;


@end

@implementation DevicePropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ViewFrame = self.view.frame;
    [self  initSection];
    [self setUpDevicePropertyEditHeaderView];
    [self getSectionForTable];
    
    
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
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
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
    NSString *identifier= DEVICE_PROPERTY_CELL;
    
    DevicePropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DevicePropertyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
     GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
    NSString *leftlabel = gValue.genericIndex.groupLabel;
    
    NSString *property = gValue.genericIndex.property;
    if([property isEqualToString:@"displayHere"] && ([gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] || [gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW"])){
        property = @"EditText";
    }
    GenericValue *genericvalue = gValue.genericIndex.values[gValue.genericValue.value];
    NSString *rightlabel = gValue.genericValue.displayText?gValue.genericValue.displayText:genericvalue.displayText;
    
    if(!self.isSensor){
        rightlabel = genericvalue.displayText;
            if([gValue.genericIndex.ID isEqualToString:@"-11"])
                rightlabel = gValue.genericValue.displayText;
    }
    if(rightlabel == nil){
        rightlabel = @"";
    }
    
    NSDictionary *cellDict = @{@"leftLabel":leftlabel,
                               @"rightLabel":rightlabel};
    
    [cell setUpCell:cellDict property:property genericValue:gValue];
    NSString* value = [Device getValueForIndex:gValue.index deviceID:gValue.deviceID];
    
    
    for(UIView *picView in cell.contentView.subviews){
        if([picView isKindOfClass:[PickerComponentView class]] || [picView isKindOfClass:[Slider class]])
            [picView removeFromSuperview];
    }
    if (self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"MULTI_BUTTON"] || [gValue.genericIndex.layoutType isEqualToString:@"LIST"] || [gValue.genericIndex.layoutType isEqualToString:@"SINGLE_TEMP"]))
    {
        
        NSDictionary *values = gValue.genericIndex.values;
        NSMutableArray *displayArr = [NSMutableArray new];
        NSMutableArray *ValueArr = [NSMutableArray new];
        NSLog(@"values button %@",values);
        
        if(gValue.genericIndex.values) {
             [self getGenericValVsDispDict:gValue.genericIndex.values displayArr:displayArr valueArr:ValueArr];
        }
        else{
             [self getValueArrfromMin:gValue.genericIndex.formatter.min max:gValue.genericIndex.formatter.max displayArr:displayArr valueArr:ValueArr];
        }
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 160) displayList:displayArr valueList:ValueArr];
        pickerView.delegate = self;
        //pickerView.center = self.view.center;
        pickerView.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.center.y);
        [cell.contentView addSubview:pickerView];
    }
    else if(self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"SLIDER_ICON"] || [gValue.genericIndex.layoutType isEqualToString:@"SLIDER"])){
        Slider *horzView = [[Slider alloc]initWithFrame:CGRectMake(0, 60, cell.contentView.frame.size.width, 40) color:[SFIColors ruleBlueColor] genericIndexValue:gValue];
        horzView.delegate = self;
        [horzView setSliderValue:[[gValue.genericIndex.formatter transformValue:value] intValue]];
        [cell.contentView addSubview:horzView];

    }
    else if(self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"SLIDER_ICON"] || [gValue.genericIndex.layoutType isEqualToString:@"SLIDER"])){
        Slider *horzView = [[Slider alloc]initWithFrame:CGRectMake(0, 60, cell.contentView.frame.size.width, 40) color:[SFIColors ruleBlueColor] genericIndexValue:gValue];
        horzView.delegate = self;
        [cell.contentView addSubview:horzView];
        
    }
    else if(self.indexPath == indexPath && !gValue.genericIndex.readOnly && ([gValue.genericIndex.layoutType isEqualToString:@"HUE"])){
        HueColorPicker *horzView = [[HueColorPicker alloc]initWithFrame:CGRectMake(0, 60, cell.contentView.frame.size.width, 40) color:[SFIColors ruleBlueColor] genericIndexValue:gValue];
        horzView.delegate = self;
        [cell.contentView addSubview:horzView];
        
    }
    return cell;
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
    NSLog(@"navigation item arr %@,%@",gValue.genericIndex.navigateElements,gValue.genericIndex.elements);
    NSString *leftlabel = gValue.genericIndex.groupLabel?:@"";
    
    NSString *property = gValue.genericIndex.property;
    if([property isEqualToString:@"navigate"] && ([gValue.genericIndex.ID isEqualToString:@"-3"])){
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
        [self.navigationController pushViewController:viewController animated:YES];
//        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-37"]){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
        SFIScenesTableViewController *viewController = [storyBoard   instantiateViewControllerWithIdentifier:@"SFIScenesTableViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    else if([property isEqualToString:@"navigate"] && [gValue.genericIndex.ID isEqualToString:@"-41"]){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
        AdvanceInformationViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"AdvanceInformationViewController"];
        viewController.genericIndexValue = gValue;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    else if(!([gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] || [gValue.genericIndex.layoutType isEqualToString:@"TEXT_VIEW"])){
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
#pragma mark pickerView Delegate
-(void )pickerViewSelectedValue:(NSString *)value genericIndexValue:(GenericIndexValue *)genericIndexValue{
    
    [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:value];
}
#pragma mark cell delegate methods
-(void)deviceNameUpdate:(NSString *)name genericIndexValue:(GenericIndexValue*)genericIndexValue{

    [DevicePayload getNameLocationChange:genericIndexValue mii:mii value:name];
}
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue currentView:(UIView*)currentView{

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

@end
