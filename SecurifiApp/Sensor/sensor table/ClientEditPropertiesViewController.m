//
//  ClientEditPropertiesViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 02/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientEditPropertiesViewController.h"
#import "SensorButtonView.h"
#import "SensorTextView.h"
#import "SFIColors.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "clientTypeCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "CollectionViewCell.h"
#import "CommonCell.h"


@interface ClientEditPropertiesViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,clientTypeCellDelegate,SensorButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *clientInfoView;
@property (weak, nonatomic) IBOutlet UIView *indexView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (nonatomic) UITableView *tableType;
@property (strong ,nonatomic) UISegmentedControl *allowOnNetworkSegment;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *clientTypesView;
@property (nonatomic)UIView *allowOnNetworkView;
@property (nonatomic)UICollectionView *collectionView;
@property (nonatomic)NSString *selectedType;/*    NSMutableString *hexBlockedDays;
*/
@property (nonatomic)NSMutableString *hexBlockedDays;

@end

@implementation ClientEditPropertiesViewController
static const float ITEM_SPACING = 2.0;
NSMutableArray * blockedDaysArray;
NSString *blockedType;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawViews];
    self.selectedType = [self.deviceDict valueForKey:@"Type"];
    CommonCell *commonView = [[CommonCell alloc]initWithFrame:CGRectMake(5, 18, self.view.frame.size.width -10, 70)];
    [self.view addSubview:commonView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)drawViews{
    if([self.indexName isEqualToString:@"Name"]){
        self.indexLabel.text = self.indexName;
        
        [self textFieldView:[self.deviceDict valueForKey:self.indexName]];
    }
    else if ([self.indexName isEqualToString:@"Type"]){
        self.indexView.hidden = YES;
        CGRect fr = self.indexView.frame;
        fr.origin.x = self.indexView.frame.origin.x;
        fr.origin.y = self.indexView.frame.origin.y ;
        fr.size.height = self.indexView.frame.size.height + 300;
        self.clientTypesView = [[UIView alloc]init];
        self.clientTypesView.frame = fr;
        
        self.tableType = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.clientTypesView.frame.size.width, self.clientTypesView.frame.size.height)];
        [self.tableType setDataSource:self];
        [self.tableType setDelegate:self];
//        [self.tableType registerClass:[clientTypeCell class] forCellReuseIdentifier:@"clientTypeCell"];
        self.tableType.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableType.allowsSelection = NO;
        
        [self.tableType reloadData];
//        self.indexView = self.tableType;
        [self.clientTypesView addSubview:self.tableType];
        [self.view addSubview:self.clientTypesView];
    }
    
    else if ([self.indexName isEqualToString:@"AllowedType"]){
        [self gridView];
       
    }
    else if ([self.indexName isEqualToString:@"pesenceSensor"]){
        NSArray *arr = @[@"YES",@"NO",@"ON",@"OFF"];
        int currentValPos = 0;
        for(NSString *str in arr){
            if([str isEqualToString:[self.deviceDict valueForKey:self.indexName]])
                break;
        currentValPos++;
        }
        self.indexLabel.text = self.indexName;
        
        [self buttonView:arr selectedValue:currentValPos];
    }
    else if ([self.indexName isEqualToString:@"inActiveTimeOut"]){
        self.indexLabel.text = self.indexName;
        [self textFieldView:[self.deviceDict valueForKey:self.indexName]];
    }
    else if ([self.indexName isEqualToString:@"Other"]){
        
    }

}
-(void)textFieldView:(NSString *)name{
    SensorTextView *textView = [[SensorTextView alloc]initWithFrame:CGRectMake(4,20,self.indexView.frame.size.width - 8,40)];
    textView.color = [UIColor clearColor];
    [textView drawTextField:name];
    CGRect fr = self.indexView.frame;
    fr.origin.x = self.indexView.frame.origin.x;
    fr.origin.y = self.indexView.frame.origin.y;
    fr.size.height = self.indexView.frame.size.height - 200;
    self.indexView.frame = fr;
    [self.indexView addSubview:textView];

}

