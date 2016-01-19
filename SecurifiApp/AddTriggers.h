//
//  AddTriggers.h
//  RulesUI
//
//  Created by Masood on 01/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRulesViewController.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, timeSegmentType)
{
    AnyTime = 0,
    Precisely = 1,
    Between = 2
};

typedef NS_ENUM(NSInteger, eventType){
    clientJoined = 0,
    clientLeft = 1
};

@protocol AddTriggersDelegate

-(void)updateTriggersButtonsPropertiesArray:(NSMutableArray*)triggersButtonPropertiesArray;
-(void)updateTimeElementsButtonsPropertiesArray:(RulesTimeElement*)ruleTimeElement;

@end

@interface AddTriggers : NSObject
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArray;
@property (nonatomic, strong)RulesTimeElement *ruleTime;


@property(nonatomic)AddRulesViewController *parentViewController;
@property(weak) id<AddTriggersDelegate> delegate;

-(void)displayTriggerDeviceList;
-(void) createDeviceIndexesLayoutForDeviceId:(int)deviceId deviceType:(SFIDeviceType)deviceType deviceName:(NSString*)deviceName deviceIndexes:(NSArray*)deviceIndexes;
@end
