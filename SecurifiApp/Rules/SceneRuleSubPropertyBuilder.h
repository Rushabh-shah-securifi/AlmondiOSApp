////
////  SceneRuleSubPropertyBuilder.h
////  SecurifiApp
////
////  Created by Securifi-Mac2 on 21/04/16.
////  Copyright © 2016 Securifi Ltd. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "Rule.h"
//#import "RulesTimeElement.h"
//#import "AddRulesViewController.h"
//#import "IndexValueSupport.h"
//#import "SFIButtonSubProperties.h"
//#import "AddRuleSceneClass.h"
//
//
//@class AddRulesViewController;
//
//@protocol SceneRuleSubPropertyBuilderDelegate
//-(void)updateTriggerAndActionDelegatePropertie:(BOOL)isTrigger;
//-(void)redrawDeviceIndexView:(sfi_id)deviceId;
//@end
//
//@interface SceneRuleSubPropertyBuilder : NSObject
//@property (nonatomic, weak) id<SceneRuleSubPropertyBuilderDelegate> delegate;
//@property (nonatomic) bool isDelayPickerPresent;
//+ (void)createEntryForView:(UIScrollView *)topScrollView indexScrollView:(UIScrollView*)indexScrollView parentView:(UIView*)view parentClass:(AddRuleSceneClass*)parentClass triggers:(NSMutableArray *)triggersList actions:(NSMutableArray *)actionsList isCrossButtonHidden:(BOOL)isHidden isRuleActive:(BOOL)isRuleActive isScene:(BOOL)isSceneFlag;
//
//
//+ (BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties;
//+(NSString*)getDays:(NSArray*)earlierSelection;
//
//@end