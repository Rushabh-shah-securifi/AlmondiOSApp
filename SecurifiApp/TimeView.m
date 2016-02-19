//
//  TimeView.m
//  SecurifiApp
//
//  Created by Masood on 21/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "TimeView.h"
#import "RulesDeviceNameButton.h"
#import "SFIColors.h"
#import "CommonMethods.h"

@interface TimeView()
@property UIView *segmentDetailView;
@property (nonatomic)NSMutableDictionary *dayDict;
@end

@implementation TimeView
int timeSegmentHeight = 30;
int datePickerHeight = 162; //date picker height does not go below 162
int datePickerWidth = 140;
int dateDividerWidth = 20;
int dayViewHeight = 50;
int viewSpacing = 20;
int infoLableHeight = 60;
int segmentDetailTopSpacing = 20;

UILabel *infoLable;
UIDatePicker* DatePickerFrom;
UIDatePicker* DatePickerTo;
UIDatePicker* preciselyDatePicker;
UISegmentedControl *timeSegmentControl;
int segmentType;

-(id)init{
    if(self == [super init]){
        infoLable = [[UILabel alloc]init];
    }
    return self;
}

-(void)addTimeView{
    [self initializeSegmentDetailView];
    [self addTimeSegment];
    [self onClickSegmentControl:timeSegmentControl];
}

-(void)addTimeSegment{
    UIScrollView *scrollView = self.deviceIndexButtonScrollView;
    NSArray *segmentItems = [NSArray arrayWithObjects:@"ANYTIME", @"PRECISELY AT", @"BETWEEN", nil];
    timeSegmentControl = [[UISegmentedControl alloc]initWithItems:segmentItems];
    
    timeSegmentControl.frame = CGRectMake(0, 20, scrollView.frame.size.width-40, timeSegmentHeight);
    timeSegmentControl.selectedSegmentIndex = self.ruleTime.segmentType;
    timeSegmentControl.tintColor = [SFIColors ruleBlueColor];
    timeSegmentControl.center = CGPointMake(CGRectGetMidX(scrollView.bounds), timeSegmentControl.center.y);
    [timeSegmentControl addTarget:self action:@selector(onClickSegmentControl:) forControlEvents: UIControlEventValueChanged];
    [scrollView addSubview:timeSegmentControl];
}

-(void)onClickSegmentControl:(UISegmentedControl *)segment{
    [self clearSegmentDetailView];
    segmentType = (int)segment.selectedSegmentIndex;
    self.ruleTime.segmentType=segmentType;
    switch (segmentType) {
        case 0:{
            [self addAnyTimeInfoLable];
            
        }
            break;
        case 1:{
            [self addPreciselyDatePicker];
            [self setTime];
            [self addDayView];
            [self setLableText];
        }
            break;
        case 2:{
            [self addBetweenDatePicker];
            [self setTimeRange];
            [self addDayView];
            [self setLableText];
        }
            break;
        default:
            break;
    }
    [self.delegate AddOrUpdateTime];
    if(segmentType == 1 || segmentType == 2)
        self.deviceIndexButtonScrollView.contentSize = CGSizeMake(self.deviceIndexButtonScrollView.frame.size.width, self.segmentDetailView.frame.size.height + 2*segmentDetailTopSpacing + timeSegmentHeight);
}

-(void)addAnyTimeInfoLable{
    [self addInfoLabelWithFrame:CGRectMake(0, 0, self.segmentDetailView.frame.size.width-40, infoLableHeight) text:@"The rule will trigger any time when sensor change their state"];
    infoLable.center = CGPointMake(self.segmentDetailView.bounds.size.width/2, self.segmentDetailView.bounds.size.height/2);
}

-(void)addInfoLabelWithFrame:(CGRect)frame text:(NSString*)text{
    infoLable.frame = frame;
//    infoLable.backgroundColor = [UIColor darkGrayColor];
    [self setupInfoLable:infoLable text:text];
    [self.segmentDetailView addSubview:infoLable];
}

-(void)setupInfoLable:(UILabel*)lable text:(NSString*)text{
    lable.text = text;
    lable.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:12];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor lightGrayColor];
    lable.lineBreakMode = NSLineBreakByWordWrapping;
    lable.numberOfLines = 0;
}


-(void)addPreciselyDatePicker{
    preciselyDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, datePickerWidth, datePickerHeight)];
    [self setFrame:preciselyDatePicker];
//    preciselyDatePicker.backgroundColor = [UIColor yellowColor];
    [self setupDatePicker:preciselyDatePicker];
    preciselyDatePicker.center = CGPointMake(CGRectGetMidX(self.segmentDetailView.bounds), preciselyDatePicker.center.y);
    
    [preciselyDatePicker addTarget:self action:@selector(onPreciselyDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentDetailView addSubview:preciselyDatePicker];
}

-(void)setFrame:(UIDatePicker*)datePicker{
    CGRect frame = datePicker.frame;
    frame.size.width = datePickerWidth;
    frame.size.height = datePickerHeight;
    [datePicker setFrame: frame];
}

