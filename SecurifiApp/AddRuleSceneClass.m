//
//  AddRuleSceneClass.m
//  SecurifiApp
//
//  Created by Masood on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AddRuleSceneClass.h"
#import "AddTriggerAndAddAction.h"
#import "SFISubPropertyBuilder.h"

@interface AddRuleSceneClass()<AddTriggerAndAddActionDelegate>
@property(nonatomic)AddTriggerAndAddAction *addTriggerAction;

@end

@implementation AddRuleSceneClass
-(id)initWithParentView:(UIView*)parentView deviceIndexScrollView:(UIScrollView*)deviceIndexScrollView deviceListScrollView:(UIScrollView*)deviceListScrollView topScrollView:(UIScrollView*)triggersActionsScrollView informationLabel:(UILabel*)infoLable triggers:(NSMutableArray*)triggers actions:(NSMutableArray*)actions isScene:(BOOL)isScene{
    if(self == [super init]){
        self.parentView = parentView;
        self.deviceIndexScrollView = deviceIndexScrollView;
        self.deviceListScrollView = deviceListScrollView;
        self.triggersActionsScrollView = triggersActionsScrollView;
        self.informationLabel = infoLable;
        self.triggers = triggers;
        self.actions = actions;
        self.isScene = isScene;
    }
    return self;
}


- (void)getTriggersDeviceList:(BOOL)isTrigger{
    self.addTriggerAction = [[AddTriggerAndAddAction alloc]initWithParentView:self.parentView deviceIndexScrollView:self.deviceIndexScrollView deviceListScrollView:self.deviceListScrollView triggers:self.triggers actions:self.actions isScene:self.isScene];
    self.addTriggerAction.delegate = self;
    [self.addTriggerAction addDeviceNameList:isTrigger];
}

- (void)buildTriggersAndActions{
    [SFISubPropertyBuilder createEntryForView:self.triggersActionsScrollView indexScrollView:self.deviceIndexScrollView parentView:self.parentView parentClass:self triggers:self.triggers actions:self.actions isCrossButtonHidden:NO isRuleActive:YES isScene:self.isScene];
}

-(void)updateInfoLabel{
    if(self.isScene){
        if(self.triggers.count == 0){
            self.informationLabel.text = @"To get started, please select an action";
        }else if(self.triggers.count >0){
            self.informationLabel.text = @"Add another action or press Save to finalize the Scene";
        }
    }else{
        if(self.triggers.count == 0){
            self.informationLabel.text = @"To get started, please select a trigger";
        }
        else if (self.triggers.count >0 && self.actions.count == 0){
            self.informationLabel.text = @"Add another trigger or press THEN to define action";
        }
        else if (self.actions.count > 0){
            self.informationLabel.text = @"Add another trigger/action or press Save to finalize the Rule";
        }
    }
}

-(RulesDeviceNameButton*)getSelectedButton:(int)deviceId eventType:(NSString*)eventType{
    RulesDeviceNameButton *button = self.addTriggerAction.currentClickedButton;
    if(button.deviceId == deviceId && button.selected){
        return button;
    }
    else if (button.deviceType == SFIDeviceType_WIFIClient && button.selected){
        return button;
    }
    return nil;
}


-(void)redrawDeviceIndexView:(sfi_id)deviceId clientEvent:(NSString*)eventType{
    [self updateInfoLabel];
    [self buildTriggersAndActions];
    RulesDeviceNameButton *deviceButton = [self getSelectedButton:deviceId eventType:eventType];
    if(deviceButton.deviceType == SFIDeviceType_WIFIClient && deviceButton.isTrigger){// wifi clients
        [self.addTriggerAction wifiClientsClicked:deviceButton];
        return;
    }
    if(deviceButton.deviceId != deviceId)
        return;
    
    if(deviceButton.isTrigger){
        if(deviceId == 0){ //time mode clients
            if([deviceButton.deviceName isEqualToString:@"Mode"]){
                [self.addTriggerAction onDeviceButtonClick:deviceButton];
            }else if([deviceButton.deviceName isEqualToString:@"Time"]){
                [self.addTriggerAction TimeEventClicked:deviceButton];
            }
        }else{
            [self.addTriggerAction onDeviceButtonClick:deviceButton];
        }
    }
    else{
        [self.addTriggerAction onDeviceButtonClick:deviceButton];
    }
}

#pragma mark delegate methods
-(void)updateTriggerAndActionDelegatePropertie:(BOOL)isTrigger{
    [self updateInfoLabel];
    [self buildTriggersAndActions];
}

@end