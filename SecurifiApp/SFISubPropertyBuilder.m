//
//  SFISubPropertyBuilder.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFISubPropertyBuilder.h"
#import "RuleBuilder.h"
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

//#import "SFITriggersActionsSwitchButton.h"
//#import "SFITriggersActionsDimmerButton.h"
#import "SwitchButton.h"
#import "DimmerButton.h"

#import "PreDelayRuleButton.h"

#import "SFIColors.h"
#import "RulesIndexValueSupport.h"
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
UIScrollView *scrollView;
int xVal = 20;



+ (void)createEntriesView:(UIScrollView *)scroll triggers:(NSArray *)triggers actions:(NSArray *)actions showCrossBtn:(BOOL)showCross{
    
    xVal = 20;
    showCrossBtn = showCross;
    scrollView = scroll;
    [self clearScrollView];
    NSLog(@" create entries count tri :%ld, ac:%ld ,ScrollView :%@",(unsigned long)triggers.count,(unsigned long)actions.count ,scrollView);
//    [self drawImage:@"plus_icon" xVal:0];
    [self buildEntryList:triggers isTrigger:YES];
    [self drawImage:@"arrow_icon"];
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

+ (void)buildEntry:(SFIButtonSubProperties *)buttonProperties positionId:(int)positionId deviceIndexes:(NSArray *)deviceIndexes isTrigger:(BOOL)isTrigger{
    NSLog(@" buttonproperty matchdata %@",buttonProperties.matchData);
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
        NSLog(@" buttonproperty deviceIndex %d buttonProperties.index %d",deviceIndex.indexID,buttonProperties.index );
        if (deviceIndex.indexID == buttonProperties.index) {
            NSArray *indexValues = deviceIndex.indexValues;
            for(IndexValueSupport *iVal in indexValues){
                if([self compareEntry:iVal buttonProperties:buttonProperties]){
                    NSLog(@" ival.iconname %@",iVal.iconName);
                    buttonProperties.positionId=positionId;
                    buttonProperties.iconName=iVal.iconName;
                    buttonProperties.displayText=[iVal getDisplayText:buttonProperties.matchData];
                    
                    if (positionId > 0)
                        [self drawImage: @"plus_icon" ];
                    [self drawButton: buttonProperties isTrigger:isTrigger];
                    
                    break;
                }
                
            }
            break;
        }
        
    }
}
+ (BOOL) compareEntry:(IndexValueSupport *)iVal buttonProperties:(SFIButtonSubProperties *)buttonProperties{
    NSLog(@" matchdata :%@ , eventType :%@, ival.match data: %@ ,ival,.eventType %@",buttonProperties.matchData,buttonProperties.eventType ,iVal.matchData,iVal.eventType);
    bool compareValue= !iVal.valueFormatterDoesNotExist || [iVal.matchData isEqualToString:buttonProperties.matchData];
    bool compareEvents=[iVal.eventType isEqualToString:buttonProperties.eventType];
    bool isWifiClient=![buttonProperties.eventType isEqualToString:@"AlmondModeUpdated"];
    return (buttonProperties.eventType==nil && compareValue) ||(compareValue &&
                                               compareEvents) || (isWifiClient && compareEvents) ;
}
+ (void)buildEntryList:(NSArray *)entries isTrigger:(BOOL)isTrigger{
    int positionId = 0;
    
    for (SFIButtonSubProperties *buttonProperties in entries) {
        if(buttonProperties.time != nil)
            [self buildTime:buttonProperties isTrigger:isTrigger];
        else{
            [self getDeviceTypeFor:buttonProperties];
            NSLog(@"buttn type %d %@",buttonProperties.deviceType,buttonProperties.deviceName);
            NSArray *deviceIndexes=[self getDeviceIndexes:buttonProperties.deviceType];
            [self buildEntry:buttonProperties positionId:positionId deviceIndexes:deviceIndexes isTrigger:isTrigger];
        }
        positionId++;
    }
}

