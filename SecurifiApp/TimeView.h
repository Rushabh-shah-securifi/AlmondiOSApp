//
//  TimeView.h
//  SecurifiApp
//
//  Created by Masood on 21/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AddRulesViewController.h"
#import "RulesTimeElement.h"

typedef NS_ENUM(NSInteger, timeSegmentType1)
{
    AnyTime0 = 0,
    Precisely1 = 1,
    Between2 = 2
};

@class UISegmentedControl;

@protocol TimeViewDelegate
-(void)AddOrUpdateTime;
@end

@interface TimeView : NSObject
@property(nonatomic)AddRulesViewController *parentViewController;
@property(nonatomic)RulesTimeElement *ruleTime;
@property(nonatomic,weak)id<TimeViewDelegate> delegate;
-(void)addTimeView;
@end
