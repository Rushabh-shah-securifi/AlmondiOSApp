//
//  Time.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "Time.h"
@interface Time()
@property (nonatomic)NSMutableDictionary *dayDict;
@end
@implementation Time

NSMutableArray *selectedDays;
NSMutableArray *selectedDayTags;
NSArray *dayArray;
NSMutableString *selectedDayString;
#pragma mark timeElement
//-(instancetype)init{
    //        self.deviceDict = [NSMutableDictionary new]; //perhaps to be deleted
    // self.dayDict = [self setDayDict];
    
    // selectedDayString = [NSMutableString new];
    // dayArray = [[NSArray alloc]initWithObjects:@"Su",@"Mo",@"Tu",@"We",@"Th",@"Fr",@"Sa", nil];
    // selectedDayTags = [NSMutableArray new];
    // selectedDays = [NSMutableArray new];
//    return self;
//}

//-(void)TimeEventClicked:(id)sender{
//    NSLog(@"time trigger ");
//    [self toggleHighlightForDeviceNameButton:sender];
//    self.parentViewController.TimeSectionView.hidden = NO;
//    self.parentViewController.deviceIndexButtonScrollView.hidden = YES;
//    self.parentViewController.timeSegmentSelector.hidden = NO;
//    self.parentViewController.lowerInformationLabel.text = @"The rule will trigger any time when sensor change their state";
//    self.parentViewController.lowerInformationLabel.textAlignment = NSTextAlignmentCenter;
//    self.parentViewController.lowerInformationLabel.hidden = NO;
//    self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 0; //Default
//    self.parentViewController.timerPikerPrecisely.hidden = YES;
//    self.parentViewController.timePikerBetween1.hidden = YES;
//    self.parentViewController.timePikerBetween2.hidden = YES;
//    self.parentViewController.dayView.hidden = YES;
//    self.parentViewController.andLabel.hidden = YES;
//    [self.parentViewController.timeSegmentSelector addTarget:self action:@selector(timeSegmentControl:) forControlEvents:UIControlEventValueChanged];
//    
//    if(self.ruleTime != nil){
//        NSLog(@"TimeEventClicked - not nil");
//        if(self.ruleTime.segmentType == Precisely1){
//            self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 1;
//        } else if(self.ruleTime.segmentType == Between1){
//            self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 2;
//        }
//        [self timeSegmentControl:self.parentViewController.timeSegmentSelector];
//    }
//}
//
//-(void)setTime{ //on edit or revisit
//    NSLog(@"setTime");
//    NSDate *date = [NSDate date];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
//    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
//    [components setHour: self.ruleTime.hours];
//    [components setMinute: self.ruleTime.mins];
//    
//    NSDate *existingTriggerTime = [gregorian dateFromComponents: components];
//    self.parentViewController.timerPikerPrecisely.date = existingTriggerTime;
//}
//
//
//-(void)setTimeRange{//on edit
//    NSDate *date = [NSDate date];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
//    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
//    [components setHour: self.ruleTime.hours];
//    [components setMinute: self.ruleTime.mins];
//    
//    NSDate *timeFrom = [gregorian dateFromComponents: components];
//    self.parentViewController.timePikerBetween1.date = timeFrom;
//    
//    NSDate *timeTo = [timeFrom dateByAddingTimeInterval:((self.ruleTime.range+1)*60)];
//    self.parentViewController.timePikerBetween2.date = timeTo;
//}
//
//- (void)timeSegmentControl:(UISegmentedControl *)segment{ //segment clicked
//    NSLog(@" segment control index %ld",(long)segment.selectedSegmentIndex);
//    switch (segment.selectedSegmentIndex) {
//            //by default segment
//        case 0:
//        {
//            self.parentViewController.timerPikerPrecisely.hidden = YES;
//            self.parentViewController.timePikerBetween1.hidden = YES;
//            self.parentViewController.timePikerBetween2.hidden = YES;
//            self.parentViewController.andLabel.hidden = YES;
//            self.parentViewController.dayView.hidden = YES;
//            self.parentViewController.lowerInformationLabel.text = @"The rule will trigger any time when sensor change their state";
//            self.parentViewController.lowerInformationLabel.textAlignment = NSTextAlignmentCenter;
//            self.parentViewController.lowerInformationLabel.hidden = NO;
//            [self updateTimeForAnyTimeSegment]; //no selector, calling method
//        }
//            break;
//            //precisely
//        case 1:{
//            [self getDayView];
//            //set previous values
//            if(self.ruleTime != nil && self.ruleTime.segmentType == Precisely1){
//                [self setTime];
//            }
//            
//            self.parentViewController.lowerInformationLabel.hidden = YES;
//            self.parentViewController.timerPikerPrecisely.hidden = NO;
//            self.parentViewController.timePikerBetween1.hidden = YES;
//            self.parentViewController.timePikerBetween2.hidden = YES;
//            [self.parentViewController.timerPikerPrecisely addTarget:self action:@selector(preciselyTimeGetter:) forControlEvents:UIControlEventValueChanged];
//            self.parentViewController.andLabel.hidden = YES;
//        }
//            break;
//            //between
//        case 2:{
//            [self getDayView];
//            //set previous values
//            if(self.ruleTime != nil && self.ruleTime.segmentType == Between1){
//                [self setTimeRange];
//            }
//            self.parentViewController.lowerInformationLabel.hidden = YES;
//            self.parentViewController.timerPikerPrecisely.hidden = YES;
//            self.parentViewController.timePikerBetween1.hidden = NO;
//            self.parentViewController.timePikerBetween2.hidden = NO;
//            self.parentViewController.andLabel.hidden = NO;
//            [self.parentViewController.timePikerBetween1 addTarget:self action:@selector(betweenTimeGetter:) forControlEvents:UIControlEventValueChanged];
//            [self.parentViewController.timePikerBetween2 addTarget:self action:@selector(betweenTimeGetter:) forControlEvents:UIControlEventValueChanged];
//        }
//            break;
//        default:
//            break;
//    }
//}
//
//-(void)updateTimeForAnyTimeSegment{
//    self.ruleTime = [RulesTimeElement new];
//    self.ruleTime.segmentType = AnyTime1;
//}
//
//
//-(void)setLableText{
//    NSLog(@"setLabelText");
//    int segmentType = (int)self.parentViewController.timeSegmentSelector.selectedSegmentIndex;
//    
//    NSLog(@"SegmentType: %d", segmentType);
//    if(segmentType == Precisely1){
//        NSDate *date =self.parentViewController.timerPikerPrecisely.date;
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"hh:mm aa"];
//        NSString *time = [dateFormat stringFromDate:date];
//        self.parentViewController.lowerInformationLabel.text =[NSString stringWithFormat:@"The Rule will trigger when sensor change their state at precisely at %@ on %@.",time
//                                                               ,[[selectedDays valueForKey:@"description"] componentsJoinedByString:@", "]];
//    }else if(segmentType == Between1){
//        NSDate *dateFrom =self.parentViewController.timePikerBetween1.date;
//        NSDate *dateTo = self.parentViewController.timePikerBetween2.date;
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"hh:mm aa"];
//        NSString *timeFrom = [dateFormat stringFromDate:dateFrom];
//        NSString *timeTo = [dateFormat stringFromDate:dateTo];
//        self.parentViewController.lowerInformationLabel.text =[NSString stringWithFormat:@"The Rule will trigger when sensor changes their state between %@ to %@ on %@.",timeFrom, timeTo,[[selectedDays valueForKey:@"description"] componentsJoinedByString:@", "]];
//    }
//    self.parentViewController.lowerInformationLabel.textAlignment = NSTextAlignmentCenter;
//    self.parentViewController.lowerInformationLabel.hidden = NO;
//    
//}
//
//-(void) storeTimeParams:(NSDate *) date{
//    NSCalendar* cal = [NSCalendar currentCalendar];
//    NSDateComponents* comp = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitWeekday  | NSCalendarUnitMonth  fromDate:date];
//    self.ruleTime.hours = [comp hour];
//    self.ruleTime.mins = [comp minute];
//    self.ruleTime.dayOfMonth = @([comp day]).stringValue; //0 - 31
//    self.ruleTime.dayOfWeek =  @([comp weekday]-1).stringValue; // 0 - 6
//    self.ruleTime.monthOfYear = @([comp month]).stringValue; // 1 - 12
//    self.ruleTime.isPresent = YES;
//    
//    
//    NSLog(@"dayofweeek: %@ - hours: %ld - mins: %ld", self.ruleTime.dayOfWeek, (long)self.ruleTime.hours, (long)self.ruleTime.mins);
//}
//
////precisely - onclickof time
//-(void)preciselyTimeGetter:(id)timerPikerPrecisely{ //segment click
//    self.ruleTime = [[RulesTimeElement alloc]init];
//    NSDate *date =self.parentViewController.timerPikerPrecisely.date;
//    self.ruleTime.segmentType = Precisely1;
//    self.ruleTime.date = [date dateByAddingTimeInterval:0];
//    [self storeTimeParams:date];
//    [self setLableText];
//    //
//    [self.delegate updateTimeElementsButtonsPropertiesArray:self.ruleTime];
//    //
//}
//
////range - on click of either of times
//-(void)betweenTimeGetter:(UIDatePicker *)timeBetweenPicker{
//    self.ruleTime = [[RulesTimeElement alloc]init];
//    NSDate *timeFrom =self.parentViewController.timePikerBetween1.date;
//    NSDate *timeto =self.parentViewController.timePikerBetween2.date;
//    
//    NSTimeInterval secondsBetween = [timeto timeIntervalSinceDate:timeFrom];
//    self.ruleTime.dateFrom = [timeFrom dateByAddingTimeInterval:0];
//    self.ruleTime.dateTo = [timeto dateByAddingTimeInterval:0];
//    self.ruleTime.range = secondsBetween/60;
//    NSLog(@"range: %ld", (long)self.ruleTime.range);
//    self.ruleTime.segmentType = Between1;
//    [self storeTimeParams:timeFrom];
//    [self setLableText];
//    [self.delegate updateTimeElementsButtonsPropertiesArray:self.ruleTime];
//    
//}
//
//-(void) setDayButtonProperties:(RulesDeviceNameButton*)dayButton withRadius:(double)dayButtonWidth{
//    CALayer * l1 = [dayButton layer];
//    [l1 setMasksToBounds:YES];
//    [l1 setCornerRadius:dayButtonWidth/2];
//    l1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
//    dayButton.titleLabel.textColor = [UIColor whiteColor];
//    dayButton.backgroundColor = [UIColor grayColor];
//    dayButton.titleLabel.textAlignment  = NSTextAlignmentCenter;
//}
//
//-(void)setHighlight:(RulesDeviceNameButton*)dayButton{
//    for (NSNumber* tag in selectedDayTags) {
//        if ([tag isEqualToNumber:@(dayButton.tag)]) {
//            dayButton.selected = YES;
//        }
//    }
//}
//
//-(void)getDayView{
//    NSLog(@"getDayView");
//    int xVal = 4;
//    self.parentViewController.dayView.hidden = NO;
//    double dayButtonWidth = self.parentViewController.dayView.frame.size.width/8.5; //kept 8.5 because we are giving pDDING OF 8 BETWEEN each button
//    //    UIView *dayView = [[UIView alloc]initWithFrame:CGRectMake(self.parentViewController.dayView.frame.origin.x, self.parentViewController.dayView.frame.origin.y,(dayButtonWidth*7)+(8*6),self.parentViewController.dayView.frame.size.height)];
//    int tag = 0;
//    for(NSString* day in dayArray){
//        RulesDeviceNameButton *dayButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, dayButtonWidth, dayButtonWidth)];
//        [self setDayButtonProperties:dayButton withRadius:dayButtonWidth];
//        [dayButton setTitle:day forState:UIControlStateNormal];
//        dayButton.tag = tag;
//        [self setHighlight:dayButton];
//        [dayButton addTarget:self action:@selector(dayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.parentViewController.dayView addSubview:dayButton];
//        xVal += dayButtonWidth + 8;
//        tag++;
//        
//    }
//    
//}
//
//- (NSMutableDictionary*)setDayDict{
//    NSMutableDictionary *dayDict = [NSMutableDictionary new];
//    [dayDict setValue:@"Sun" forKey:@(0).stringValue];
//    [dayDict setValue:@"Mon" forKey:@(1).stringValue];
//    [dayDict setValue:@"Tue" forKey:@(2).stringValue];
//    [dayDict setValue:@"Wed" forKey:@(3).stringValue];
//    [dayDict setValue:@"Thu" forKey:@(4).stringValue];
//    [dayDict setValue:@"Fri" forKey:@(5).stringValue];
//    [dayDict setValue:@"Sat" forKey:@(6).stringValue];
//    return dayDict;
//}
//-(void)dayBtnClicked:(RulesDeviceNameButton*)sender{
//    sender.selected = !sender.selected;
//    [sender changeStyle];
//    NSString *day=[self.dayDict valueForKey:@(sender.tag).stringValue] ;
//    NSLog(@" sender tag %ld %d",(long)sender.tag,sender.selected);
//    if(sender.selected){
//        
//        [selectedDays addObject:day];
//        [selectedDayString appendString:@","];//rushabh
//        [selectedDayString appendString:@(sender.tag).stringValue];
//    }
//    else{
//        [selectedDays removeObject:day];
//        [selectedDayTags removeObject:@(sender.tag)];
//        
//    }
//    NSLog(@"selectedDays: %@",selectedDays);
//    
//    NSString *temp = [selectedDayString substringFromIndex:1];
//    NSLog(@" selected days steing %@",temp);
//    self.ruleTime.dayOfWeek = temp;//rushab
//    
//    [self setLableText];
//}
@end