-(void)setupDatePicker:(UIDatePicker*)datePicker{
    datePicker.datePickerMode = UIDatePickerModeTime;
}

- (void)onPreciselyDatePickerValueChanged:(id)sender{
    NSDate *date = preciselyDatePicker.date;
    self.ruleTime.segmentType = Precisely1;
    [self storeTimeParams:date];
    self.ruleTime.dateFrom = [date dateByAddingTimeInterval:0];
    self.ruleTime.range=0;
    [self setLableText];
    [self.delegate AddOrUpdateTime];
}

-(void) storeTimeParams:(NSDate *) date{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitWeekday  | NSCalendarUnitMonth  fromDate:date];
    self.ruleTime.hours = [comp hour];
    self.ruleTime.mins = [comp minute];
    self.ruleTime.dayOfMonth = @([comp day]).stringValue; //0 - 31
    self.ruleTime.dayOfWeek =  self.ruleTime.dayOfWeek; //@([comp weekday]-1).stringValue; // 0 - 6
    self.ruleTime.monthOfYear = @([comp month]).stringValue; // 1 - 12
    self.ruleTime.isPresent = YES;
}


-(void)addBetweenDatePicker{
    UIView *betweenDatePickerView = [self createBetweenDateComponentView];
    betweenDatePickerView.center = CGPointMake(CGRectGetMidX(self.segmentDetailView.bounds), betweenDatePickerView.center.y);
    [self.segmentDetailView addSubview:betweenDatePickerView];
}

-(UIView*)createBetweenDateComponentView{
    UIView *datePickerSubView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,(datePickerWidth*2 + dateDividerWidth) , datePickerHeight)];
    
    DatePickerFrom= [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, datePickerWidth, datePickerHeight)];
    [self setFrame:DatePickerFrom];
    [self setupDatePicker:DatePickerFrom];
    [DatePickerFrom addTarget:self action:@selector(onBetweenDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    DatePickerTo = [[UIDatePicker alloc]initWithFrame:CGRectMake(datePickerWidth +dateDividerWidth, 0, datePickerWidth, datePickerHeight)];
    [self setFrame:DatePickerTo];
    [self setupDatePicker:DatePickerTo];
    [DatePickerTo addTarget:self action:@selector(onBetweenDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *dateDividerLbl = [[UILabel alloc]initWithFrame:CGRectMake(datePickerWidth, 0, datePickerWidth, datePickerWidth)];
    dateDividerLbl.text = @"-";
    dateDividerLbl.textAlignment = NSTextAlignmentCenter;
    dateDividerLbl.center = CGPointMake(datePickerSubView.bounds.size.width/2, datePickerSubView.bounds.size.height/2);
    
    [datePickerSubView addSubview:DatePickerFrom];
    [datePickerSubView addSubview:dateDividerLbl];
    [datePickerSubView addSubview:DatePickerTo];
    
    return datePickerSubView;
}

- (void)onBetweenDatePickerValueChanged:(id)sender{
    NSDate *timeFrom = DatePickerFrom.date;
    NSDate *timeto = DatePickerTo.date;

    self.ruleTime.dateFrom = [timeFrom dateByAddingTimeInterval:0];
    self.ruleTime.dateTo = [timeto dateByAddingTimeInterval:0];
    
    self.ruleTime.range=[self caluculateRange:timeFrom toDate:timeto];
    self.ruleTime.segmentType = Between2;
    [self storeTimeParams:timeFrom];
    [self setLableText];
    [self.delegate AddOrUpdateTime];
    
}


-(int)caluculateRange:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:fromDate];
    NSInteger startHr = [components hour];
    NSInteger startMins = [components minute];
    
    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:toDate];
    NSInteger endHr = [components hour];
    NSInteger endMin = [components minute];
    
    startMins = startHr*60 + startMins;
    endMin = endHr*60+ endMin;
    if(endMin == startMins){
        return 0;
    }else if(endMin < startMins){
         return (int)((1440 - startMins) + endMin);
    }else{
        return (int)(endMin - startMins);
    }

}

