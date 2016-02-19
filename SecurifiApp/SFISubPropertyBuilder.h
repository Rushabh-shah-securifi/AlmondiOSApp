//
//  SFISubPropertyBuilder.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecurifiToolkit/Rule.h"
#import "RulesTimeElement.h"
#import "AddRulesViewController.h"
#import "IndexValueSupport.h"
#import "SFIButtonSubProperties.h"

@class AddRulesViewController;

@protocol SFISubPropertyBuilderDelegate
-(void)redrawDeviceIndexView:(sfi_id)deviceId clientEvent:(NSString*)eventType;
@end

@interface SFISubPropertyBuilder : NSObject
@property (nonatomic) bool isDelayPickerPresent;
@property (nonatomic, weak) id<SFISubPropertyBuilderDelegate> delegate;

-(void)createEntryForView:(UIScrollView *)topScrollView indexScrollView:(UIScrollView*)indexScrollView parentView:(UIView*)view triggers:(NSArray *)triggersList actions:(NSArray *)actionsList isCrossButtonHidden:(BOOL)isHidden isRuleActive:(BOOL)isRuleActive;


@end