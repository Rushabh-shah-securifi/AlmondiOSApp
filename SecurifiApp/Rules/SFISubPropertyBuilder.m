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
#import "SecurifiToolkit/ClientParser.h"

#import "ValueFormatter.h"
#import "IndexValueSupport.h"
#import "DelayPicker.h"
#import "CommonMethods.h"
#import "Device.h"
#import "RuleSceneUtil.h"

#import "GenericIndexValue.h"
#import "GenericIndexClass.h"
#import "GenericValue.h"
#import "AlmondJsonCommandKeyConstants.h"

#import "WeatherRuleButton.h"

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
    NSLog(@"createEntryForView");
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
    triggers = triggersList;
    actions = actionsList;
    
    if (!isCrossHidden) {
        deviceIndexButtonScrollView = indexScrollView;
        parentView = view;
        addRuleScene = parentClass;
    }
    //NSLog(@"triggers: %@, actions: %@", triggersList, actionsList);
    [self clearTopScrollView];
    if(triggersList.count == 0 && actionsList.count == 0)
        [self addTopLabel];
    
    if(triggersList.count > 0){
        [self buildEntryList:triggersList isTrigger:YES ];
        if (!isScene) {
            //             [self drawImage:@"arrow_icon" withSubProperties:<#(SFIButtonSubProperties *)#> isTrigger:<#(BOOL)#>];
        }
    }
    if(actionsList.count>0){
        [self buildEntryList:actionsList isTrigger:NO ];
    }
    
    //    if(xVal > topScrollView.frame.size.width){
    //        [topScrollView setContentOffset:CGPointMake(xVal-topScrollView.frame.size.width , 0) animated:YES];
    //    }
    topScrollView.contentSize = CGSizeMake(xVal, topScrollView.frame.size.height);//to do
}

+ (void)clearTopScrollView{
    //NSLog(@"clearTopScrollView");
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
    topLabel.textColor = [SFIColors test1GrayColor];
    topLabel.center = CGPointMake(parentView.bounds.size.width/2, triggersActionsScrollView.bounds.size.height/2);
    [triggersActionsScrollView addSubview:topLabel];
}

+ (SwitchButton *)setIconAndText:(int)positionId buttonProperties:(SFIButtonSubProperties *)buttonProperties icon:(NSString *)icon text:(NSString*)text isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimmbutton bottomText:(NSString*)bottomText{
    buttonProperties.positionId=positionId;
    buttonProperties.iconName=icon;
    buttonProperties.displayText=text;
    [self drawButton: buttonProperties isTrigger:isTrigger isDimButton:isDimmbutton bottomText:bottomText];
    return [self drawImage: @"plus_icon" withSubProperties:buttonProperties isTrigger:isTrigger];
}

+ (void)buildEntryList:(NSArray *)entries isTrigger:(BOOL)isTrigger {
    int positionId = 0;
    SwitchButton *lastImageButton;
    //NSLog(@"entries: %@", entries);
    for (SFIButtonSubProperties *buttonProperties in entries) {
        if(buttonProperties.time != nil && buttonProperties.time.segmentType!=0){
            lastImageButton=[self buildTime:buttonProperties isTrigger:isTrigger positionId:positionId];
            positionId++;
        }else{
            NSLog(@"Subproperty: devicetype %d, index: %d, value: %@",buttonProperties.deviceType, buttonProperties.index, buttonProperties.matchData);
            NSArray *genericIndexValues = [self getDeviceIndexes:buttonProperties isTrigger:isTrigger];
            NSLog(@"genericIndexValues count %ld",(unsigned long)genericIndexValues.count);
            if(genericIndexValues == nil || genericIndexValues.count<=0)
                continue;
            NSLog(@"button property: %@, genericindexvalues: %@ valid entry %d", buttonProperties, genericIndexValues,buttonProperties.valid);
            lastImageButton= [self buildEntry:buttonProperties positionId:positionId genericIndexValues:genericIndexValues isTrigger:isTrigger];
            //NSLog(@"position id :: %d",positionId);
            //NSLog(@"lastImageButton %@",lastImageButton);
            if(lastImageButton!=nil)
                positionId++;
        }
    }
    
    //Replace the end image with arrow or nothing appropriately
    if(lastImageButton!=nil){
        //NSLog(@"istrigger: %d, actioncount:%ld", isTrigger, (unsigned long)actions.count);
        UIImage *lastImage= (isTrigger && actions.count>0)?[UIImage imageNamed:@"arrow_icon"]:nil;
        [lastImageButton setImage:lastImage replace:YES];
    }
}

