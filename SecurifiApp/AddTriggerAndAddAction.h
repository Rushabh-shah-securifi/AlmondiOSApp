//
//  AddTriggerAndAddAction.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 18/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRulesViewController.h"
#import "RulesTimeElement.h"


@protocol AddTriggerAndAddActionDelegate

-(void) updateActionsButtonsPropertiesArray:(NSMutableArray*)actionButtonPropertiesArray;
-(void) updateTriggersButtonsPropertiesArray:(NSMutableArray*)triggersButtonPropertiesArray;
-(void)updateTimeElementsButtonsPropertiesArray:(RulesTimeElement*)ruleTimeElement;
-(void)updateTriggerAndActionDelegatePropertie:(BOOL)isTrigger;
@end
@interface AddTriggerAndAddAction : NSObject
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArrayTrigger;
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArrayAction;
@property (nonatomic)AddRulesViewController *parentViewController;
@property (nonatomic)id<AddTriggerAndAddActionDelegate> delegate;
@property (nonatomic, strong)RulesTimeElement *ruleTime;
@property (nonatomic) bool isTrigger;
@property (nonatomic) bool isAction;


-(void)addDeviceNameList:(BOOL)isTrigger;
@end
