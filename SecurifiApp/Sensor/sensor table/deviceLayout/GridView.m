//
//  GridView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 18/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GridView.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"
#import "Colours.h"
#import "CollectionViewCell.h"

#define ITEM_SPACING  2.0
@interface GridView()<UICollectionViewDataSource,UICollectionViewDelegate>
//wifi client @property
//@property (nonatomic)  UIView *indexView;
//@property (nonatomic)  UILabel *indexLabel;
@property (strong ,nonatomic) UISegmentedControl *allowOnNetworkSegment;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *clientTypesView;
@property (nonatomic)NSString *indexName;
@property (nonatomic) NSDictionary *deviceDict;
@property (nonatomic)NSMutableString *hexBlockedDays;
@property (nonatomic)UICollectionView *collectionView;

@end
@implementation GridView
NSMutableArray * blockedDaysArray;
NSString *blockedType;
-(id)initWithFrame:(CGRect)frame{
    NSLog(@"initWithFrame ");
    self = [super initWithFrame:frame];
    if(!self){
        
    }
    return  self;
}

-(void)addSegmentControll{
    UILabel *indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont securifiFont:14];
    indexLabel.text = @"Allow On network";
    indexLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:indexLabel];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Always", @"Schedule", @"Block", nil];
    self.allowOnNetworkSegment = [[UISegmentedControl alloc]initWithItems:itemArray];
    self.allowOnNetworkSegment.frame = CGRectMake(5, indexLabel.frame.size.height + 10, self.frame.size.width - 10, 25);
    self.allowOnNetworkSegment.center = CGPointMake(CGRectGetMidX(self.bounds), self.allowOnNetworkSegment.center.y);
    self.allowOnNetworkSegment.tintColor = [UIColor whiteColor];
    //    self.allowOnNetworkSegment.segmentedControlStyle = UISegmentedControlStylePlain;
    [self.allowOnNetworkSegment addTarget:self action:@selector(segmentControllChanged:) forControlEvents: UIControlEventValueChanged];
    [self setUpAllowOnNetworkSegment];
    [self addSubview:self.allowOnNetworkSegment];
    
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
            for(UIView *view in self.scrollView.subviews){
                [view removeFromSuperview];
            }
            [self.scrollView removeFromSuperview];
        }break;
        case 1:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scrollView.hidden = NO;
                self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.allowOnNetworkSegment.frame.origin.y + self.allowOnNetworkSegment.frame.size.height + 10, self.frame.size.width - 15, self.frame.size.height - self.frame.origin.y - 100)];
                self.scrollView.backgroundColor = [UIColor clearColor];
                [self addSubview:self.scrollView];
                [self addInfo];
                [self addSaveButton];
            });
   
        }break;
        case 2:
        {
            for(UIView *view in self.scrollView.subviews){
                [view removeFromSuperview];
            }
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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 26*itemSize + 26*ITEM_SPACING + 180);
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
-(void)addSaveButton{
    UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0,930 ,110,30)];
    NSLog(@" savebutton frame %@",NSStringFromCGRect(saveButton.frame));
    saveButton.backgroundColor = [UIColor whiteColor];
    saveButton.titleLabel.font = [UIFont securifiFont:14];
    [saveButton setTitleColor:[SFIColors clientGreenColor] forState:UIControlStateNormal];
    [saveButton setTitle:@"SAVE" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), saveButton.center.y);
    [self.scrollView addSubview:saveButton];
    

}
-(void)saveButtonTap:(id)sender{
    // delegate methods
    NSLog(@"saveButtonTap %@",_hexBlockedDays);
}
@end
