//
//  TimeText.m
//  nOCD
//
//  Created by Argam on 10/28/15.
//  Copyright © 2015 MagicDevs. All rights reserved.
//

#import "TimeText.h"

@implementation TimeText

static int MONTH = 2;// all the times that have month different [catch it, it might have been yesterday
// also!] [could have been just last week also]
static int TODAY = 0; // all time which comes to this date. means from 00:00
static int YEAR = 3;// all the times which has its year as diff from ours
static int YESTERDAY = 1;//

static int MINUTE = 60;
static int HOUR = 60 * 60;
static int DAY = 24 * 60 * 60;

+ (NSString*) convertNumberToMonthMMM:(int) mon
{
    switch (mon) {
            
        case 1:
            return @"JAN";
        case 2:
            return @"FEB";
        case 3:
            return @"MAR";
        case 4:
            return @"APR";
        case 5:
            return @"MAY";
        case 6:
            return @"JUN";
        case 7:
            return @"JUL";
        case 8:
            return @"AUG";
        case 9:
            return @"SEP";
        case 10:
            return @"OCT";
        case 11:
            return @"NOV";
        case 12:
            return @"DEC";
            
    }
    return nil;
}

+ (NSString*) getShortDate:(long) thenTime
{
    NSDate *today = [NSDate new];
    long timeNow = [today timeIntervalSince1970];//*1000
    long timeElapsed = timeNow-thenTime;
    if(timeElapsed<=MINUTE){
        return @"Just Now";//context.getResources().getString(R.string.justNow);
    }
    if(timeElapsed<=2*MINUTE){
        return @"A Minute Ago";//context.getResources().getString(R.string.aMinAgo);
    }
    else if (timeElapsed <HOUR){
        return [NSString stringWithFormat:@"%ld Minutes Ago", timeElapsed/MINUTE];//timeElapsed/MINUTE +" "+context.getResources().getString(R.string.minsAgo);
    }
    else if (timeElapsed < 90*MINUTE){
        return @"A Hour Ago";//context.getResources().getString(R.string.anHourAgo);
    }
    else if (timeElapsed <= 23* HOUR){
        return [NSString stringWithFormat:@"%ld Hours Ago", timeElapsed/HOUR];//timeElapsed/HOUR +" "+context.getResources().getString(R.string.hoursAgo);
    }
    else if (timeElapsed <= 25* HOUR){
        return @"Yesterday";//context.getResources().getString(R.string.yesterday);
    }
    else if (timeElapsed > 25* HOUR){
        return [NSString stringWithFormat:@"%ld Days Ago", timeElapsed/DAY];//timeElapsed/DAY +" "+context.getResources().getString(R.string.daysAgo);
    }
    
    return nil;
}

+ (int) getCategory:(NSString*) time
{
    long thenTime = [time longLongValue];
    NSDate *d1 = [NSDate new];
    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:thenTime];///1000
    
    NSDateComponents *c1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d1];
    NSDateComponents *c2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d2];
    
    if ([c1 year] == [c2 year] && [c1 month] == [c2 month] && [c1 day] == [c2 day])
    {
        return TODAY;
    }
    
    [c1 setDay:([c1 day] - 1)];
    if ([c1 year] == [c2 year] && [c1 month] == [c2 month] && [c1 day] == [c2 day])
    {
        return YESTERDAY;
    }
    
    c1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d1];
    
    if ([c1 year] == [c2 year])
    {
        return MONTH;
    }
    else
    {
        return YEAR;
    }
}

+ (NSArray*) getSubTime:(NSString*) time :(int) category
{
    long thenTime = [time longLongValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:thenTime];//1000
    
    NSDateComponents *c1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    NSInteger hour = [c1 hour];
    if (hour > 12) {
        hour -= 12;
    }
    
    NSInteger min = [c1 minute];
    NSString *hoursStr = hour < 10 ? [NSString stringWithFormat:@"0%ld", hour] : [NSString stringWithFormat:@"%ld", hour];
    
    NSString *minStr = min < 10 ? [NSString stringWithFormat:@"0%ld", min] : [NSString stringWithFormat:@"%ld", min];
    NSString *am = [c1 hour] < 12 ? @" AM" : @" PM";
    
    if (category == TODAY || category == YESTERDAY)
    {
        return [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@:%@", hoursStr, minStr], am, nil];
    }
    
    if (category == MONTH)
    {
        NSInteger date_ = [c1 day];
        NSString *dateString = date_ < 10 ? [NSString stringWithFormat:@"0%ld", date_] : [NSString stringWithFormat:@"%ld", date_];
        
        return [[NSArray alloc] initWithObjects:dateString,[NSString stringWithFormat:@", %@:%@%@", hoursStr, minStr, am], nil];
        
    }
    
    
    NSString *month = [self convertNumberToMonthMMM:(int)[c1 month]];
    NSInteger date_ = [c1 day];
    NSString *dateString = date_ < 10 ? [NSString stringWithFormat:@"0%ld", date_] : [NSString stringWithFormat:@"%ld", date_];
    
    return [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@ %@", month, dateString], [NSString stringWithFormat:@", %@:%@%@", hoursStr, minStr, am], nil];
}

+ (NSString*) getTime:(long) time
{
    int category = [self getCategory:[NSString stringWithFormat:@"%ld", time]];
    
    if (category == TODAY || category == YESTERDAY)
    {
        return [self getShortDate:time];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];//1000
    NSDateComponents *c1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    if (category == MONTH)
    {
        return [self convertNumberToMonthMMM:(int)[c1 month]];
    }
    
    return [NSString stringWithFormat:@"%ld", [c1 year]];
}

+ (NSString*) getTime:(NSString*) time category:(int) category
{
    if (category == TODAY)
    {
        return @"Today";
    }
    
    if (category == YESTERDAY)
    {
        return @"Yesterday";
    }
    
    if (category == MONTH)
    {
        
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time longLongValue]];//1000
    NSDateComponents *c1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    if (category == MONTH)
    {
        return [self convertNumberToMonthMMM:(int)[c1 month]];
    }
    
    return [NSString stringWithFormat:@"%ld", [c1 year]];
}

@end
