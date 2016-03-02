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
#import "AddRuleSceneClass.h"

@class AddRulesViewController;

@interface SFISubPropertyBuilder : NSObject
@property (nonatomic) bool isDelayPickerPresent;

+ (void)createEntryForView:(UIScrollView *)topScrollView indexScrollView:(UIScrollView*)indexScrollView parentView:(UIView*)view parentClass:(AddRuleSceneClass*)parentClass triggers:(NSMutableArray *)triggersList actions:(NSMutableArray *)actionsList isCrossButtonHidden:(BOOL)isHidden isRuleActive:(BOOL)isRuleActive isScene:(BOOL)isSceneFlag;


@end