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

#define DEVICE_PROPERTY_CELL @"devicepropertycell"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;

@interface DevicePropertiesViewController () <DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;

@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceHeaderView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property BOOL is_Expanded;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation DevicePropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  initSection];
    
    NSMutableArray *sectionArr = [NSMutableArray new];
    [self setUpDevicePropertyEditHeaderView];
    NSMutableArray *genericIndexObjs = [[NSMutableArray alloc]init];
    
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
    //self.expandedCells = [[NSMutableArray alloc]init];
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat kExpandedCellHeight = 160;
    CGFloat kNormalCellHeigh = 50;
    
    if (self.indexPath == indexPath)
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
    if(section == 2)
        return defHeaderHeight + defHeaderLableHt;
    
    return defHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    int viewHt;
    if(section == 2){
        viewHt = defHeaderHeight + defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
        [UICommonMethods setLableProperties:label text:@"TEMPERATURE" textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
        [view addSubview:label];
    }
    
    else{
        viewHt = defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), defHeaderHeight)];
    }
    
    view.backgroundColor = [UIColor whiteColor];
    [UICommonMethods addLineSeperator:view yPos:viewHt-1];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1)];
    //[UICommonMethods addLineSeperator:view yPos:0];
    return view;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= DEVICE_PROPERTY_CELL;
    
    DevicePropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DevicePropertyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setUpCell:nil indexPath:indexPath];
    if (self.indexPath == indexPath)
    {
        for(UIView *picView in cell.contentView.subviews){
            if([picView isKindOfClass:[PickerComponentView class]])
               [picView removeFromSuperview];
        }
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 160) arrayList:@[@"1",@"2",@"3",@"1",@"2",@"3"]];
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