+ (SwitchButton *)buildEntry:(SFIButtonSubProperties *)buttonProperties positionId:(int)positionId genericIndexValues:(NSArray *)genericIndexValues isTrigger:(BOOL)isTrigger{
    //NSLog(@"buildEntry: potionID %d,%@",positionId ,buttonProperties.eventType);
    if((buttonProperties.valid == NO )|| [self isDeviceUnknown:buttonProperties]){
        buttonProperties.deviceName = @"UnKnown Device";
        return [self setIconAndText:positionId buttonProperties:buttonProperties icon:@"default_device" text:@"Device not Found" isTrigger:isTrigger isDimButton:NO bottomText:@""];
    }
    SwitchButton * imageButton =nil;
    for(GenericIndexValue *indexValue in genericIndexValues){
        //NSLog(@"indexValue.deviceId %d",indexValue.deviceID);
        GenericIndexClass *genericIndex = indexValue.genericIndex;
        //GenericValue *selectedValue = indexValue.genericValue;
        //NSLog(@"genericIndexValues %@ ,%@,%@",genericIndexValues,buttonProperties.matchData,buttonProperties.displayText);
        
        NSDictionary *genericValueDic;
        if(genericIndex.values == nil){
            genericValueDic = [self formatterDict:genericIndex];
        }else{
            genericValueDic = genericIndex.values;
        }
        NSLog(@"genericIndex.Id %@",genericIndex.ID);
        NSArray *genericValueKeys = genericValueDic.allKeys;
        NSLog(@"genericindex %d == subpropertyindex %d",indexValue.index,buttonProperties.index);
        if (indexValue.index == buttonProperties.index) {
            if([buttonProperties.matchData isEqualToString:@"toggle"])
            {
                return [self setIconAndText:positionId buttonProperties:buttonProperties icon:@"toggle_icon.png" text:@"Toggle" isTrigger:isTrigger isDimButton:NO bottomText:@"TOGGLE"];
            }
            
            for (NSString *value in genericValueKeys) {
                //NSLog(@"values %@",value);
                GenericValue *gVal = genericValueDic[value];
                BOOL isDimButton = genericIndex.layoutType!=nil && ([genericIndex.layoutType isEqualToString: SINGLE_TEMP] || [genericIndex.layoutType isEqualToString:SLIDER] || [genericIndex.layoutType isEqualToString:TEXT_VIEW] || [genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] || [genericIndex.layoutType isEqualToString:@"SLIDER_ICON"] || [genericIndex.layoutType isEqualToString:@"HUE"]);
                
                //NSLog(@"gaval.value: %@, propertyvalue: %@, displayeddata: %@", gVal.value, buttonProperties.matchData, buttonProperties.displayedData);
                if([CommonMethods compareEntry:isDimButton matchData:gVal.value eventType:gVal.eventType buttonProperties:buttonProperties]){
                    NSString *text;
                    if(isDimButton){
                    buttonProperties.displayedData = [NSString stringWithFormat:@"%d",(int)roundf([buttonProperties.matchData intValue]*(genericIndex.formatter.factor == 0?1.0:genericIndex.formatter.factor))];
                         NSLog(@"buttonProperties.displayedData %@", buttonProperties.displayedData);
                        text = [NSString stringWithFormat:@"%@%@", buttonProperties.displayedData,(genericIndex.formatter.units == nil?@"":genericIndex.formatter.units)];
                         //NSLog(@"is dim button text %@",text);
                        if(buttonProperties.deviceType == SFIDeviceType_HueLamp_48){
                            text = [NSString stringWithFormat:@"%@%@",@((buttonProperties.matchData.intValue * 100/255)).stringValue,genericIndex.formatter.units];
                        }
                    }
                    else
                        text = gVal.displayText;

                    //NSLog(@"bottomText  %@ gval.icon %@",text,gVal.icon);
                    NSString *icon = gVal.icon == nil?genericIndex.icon:gVal.icon;
                    //NSLog(@"icon %@",icon);
                    
                    return [self setIconAndText:positionId buttonProperties:buttonProperties icon:icon text:text isTrigger:isTrigger isDimButton:isDimButton bottomText:gVal.displayText];
                }//if
            }//for/*19455*/
            return imageButton;
        }
    }
    return imageButton;
}

+(BOOL)isDeviceUnknown:(SFIButtonSubProperties*)properties{
    if([properties.eventType isEqualToString:@"TimeTrigger"]
       ||[properties.eventType isEqualToString:@"AlmondModeUpdated"]
       ||[properties.type isEqualToString:@"NetworkResult"]
       )
        return NO;
    else if([properties.type isEqualToString:@"WeatherTrigger"]){
        return NO;
    }
    else if([properties.eventType isEqualToString:@"ClientJoined"] || [properties.eventType isEqualToString:@"ClientLeft"]){
        if([Client findClientByMAC:properties.matchData] == NO)
            return YES;
        
    }
    else if([Device getDeviceForID:properties.deviceId] == nil)
        return YES;
    return NO;
}