-(void)buttonView:(NSArray*)arr selectedValue:(int)selectedVal{
    
    SensorButtonView *presenceSensor = [[SensorButtonView alloc]initWithFrame:CGRectMake(5,40,self.indexView.frame.size.width - 8,30 )];
    presenceSensor.color = [SFIColors clientGreenColor];
    [presenceSensor drawButton:arr selectedValue:selectedVal];
    presenceSensor.delegate = self;
    [self.indexView addSubview:presenceSensor];
}

-(void)updateButtonStatus:(NSString *)newValue{//here we have to pass many things like deviceIndexId,deviceID,...
}

#pragma mark uitableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      NSArray *type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
        return type.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSArray *type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    clientTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clientTypeCell"];
    if (cell == nil) {
        cell = [[clientTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientTypeCell"];
        [cell setupLabel];
        //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    int currentvalPos = 0;
    for(NSString *str in type){
        if([str isEqualToString:self.selectedType])
            break;
        currentvalPos++;
    }
    cell.delegate = self;
    cell.color = [SFIColors clientGreenColor];
    cell.backgroundColor = [SFIColors clientGreenColor];
    [cell writelabelName:[type objectAtIndex:indexPath.row]];
    if(currentvalPos == indexPath.row)
        [cell changeButtonColor];
    return cell;


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

#pragma mark cell delegate
-(void)selectedTypes:(NSString *)typeName{
    self.selectedType = typeName;
    [self.tableType reloadData];
}
#pragma mark gridView
-(void)gridView{
    [self addSegmentControll];
    
}
-(void)addSegmentControll{
    self.allowOnNetworkView = [[UIView alloc]initWithFrame:CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y, self.indexView.frame.size.width, self.view.frame.size.height - self.indexView.frame.origin.y -150)];
    self.allowOnNetworkView.backgroundColor = [SFIColors clientGreenColor];
    [self.view addSubview:self.allowOnNetworkView];
    self.indexView.hidden = YES;
    
    UILabel *indexLabel = [[UILabel alloc]initWithFrame:self.indexLabel.frame];
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont securifiFont:14];
    indexLabel.text = @"Allow On network";
    indexLabel.backgroundColor = [UIColor clearColor];
    [self.allowOnNetworkView addSubview:indexLabel];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Always", @"Schedule", @"Block", nil];
    self.allowOnNetworkSegment = [[UISegmentedControl alloc]initWithItems:itemArray];
    self.allowOnNetworkSegment.frame = CGRectMake(self.indexView.frame.origin.x + 5, indexLabel.frame.size.height + 10, self.indexView.frame.size.width - 10, 25);
    self.allowOnNetworkSegment.center = CGPointMake(CGRectGetMidX(self.indexView.bounds), self.allowOnNetworkSegment.center.y);
    self.allowOnNetworkSegment.tintColor = [UIColor whiteColor];
//    self.allowOnNetworkSegment.segmentedControlStyle = UISegmentedControlStylePlain;
    [self.allowOnNetworkSegment addTarget:self action:@selector(segmentControllChanged:) forControlEvents: UIControlEventValueChanged];
    [self setUpAllowOnNetworkSegment];
    [self.allowOnNetworkView addSubview:self.allowOnNetworkSegment];
    
    //self.indexView.frame = CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y, self.indexView.frame.size.width, 500);
//    [self.view addSubview:self.indexView];
}
-(void)setUpAllowOnNetworkSegment{
    if([[self.deviceDict valueForKey:@"AllowedType"] isEqualToString:@"0"]){
        self.scrollView.hidden = YES;
        self.allowOnNetworkSegment.selectedSegmentIndex = 0; //Always
        blockedType = @"0";
        self.hexBlockedDays = [@"000000,000000,000000,000000,000000,00000,00000" mutableCopy];
    }else if([[self.deviceDict valueForKey:@"AllowedType"] isEqualToString:@"1"]){
        self.scrollView.hidden = YES;
        self.allowOnNetworkSegment.selectedSegmentIndex = 2; //Blocked
        self.hexBlockedDays = [@"ffffff,ffffff,ffffff,ffffff,ffffff,ffffff,ffffff" mutableCopy];
        blockedType = @"1";
    }else{
         self.scrollView.hidden = NO;
        self.allowOnNetworkSegment.selectedSegmentIndex = 1; //OnSchedule
        blockedType = @"2";
    }
}

-(void)segmentControllChanged:(id)sender{
    switch (self.allowOnNetworkSegment.selectedSegmentIndex) {
        case 0:
            {
            self.scrollView.hidden = YES;
                self.collectionView.hidden = YES;
                [self.scrollView removeFromSuperview];
            }break;
        case 1:
            {
                
                self.scrollView.hidden = NO;
                self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.allowOnNetworkView.frame.origin.x, self.allowOnNetworkSegment.frame.origin.y + self.allowOnNetworkSegment.frame.size.height + 10, self.indexView.frame.size.width - 10, self.view.frame.size.height - self.indexView.frame.origin.y - 100)];
                self.scrollView.backgroundColor = [UIColor clearColor];
                [self.allowOnNetworkView addSubview:self.scrollView];
                [self addInfo];
                
                
            
            }break;
        case 2:
            {
                [self.scrollView removeFromSuperview];
            self.scrollView.hidden = YES;
                self.collectionView.hidden = YES;
            }break;
        default:
            break;
    }
}
-(void)addInfo{
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    infoView.backgroundColor = [UIColor clearColor];
    UILabel *blockImg;
    UILabel *blockLbl;
    UILabel *UnblockImg;
    UILabel *unBlockLbl;
    blockImg = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    blockLbl = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, 70, 20)];
    UnblockImg = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 20, 20)];
    unBlockLbl = [[UILabel alloc]initWithFrame:CGRectMake(122, 0, 70, 20)];
    
    blockImg.backgroundColor = [UIColor colorFromHexString:@"DADADC"];
    blockLbl.text = @"Block";
    blockLbl.textColor = [UIColor whiteColor];
    blockLbl.font = [UIFont securifiLightFont:14];
    
    UnblockImg.backgroundColor = [UIColor whiteColor];
    unBlockLbl.text = @"Unblock";
    unBlockLbl.textColor = [UIColor whiteColor];
    unBlockLbl.font = [UIFont securifiLightFont:14];
    
    [infoView addSubview:blockImg];
    [infoView addSubview:blockLbl];
    [infoView addSubview:UnblockImg];
    [infoView addSubview:unBlockLbl];
    
    infoView.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), infoView.center.y);
    [self.scrollView addSubview:infoView];
    UILabel *infoLabel = [[UILabel alloc]
                          initWithFrame:CGRectMake(0, infoView.frame.size.height, self.scrollView.frame.size.width, 80)];
    infoLabel.text = @"Tap on the 24/7 grid to create a schedule during which this device is blocked/unblocked on the network. Also, you can tap on (Su,Mo..) to block/unblock device on that particular day or (0,1..) for particular hour.";
    infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    infoLabel.backgroundColor = [SFIColors clientGreenColor];
    infoLabel.font = [UIFont securifiLightFont:12];
    infoLabel.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), infoLabel.center.y);
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.numberOfLines = 4;
    infoLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:infoLabel];
     UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, infoLabel.frame.size.height + infoView.frame.size.height +5, self.scrollView.frame.size.width, 1020) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    self.collectionView.backgroundColor = [SFIColors clientGreenColor];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.allowsMultipleSelection = YES;
    [self.scrollView addSubview:self.collectionView];
    [self initializeblockedDaysArray];
 
    
}
-(void)initializeblockedDaysArray{
    blockedDaysArray = [NSMutableArray new];
    
    for(int i = 0; i <= 8; i++){
        NSMutableDictionary *blockedHours = [NSMutableDictionary new];
        for(int j = 0; j <= 25; j++){
            [blockedHours setValue:@"0" forKey:@(j).stringValue];
        }
        [blockedDaysArray addObject:blockedHours];
    }
    NSArray *strings = [[self.deviceDict valueForKey:@"Schedule"] componentsSeparatedByString:@","];
    if([strings count] > 7){
        return;
    }
    int dictCount = 1;
    for(NSString *hex in strings){
        NSUInteger hexAsInt;
        NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:dictCount];
        [[NSScanner scannerWithString:hex] scanHexInt:&hexAsInt];
        NSString *binary = [NSString stringWithFormat:@"%@", [self toBinary:hexAsInt]];
        int len = (int)binary.length;
        for (NSInteger charIdx=len-1; charIdx>=0; charIdx--)
            [blockedHours setValue:[NSString stringWithFormat:@"%c", [binary characterAtIndex:charIdx]] forKey:@(len-charIdx).stringValue];
        dictCount++;
    }

}
-(NSString *)toBinary:(NSUInteger)input
{
    if (input == 1 || input == 0)
        return [NSString stringWithFormat:@"%lu", (unsigned long)input];
    return [NSString stringWithFormat:@"%@%lu", [self toBinary:input / 2], input % 2];
}

