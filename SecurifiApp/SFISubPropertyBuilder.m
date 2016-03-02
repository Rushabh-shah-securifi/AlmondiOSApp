//
//  SFISubPropertyBuilder.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFISubPropertyBuilder.h"
#import "RulesConstants.h"
#import "SensorIndexSupport.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "DeviceListAndValues.h"
#import "SFIDeviceIndex.h"
#import "SFIButtonSubProperties.h"
#import "ValueFormatter.h"
#import "SecurifiToolkit.h"

#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "UIFont+Securifi.h"
#import "RulesConstants.h"
#import "Colours.h"

#import "SwitchButton.h"
#import "DimmerButton.h"

#import "PreDelayRuleButton.h"

#import "SFIColors.h"
#import "AddRulesViewController.h"
#import "SecurifiToolkit/Parser.h"

#import "ValueFormatter.h"
#import "IndexValueSupport.h"
#import "DelayPicker.h"
#import "CommonMethods.h"


@interface SFISubPropertyBuilder()

@end


@implementation SFISubPropertyBuilder
bool isCrossHidden;
BOOL isActive;
bool disableUserInteraction;
bool isScene;
DelayPicker *delayPicker;
NSArray *deviceArray;
SecurifiToolkit *toolkit;

NSMutableArray *triggers;
NSMutableArray *actions;
UIView *parentView;
UIScrollView *deviceIndexButtonScrollView;
UIScrollView *triggersActionsScrollView;
AddRuleSceneClass *addRuleScene;

int xVal = 20;
UILabel *topLabel;

+ (void)createEntryForView:(UIScrollView *)topScrollView indexScrollView:(UIScrollView*)indexScrollView parentView:(UIView*)view parentClass:(AddRuleSceneClass*)parentClass triggers:(NSMutableArray *)triggersList actions:(NSMutableArray *)actionsList isCrossButtonHidden:(BOOL)isHidden isRuleActive:(BOOL)isRuleActive isScene:(BOOL)isSceneFlag{
    delayPicker = [DelayPicker new];
    toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    deviceArray=[toolkit deviceList:plus.almondplusMAC];
    
    xVal = 20;
    isCrossHidden = isHidden;
    isActive = isRuleActive;
    isScene = isSceneFlag;
    disableUserInteraction = !isHidden;//for disable userInteraction in ruletableView
    triggersActionsScrollView = topScrollView;
    if (!isCrossHidden) {
        triggers = triggersList;
        actions = actionsList;
        deviceIndexButtonScrollView = indexScrollView;
        parentView = view;
        addRuleScene = parentClass;
    }
    
    [self clearTopScrollView];
    if(triggersList.count == 0 && actionsList.count == 0)
        [self addTopLabel];
    
    if(triggersList.count > 0){
        [self buildEntryList:triggersList isTrigger:YES];
        if (!isScene) {
            [self drawImage:@"arrow_icon"];
        }
    }
    if(actionsList.count>0){
        [self buildEntryList:actionsList isTrigger:NO];
    }

    if(xVal > topScrollView.frame.size.width){
        [topScrollView setContentOffset:CGPointMake(xVal-topScrollView.frame.size.width + 20, 0) animated:YES];
    }
    topScrollView.contentSize = CGSizeMake(xVal + 20, topScrollView.frame.size.height);//to do
}

+ (void)clearTopScrollView{
    NSLog(@"clearTopScrollView");
    NSArray *viewsToRemove = [triggersActionsScrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]])
            [v removeFromSuperview];
    }
}

+ (void)addTopLabel{
    topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    topLabel.text = [NSString stringWithFormat:@"Your %@ will appear here.", isScene? @"Scene": @"Rule"];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.font = [UIFont systemFontOfSize:15];
    topLabel.textColor = [UIColor lightGrayColor];
    topLabel.center = CGPointMake(parentView.bounds.size.width/2, triggersActionsScrollView.bounds.size.height/2);
    [triggersActionsScrollView addSubview:topLabel];
}


