//
//  RulesView.h
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SecurifiToolkit/Rule.h"
#import "RulesTimeElement.h"
#import "AddRulesViewController.h"

@class RulesTimeElement;

@protocol RuleViewDelegate <NSObject>
-(void)updateActionsArray:(NSMutableArray*)actionButtonPropertiesArray andDeviceIndexesForId:(int)deviceId;
-(void)updateTriggerArray:(NSMutableArray*)triggerButtonPropertiesArray andDeviceIndexesForId:(int)deviceId;
-(void)updateTime:(RulesTimeElement*) time;
@end

@interface RulesView : NSObject

@property (nonatomic ,strong)NSMutableArray *deviceArray;
@property (nonatomic, strong)NSMutableArray *deviceValueArray;

@property (nonatomic, strong) NSArray *triggersButtonPropertiesArray;
@property (nonatomic, strong) NSArray *actionButtonPropertiesArray;
@property(nonatomic)AddRulesViewController *parentViewController;


@property (nonatomic, strong) NSString* ruleName;
@property (nonatomic, strong) Rule *rule;
@property (nonatomic)id<RuleViewDelegate> delegate;
@property (nonatomic)BOOL toHideCrossButton;


- (void)createTriggersActionsView:(UIScrollView*)triggersActionsScrollView;
@end