#pragma mark collectionView delegates
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 26;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  9;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //You may want to create a divider to scale the size by the way..
    float itemSize = self.collectionView.bounds.size.width/10;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 26*itemSize + 26*ITEM_SPACING + 120);
    return CGSizeMake(itemSize, itemSize);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_SPACING;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_SPACING;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    if((row==0 && section==0) || (row==8 && section==0) || (row==0 && section==25) || (row==8 && section==25)){//corners
        [cell handleCornerCells];
        return cell;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.userInteractionEnabled = YES;
    [cell setlabel];
    NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:row];
    NSString *blockedVal = [blockedHours valueForKey:@(section).stringValue];
    if([blockedVal isEqualToString:@"1"]){
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell addDayTimeLable:indexPath isSelected:@"1"];
    }else{
        [cell addDayTimeLable:indexPath isSelected:@"0"];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)selectionOfHoursForRow:(NSInteger)row andSection:(NSInteger)section collectionView:(UICollectionView *)collectionView selected:(NSString*)selected{
    if((row==0 && section==0) || (row==8 && section==0) || (row==0 && section==25) || (row==8 && section==25))//corners
        return;
    
    NSMutableDictionary *blockedHours;
    blockedHours = [blockedDaysArray objectAtIndex:row];
    [blockedHours setValue:selected forKey:@(section).stringValue];
    
    if((section == 0 || section == 25) && (row >= 1 && row <= 7)){ //days click
        blockedHours = [blockedDaysArray objectAtIndex:row];
        for(int j = 0; j <= 25; j++){
            [blockedHours setValue:selected forKey:@(j).stringValue];
        }
        [collectionView reloadData];
    }
    else if((row == 0 || row == 8) && (section >= 1 && section <= 24)){ //hours click
        for(NSMutableDictionary *dict in blockedDaysArray){
            [dict setValue:selected forKey:@(section).stringValue];
        }
        [collectionView reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [self selectionOfHoursForRow:row andSection:section collectionView:collectionView selected:@"1"];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [self selectionOfHoursForRow:row andSection:section collectionView:collectionView selected:@"0"];
    [self convertDaysDictToHex];
}

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(nonnull SEL)action forItemAtIndexPath:(nonnull NSIndexPath *)indexPath withSender:(nullable id)sender{
    return NO;
}
-(void)convertDaysDictToHex{
    _hexBlockedDays = [@"" mutableCopy];
    for(int i = 1; i <= 7; i++){
        NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:i];
        NSMutableString *boolStr = [NSMutableString new];
        for(int j = 24; j >= 1; j--){
            [boolStr appendString:[blockedHours valueForKey:@(j).stringValue]];
        }
        
        NSMutableString *hexStr = [self boolStringToHex:[NSString stringWithString:boolStr]];
        while(6-[hexStr length]){
            [hexStr insertString:@"0" atIndex:0];
        }
        if(i == 1)
            [_hexBlockedDays appendString:hexStr];
        else
            [_hexBlockedDays appendString:[NSString stringWithFormat:@",%@", hexStr]];
    }
}
-(NSMutableString*)boolStringToHex:(NSString*)str{
    char* cstr = [str cStringUsingEncoding: NSASCIIStringEncoding];
    NSUInteger len = strlen(cstr);
    char* lastChar = cstr + len - 1;
    NSUInteger curVal = 1;
    NSUInteger result = 0;
    while (lastChar >= cstr) {
        if (*lastChar == '1')
        {
            result += curVal;
        }
        lastChar--;
        curVal <<= 1;
    }
    NSString *resultStr = [NSString stringWithFormat: @"%lx", (unsigned long)result];
    return [resultStr mutableCopy];
}
@end