+ (void)setIconAndText:(int)positionId buttonProperties:(SFIButtonSubProperties *)buttonProperties icon:(NSString *)icon text:(NSString*)text isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimmbutton bottomText:(NSString*)bottomText{
    buttonProperties.positionId=positionId;
    buttonProperties.iconName=icon;
    buttonProperties.displayText=text;
    if (positionId > 0)
        [self drawImage: @"plus_icon" ];
    [self drawButton: buttonProperties isTrigger:isTrigger isDimButton:isDimmbutton bottomText:bottomText];
}

+ (BOOL)buildEntry:(SFIButtonSubProperties *)buttonProperties positionId:(int)positionId deviceIndexes:(NSArray *)deviceIndexes isTrigger:(BOOL)isTrigger{
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
        if (deviceIndex.indexID == buttonProperties.index) {
            if([buttonProperties.matchData isEqualToString:@"toggle"])
            {
                [self setIconAndText:positionId buttonProperties:buttonProperties icon:@"toggle_icon.png" text:@"Toggle" isTrigger:isTrigger isDimButton:NO bottomText:@"TOGGLE"];
                return true;
            }
            NSArray *indexValues = deviceIndex.indexValues;
            for(IndexValueSupport *iVal in indexValues){
                BOOL isDimButton=iVal.layoutType!=nil && ([iVal.layoutType isEqualToString:@"dimButton"] || [iVal.layoutType isEqualToString:@"textButton"]);
                if([CommonMethods compareEntry:isDimButton matchData:iVal.matchData eventType:iVal.eventType buttonProperties:buttonProperties]){
                    NSString *bottomText;
                    
                    if(isDimButton){
                        buttonProperties.displayedData=[iVal.valueFormatter scaledValue:buttonProperties.matchData];
                        bottomText = [NSString stringWithFormat:@"%@%@", buttonProperties.displayedData,iVal.valueFormatter.suffix];
                            if(buttonProperties.deviceType == SFIDeviceType_HueLamp_48){
                                bottomText = [NSString stringWithFormat:@"%@%@",@(buttonProperties.matchData.intValue * 100/255).stringValue,iVal.valueFormatter.suffix];
                            }
                        }
                    else
                        bottomText = [iVal getDisplayText:buttonProperties.matchData];
                    [self setIconAndText:positionId buttonProperties:buttonProperties icon:iVal.iconName text:bottomText isTrigger:isTrigger isDimButton:isDimButton bottomText:iVal.displayText];
                    
                    return true;
                }
            }
            return false;
        }
    }
    return false;
}

+ (void)buildEntryList:(NSArray *)entries isTrigger:(BOOL)isTrigger{
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in entries) {
        if(buttonProperties.time != nil && buttonProperties.time.segmentType!=0){
            [self buildTime:buttonProperties isTrigger:isTrigger positionId:positionId];
            positionId++;
            
        }else{
            NSArray *deviceIndexes=[self getDeviceIndexes:buttonProperties];
            if(deviceIndexes==nil || deviceIndexes.count<=0)
                continue;
            if([self buildEntry:buttonProperties positionId:positionId deviceIndexes:deviceIndexes isTrigger:isTrigger])
                positionId++;
        }
        
    }
}