+(NSDictionary*)formatterDict:(GenericIndexClass*)genericIndex{
    NSMutableDictionary *genericValueDic = [[NSMutableDictionary alloc]init];
    [genericValueDic setValue:[[GenericValue alloc]initWithDisplayText:genericIndex.groupLabel iconText:@(genericIndex.formatter.min).stringValue value:@"" excludeFrom:@"" transformedValue:@"0"] forKey:genericIndex.groupLabel];
    return genericValueDic;
}

+ (SwitchButton*)buildTime:(SFIButtonSubProperties *)timesubProperties isTrigger:(BOOL)isTrigger positionId:(int)positionId{
    DimmerButton *dimbutton=[[DimmerButton alloc]initWithFrame:CGRectMake(xVal, 5, dimFrameWidth, dimFrameHeight)];
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
    //@FIXME : Should add entryPadding
    xVal += dimFrameWidth-20+entryPadding;
    [triggersActionsScrollView addSubview:dimbutton];
    
    return [self drawImage:@"plus_icon" withSubProperties:timesubProperties isTrigger:isTrigger];
}

+ (NSArray*)getDeviceIndexes:(SFIButtonSubProperties *)properties isTrigger:(BOOL)isTrigger{
    NSLog(@"before propertiesid: %d, properties type: %d, matchdata: %@ , eventTYpe %@", properties.deviceId, properties.deviceType, properties.matchData,properties.eventType);

    [self getDeviceTypeFor:properties];
    
    NSLog(@"propertiesid: %d, properties type: %d, matchdata: %@, index: %d", properties.deviceId, properties.deviceType, properties.matchData, properties.index);
    return [RuleSceneUtil getGenericIndexValueArrayForID:properties.deviceId type:properties.deviceType isTrigger:isTrigger isScene:isScene triggers:triggers action:actions];
}

