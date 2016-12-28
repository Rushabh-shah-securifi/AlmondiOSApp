//
//  DetailsPeriodViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 27/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DetailsPeriodViewController.h"
#import "UIViewController+Securifi.h"
#import "HistoryCell.h"
#import "CommonMethods.h"
#import "GLCalendarView.h"
#import "GLCalendarDateRange.h"
#import "GLDateUtils.h"
#import "GLCalendarDayCell.h"
#import "Colours.h"


@interface DetailsPeriodViewController ()<UITableViewDelegate,UITableViewDelegate,GLCalendarViewDelegate>
@property (nonatomic) NSArray *suggSearchArr;
@property (weak, nonatomic) IBOutlet UITableView *detailTable;

@property (nonatomic, weak) IBOutlet GLCalendarView *calendarView;
@property (nonatomic, weak) GLCalendarDateRange *rangeUnderEdit;
@property (nonatomic) NSString *value;
@property (nonatomic) NSString *lastDate;
@property (nonatomic) NSString *labelTxt;

@end

@implementation DetailsPeriodViewController
NSMutableDictionary *_eventsByDate;

NSDate *_todayDate;
NSDate *_minDate;
NSDate *_maxDate;

NSDate *_dateSelected;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSuggestionSearchObj];
    //[self loadCalendar];
    self.calendarView.delegate = self;
     self.calendarView.showMaginfier = YES;


    NSLog(@"viewDidLoad");
    [self.detailTable registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"cell_Identifier"];
    NSInteger lastSection = 0;
    NSInteger lastRow = [self.str integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
    [self.detailTable reloadData];
    [self tableViewCheckMark:indexPath];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.rangeUnderEdit = nil;
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark tableVieDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggSearchArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_Identifier" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_Identifier"];
    }
    
    [cell setCell:[self.suggSearchArr objectAtIndex:indexPath.row]hideItem:YES isCategory:NO showTime:NO count:indexPath.row+1  hideCheckMarkIMg:YES];
    return cell;
}
-(void)tableViewCheckMark:(NSIndexPath*)indexPath{
    
   HistoryCell* cell = [self.detailTable cellForRowAtIndexPath:indexPath];
    cell.checkMarkImg.hidden = NO;
    switch (indexPath
            .row) {
        case 0:
        {
            self.value = @"1";
            self.lastDate = [CommonMethods getTodayDate];
            self.calendarView.hidden = YES;
            self.rangeUnderEdit = nil;
            self.labelTxt = @"Today";
        }
            break;
        case 1:
        {
            self.value = @"7";
            self.lastDate = [CommonMethods getTodayDate];
            self.calendarView.hidden = YES;
            self.labelTxt = @"Past week";
            self.rangeUnderEdit = nil;
        }
            break;
        case 2:
        {
            self.value = @"30";
            self.lastDate = [CommonMethods getTodayDate];
            self.calendarView.hidden = YES;
            self.labelTxt = @"Past month";
            self.rangeUnderEdit = nil;
        }
            break;
        case 3:
        {
            self.calendarView.hidden = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.calendarView scrollToDate:self.calendarView.lastDate animated:NO];
            });
        }
            break;
        default:
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.detailTable reloadData];
    [self tableViewCheckMark:indexPath];
   
}
-(void)addSuggestionSearchObj{
    NSDictionary *oneDay = @{@"hostName":@"  Today",
                             @"image" : [UIImage imageNamed:@"schedule_icon"]
                             };
    NSDictionary *sevenDays = @{@"hostName":@"  Past week",
                                @"image" : [UIImage imageNamed:@"schedule_icon"]
                                };
    NSDictionary *month = @{@"hostName":@"  Past month",
                            @"image" : [UIImage imageNamed:@"schedule_icon"]
                            };
    NSDictionary *dateRange = @{@"hostName":@"  Date Range",
                                @"image" : [UIImage imageNamed:@"event_icon"]
                                };
    
    
    self.suggSearchArr = [[NSArray alloc]initWithObjects:oneDay,sevenDays,month, dateRange,nil];
}
#pragma mark GLCalendarView delegate
- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-30];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-YYYY"];
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    //    self.rangeUnderEdit = nil;
    NSLog(@"canAddRangeWithBeginDate");
    if([self isDateBeyoundDate:beginDate]){
        [self showToast:@"double tap on date for range selection"];
        return YES;
    }
    else
    {
        [self showToast:[NSString stringWithFormat:@"Please select date between %@ to %@",[formatter stringFromDate:date],[formatter stringFromDate:[NSDate date]]]];
        return NO;
    }
}

- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate
{
    NSLog(@"rangeToAddWithBeginDate");
    
    NSLog(@"self.calendarView.ranges count %ld",self.calendarView.ranges.count);
    for(GLCalendarDateRange *rang in self.calendarView.ranges)
        [self.calendarView removeRange:rang];
    [self.calendarView reload];
    [self.calendarView scrollToDate:beginDate animated:YES];
    NSDate* endDate = [GLDateUtils dateByAddingDays:0 toDate:beginDate];
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:endDate];
    range.backgroundColor = [UIColor colorFromHexString:@"825CC2"];
    range.editable = YES;
    self.rangeUnderEdit = range;
    return range;
}

- (void)calenderView:(GLCalendarView *)calendarView beginToEditRange:(GLCalendarDateRange *)range
{
    NSLog(@"begin to edit range: %@", range);
    self.rangeUnderEdit = range;
}

- (void)calenderView:(GLCalendarView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing
{
    NSLog(@"finish edit range: %@", range);
    for(GLCalendarDateRange *rang in self.calendarView.ranges)
        [self.calendarView removeRange:rang];
    [self.calendarView reload];
    
}

- (BOOL)calenderView:(GLCalendarView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    
    if([self isDateBeyoundDate:endDate] && [self isDateBeyoundDate:beginDate])
        return YES;
    else{
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:-30];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-YYYY"];
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
         [self showToast:[NSString stringWithFormat:@"Please select date between %@ to %@",[formatter stringFromDate:date],[formatter stringFromDate:[NSDate date]]]];
        return NO;
    }
}

- (void)calenderView:(GLCalendarView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    NSLog(@"did update range: %@", range);
    self.rangeUnderEdit = range;
}

-(BOOL)isDateBeyoundDate:(NSDate*)selectedDate{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-1];
    NSDate *yesterDayDate  = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    [dateComponents setDay:-30];
    NSDate *thirtyDays = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    if([self day:selectedDate isBeforeDay:thirtyDays])
        return NO;
    else if(![self day:selectedDate isBeforeDay:yesterDayDate])
        return NO;
    return YES;
}
- (BOOL)day:(NSDate*)day1 isBeforeDay:(NSDate*)day2 {
    return ([day1 compare:day2] == NSOrderedAscending);
}


- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (IBAction)doneButtonClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
    if(self.rangeUnderEdit != nil)
    {   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        _lastDate = [formatter stringFromDate:self.rangeUnderEdit.endDate];
        self.value = [NSString stringWithFormat:@"%ld",[self daysBetweenDate:self.rangeUnderEdit.beginDate andDate:self.rangeUnderEdit.endDate] + 1];
        [formatter setDateFormat:@"dd MMM yy"];
        if([self.rangeUnderEdit.beginDate compare:self.rangeUnderEdit.endDate] == NSOrderedSame )
            self.labelTxt = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.rangeUnderEdit.beginDate]];
        else
            self.labelTxt = [NSString stringWithFormat:@"%@ to %@",[formatter stringFromDate:self.rangeUnderEdit.beginDate],[formatter stringFromDate:self.rangeUnderEdit.endDate]];
    }
    if(![self.value isEqualToString:@""])
        [self.delegate updateDetailPeriod:self.value date:self.lastDate lavelText:self.labelTxt];
    
   
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
