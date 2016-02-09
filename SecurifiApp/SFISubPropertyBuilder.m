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
#import "IndexValueSupport.h"
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


@interface SFISubPropertyBuilder()

@end


@implementation SFISubPropertyBuilder
bool isCrossHidden;
BOOL isActive;
bool disableUserInteraction;
DelayPicker *delayPicker;
UIScrollView *scrollView;
AddRulesViewController *parentController;
NSArray *deviceArray;
SecurifiToolkit *toolkit;
int xVal = 20;

+ (void)createEntriesView:(UIScrollView *)scroll triggers:(NSArray *)triggers actions:(NSArray *)actions isCrossButtonHidden:(BOOL)isHidden parentController:(AddRulesViewController*)addRuleController isRuleActive:(BOOL)isRuleActive{
    delayPicker = [DelayPicker new];
    toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    deviceArray=[toolkit deviceList:plus.almondplusMAC];
    
    xVal = 20;
    isCrossHidden = isHidden;
    isActive = isRuleActive;
    disableUserInteraction = !isHidden;//for disable userInteraction in ruletableView
    scrollView = scroll;
    if (addRuleController != nil) { //to avoid nil from rulestableview
        parentController = addRuleController;
    }
    [self clearScrollView];
    
    if(triggers.count > 0){
        [self buildEntryList:triggers isTrigger:YES];
        [self drawImage:@"arrow_icon"];
    }
    if(actions.count>0)
        [self buildEntryList:actions isTrigger:NO];
    
    if(xVal > scrollView.frame.size.width){
        [scrollView setContentOffset:CGPointMake(xVal-scrollView.frame.size.width + 20, 0) animated:YES];
    }
    scrollView.contentSize = CGSizeMake(xVal + 20, scrollView.frame.size.height);//to do
}

