//
//  DetailsPeriodViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 27/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DetailsPeriodViewController.h"
#import "HistoryCell.h"
#import "CommonMethods.h"
#import "DSLCalendarView.h"



@interface DetailsPeriodViewController ()<UITableViewDelegate,UITableViewDelegate,DSLCalendarViewDelegate>
@property (nonatomic) NSArray *suggSearchArr;
@property (weak, nonatomic) IBOutlet UITableView *detailTable;
@property (nonatomic, weak) IBOutlet DSLCalendarView *calendarView;
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
    self.calendarView.delegate = self;
    //    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    //    [self.calendarView setVisibleMonth:components animated:YES];
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
            self.labelTxt = @"LastDay";
        }
            break;
        case 1:
        {
            self.value = @"7";
            self.lastDate = [CommonMethods getTodayDate];
            self.calendarView.hidden = YES;
            self.labelTxt = @"Past week";
        }
            break;
        case 2:
        {
            self.value = @"30";
            self.lastDate = [CommonMethods getTodayDate];
            self.calendarView.hidden = YES;
            self.labelTxt = @"Past month";
        }
            break;
        case 3:
        {
            self.calendarView.hidden = NO;
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
    NSDictionary *oneDay = @{@"hostName":@"  Last Day",
                             @"image" : [UIImage imageNamed:@"schedule_icon"]
                             };
    NSDictionary *sevenDays = @{@"hostName":@"  Past week",
                                @"image" : [UIImage imageNamed:@"schedule_icon"]
                                };
    NSDictionary *month = @{@"hostName":@"  Past month",
                            @"image" : [UIImage imageNamed:@"schedule_icon"]
                            };
    NSDictionary *dateRange = @{@"hostName":@"  Date Range...",
                                @"image" : [UIImage imageNamed:@"event_icon"]
                                };
    
    
    self.suggSearchArr = [[NSArray alloc]initWithObjects:oneDay,sevenDays,month, dateRange,nil];
}
#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView *)calendarView didSelectRange:(DSLCalendarRange *)range {
    if (range != nil) {
        NSLog( @"Selected %@ %ld/%ld - %ld/%ld",range.endDay, (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
        NSLog(@"day diff %ld",[self daysBetweenDate:range.startDay.date andDate:range.endDay.date]);
        self.labelTxt = [NSString stringWithFormat:@"%ld-%ld to %ld-%ld",(long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month];
        self.lastDate = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)range.endDay.year,(long)range.endDay.month,(long)range.endDay.day];
        self.value = [NSString stringWithFormat:@"%d",[self daysBetweenDate:range.startDay.date andDate:range.endDay.date] + 1];
    }
    else {
        NSLog( @"No selection" );
    }
}

- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCalendarRange *)range {
    //    if (NO) { // Only select a single day
    //        return [[DSLCalendarRange alloc] initWithStartDay:day endDay:day];
    //    }
    //if (YES) { // Don't allow selections before today
    NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
    
    NSDateComponents *startDate = range.startDay;
    NSDateComponents *endDate = range.endDay;
    NSLog(@"before Date %d %d",[self day:startDate isBeforeDay:today],[self day:endDate isBeforeDay:today]);
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-30];
    NSDate *thirtyDays = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    dateComponents = [thirtyDays dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
    
    NSLog(@"range %@,start day %@ endDay %@",range,startDate,endDate);
    if ([self day:startDate isBeforeDay:today] && [self day:endDate isBeforeDay:today]) {
        if ([self day:startDate isBeforeDay:today]) {
            
            //                startDate = [today copy];
        }
        if ([self day:startDate isBeforeDay:dateComponents]) {
            startDate = [dateComponents copy];
            //                endDate = [today copy];
        }
        if (![self day:endDate isBeforeDay:today]) {
            endDate = [today copy];
        }
        
        
        return [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
    }
    else {
        return nil;
    }
    
    
    return range;
}

- (void)calendarView:(DSLCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents *)month duration:(NSTimeInterval)duration {
    NSLog(@"Will show %@ in %.3f seconds", month, duration);
}

- (void)calendarView:(DSLCalendarView *)calendarView didChangeToVisibleMonth:(NSDateComponents *)month {
    NSLog(@"Now showing %@", month);
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
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
    if(![self.value isEqualToString:@""])
        [self.delegate updateDetailPeriod:self.value date:self.lastDate lavelText:self.labelTxt];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