-(void)addDayView{
    int xVal = 4;
    int spacing = 8;
    double dayButtonWidth = 35;
    UIView *dayView = [[UIView alloc]initWithFrame:CGRectMake(0, datePickerHeight, (dayButtonWidth+spacing)*7, dayViewHeight)];
    int tag = 0;
    NSArray* dayArray = [[NSArray alloc]initWithObjects:@"Su",@"Mo",@"Tu",@"We",@"Th",@"Fr",@"Sa", nil];
    for(NSString* day in dayArray){
        UIButton *dayButton = [[UIButton alloc] initWithFrame:CGRectMake(xVal, 0, dayButtonWidth, dayButtonWidth)];
        dayButton.center = CGPointMake(dayButton.center.x, dayView.bounds.size.height/2);
        [self setDayButtonProperties:dayButton withRadius:dayButtonWidth];
        [dayButton setTitle:day forState:UIControlStateNormal];
        dayButton.titleLabel.font = [UIFont systemFontOfSize:12];
        dayButton.tag = tag;
        [dayButton addTarget:self action:@selector(onDayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [dayView addSubview:dayButton];
        dayButton.selected = NO;
        [self setPreviousHighlight:dayButton];
        xVal += dayButtonWidth + spacing;
        tag++;
    }
    dayView.center = CGPointMake(CGRectGetMidX(self.segmentDetailView.bounds), dayView.center.y);
//    dayView.backgroundColor = [UIColor orangeColor];
    [self.segmentDetailView addSubview:dayView];
}

-(void) setDayButtonProperties:(UIButton*)dayButton withRadius:(double)dayButtonWidth{
    CALayer * l1 = [dayButton layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:dayButtonWidth/2];
    l1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
    dayButton.titleLabel.textColor = [UIColor whiteColor];
    dayButton.backgroundColor = [UIColor grayColor];
    dayButton.titleLabel.textAlignment  = NSTextAlignmentCenter;
}

-(void)setPreviousHighlight:(UIButton*)dayButton{
    NSMutableArray *earlierSelection = self.ruleTime.dayOfWeek;
    for (NSString* tag in earlierSelection) {
        if ([tag isEqualToString:@(dayButton.tag).stringValue]) {
            dayButton.selected = YES;
            dayButton.backgroundColor = [SFIColors ruleBlueColor];
            
        }
    }
}

-(void)onDayBtnClicked:(UIButton*)dayButton{
    NSMutableArray *earlierSelection = self.ruleTime.dayOfWeek;
    dayButton.selected = !dayButton.selected;
    dayButton.backgroundColor = dayButton.selected?[SFIColors ruleBlueColor]:[SFIColors ruleGraycolor];
    if(dayButton.selected){
        [earlierSelection addObject:@(dayButton.tag).stringValue];
    }
    else{
        [earlierSelection removeObject:@(dayButton.tag).stringValue];
    }
    [self.delegate AddOrUpdateTime];
    [self setLableText];
}


-(void)setLableText{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm aa"];
    NSString *days = [CommonMethods getDays:self.ruleTime.dayOfWeek];
    if(segmentType == Precisely1){
        NSDate *date =preciselyDatePicker.date;
        NSString *time = [dateFormat stringFromDate:date];
        [self setPreciseAndBetweenInfoLable:[NSString stringWithFormat:@"The Rule will trigger when sensor change their state at precisely at %@ on %@.",time,days]];
    }else if(segmentType == Between2){
        NSDate *dateFrom = DatePickerFrom.date;
        NSDate *dateTo = DatePickerTo.date;
        NSString *timeFrom = [dateFormat stringFromDate:dateFrom];
        NSString *timeTo = [dateFormat stringFromDate:dateTo];
        [self setPreciseAndBetweenInfoLable:[NSString stringWithFormat:@"The Rule will trigger when sensor changes their state between %@ to %@ on %@.",timeFrom, timeTo,days]];
    }
}

-(NSString*)getDays{
    NSMutableArray *earlierSelection = self.ruleTime.dayOfWeek;
    //Loop through earlierSelection
    NSMutableString *days = [NSMutableString new];
    int i=0;
    for(NSString *dayVal in earlierSelection){
        if(i == 0)
            [days appendString:[self.dayDict valueForKey:dayVal]];
        else
            [days appendString:[NSString stringWithFormat:@",%@", [self.dayDict valueForKey:dayVal]]];
        i++;
    }
    return [NSString stringWithString:days];
}

-(void)setPreciseAndBetweenInfoLable:(NSString*)text{
    CGRect frame = CGRectMake(0, datePickerHeight + dayViewHeight, self.segmentDetailView.frame.size.width-40, infoLableHeight);
    [self addInfoLabelWithFrame:frame text:text];
    infoLable.center = CGPointMake(CGRectGetMidX(self.segmentDetailView.bounds), infoLable.center.y);
}


-(void)setTime{ //on edit or revisit
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: self.ruleTime.hours];
    [components setMinute: self.ruleTime.mins];
    
    NSDate *existingTriggerTime = [gregorian dateFromComponents: components];
    preciselyDatePicker.date = existingTriggerTime;
}

-(void)setTimeRange{//on edit
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: self.ruleTime.hours];
    [components setMinute: self.ruleTime.mins];
    
    NSDate *timeFrom = [gregorian dateFromComponents: components];
    DatePickerFrom.date = timeFrom;
    
    NSDate *timeTo = [timeFrom dateByAddingTimeInterval:((self.ruleTime.range)*60)];
    DatePickerTo.date = timeTo;
}

-(void)clearSegmentDetailView{
    for(UIView *view in [self.segmentDetailView subviews]){
        [view removeFromSuperview];
    }
}

-(void)initializeSegmentDetailView{
    UIScrollView *scrollView = self.deviceIndexButtonScrollView;
    self.segmentDetailView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                     timeSegmentHeight + segmentDetailTopSpacing,
                                                                     scrollView.frame.size.width,
                                                                     datePickerHeight + dayViewHeight + infoLableHeight + viewSpacing * 2)];
    [scrollView addSubview:self.segmentDetailView];
}



@end
