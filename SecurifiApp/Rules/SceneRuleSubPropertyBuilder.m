////
////  SceneRuleSubPropertyBuilder.m
////  SecurifiApp
////
////  Created by Securifi-Mac2 on 21/04/16.
////  Copyright © 2016 Securifi Ltd. All rights reserved.
////
//
//#import "SceneRuleSubPropertyBuilder.h"
//#import "RulesConstants.h"
//#import "SecurifiToolkit/SFIDevice.h"
//#import "DeviceListAndValues.h"
//#import "SFIButtonSubProperties.h"
//#import "DeviceListAndValues.h"
//#import "SecurifiToolkit/SecurifiTypes.h"
//#import "UIFont+Securifi.h"
//#import "RulesConstants.h"
//#import "Colours.h"
//#import "SwitchButton.h"
//#import "DimmerButton.h"
//#import "PreDelayRuleButton.h"
//#import "SFIColors.h"
//#import "AddRulesViewController.h"
//#import "SecurifiToolkit/ClientParser.h"
//#import "ValueFormatter.h"
//#import "IndexValueSupport.h"
//#import "DelayPicker.h"
//#import "CommonMethods.h"
//#import "GenericParams.h"
//#import "GenericValue.h"
//#import "GenericIndexUtil.h"
//#import "GenericIndexClass.h"
//#import "GenericIndexValue.h"
//#import "Device.h"
//#import "RuleSceneUtil.h"
//
//
//@interface SceneRuleSubPropertyBuilder()
//
//@end
//@implementation SceneRuleSubPropertyBuilder
//bool isCrossHidden;
//BOOL isActive;
//bool disableUserInteraction;
//bool isScene;
//DelayPicker *delayPicker;
//NSArray *deviceArray;
//SecurifiToolkit *toolkit;
//
//NSMutableArray *triggers;
//NSMutableArray *actions;
//UIView *parentView;
//UIScrollView *deviceIndexButtonScrollView;
//UIScrollView *triggersActionsScrollView;
//AddRuleSceneClass *addRuleScene;
//
//int xVal = 20;
//UILabel *topLabel;
//+ (void)createEntryForView:(UIScrollView *)topScrollView indexScrollView:(UIScrollView*)indexScrollView parentView:(UIView*)view parentClass:(AddRuleSceneClass*)parentClass triggers:(NSMutableArray *)triggersList actions:(NSMutableArray *)actionsList isCrossButtonHidden:(BOOL)isHidden isRuleActive:(BOOL)isRuleActive isScene:(BOOL)isSceneFlag{
//    delayPicker = [DelayPicker new];
//    toolkit = [SecurifiToolkit sharedInstance];
//    SFIAlmondPlus *plus = [toolkit currentAlmond];
//    deviceArray=[toolkit deviceList:plus.almondplusMAC];
//    
//    xVal = 20;
//    isCrossHidden = isHidden;
//    isActive = isRuleActive;
//    isScene = isSceneFlag;
//    disableUserInteraction = !isHidden;//for disable userInteraction in ruletableView
//    triggersActionsScrollView = topScrollView;
//    if (!isCrossHidden) {
//        triggers = triggersList;
//        actions = actionsList;
//        deviceIndexButtonScrollView = indexScrollView;
//        parentView = view;
//        addRuleScene = parentClass;
//    }
//    
//    [self clearTopScrollView];
//    if(triggersList.count == 0 && actionsList.count == 0)
//        [self addTopLabel];
//    
//    if(triggersList.count > 0){
//        [self buildEntryList:triggersList isTrigger:YES ];
//        if (!isScene) {
//            // [self drawImage:@"arrow_icon" withSubProperties:(SFIButtonSubProperties *) isTrigger:(BOOL)];
//        }
//    }
//    if(actionsList.count>0){
//        [self buildEntryList:actionsList isTrigger:NO ];
//    }
//    
//    if(xVal > topScrollView.frame.size.width){
//        [topScrollView setContentOffset:CGPointMake(xVal-topScrollView.frame.size.width , 0) animated:YES];
//    }
//    topScrollView.contentSize = CGSizeMake(xVal, topScrollView.frame.size.height);//to do
//}
//+ (void)buildEntryList:(NSArray *)entries isTrigger:(BOOL)isTrigger {
//    int positionId = 0;
//    SwitchButton *lastImageButton;
//    for (SFIButtonSubProperties *buttonProperties in entries) {
//        if(buttonProperties.time != nil && buttonProperties.time.segmentType!=0){
////            lastImageButton=[self buildTime:buttonProperties isTrigger:isTrigger positionId:positionId];
////            positionId++;
//        }else{
//            NSArray *deviceIndexes=[self getDeviceIndexes:buttonProperties];
//            if(deviceIndexes==nil || deviceIndexes.count<=0)
//                continue;
////            lastImageButton= [self buildEntry:buttonProperties positionId:positionId deviceIndexes:deviceIndexes isTrigger:isTrigger];
//            if(lastImageButton!=nil)
//                positionId++;
//        }
//    }
//    //Replace the end image with arrow or nothing appropriately
//    if(lastImageButton!=nil){
//        UIImage *lastImage= (isTrigger && actions.count>0)?[UIImage imageNamed:@"arrow_icon"]:nil;
//        [lastImageButton setImage:lastImage replace:YES];
//    }
//}
//+ (NSArray*)getDeviceIndexes:(SFIButtonSubProperties *)properties{
//    [self getDeviceTypeFor:properties];
//    
//    return [RuleSceneUtil getActuatorIndexes:properties.deviceType];
//}
//
//+ (void)clearTopScrollView{
//    NSLog(@"clearTopScrollView");
//    NSArray *viewsToRemove = [triggersActionsScrollView subviews];
//    for (UIView *v in viewsToRemove) {
//        if (![v isKindOfClass:[UIImageView class]])
//            [v removeFromSuperview];
//    }
//}
//+ (void)getDeviceTypeFor:(SFIButtonSubProperties*)buttonSubProperty{// handling for device only
//        for(Device *device in deviceArray){
//            if(buttonSubProperty.deviceId == device.ID){
//                buttonSubProperty.deviceType = device.type;
//                buttonSubProperty.deviceName = device.name;
//            }
//        }
//    }
//+ (void)addTopLabel{
//    topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
//    topLabel.text = [NSString stringWithFormat:@"Your %@ will appear here.", isScene? @"Scene": @"Rule"];
//    topLabel.textAlignment = NSTextAlignmentCenter;
//    topLabel.font = [UIFont systemFontOfSize:15];
//    topLabel.textColor = [SFIColors test1GrayColor];
//    topLabel.center = CGPointMake(parentView.bounds.size.width/2, triggersActionsScrollView.bounds.size.height/2);
//    [triggersActionsScrollView addSubview:topLabel];
//}
//@end
