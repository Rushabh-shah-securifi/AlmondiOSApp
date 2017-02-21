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



@interface UseAsPresenseViewController ()<UITableViewDataSource,UITableViewDelegate,DevicePropertyTableViewCellDelegate,PickerComponentViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *sectionArr;
@property (strong, nonatomic) NSIndexPath *indexPath;


@end

@implementation UseAsPresenseViewController
static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;
static const int normalheaderheight = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionArr = [NSMutableArray new];
    [self getSectionForTable];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSectionForTable{
    GenericParams *gparams = self.genericParams;
    
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
    NSString *identifier= @"devicepropertycell";
    
    DevicePropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DevicePropertyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    GenericIndexValue *gValue = [[self getRowforSection:indexPath.section] objectAtIndex:indexPath.row];
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
        NSLog(@"values button %@",values);
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 160) arrayList:values];
        pickerView.delegate = self;
        //pickerView.center = self.view.center;
        pickerView.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.center.y);
        [cell.contentView addSubview:pickerView];
    }
    return cell;
}

@end
