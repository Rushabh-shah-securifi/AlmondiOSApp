//
//  DetailsPeriodViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 27/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DetailsPeriodViewController.h"
#import "HistoryCell.h"
#import "DSLCalendarView.h"



@interface DetailsPeriodViewController ()<UITableViewDelegate,UITableViewDelegate,DSLCalendarViewDelegate>
@property (nonatomic) NSArray *suggSearchArr;
@property (weak, nonatomic) IBOutlet UITableView *detailTable;
@property (nonatomic, weak) IBOutlet DSLCalendarView *calendarView;
@property (nonatomic) NSString *value;


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
    
    [cell setCell:[self.suggSearchArr objectAtIndex:indexPath.row]hideItem:YES isCategory:NO showTime:NO count:indexPath.row+1];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate updateDetailPeriod];
    switch (indexPath
            .row) {
        case 1:
        {
            self.value = @"1";
        }
            break;
        case 2:
        {
            self.value = @"7";
        }
            break;
        case 3:
        {
            self.value = @"30";
        }
            break;
            
        default:
            break;
    }
    
}
-(void)addSuggestionSearchObj{
    NSDictionary *realTime = @{@"hostName":@"  Real Time",
                               @"image" : [UIImage imageNamed:@"search_icon"]
                               };
    
    NSDictionary *oneDay = @{@"hostName":@"  1 Hour",
                            @"image" : [UIImage imageNamed:@"schedule_icon"]
                            };
    NSDictionary *sevenDays = @{@"hostName":@"  7 Days",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
    NSDictionary *month = @{@"hostName":@"  30 Days",
                                @"image" : [UIImage imageNamed:@"schedule_icon"]
                                };
    NSDictionary *dateRange = @{@"hostName":@"  Date Range...",
                               @"image" : [UIImage imageNamed:@"event_icon"]
                               };
    
    
    self.suggSearchArr = [[NSArray alloc]initWithObjects:realTime,oneDay,sevenDays,month, dateRange,nil];
}
#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView *)calendarView didSelectRange:(DSLCalendarRange *)range {
    if (range != nil) {
        NSLog( @"Selected %ld/%ld - %ld/%ld", (long)range.startDay.day, (long)range.startDay.month, (long)range.endDay.day, (long)range.endDay.month);
        NSLog(@"day diff %ld",[self daysBetweenDate:range.startDay.date andDate:range.endDay.date]);
        self.value = [NSString stringWithFormat:@"%ld",[self daysBetweenDate:range.startDay.date andDate:range.endDay.date] + 1];
    }
    else {
        NSLog( @"No selection" );
    }
}

- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCalendarRange *)range {
    if (NO) { // Only select a single day
        return [[DSLCalendarRange alloc] initWithStartDay:day endDay:day];
    }
    else if (NO) { // Don't allow selections before today
        NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
        
        NSDateComponents *startDate = range.startDay;
        NSDateComponents *endDate = range.endDay;
        
        if ([self day:startDate isBeforeDay:today] && [self day:endDate isBeforeDay:today]) {
            return nil;
        }
        else {
            if ([self day:startDate isBeforeDay:today]) {
                startDate = [today copy];
            }
            if ([self day:endDate isBeforeDay:today]) {
                endDate = [today copy];
            }
            
            return [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
        }
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
     [self.navigationController popViewControllerAnimated:YES];
}
@end
