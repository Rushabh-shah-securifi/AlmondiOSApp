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

#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "UIFont+Securifi.h"
#import "RulesConstants.h"
#import "Colours.h"

//#import "SFITriggersActionsSwitchButton.h"
//#import "SFITriggersActionsDimmerButton.h"
#import "SwitchButton.h"
#import "DimmerButton.h"

#import "PreDelayRuleButton.h"

#import "SFIColors.h"
//#import "AddActions.h"
#import "AddRulesViewController.h"
#import "SecurifiToolkit/Parser.h"

#import "ValueFormatter.h"
#import "IndexValueSupport.h"
#import "DelayPicker.h"


@interface SFISubPropertyBuilder()

@end


@implementation SFISubPropertyBuilder
bool showCrossBtn;
DelayPicker *delayPicker;
UIScrollView *scrollView;
AddRulesViewController *parentController;
int xVal = 20;



+ (void)createEntriesView:(UIScrollView *)scroll triggers:(NSArray *)triggers actions:(NSArray *)actions showCrossBtn:(BOOL)showCross parentController:(AddRulesViewController*)addRuleController{
    
    xVal = 20;
    showCrossBtn = showCross;
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

+ (BOOL)buildEntry:(SFIButtonSubProperties *)buttonProperties positionId:(int)positionId deviceIndexes:(NSArray *)deviceIndexes isTrigger:(BOOL)isTrigger{
    NSLog(@" buttonproperty matchdata %@",buttonProperties.matchData);
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
        NSLog(@" buttonproperty deviceIndex %d buttonProperties.index %d",deviceIndex.indexID,buttonProperties.index );
        if (deviceIndex.indexID == buttonProperties.index) {
            NSArray *indexValues = deviceIndex.indexValues;
            for(IndexValueSupport *iVal in indexValues){
                if([self compareEntry:!iVal.valueFormatterDoesNotExist matchData:iVal.matchData eventType:iVal.eventType buttonProperties:buttonProperties]){
                    NSLog(@" ival.iconname %@",iVal.iconName);
                    buttonProperties.positionId=positionId;
                    buttonProperties.iconName=iVal.iconName;
                    buttonProperties.displayText=[iVal getDisplayText:buttonProperties.matchData];
                    
                    if (positionId > 0)
                        [self drawImage: @"plus_icon" ];
                    [self drawButton: buttonProperties isTrigger:isTrigger];
                    
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
    return (buttonProperties.eventType==nil && compareValue) ||(compareValue &&
                                                                compareEvents) || (isWifiClient && compareEvents) ;
}
+ (void)buildEntryList:(NSArray *)entries isTrigger:(BOOL)isTrigger{
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in entries) {
        if(buttonProperties.time != nil){
            [self buildTime:buttonProperties isTrigger:isTrigger positionId:positionId];
            positionId++;
        }else{
            NSLog(@"buttn type %d %@",buttonProperties.deviceType,buttonProperties.deviceName);
            NSArray *deviceIndexes=[self getDeviceIndexes:buttonProperties.deviceType];
            if(deviceIndexes==nil || deviceIndexes.count<=0)
                continue;
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
               [dimbutton setupValues:[dateFormat stringFromDate:timesubProperties.time.date] Title:@"Time" displayText:@"days" suffix:@""];

    }
    else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        NSString *time = [NSString stringWithFormat:@"%@\n%@", [dateFormat stringFromDate:timesubProperties.time.dateFrom], [dateFormat stringFromDate:timesubProperties.time.dateTo]];
        NSLog(@"time interval: %@", time);
        [dimbutton setupValues:time Title:@"Time Interval" displayText:@"days" suffix:@""];
    }
    dimbutton.subProperties.positionId = positionId;
    [dimbutton setButtonCross:showCrossBtn];
    [dimbutton addTarget:self action:@selector(onDimmerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    dimbutton.bgView.backgroundColor =[SFIColors ruleBlueColor];
    xVal += triggerActionDimWidth;
    [scrollView addSubview:dimbutton];

}

+ (NSArray*)getDeviceIndexes:(SFIDeviceType)deviceType{
    SensorIndexSupport *Index=[[SensorIndexSupport alloc]init];
    return [Index getIndexesFor:deviceType];
}

+ (void)drawButton:(SFIButtonSubProperties*)subProperties isTrigger:(BOOL)isTrigger{
    
    if(isTrigger){
        SwitchButton *switchButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal, 5, triggerActionBtnWidth, triggerActionBtnHeight)];
        switchButton.isTrigger = isTrigger;
        [switchButton setupValues:[UIImage imageNamed:subProperties.iconName] topText:subProperties.deviceName bottomText:subProperties.displayText isTrigger:isTrigger];
        

        switchButton.inScroll = YES;
        switchButton.userInteractionEnabled = YES;
        [switchButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        xVal += triggerActionBtnWidth;
        [switchButton setButtonCross:showCrossBtn]  ;
        [scrollView addSubview:switchButton];

    }
    else{
        PreDelayRuleButton *switchButton = [[PreDelayRuleButton alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
        
        [switchButton setupValues:[UIImage imageNamed:subProperties.iconName] Title:subProperties.deviceName displayText:subProperties.displayText delay:subProperties.delay];
        
         switchButton.subProperties = subProperties;
        
        [switchButton->actionbutton setButtonCross:showCrossBtn];
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
        
        xVal += rulesButtonsViewWidth;
        
        [scrollView addSubview:switchButton];

    }
}


+ (void)onTriggerCrossButtonClicked:(SwitchButton*)switchButton{
    //includes mode
    if(switchButton.isTrigger){
    [parentController.rule.triggers removeObjectAtIndex:switchButton.subProperties.positionId];
    NSLog(@"par.count %d ",parentController.rule.triggers.count);
        
    }
    else{
        [parentController.rule.actions removeObjectAtIndex:switchButton.subProperties.positionId];
        NSLog(@"par.count %d ",parentController.rule.triggers.count);
    }
    [parentController redrawDeviceIndexView:switchButton.subProperties.deviceId];
}


+ (void)onDimmerCrossButtonClicked:(DimmerButton*)dimmerButton{
    NSLog(@"dimbutton posId %d",dimmerButton.subProperties.positionId);
    [parentController.rule.triggers removeObjectAtIndex:dimmerButton.subProperties.positionId];
    [parentController redrawDeviceIndexView:dimmerButton.subProperties.deviceId];
    
}

+ (void)onActionDelayClicked:(id)sender{
    
    NSLog(@"onactiondelay clicked");
    UIButton *delayButton = sender;
    
    delayPicker = [DelayPicker new];
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


+ (void)drawImage:(NSString *)iconName {
    NSLog(@"arrow button");
    SwitchButton *imageButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal,5, triggerActionBtnWidth, triggerActionBtnHeight)];//todo
    [imageButton setupValues:[UIImage imageNamed:iconName] topText:@"" bottomText:@"" isTrigger:YES];
    //image.image = [UIImage imageNamed:iconName];
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:imageButton];
    
}
@end