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

typedef NS_ENUM(NSInteger, timeSegmentType1)
{
    AnyTime1 = 0,
    Precisely1 = 1,
    Between1 = 2
};

@protocol AddTriggerAndAddActionDelegate

-(void) updateActionsButtonsPropertiesArray:(NSMutableArray*)actionButtonPropertiesArray;
-(void) updateTriggersButtonsPropertiesArray:(NSMutableArray*)triggersButtonPropertiesArray;
-(void)updateTimeElementsButtonsPropertiesArray:(RulesTimeElement*)ruleTimeElement;
@end
@interface AddTriggerAndAddAction : NSObject
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArray;
@property (nonatomic)AddRulesViewController *parentViewController;
@property (nonatomic)id<AddTriggerAndAddActionDelegate> delegate;
@property (nonatomic, strong)RulesTimeElement *ruleTime;
@property (nonatomic) bool isTrigger;
@property (nonatomic) bool isAction;


-(void)displayTriggerActionDeviceName:(NSArray *)deviceListArray;
@end