+ (void)drawButton:(SFIButtonSubProperties*)subProperties isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimmbutton bottomText:(NSString *)bottomText{
    if(isTrigger){
        NSString *toptext = subProperties.deviceName;
        NSString *insideDisplayText = (isDimmbutton && !isScene) ? [NSString stringWithFormat:@"%@ %@",[subProperties getcondition],subProperties.displayText]:subProperties.displayText ;
        NSLog(@"insideDisplayText: %@", insideDisplayText);
        if(subProperties.deviceType == SFIDeviceType_HueLamp_48 && subProperties.index == 3)
            isDimmbutton = NO;//for we are putting images of hueLamp
        
        if(subProperties.deviceType == SFIDeviceType_Weather && subProperties.index == 1){
            NSLog(@"delay: %@", subProperties.delay);
            WeatherRuleButton *weatherButton = [[WeatherRuleButton alloc]initWithFrame:CGRectMake(xVal, 5, 42, 42)];
            
            NSString *insideText = @"0 min after";
            if(subProperties.delay.integerValue != 0){
                NSString *suffix = (subProperties.delay.integerValue > 0)? @"after": @"before";
                int delayVal = (subProperties.delay.integerValue < 0)? (subProperties.delay.intValue * -1): subProperties.delay.intValue;
                insideText = [NSString stringWithFormat:@"%d min %@", delayVal, suffix];
            }
            
            [weatherButton setupValues:[UIImage imageNamed:subProperties.iconName] Title:toptext displayText:@"display" isDimmer:isDimmbutton bottomText:bottomText insideText:insideText isHideCross:isCrossHidden];
            weatherButton.switchButtonRight.subProperties = subProperties;
            weatherButton.switchButtonRight.isTrigger = YES;
            [weatherButton.switchButtonRight addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if(!isActive && isCrossHidden){
                weatherButton.switchButtonRight.bgView.backgroundColor = [SFIColors ruleGraycolor];
                weatherButton.switchButtonLeft.bgView.backgroundColor = [SFIColors ruleGraycolor];
            }
            
            xVal += (entryBtnWidth*2)+entryPadding;
            [weatherButton.switchButtonRight setButtonCross:isCrossHidden];
            weatherButton.switchButtonRight.userInteractionEnabled = disableUserInteraction;
            [triggersActionsScrollView addSubview:weatherButton];
        }
        else{
            SwitchButton *switchButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal, 5, entryBtnWidth, entryBtnHeight)];
            switchButton.isTrigger = isTrigger;
            
            [switchButton setupValues:[UIImage imageNamed:subProperties.iconName] topText:toptext bottomText:bottomText isTrigger:isTrigger isDimButton:isDimmbutton insideText:insideDisplayText isScene:isScene];
            switchButton.subProperties = subProperties;
            switchButton.inScroll = YES;
            switchButton.userInteractionEnabled = YES;
            
            [switchButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if(!isActive && isCrossHidden)
                switchButton.bgView.backgroundColor = [SFIColors ruleGraycolor];
            xVal += entryBtnWidth+entryPadding;
            [switchButton setButtonCross:isCrossHidden];
            switchButton.userInteractionEnabled = disableUserInteraction;
            
            if(subProperties.deviceType == SFIDeviceType_HueLamp_48){
                if(subProperties.index == 2)
                    [switchButton changeImageColor:[UIColor whiteColor]];
                else if(subProperties.index == 3)
                    [switchButton changeImageColor:[UIColor colorFromHexString:[self getColorHex:subProperties.matchData]]];
            }
            [triggersActionsScrollView addSubview:switchButton];
        }

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
        switchButton->actionbutton.crossButtonImage.userInteractionEnabled = NO;
        // (switchButton->actionbutton).crossButton.subproperty = subProperties;
        switchButton->actionbutton.isTrigger = isTrigger;
        //[switchButton changeBGColor:isTrigger clearColor:NO];
        (switchButton->actionbutton).subProperties = subProperties;
        (switchButton->actionbutton).isTrigger = isTrigger;
        [switchButton->actionbutton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        ////NSLog(@"HUE HERE");
        if(subProperties.deviceType == SFIDeviceType_HueLamp_48){
            if(subProperties.index == 2)
                [switchButton->actionbutton changeImageColor:[UIColor whiteColor]];
            else if(subProperties.index == 3)
                [switchButton->actionbutton changeImageColor:[UIColor colorFromHexString:[self getColorHex:subProperties.matchData]]];
        }
        (switchButton->delayButton).userInteractionEnabled = disableUserInteraction;
        [switchButton->delayButton addTarget:self action:@selector(onActionDelayClicked:) forControlEvents:UIControlEventTouchUpInside];
        xVal += rulesButtonsViewWidth + entryPadding;
        
        [triggersActionsScrollView addSubview:switchButton];
        
    }
}


+ (void)onTriggerCrossButtonClicked:(SwitchButton*)switchButton{
    NSLog(@"istrigger: %d, switch.position ID %d",switchButton.isTrigger, switchButton.subProperties.positionId);

    if(delayPicker.isPresentDelayPicker){
        [delayPicker removeDelayView];
        deviceIndexButtonScrollView.userInteractionEnabled = YES;
    }
    if(switchButton.isTrigger && switchButton.subProperties.positionId < triggers.count){
        [triggers removeObjectAtIndex:switchButton.subProperties.positionId];
    }
    else{
        if(switchButton.subProperties.positionId < actions.count)
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
        //NSLog(@"NetworkResult type");
        buttonSubProperty.deviceType = SFIDeviceType_REBOOT_ALMOND;
        buttonSubProperty.index = 1;//as there is no index from cloud
    }else if([buttonSubProperty.type isEqualToString:@"WeatherTrigger"]){
        buttonSubProperty.deviceType= SFIDeviceType_Weather;
        buttonSubProperty.deviceName = @"Weather";
    }
    else if([buttonSubProperty.eventType isEqualToString:@"AlmondModeUpdated"]){
        //NSLog(@"AlmondModeUpdated type");
        buttonSubProperty.deviceType= 0;
        buttonSubProperty.deviceName = @"Mode";
    }else if(buttonSubProperty.index == 1 && buttonSubProperty.eventType !=nil && toolkit.clients!=nil){
        //NSLog(@"client type");
        for(Client *connectedClient in toolkit.clients){
            if([buttonSubProperty.matchData isEqualToString:connectedClient.deviceMAC]){
                buttonSubProperty.deviceType = SFIDeviceType_WIFIClient;
                buttonSubProperty.deviceName = connectedClient.name;
            }
        }
    }else{
        //NSLog(@"else part type devices");
        for(Device *device in toolkit.devices){
            if(buttonSubProperty.deviceId == device.ID){
                buttonSubProperty.deviceType = device.type;
                buttonSubProperty.deviceName = device.name;
            }
        }
    }
}

+ (SwitchButton *)drawImage:(NSString *)iconName withSubProperties:(SFIButtonSubProperties*)subProperties isTrigger:(BOOL)isTrigger{
    SwitchButton *imageButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal,5, separatorWidth, entryBtnHeight)];//todo
    imageButton.isTrigger = isTrigger;
    imageButton.subProperties = subProperties;
    [imageButton setImage:[UIImage imageNamed:iconName] replace:NO];
    //image.image = [UIImage imageNamed:iconName];
    [imageButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    xVal += separatorWidth+ entryPadding;
    [triggersActionsScrollView addSubview:imageButton];
    return imageButton;
}


@end