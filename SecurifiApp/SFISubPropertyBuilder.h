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
-(void)updateTriggerAndActionDelegatePropertie:(BOOL)isTrigger;
-(void)redrawDeviceIndexView:(sfi_id)deviceId;
@end

@interface SFISubPropertyBuilder : NSObject
@property (nonatomic, weak) id<SFISubPropertyBuilderDelegate> delegate;
@property (nonatomic) bool isDelayPickerPresent;
+(void)createEntriesView:(UIScrollView *)scroll triggers:(NSArray *)triggers actions:(NSArray *)actions showCrossBtn:(BOOL)showCross parentController:(AddRulesViewController*)addRuleController;

+ (BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties;
+(NSString*)getDays:(NSArray*)earlierSelection;
@end