+ (void)buildTime:(SFIButtonSubProperties *)timesubProperties isTrigger:(BOOL)isTrigger{
    NSLog(@"drawTime");
    
    DimmerButton *dimbutton=[[DimmerButton alloc]initWithFrame:CGRectMake(xVal, 5, triggerActionDimWidth, triggerActionDimHeight)];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm aa"];

    if(timesubProperties.time.date != nil){
               [dimbutton setupValues:[dateFormat stringFromDate:timesubProperties.time.date] Title:@"Time" displayText:@"days" suffix:@""];

    }
    else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        NSString *time = [NSString stringWithFormat:@"%@\n%@", [dateFormat stringFromDate:timesubProperties.time.dateFrom], [dateFormat stringFromDate:timesubProperties.time.dateTo]];
        NSLog(@"time interval: %@", time);
        [dimbutton setupValues:time Title:@"Time Interval" displayText:@"days" suffix:@""];
    }

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
        
        [switchButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        xVal += triggerActionBtnWidth;
        
        [scrollView addSubview:switchButton];

    }
    else{
        PreDelayRuleButton *switchButton = [[PreDelayRuleButton alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
        
        [switchButton setupValues:[UIImage imageNamed:subProperties.iconName] Title:subProperties.deviceName displayText:subProperties.displayText delay:@(0).stringValue];
        
        
        
        [switchButton->actionbutton setButtonCross:showCrossBtn];
       // (switchButton->actionbutton).crossButton.subproperty = subProperties;
        switchButton->actionbutton.isTrigger = isTrigger;
        //[switchButton changeBGColor:isTrigger clearColor:NO];
        
       
        //[switchButton.crossButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [switchButton->delayButton addTarget:self action:@selector(onActionDelayClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        xVal += rulesButtonsViewWidth;
        
        [scrollView addSubview:switchButton];

    }
}
+ (void)onActionDelayClicked:(id)sender{
    NSLog(@"onactiondelay clicked");
    DelayPicker *daypicker = [DelayPicker new];
    [daypicker setupPicker:scrollView];
}

+ (void)drawImage:(NSString *)iconName {
    NSLog(@"arrow button");
    SwitchButton *imageButton = [[SwitchButton alloc] initWithFrame:CGRectMake(xVal,5, triggerActionBtnWidth, triggerActionBtnHeight)];//todo
    [imageButton setupValues:[UIImage imageNamed:iconName] topText:@"" bottomText:@"" isTrigger:YES];
    //image.image = [UIImage imageNamed:iconName];
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:imageButton];
    
}
+(void)getDeviceTypeFor:(SFIButtonSubProperties*)buttonSubProperty{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSLog(@" eventType :- %@ index :%d device id -: %d",buttonSubProperty.eventType,buttonSubProperty.index,buttonSubProperty.deviceId);

    if((buttonSubProperty.deviceId  == 1) && [buttonSubProperty.eventType isEqualToString:@"AlmondModeUpdated"]){
        buttonSubProperty.deviceType= SFIDeviceType_BinarySwitch_0;
        buttonSubProperty.deviceName = @"Mode";
    }else if(buttonSubProperty.index == 0 && buttonSubProperty.eventType !=nil){
        
        for(SFIConnectedDevice *connectedClient in toolkit.wifiClientParser){
            
            if(buttonSubProperty.deviceId == connectedClient.deviceID.intValue){
                buttonSubProperty.deviceType = SFIDeviceType_WIFIClient;
                buttonSubProperty.deviceName = connectedClient.name;
                break;
            }
        }
        
    }else{
        
        for(SFIDevice *device in [toolkit deviceList:plus.almondplusMAC]){
            if(buttonSubProperty.deviceId == device.deviceID){
                buttonSubProperty.deviceType = device.deviceType;
                buttonSubProperty.deviceName = device.deviceName;
            break;
            }
        }
    }
    NSLog(@" id :%d,name :%@ ",buttonSubProperty.deviceId,buttonSubProperty.deviceName);
}

//-(void)onActionDelayButtonClicked:(id)sender{
//    NSLog(@"onActionDelayButtonClicked: %@", sender);
//    UIButton *delayButton = sender;
//    delayButton.selected = !delayButton.selected;
//    rulesButtonViewClick = (RulesButtonsView*)[sender superview];
//    delaySecs = [rulesButtonViewClick.subProperties.delay intValue];
//    //    [self removeDelayView]; //check always in beginning
//    if(delayButton.selected){
//        pickerMinsRange = [[NSMutableArray alloc]init];
//        pickerSecsRange = [[NSMutableArray alloc]init];
//        for (int i = 0; i <= 4; i++) {
//            [pickerMinsRange addObject:[NSString stringWithFormat:@"%d",i]];
//        }
//        for (int i = 0; i <= 59; i++) {
//            [pickerSecsRange addObject:[NSString stringWithFormat:@"%d",i]];
//        }
//        [self setupPicker];
//    } else{
//        [self removeDelayView];
//        delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
//        [delayButton setBackgroundColor:[UIColor colorFromHexString:@"FF9500"]];
//        SFIButtonSubProperties *buttonProperties = [self.rule.actions objectAtIndex:rulesButtonViewClick.subProperties.positionId];
//        buttonProperties.delay = [NSString stringWithFormat:@"%d", [self getDelay]];
//        delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
//        NSLog(@"no of secs delay: %d", [self getDelay]);
//        //        [rulesButtonViewClick setNewValue:[NSString stringWithFormat:@"%d", [self getDelay]]];
//        [self.delegate updateActionsArray:self.rule.actions andDeviceIndexesForId:rulesButtonViewClick.subProperties.deviceId];
//    }
//}



@end