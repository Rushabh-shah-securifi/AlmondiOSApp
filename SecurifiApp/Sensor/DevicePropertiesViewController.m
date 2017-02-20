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

#define DEVICE_PROPERTY_CELL @"devicepropertycell"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;
static const int normalheaderheight = 2;

@interface DevicePropertiesViewController () <DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;

@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceHeaderView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property BOOL is_Expanded;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property NSInteger deviceId;
@property BOOL isSensor;


@property (nonatomic) NSMutableArray *sectionArr;

@end

@implementation DevicePropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)initSection{
    self.sectionArr = [NSMutableArray new];
   
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
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
        [UICommonMethods setLableProperties:label text:gclass.header textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
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
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
        label.numberOfLines = 2;
        [UICommonMethods setLableProperties:label text:NSLocalizedString(gclass.footer,@"") textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
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
     GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
    NSString *leftlabel = gValue.genericIndex.groupLabel;
    NSString *property = gValue.genericIndex.property;
    NSString *rightlabel = gValue.genericValue.displayText?gValue.genericValue.displayText:gValue.genericValue.value;
    
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
        NSLog(@"values button %@",values);
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 160) arrayList:values];
        //pickerView.center = self.view.center;
        pickerView.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.center.y);
        [cell.contentView addSubview:pickerView];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
    {
        DeviceNotificationViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"DeviceNotificationViewController"];
    
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if(indexPath.section != 1 || indexPath.section != 0) {
        if(self.indexPath == indexPath)
            self.indexPath = nil;
        else
            self.indexPath = indexPath;
        
        [tableView beginUpdates]; // Animate the height change
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
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

@end
