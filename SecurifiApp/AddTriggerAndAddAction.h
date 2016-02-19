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
#import "RulesDeviceNameButton.h"


@protocol AddTriggerAndAddActionDelegate
-(void)updateTriggerAndActionDelegatePropertie:(BOOL)isTrigger;
@end

@interface AddTriggerAndAddAction : NSObject
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArrayTrigger;
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArrayAction;

@property (strong, nonatomic) UIScrollView *deviceListScrollView;
@property (strong, nonatomic) UIScrollView *deviceIndexButtonScrollView;
@property (strong, nonatomic) UIView *parentView;

@property (nonatomic, weak)id<AddTriggerAndAddActionDelegate> delegate;
@property (nonatomic, strong)RulesTimeElement *ruleTime;
@property (nonatomic) bool isTrigger;
@property (nonatomic) bool isAction;


-(void)addDeviceNameList:(BOOL)isTrigger;
-(void)onDeviceButtonClick:(RulesDeviceNameButton *)sender;
-(void)TimeEventClicked:(id)sender;
-(void)wifiClientsClicked:(RulesDeviceNameButton*)deviceButton;

@end