+ (void)clearScrollView{
    NSArray *viewsToRemove = [scrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

+ (void)setIconAndText:(int)positionId buttonProperties:(SFIButtonSubProperties *)buttonProperties icon:(NSString *)icon text:(NSString*)text isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimmbutton bottomText:(NSString*)bottomText{
    buttonProperties.positionId=positionId;
    buttonProperties.iconName=icon;
    buttonProperties.displayText=text;
    NSLog(@"buttonPositionID %@ %d",buttonProperties.matchData,buttonProperties.positionId);
    
    
    if (positionId > 0)
        [self drawImage: @"plus_icon" ];
    [self drawButton: buttonProperties isTrigger:isTrigger isDimButton:isDimmbutton bottomText:bottomText];
}

+ (BOOL)buildEntry:(SFIButtonSubProperties *)buttonProperties positionId:(int)positionId deviceIndexes:(NSArray *)deviceIndexes isTrigger:(BOOL)isTrigger{
    NSLog(@" buttonproperty matchdata %@",buttonProperties.matchData);
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
        NSLog(@" buttonproperty deviceIndex %d buttonProperties.index %d",deviceIndex.indexID,buttonProperties.index );
        if (deviceIndex.indexID == buttonProperties.index) {
            if([buttonProperties.matchData isEqualToString:@"toggle"])
            {
                [self setIconAndText:positionId buttonProperties:buttonProperties icon:@"toggle_icon.png" text:@"Toggle" isTrigger:isTrigger isDimButton:NO bottomText:@""];
                return true;
            }
            NSArray *indexValues = deviceIndex.indexValues;
            for(IndexValueSupport *iVal in indexValues){
                BOOL isDimButton=iVal.layoutType!=nil && ([iVal.layoutType isEqualToString:@"dimButton"] || [iVal.layoutType isEqualToString:@"textButton"]);
                NSLog(@" isDimbutton %d",isDimButton);
                if([self compareEntry:isDimButton matchData:iVal.matchData eventType:iVal.eventType buttonProperties:buttonProperties]){
                    NSLog(@" ival.iconname %@",iVal.iconName);
                    NSString *bottomText;
                    
                    if(isDimButton)
                        bottomText = [NSString stringWithFormat:@"%@ %@",buttonProperties.matchData,iVal.valueFormatter.suffix];
                    else
                        bottomText = [iVal getDisplayText:buttonProperties.matchData];
                    NSLog(@" ival display text ::%@",iVal.displayText);
                    [self setIconAndText:positionId buttonProperties:buttonProperties icon:iVal.iconName text:bottomText isTrigger:isTrigger isDimButton:isDimButton bottomText:iVal.displayText];
                    
                    return true;
                }
            }
            return false;
        }
    }
    return false;
}

+ (BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties{
    NSLog(@" matchdata :%@ , eventType :%@, ival.match data: %@ ,ival,.eventType %@  , isSlider %d",buttonProperties.matchData,buttonProperties.eventType ,matchData,eventType,isSlider);
    bool compareValue= isSlider || [matchData isEqualToString:buttonProperties.matchData];
    bool compareEvents=[eventType isEqualToString:buttonProperties.eventType];
    bool isWifiClient=![buttonProperties.eventType isEqualToString:@"AlmondModeUpdated"];
    NSLog(@" button subproperties match data %@",buttonProperties.matchData);
    return (buttonProperties.eventType==nil && compareValue) ||(compareValue &&
                                                                compareEvents) || (isWifiClient && compareEvents) ;
}
+ (void)buildEntryList:(NSArray *)entries isTrigger:(BOOL)isTrigger{
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in entries) {
        if(buttonProperties.time != nil && buttonProperties.time.segmentType!=0){
            [self buildTime:buttonProperties isTrigger:isTrigger positionId:positionId];
            NSLog(@"positionId :- %d",positionId);
            positionId++;
            
        }else{
            NSLog(@"buttn type %d %@",buttonProperties.deviceType,buttonProperties.deviceName);
            NSArray *deviceIndexes=[self getDeviceIndexes:buttonProperties];
            if(deviceIndexes==nil || deviceIndexes.count<=0)
                continue;
            NSLog(@"potionID trigger :%d",positionId);
            if([self buildEntry:buttonProperties positionId:positionId deviceIndexes:deviceIndexes isTrigger:isTrigger])
                positionId++;
        }
        
    }
}

+ (void)buildTime:(SFIButtonSubProperties *)timesubProperties isTrigger:(BOOL)isTrigger positionId:(int)positionId{
    NSLog(@"drawTime");
    if(positionId > 0)
        [self drawImage:@"plus_icon"];
    DimmerButton *dimbutton=[[DimmerButton alloc]initWithFrame:CGRectMake(xVal, 5, triggerActionDimWidth, triggerActionDimHeight + 10)];
    NSLog(@"position Id :%d",positionId);
    
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm aa"];
    int segmentType=timesubProperties.time.segmentType;
    if(segmentType==1){
        NSLog(@"timesubProperties.time.dayOfWeek %@,%lu",timesubProperties.time.dayOfWeek,(unsigned long)timesubProperties.time.dayOfWeek.count);
        [dimbutton setupValues:[dateFormat stringFromDate:timesubProperties.time.dateFrom] Title:@"Time" displayText:[self getDays:timesubProperties.time.dayOfWeek] suffix:@""];
        
    }
    else{
        NSString *time = [NSString stringWithFormat:@"%@\n%@", [dateFormat stringFromDate:timesubProperties.time.dateFrom], [dateFormat stringFromDate:timesubProperties.time.dateTo]];
        NSLog(@"time interval: %@", time);
        [dimbutton setupValues:time Title:@"Time Interval" displayText:[self getDays:timesubProperties.time.dayOfWeek] suffix:@""];
    }
    dimbutton.subProperties = timesubProperties;
    dimbutton.subProperties.positionId = positionId;
    NSLog(@"dimbutton.subProperties.positionId  %d :%d",dimbutton.subProperties.positionId,positionId);
    [dimbutton setButtonCross:isCrossHidden];
    dimbutton.userInteractionEnabled = disableUserInteraction;
    
    [dimbutton addTarget:self action:@selector(onDimmerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    dimbutton.bgView.backgroundColor =(!isActive && isCrossHidden)?[SFIColors ruleGraycolor]:[SFIColors ruleBlueColor];
    xVal += triggerActionDimWidth;
    [scrollView addSubview:dimbutton];
    
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
        [scrollView addSubview:switchButton];
        
    }
    else{
        PreDelayRuleButton *switchButton = [[PreDelayRuleButton alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
        if(subProperties.deviceType == SFIDeviceType_HueLamp_48)
            isDimmbutton = NO;//for we are putting images of hueLamp
        
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
        
        [scrollView addSubview:switchButton];
        
    }
}


+ (void)onTriggerCrossButtonClicked:(SwitchButton*)switchButton{
    //includes mode
    if(delayPicker.isPresentDelayPicker){
        [delayPicker removeDelayView];
        parentController.deviceIndexButtonScrollView.userInteractionEnabled = YES;
    }
    if(switchButton.isTrigger){
        [parentController.rule.triggers removeObjectAtIndex:switchButton.subProperties.positionId];
        NSLog(@"par.count %d :%@ :%@:%d:,eventType:%@",switchButton.subProperties.positionId,switchButton.subProperties.matchData,switchButton.subProperties.deviceName,switchButton.deviceType,switchButton.subProperties.eventType);
    }
    else{
        [parentController.rule.actions removeObjectAtIndex:switchButton.subProperties.positionId];
        NSLog(@"par.count %lu ",(unsigned long)parentController.rule.triggers.count);
    }
    [parentController redrawDeviceIndexView:switchButton.subProperties.deviceId clientEvent:switchButton.subProperties.eventType];
}


+ (void)onDimmerCrossButtonClicked:(DimmerButton*)dimmerButton{
    if(delayPicker.isPresentDelayPicker){
        [delayPicker removeDelayView];
        parentController.deviceIndexButtonScrollView.userInteractionEnabled = YES;
    }
    NSLog(@"dimbutton posId %d",dimmerButton.subProperties.positionId);
    [parentController.rule.triggers removeObjectAtIndex:dimmerButton.subProperties.positionId];
    [parentController redrawDeviceIndexView:dimmerButton.subProperties.deviceId clientEvent:@""];
    
}

+ (void)onActionDelayClicked:(id)sender{
    NSLog(@"onactiondelay clicked");
    UIButton *delayButton = sender;
    [delayPicker addPickerForButton:delayButton parentController:parentController];
}
+(NSString *)getColorHex:(NSString*)value {
    if (!value) {
        return @"";
    }
    float hue = [value floatValue];
    hue = hue / 65535;
    UIColor *color = [UIColor colorWithHue:hue saturation:100 brightness:100 alpha:1.0];
    return [color.hexString uppercaseString];
};

+(void)getDeviceTypeFor:(SFIButtonSubProperties*)buttonSubProperty{
    
    NSLog(@" eventType :- %@ index :%d device id --: %d %@",buttonSubProperty.eventType,buttonSubProperty.index,buttonSubProperty.deviceId,buttonSubProperty.type);
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
    NSLog(@" id :%d,name :%@ ",buttonSubProperty.deviceId,buttonSubProperty.deviceName);
}

+ (void)drawImage:(NSString *)iconName {
    NSLog(@"arrow button");
    
    SwitchButton *imageButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal,5, triggerActionBtnWidth, triggerActionBtnHeight)];//todo
    [imageButton setupValues:[UIImage imageNamed:iconName] topText:@"" bottomText:@"" isTrigger:YES isDimButton:NO insideText:@""];
    //image.image = [UIImage imageNamed:iconName];
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:imageButton];
    
}
+(NSString*)getDays:(NSArray*)earlierSelection{
    if(earlierSelection==nil || earlierSelection.count==0)
        return @"EveryDay";
    NSMutableDictionary *dayDict = [self setDayDict];
    //Loop through earlierSelection
    NSMutableString *days = [NSMutableString new];
    int i=0;
    for(NSString *dayVal in earlierSelection){
        NSString *value=[dayDict valueForKey:dayVal];
        [days appendString:(i==0)?value:[NSString stringWithFormat:@",%@", value]];
        i++;
    }
    return [NSString stringWithString:days];
}
+(NSMutableDictionary*)setDayDict{
    NSMutableDictionary *dayDict = [NSMutableDictionary new];
    [dayDict setValue:@"Sun" forKey:@(0).stringValue];
    [dayDict setValue:@"Mon" forKey:@(1).stringValue];
    [dayDict setValue:@"Tue" forKey:@(2).stringValue];
    [dayDict setValue:@"Wed" forKey:@(3).stringValue];
    [dayDict setValue:@"Thu" forKey:@(4).stringValue];
    [dayDict setValue:@"Fri" forKey:@(5).stringValue];
    [dayDict setValue:@"Sat" forKey:@(6).stringValue];
    return dayDict;
}

@end