+ (void)buildTime:(SFIButtonSubProperties *)timesubProperties isTrigger:(BOOL)isTrigger positionId:(int)positionId{
    if(positionId > 0)
        [self drawImage:@"plus_icon"];
    DimmerButton *dimbutton=[[DimmerButton alloc]initWithFrame:CGRectMake(xVal, 5, triggerActionDimWidth, triggerActionDimHeight + 10)];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm aa"];
    int segmentType=timesubProperties.time.segmentType;
    if(segmentType==1){
        [dimbutton setupValues:[dateFormat stringFromDate:timesubProperties.time.dateFrom] Title:@"Time" displayText:[CommonMethods getDays:timesubProperties.time.dayOfWeek] suffix:@""];
        
    }
    else{
        NSString *time = [NSString stringWithFormat:@"%@\n%@", [dateFormat stringFromDate:timesubProperties.time.dateFrom], [dateFormat stringFromDate:timesubProperties.time.dateTo]];
        [dimbutton setupValues:time Title:@"Time Interval" displayText:[CommonMethods getDays:timesubProperties.time.dayOfWeek] suffix:@""];
    }
    dimbutton.subProperties = timesubProperties;
    dimbutton.subProperties.positionId = positionId;
    [dimbutton setButtonCross:isCrossHidden];
    dimbutton.userInteractionEnabled = disableUserInteraction;
    
    [dimbutton addTarget:self action:@selector(onDimmerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    dimbutton.bgView.backgroundColor =(!isActive && isCrossHidden)?[SFIColors ruleGraycolor]:[SFIColors ruleBlueColor];
    xVal += triggerActionDimWidth;
    [triggersActionsScrollView addSubview:dimbutton];
    
}

+ (NSArray*)getDeviceIndexes:(SFIButtonSubProperties *)properties{
    [self getDeviceTypeFor:properties];
    SensorIndexSupport *Index=[[SensorIndexSupport alloc]init];
    return [Index getIndexesFor:properties.deviceType];
}

+ (void)drawButton:(SFIButtonSubProperties*)subProperties isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimmbutton bottomText:(NSString *)bottomText{
    if(isTrigger){
        SwitchButton *switchButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal, 5, triggerActionBtnWidth, triggerActionBtnHeight)];
        switchButton.isTrigger = isTrigger;
        [switchButton setupValues:[UIImage imageNamed:subProperties.iconName] topText:subProperties.deviceName bottomText:bottomText isTrigger:isTrigger isDimButton:isDimmbutton insideText:subProperties.displayText];
        switchButton.subProperties = subProperties;
        switchButton.inScroll = YES;
        switchButton.userInteractionEnabled = YES;
        
        [switchButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if(!isActive && isCrossHidden)
            switchButton.bgView.backgroundColor = [SFIColors ruleGraycolor];
        xVal += triggerActionBtnWidth;
        [switchButton setButtonCross:isCrossHidden];
        switchButton.userInteractionEnabled = disableUserInteraction;
        [triggersActionsScrollView addSubview:switchButton];
        
    }
    else{
        PreDelayRuleButton *switchButton = [[PreDelayRuleButton alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
        
        if(subProperties.deviceType == SFIDeviceType_HueLamp_48 && subProperties.index == 3)
            isDimmbutton = NO;//for we are putting images of hueLamp
        if([subProperties.type isEqualToString:@"NetworkResult"])
            subProperties.deviceName = @"Almond Control";
        [switchButton setupValues:[UIImage imageNamed:subProperties.iconName] Title:subProperties.deviceName displayText:subProperties.displayText delay:subProperties.delay isDimmer:isDimmbutton bottomText:bottomText];
        if(!isActive && isCrossHidden){
            switchButton->actionbutton.bgView.backgroundColor = [SFIColors ruleGraycolor];
            switchButton->delayButton.backgroundColor = [SFIColors ruleGraycolor];
        }
        switchButton.subProperties = subProperties;
        
        [switchButton->actionbutton setButtonCross:isCrossHidden];
        (switchButton->actionbutton).userInteractionEnabled = disableUserInteraction;
        // (switchButton->actionbutton).crossButton.subproperty = subProperties;
        switchButton->actionbutton.isTrigger = isTrigger;
        //[switchButton changeBGColor:isTrigger clearColor:NO];
        (switchButton->actionbutton).subProperties = subProperties;
        (switchButton->actionbutton).isTrigger = isTrigger;
        [switchButton->actionbutton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if(subProperties.deviceType == SFIDeviceType_HueLamp_48){
            if(subProperties.index == 2)
                [switchButton->actionbutton changeImageColor:[UIColor whiteColor]];
            else if(subProperties.index == 3)
                [switchButton->actionbutton changeImageColor:[UIColor colorFromHexString:[self getColorHex:subProperties.matchData]]];
        }
        
        [switchButton->delayButton addTarget:self action:@selector(onActionDelayClicked:) forControlEvents:UIControlEventTouchUpInside];
        (switchButton->delayButton).userInteractionEnabled = disableUserInteraction;
        xVal += rulesButtonsViewWidth;
        
        [triggersActionsScrollView addSubview:switchButton];
        
    }
}


+ (void)onTriggerCrossButtonClicked:(SwitchButton*)switchButton{
    //includes mode
    if(delayPicker.isPresentDelayPicker){
        [delayPicker removeDelayView];
        deviceIndexButtonScrollView.userInteractionEnabled = YES;
    }
    if(switchButton.isTrigger){
        [triggers removeObjectAtIndex:switchButton.subProperties.positionId];
    }
    else{
        [actions removeObjectAtIndex:switchButton.subProperties.positionId];
    }
    [addRuleScene redrawDeviceIndexView:switchButton.subProperties.deviceId clientEvent:switchButton.subProperties.eventType];
}


+ (void)onDimmerCrossButtonClicked:(DimmerButton*)dimmerButton{
    if(delayPicker.isPresentDelayPicker){
        [delayPicker removeDelayView];
        deviceIndexButtonScrollView.userInteractionEnabled = YES;
    }
    [triggers removeObjectAtIndex:dimmerButton.subProperties.positionId];
    [addRuleScene redrawDeviceIndexView:dimmerButton.subProperties.deviceId clientEvent:@""];
    
}

+ (void)onActionDelayClicked:(id)sender{
    UIButton *delayButton = sender;
    delayPicker.triggersActionsScrollView = triggersActionsScrollView;
    delayPicker.deviceIndexButtonScrollView = deviceIndexButtonScrollView;
    delayPicker.parentView = parentView;
    [delayPicker addPickerForButton:delayButton];
}

+ (NSString *)getColorHex:(NSString*)value {
    if (!value) {
        return @"";
    }
    float hue = [value floatValue];
    hue = hue / 65535;
    UIColor *color = [UIColor colorWithHue:hue saturation:100 brightness:100 alpha:1.0];
    return [color.hexString uppercaseString];
};

+ (void)getDeviceTypeFor:(SFIButtonSubProperties*)buttonSubProperty{
    buttonSubProperty.deviceType = SFIDeviceType_UnknownDevice_0;
    if([buttonSubProperty.type isEqualToString:@"NetworkResult"]){
        buttonSubProperty.deviceType = SFIDeviceType_REBOOT_ALMOND;
        buttonSubProperty.index = 1;//as there is no index from cloud
    }
    else if([buttonSubProperty.eventType isEqualToString:@"AlmondModeUpdated"]){
        buttonSubProperty.deviceType= SFIDeviceType_BinarySwitch_0;
        buttonSubProperty.deviceName = @"Mode";
    }else if(buttonSubProperty.index == 0 && buttonSubProperty.eventType !=nil && toolkit.wifiClientParser!=nil){
        for(SFIConnectedDevice *connectedClient in toolkit.wifiClientParser){
            if(buttonSubProperty.deviceId == connectedClient.deviceID.intValue){
                buttonSubProperty.deviceType = SFIDeviceType_WIFIClient;
                buttonSubProperty.deviceName = connectedClient.name;
            }
        }
    }else{
        for(SFIDevice *device in deviceArray){
            if(buttonSubProperty.deviceId == device.deviceID){
                buttonSubProperty.deviceType = device.deviceType;
                buttonSubProperty.deviceName = device.deviceName;
            }
        }
    }
}

+ (void)drawImage:(NSString *)iconName {
    SwitchButton *imageButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal,5, triggerActionBtnWidth, triggerActionBtnHeight)];//todo
    [imageButton setupValues:[UIImage imageNamed:iconName] topText:@"" bottomText:@"" isTrigger:YES isDimButton:NO insideText:@""];
    //image.image = [UIImage imageNamed:iconName];
    xVal += triggerActionBtnWidth;
    [triggersActionsScrollView addSubview:imageButton];
    
}


@end