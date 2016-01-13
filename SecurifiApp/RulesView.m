//
//  RulesView.m
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "RulesView.h"
#import "RulesConstants.h"
//#import "SensorIndexSupport.h"
#import "RuleSensorIndexSupport.h"
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
#import "SFITriggersActionsSwitchButton.h"
#import "SFITriggersActionsDimmerButton.h"
#import <Colours.h>
#import "RulesIndexValueSupport.h"
#import "AddActions.h"
#import "AddRulesViewController.h"
#import "SavedRulesTableViewController.h"
#import "SecurifiToolkit/Parser.h"
#import "RulesButtonsView.h"


@interface RulesView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic) NSMutableArray* rulesTriggersIndexValSupport;
@property(nonatomic) NSMutableArray* rulesActionsIndexValSupport;
@property(nonatomic) SFIButtonSubProperties *triggerModeProperties;
@property(nonatomic) SFIButtonSubProperties *actionModeProperties;
@property(nonatomic) NSMutableArray* wifiClientsSupport;
@property(nonatomic) NSMutableArray* actionModePropertyArray;
@property(nonatomic) AddActions* actionsView;
@property(nonatomic) NSArray *wifi;

@property(nonatomic) SavedRulesTableViewController *ruleTable;
@end


@implementation RulesView
RulesButtonsView *rulesButtonViewClick;


NSMutableArray * pickerMinsRange;
NSMutableArray *pickerSecsRange;

int delaySecs;
int secs;
int mins;

UIView * actionSheet;

-(id)init{
    if(self == [super init]){
        NSLog(@"init method");
        self.wifi = [NSArray new];
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = [toolkit currentAlmond];
        self.deviceArray = [NSMutableArray arrayWithArray:[toolkit deviceList:plus.almondplusMAC]];/*- (NSArray *)deviceList:(NSString *)almondMac;*/
        //        DeviceListAndValues *deviceandValue = [[DeviceListAndValues alloc]init];
        //        self.deviceArray =[deviceandValue addDevice];
        //self.deviceValueArray = [deviceandValue addDeviceValues];
        self.actionsView = [AddActions new];
        self.wifiClientsSupport = [NSMutableArray new];
        //        actionSheet = nil;
    }
    return self;
}

-(RulesIndexValueSupport*)createRulesActionIndexValueSupport:(NSString*)iconName text:(NSString*)displayText title:(NSString*)title layoutType:(NSString*)layoutType suffix:(NSString*)suffix withDeviceID:(sfi_id)deviceID delay:(NSString*)delay positionId:(int)positionId{
    RulesIndexValueSupport *rulesValSupport = [RulesIndexValueSupport new];
    rulesValSupport.iconName = iconName;
    rulesValSupport.displayText = displayText;
    rulesValSupport.title = title;
    rulesValSupport.layoutType = layoutType;
    rulesValSupport.suffix = suffix;
    rulesValSupport.deviceID = deviceID;
    rulesValSupport.delay = delay;
    rulesValSupport.positionId = positionId;
    return rulesValSupport;
}

-(RulesIndexValueSupport*)createRulesIndexValueSupport:(NSString*)iconName text:(NSString*)displayText title:(NSString*)title layoutType:(NSString*)layoutType suffix:(NSString*)suffix withDeviceID:(sfi_id)deviceID positionId:(int)positionId{
    RulesIndexValueSupport *rulesValSupport = [RulesIndexValueSupport new];
    rulesValSupport.iconName = iconName;
    rulesValSupport.displayText = displayText;
    rulesValSupport.title = title;
    rulesValSupport.layoutType = layoutType;
    rulesValSupport.suffix = suffix;
    rulesValSupport.deviceID = deviceID;
    rulesValSupport.positionId = positionId;
    return rulesValSupport;
}

//triggers - need to loop as I needed device type
-(void) createTriggersRulesIndexValArray{
    RuleSensorIndexSupport *Index=[[RuleSensorIndexSupport alloc]init];
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in self.rule.triggers) {
        for(SFIDevice *myDevice in self.deviceArray){ // using as we require devicetype
            if(myDevice.deviceID == buttonProperties.deviceId){
                NSArray *deviceIndexes=[Index getIndexesFor:myDevice.deviceType];
                for(SFIDeviceIndex *deviceIndex in deviceIndexes){
                    if (deviceIndex.indexID == buttonProperties.index) {
                        NSArray *indexValues = deviceIndex.indexValues;
                        for(IndexValueSupport *iVal in indexValues){
                            if([iVal.matchData isEqualToString:buttonProperties.matchData]){
                                [self.rulesTriggersIndexValSupport addObject:[self createRulesIndexValueSupport:iVal.iconName text:iVal.displayText title:myDevice.deviceName layoutType:iVal.layoutType suffix:iVal.valueFormatter.suffix withDeviceID:myDevice.deviceID positionId:positionId]];
                                break;
                            }
                            else if([iVal.layoutType isEqualToString:@"dimButton"] ){ //to do handle device 2
                                //buttonProperties.matchData has current data
                                [self.rulesTriggersIndexValSupport addObject:[self createRulesIndexValueSupport:iVal.iconName text:iVal.displayText title:myDevice.deviceName layoutType:iVal.layoutType suffix:iVal.valueFormatter.suffix withDeviceID:myDevice.deviceID positionId:positionId]];
                                break;
                            }
                            else if([iVal.layoutType isEqualToString:@"hue"]){
                                [self.rulesTriggersIndexValSupport addObject:[self createRulesIndexValueSupport:iVal.iconName text:iVal.displayText title:myDevice.deviceName layoutType:iVal.layoutType suffix:iVal.valueFormatter.suffix withDeviceID:myDevice.deviceID positionId:positionId]];
                                break;
                            }
                        }
                        //                        break;
                    }
                }
            }
            //            break;
        }
        positionId++;
    }
}

//actions
-(void) createActionsRulesIndexValArray{
    NSLog(@"getActionsIndexValArray");
    RuleSensorIndexSupport *Index=[[RuleSensorIndexSupport alloc]init];
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in self.rule.actions) {
        for(SFIDevice *myDevice in self.deviceArray){
            if(myDevice.deviceID == buttonProperties.deviceId){
                NSMutableArray *deviceIndexes = [NSMutableArray arrayWithArray:[Index getIndexesFor:myDevice.deviceType]];
                
                if ([self.actionsView istoggle:myDevice]) {
                    NSLog(@" it is toggle index");
                    SFIDeviceIndex *temp = [self.actionsView getToggelDeviceIndex];
                    [deviceIndexes addObject : temp];
                }
                
                for(SFIDeviceIndex *deviceIndex in deviceIndexes){
                    if (deviceIndex.indexID == buttonProperties.index) {
                        NSArray *indexValues = deviceIndex.indexValues;
                        for(IndexValueSupport *iVal in indexValues){
                            NSLog(@"device id: %d, index: %d", myDevice.deviceID, deviceIndex.indexID);
                            if([iVal.matchData isEqualToString:buttonProperties.matchData]){
                                NSLog(@"button properties. delay: %@", buttonProperties.delay);
                                [self.rulesActionsIndexValSupport addObject:[self createRulesActionIndexValueSupport:iVal.iconName text:iVal.displayText title:myDevice.deviceName layoutType:iVal.layoutType suffix:iVal.valueFormatter.suffix withDeviceID:myDevice.deviceID delay:buttonProperties.delay positionId:positionId]];
                                break;
                            }
                            else if([iVal.layoutType isEqualToString:@"dimButton"] ){ //to do - handle device 2
                                [self.rulesActionsIndexValSupport addObject:[self createRulesActionIndexValueSupport:iVal.iconName text:iVal.displayText title:myDevice.deviceName layoutType:iVal.layoutType suffix:iVal.valueFormatter.suffix withDeviceID:myDevice.deviceID delay:buttonProperties.delay positionId:positionId]];
                                break;
                            }
                            else if([iVal.layoutType isEqualToString:@"hue"]){
                                [self.rulesActionsIndexValSupport addObject:[self createRulesActionIndexValueSupport:iVal.iconName text:iVal.displayText title:myDevice.deviceName layoutType:iVal.layoutType suffix:iVal.valueFormatter.suffix withDeviceID:myDevice.deviceID delay:buttonProperties.delay positionId:positionId]];
                                break;
                            }
                        }
                        //                        break;
                    }
                }
            }
            //            break;
        }
        positionId++;
    }
}

-(void)retriveTriggerMode{
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in self.rule.triggers) {
        if(buttonProperties.deviceId == 0){
            NSLog(@"retriveTriggerMode - position id : %d", positionId);
            self.triggerModeProperties = [[SFIButtonSubProperties alloc]init];
            buttonProperties.positionId = positionId;
            self.triggerModeProperties = buttonProperties;
        }
        positionId++;
    }
}

-(void)retriveActionMode{
    self.actionModePropertyArray = [[NSMutableArray alloc]init];
    int positionId=0;
    for (SFIButtonSubProperties *buttonProperties in self.rule.actions) {
        if(buttonProperties.deviceId == 0){
            buttonProperties.positionId = positionId;
            [self.actionModePropertyArray addObject:buttonProperties];
        }
        positionId++;
    }
    NSLog(@" actionModePropertyArray.count %ld",self.actionModePropertyArray.count);
}

-(void)retriveWifiClients{
    [self.wifiClientsSupport removeAllObjects];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.wifiClientsArray = toolkit.wifiClientParser;
    NSLog(@"wificlients: %ld, client device array: %@", (unsigned long)self.rule.wifiClients.count, self.wifiClientsArray);
    int positionId = 0;
    for (SFIButtonSubProperties *buttonProperties in self.rule.wifiClients) {
        NSLog(@"button %@ ,%d,%d",buttonProperties.matchData ,buttonProperties.index,buttonProperties.deviceId);
        for(SFIConnectedDevice *myDevice in toolkit.wifiClientParser){
            if(myDevice.deviceID.intValue == buttonProperties.deviceId){
                NSLog(@"device id matched %@",buttonProperties.eventType);
                if([buttonProperties.eventType isEqualToString:@"ClientJoined"]){
                    
                    [self.wifiClientsSupport addObject:[self createRulesIndexValueSupport:@"device-joining" text:@"Join" title:myDevice.name layoutType:@"" suffix:@"" withDeviceID:(myDevice.deviceID).intValue positionId:positionId]];
                    [self refreshArray];
                }else if([buttonProperties.eventType isEqualToString:@"ClientLeft"]){
                    NSLog(@"client left mydevice mac %@ ,device name: %@,",myDevice.deviceMAC,myDevice.name);
                    [self.wifiClientsSupport addObject:[self createRulesIndexValueSupport:@"device-leaving" text:@"Leave" title:myDevice.name layoutType:@"" suffix:@"" withDeviceID:(myDevice.deviceID).intValue positionId:positionId]];
                    [self refreshArray];
                }
                break;
            }
        }
        positionId++;
    }
}

-(void)refreshArray{
    NSArray *cleanedArray = [[NSSet setWithArray:self.wifiClientsSupport] allObjects];
    self.wifiClientsSupport =[NSMutableArray arrayWithArray:cleanedArray];
}


//incoming point - preprocessing is done here
- (void)createTriggersActionsView:(UIScrollView*)triggersActionsScrollView{
    //
    //clear view
    NSArray *viewsToRemove = [triggersActionsScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    //trigger - time
    
    //trigger - clients
    [self retriveWifiClients];
    //trigger - mode
    [self retriveTriggerMode];
    [self retriveActionMode];
    
    //rules selected items
    self.rulesTriggersIndexValSupport = [NSMutableArray new];
    [self createTriggersRulesIndexValArray];
    
    self.rulesActionsIndexValSupport = [NSMutableArray new];
    [self createActionsRulesIndexValArray];
    
    //add seleted rules
    [self displayRule:triggersActionsScrollView];
}

-(int)drawAddButton:(UIScrollView *)scrollView xCoordinate:(int)xVal{
    NSLog(@"add button");
    SFITriggersActionsSwitchButton *addButton = [[SFITriggersActionsSwitchButton alloc] initWithFrame:CGRectMake(xVal,5, triggerActionBtnWidth, triggerActionBtnHeight)];//todo
    [addButton setupValues:[UIImage imageNamed:@"plus_icon"] Title:@"" displayText:@""];
    [addButton changeBGColor:[UIColor clearColor]];
    xVal += triggerActionBtnWidth;
    
    [scrollView addSubview:addButton];
    
    return xVal;
}

-(int)drawArrowButton:(UIScrollView *)scrollView xCoordinate:(int)xVal{
    NSLog(@"arrow button");
    SFITriggersActionsSwitchButton *addButton = [[SFITriggersActionsSwitchButton alloc] initWithFrame:CGRectMake(xVal,5, triggerActionBtnWidth, triggerActionBtnHeight)];//todo
    [addButton setupValues:[UIImage imageNamed:@"arrow_icon"] Title:@"" displayText:@""];
    [addButton changeBGColor:[UIColor clearColor]];
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:addButton];
    
    return xVal;
}

-(NSString *)getColorHex:(NSString*)value {
    if (!value) {
        return @"";
    }
    float hue = [value floatValue];
    hue = hue / 65535;
    UIColor *color = [UIColor colorWithHue:hue saturation:100 brightness:100 alpha:1.0];
    return [color.hexString uppercaseString];
};

-(int)drawButton:(UIScrollView *)scrollView indexValueSupport:(RulesIndexValueSupport*)rVal xCoordinate:(int)xVal isTrigger:(BOOL)isTrigger{
    SFITriggersActionsSwitchButton *switchButton = [[SFITriggersActionsSwitchButton alloc] initWithFrame:CGRectMake(xVal, 5, triggerActionBtnWidth, triggerActionBtnHeight)];
    
    NSString *dimDisplayText;
    if([rVal.layoutType isEqualToString:@"dimButton"]){
        dimDisplayText = [NSString stringWithFormat:@"%@ %@%@", rVal.displayText, rVal.matchData, rVal.suffix];
        [switchButton setupValues:[UIImage imageNamed:rVal.iconName] Title:rVal.title displayText:dimDisplayText];
    }else{
        [switchButton setupValues:[UIImage imageNamed:rVal.iconName] Title:rVal.title displayText:rVal.displayText];
    }
    
    [switchButton setButtonCross:self.toHideCrossButton];
    switchButton.crossButton.subproperty = [self createSubPropertiesFordeviceID:rVal.deviceID positionId:rVal.positionId];
    
    [switchButton changeBGColor:[UIColor colorFromHexString:@"02a8f3"]];
    [switchButton.crossButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:switchButton];
    return xVal;
}


-(int)drawHueItems:(UIScrollView*)scrollView indexValueSupport:(RulesIndexValueSupport*)rVal xCoordinate:(int)xVal isTrigger:(BOOL)isTrigger{
    //for now only hue-color
    RulesButtonsView *hueButton = [[RulesButtonsView alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
    [hueButton setupValues:[UIImage imageNamed:rVal.iconName] Title:rVal.title displayText:rVal.displayText delay:rVal.delay];
    
    [hueButton->actionbutton setButtonCross:self.toHideCrossButton];
    (hueButton->actionbutton).crossButton.subproperty = [self createActionsSubPropertiesForDeviceId:rVal.deviceID delay:rVal.delay positionId:rVal.positionId];
    hueButton.subProperties = [self createActionsSubPropertiesForDeviceId:rVal.deviceID delay:rVal.delay positionId:rVal.positionId];
    
    NSString *colorHexString = [self getColorHex:rVal.matchData];
    [hueButton changeBGColor:[UIColor colorFromHexString:@"FF9500"]];
    [(hueButton->actionbutton).crossButton addTarget:self action:@selector(onActionCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    (hueButton->delayButton).userInteractionEnabled = !self.toHideCrossButton;
    [hueButton->delayButton addTarget:self action:@selector(onActionDelayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [hueButton->actionbutton changeImageColor:[UIColor colorFromHexString:colorHexString]];
    xVal += 91;
    [scrollView addSubview:hueButton];
    return xVal;
}

-(int)drawActionButton:(UIScrollView *)scrollView indexValueSupport:(RulesIndexValueSupport*)rVal xCoordinate:(int)xVal isTrigger:(BOOL)isTrigger{
    NSLog(@"action-delay: %@", rVal.delay);
    if([rVal.layoutType isEqualToString:@"hue"]){
        xVal = [self drawHueItems:scrollView indexValueSupport:rVal xCoordinate:xVal isTrigger:isTrigger]; //xval adjusted in method
        return xVal;
    }
    
    RulesButtonsView *switchButton = [[RulesButtonsView alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
    NSString *dimDisplayText;
    if([rVal.layoutType isEqualToString:@"dimButton"]){
        dimDisplayText = [NSString stringWithFormat:@"%@ %@%@", rVal.displayText, rVal.matchData, rVal.suffix];
        [switchButton setupValues:[UIImage imageNamed:rVal.iconName] Title:rVal.title displayText:dimDisplayText delay:rVal.delay];
    }else{
        [switchButton setupValues:[UIImage imageNamed:rVal.iconName] Title:rVal.title displayText:rVal.displayText delay:rVal.delay];
    }
    [(switchButton->actionbutton) setButtonCross:self.toHideCrossButton];
    
    (switchButton->actionbutton).crossButton.subproperty = [self createActionsSubPropertiesForDeviceId:rVal.deviceID delay:rVal.delay positionId:rVal.positionId];
    switchButton.subProperties = [self createActionsSubPropertiesForDeviceId:rVal.deviceID delay:rVal.delay positionId:rVal.positionId];
    
    [switchButton changeBGColor:[UIColor colorFromHexString:@"FF9500"]];
    [(switchButton->actionbutton).crossButton addTarget:self action:@selector(onActionCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    (switchButton->delayButton).userInteractionEnabled = !self.toHideCrossButton;
    [switchButton->delayButton addTarget:self action:@selector(onActionDelayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    xVal += 91;
    [scrollView addSubview:switchButton];
    
    return xVal;
}

-(int)drawMode:(UIScrollView *)scrollView xPosition:(int)xVal isTrigger:(BOOL)isTrigger{
    SFITriggersActionsSwitchButton *switchButton = [[SFITriggersActionsSwitchButton alloc] initWithFrame:CGRectMake(xVal, 5, triggerActionBtnWidth, triggerActionBtnHeight)];
    if([self.triggerModeProperties.matchData isEqualToString:@"home"]){
        NSLog(@"home mode");
        [switchButton setupValues:[UIImage imageNamed:@"home_icon"] Title:@"Mode" displayText:@"Home"];
        [switchButton setButtonCross:self.toHideCrossButton];
        switchButton.crossButton.subproperty = [self createSubPropertiesFordeviceID:0 positionId:self.triggerModeProperties.positionId];
    }else{
        NSLog(@"away mode");
        [switchButton setupValues:[UIImage imageNamed:@"away_icon"] Title:@"Mode" displayText:@"Away"];
        [switchButton setButtonCross:self.toHideCrossButton];
        switchButton.crossButton.subproperty = [self createSubPropertiesFordeviceID:0 positionId:self.triggerModeProperties.positionId];
    }
    NSLog(@"mode subproperties: %@", switchButton.crossButton.subproperty);
    [switchButton changeBGColor:[UIColor colorFromHexString:@"02a8f3"]];
    [switchButton.crossButton addTarget:self action:@selector(onTriggerCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:switchButton];
    self.actionModeProperties = nil;
    self.triggerModeProperties = nil;
    return xVal;
}

-(int)drawActionMode:(UIScrollView *)scrollView xPosition:(int)xVal isTrigger:(BOOL)isTrigger{
    RulesButtonsView *switchButton = [[RulesButtonsView alloc] initWithFrame:CGRectMake(xVal, 5, rulesButtonsViewWidth, rulesButtonsViewHeight)];
    if([self.triggerModeProperties.matchData isEqualToString:@"home"]){
        NSLog(@"home mode");
        [switchButton setupValues:[UIImage imageNamed:@"home_icon"] Title:@"Mode" displayText:@"Home" delay:@"0"];
        [switchButton->actionbutton setButtonCross:self.toHideCrossButton];
        (switchButton->actionbutton).crossButton.subproperty = [self createActionsSubPropertiesForDeviceId:0 delay:self.triggerModeProperties.delay positionId:self.triggerModeProperties.positionId];
        switchButton.subProperties = [self createActionsSubPropertiesForDeviceId:0 delay:self.triggerModeProperties.delay positionId:self.triggerModeProperties.positionId];
    }else{
        NSLog(@"away mode");
        [switchButton setupValues:[UIImage imageNamed:@"away_icon"] Title:@"Mode" displayText:@"Away" delay:@"0"];
        [(switchButton->actionbutton) setButtonCross:self.toHideCrossButton];
        (switchButton->actionbutton).crossButton.subproperty = [self createActionsSubPropertiesForDeviceId:0 delay:self.triggerModeProperties.delay positionId:self.triggerModeProperties.positionId];
        switchButton.subProperties = [self createActionsSubPropertiesForDeviceId:0 delay:self.triggerModeProperties.delay positionId:self.triggerModeProperties.positionId];
    }
    
    [switchButton changeBGColor:[UIColor colorFromHexString:@"FF9500"]];
    [(switchButton->actionbutton).crossButton addTarget:self action:@selector(onActionCrossButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [switchButton->delayButton addTarget:self action:@selector(onActionDelayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    xVal += 91;
    [scrollView addSubview:switchButton];
    self.actionModeProperties = nil;
    self.triggerModeProperties = nil;
    return xVal;
}

-(int)drawClients:(UIScrollView *)scrollView indexValueSupport:(RulesIndexValueSupport*)rVal xCoordinate:(int)xVal{
    NSLog(@" rVal %d ,%@ ",rVal.deviceID,rVal.matchData);
    SFITriggersActionsSwitchButton *switchButton = [[SFITriggersActionsSwitchButton alloc] initWithFrame:CGRectMake(xVal, 5, triggerActionBtnWidth, triggerActionBtnHeight)];
    [switchButton setupValues:[UIImage imageNamed:rVal.iconName] Title:rVal.title displayText:rVal.displayText];
    NSLog(@" switchbutton %d ,%@,",switchButton.subProperties.deviceId,switchButton.subProperties.matchData);
    [switchButton setButtonCross:self.toHideCrossButton];
    switchButton.crossButton.subproperty = [self createSubPropertiesFordeviceID:rVal.deviceID positionId:rVal.positionId];
    [switchButton.crossButton addTarget:self action:@selector(onClientsCrossButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [switchButton changeBGColor:[UIColor colorFromHexString:@"02a8f3"]];
    xVal += triggerActionBtnWidth;
    [scrollView addSubview:switchButton];
    
    return xVal;
}

-(int)drawTime:(UIScrollView *)scrollView xCoordinate:(int)xVal{
    NSLog(@"drawTime");
    
    SFITriggersActionsDimmerButton *dimbutton=[[SFITriggersActionsDimmerButton alloc]initWithFrame:CGRectMake(xVal, 5, triggerActionDimWidth, triggerActionDimHeight)];
    
    int timeSegment = self.rule.time.segmentType;
    if(timeSegment == 1){
        NSDate *date =self.rule.time.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        [dimbutton setupValues:[dateFormat stringFromDate:date] Title:@"Time" displayText:@"days" suffix:@""];
    }else if(timeSegment == 2){
        NSDate *dateFrom =self.rule.time.dateFrom;
        NSDate *dateTo = self.rule.time.dateTo;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        NSString *time = [NSString stringWithFormat:@"%@\n%@", [dateFormat stringFromDate:dateFrom], [dateFormat stringFromDate:dateTo]];
        NSLog(@"time interval: %@", time);
        [dimbutton setupValues:time Title:@"Time Interval" displayText:@"days" suffix:@""];
    }
    [dimbutton setButtonCross:self.toHideCrossButton];
    [dimbutton.crossButton addTarget:self action:@selector(onTimeCrossButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [dimbutton changeBGColor:[UIColor colorFromHexString:@"02a8f3"]]; //just to change color, perhaps you have to create method
    
    xVal += triggerActionDimWidth;
    [scrollView addSubview:dimbutton];
    return xVal;
}

-(void) displayRule:(UIScrollView *)triggersActionsScrollView{
    NSLog(@"createSeletedRuleCell");
    int xVal = 20;
    /*********************Triggers******************/
    BOOL isFirst = YES;
    //trigger - time
    if(self.rule.time.segmentType == 1 || self.rule.time.segmentType == 2){
        xVal = [self drawTime:triggersActionsScrollView xCoordinate:xVal];
        isFirst = NO;
    }
    //trigger - clients
    for (RulesIndexValueSupport *rVal in self.wifiClientsSupport){
        if (isFirst){
            xVal = [self drawClients:triggersActionsScrollView indexValueSupport:rVal xCoordinate:xVal];
            isFirst = NO;
            
        }else{
            xVal = [self drawAddButton:triggersActionsScrollView xCoordinate:xVal];
            xVal = [self drawClients:triggersActionsScrollView indexValueSupport:rVal xCoordinate:xVal];
        }
    }
    //trigger - mode
    if(self.triggerModeProperties != nil){
        if(isFirst){
            xVal = [self drawMode:triggersActionsScrollView xPosition:xVal isTrigger:YES];
            isFirst = NO;
        }
        else{
            xVal = [self drawAddButton:triggersActionsScrollView xCoordinate:xVal];
            xVal = [self drawMode:triggersActionsScrollView xPosition:xVal isTrigger:YES];
        }
    }
    //triggers  device indexes
    for (RulesIndexValueSupport *rVal in self.rulesTriggersIndexValSupport) {
        if (isFirst){
            xVal = [self drawButton:triggersActionsScrollView indexValueSupport:rVal xCoordinate:xVal isTrigger:YES];
            isFirst = NO;
            
        }else{
            xVal = [self drawAddButton:triggersActionsScrollView xCoordinate:xVal];
            xVal = [self drawButton:triggersActionsScrollView indexValueSupport:rVal xCoordinate:xVal isTrigger:YES];
        }
    }
    /********************* actions *****************/
    //action mode
    isFirst = YES;
    if(self.actionModePropertyArray != nil){
        for(SFIButtonSubProperties *buttonsubproperty in self.actionModePropertyArray){
            self.triggerModeProperties = buttonsubproperty;
            if(isFirst){
                xVal = [self drawArrowButton:triggersActionsScrollView xCoordinate:xVal];
                xVal = [self drawActionMode:triggersActionsScrollView xPosition:xVal isTrigger:NO];
                isFirst = NO;
            }
            else{
                xVal = [self drawAddButton:triggersActionsScrollView xCoordinate:xVal];
                xVal = [self drawActionMode:triggersActionsScrollView xPosition:xVal isTrigger:NO];
            }
            
        }
        [self.actionModePropertyArray removeAllObjects];
    }
    
    //actions device indexes
    for (RulesIndexValueSupport *rVal in self.rulesActionsIndexValSupport) {
        if (isFirst){
            xVal = [self drawArrowButton:triggersActionsScrollView xCoordinate:xVal];
            xVal = [self drawActionButton:triggersActionsScrollView indexValueSupport:rVal xCoordinate:xVal isTrigger:NO];
            isFirst = NO;
        }else{
            xVal = [self drawAddButton:triggersActionsScrollView xCoordinate:xVal];
            xVal = [self drawActionButton:triggersActionsScrollView indexValueSupport:rVal xCoordinate:xVal isTrigger:NO];
        }
    }
    
    if(xVal > triggersActionsScrollView.frame.size.width){
        [triggersActionsScrollView setContentOffset:CGPointMake(xVal-triggersActionsScrollView.frame.size.width + 20, 0) animated:YES];
    }
    triggersActionsScrollView.contentSize = CGSizeMake(xVal + 20, triggersActionsScrollView.frame.size.height);//to do
}


#pragma mark helper methods
-(int)maxCellId:(NSArray*)deviceIndexes{
    int numberOfCells = -1;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        if(numberOfCells < deviceIndex.cellId){
            numberOfCells = deviceIndex.cellId;
        }
    }
    return numberOfCells;
}


- (void) shiftButtonsByWidth:(int)width View:(UIView *)view forIteration:(int)i{
    for (int j = 1; j < i; j++) {
        UIView *childView = [view subviews][j-1];
        
        childView.frame = CGRectMake(childView.frame.origin.x -  (width/2),
                                     childView.frame.origin.y,
                                     childView.frame.size.width,
                                     childView.frame.size.height);
    }
}

-(SFIButtonSubProperties*) createSubPropertiesFordeviceID:(sfi_id)deviceID positionId:(int)positionId{
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.positionId = positionId;
    return subProperties;
}

-(SFIButtonSubProperties*) createActionsSubPropertiesForDeviceId:(sfi_id)deviceID delay:(NSString*)delay positionId:(int)positionId{
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.delay = delay;
    subProperties.positionId = positionId;
    return subProperties;
}

#pragma mark selector methods
-(void)onTriggerCrossButtonClicked:(CrossButton*)crossButton{
    //includes mode
    [self.rule.triggers removeObjectAtIndex:crossButton.subproperty.positionId];
    [self.delegate updateTriggerArray:self.rule.triggers andDeviceIndexesForId:crossButton.subproperty.deviceId];
}

-(void)onActionCrossButtonClicked:(CrossButton*)crossButton{
    [self.rule.actions removeObjectAtIndex:crossButton.subproperty.positionId];
    [self.delegate updateActionsArray:self.rule.actions andDeviceIndexesForId:crossButton.subproperty.deviceId];
}

-(void)onClientsCrossButtonClick:(CrossButton*)crossButton{
    [self.rule.wifiClients removeObjectAtIndex:crossButton.subproperty.positionId];
    [self.delegate updateWifiClients:self.rule.wifiClients];
}

-(void)onTimeCrossButtonClick:(CrossButton*)sender{
    self.rule.time.segmentType = -1;
    [self.delegate updateTime:self.rule.time]; //not needed as we are just passing reference
}

-(int)getDelay{
    return secs + (mins * 60);
}

-(void)removeDelayView{
    //    if(actionSheet != nil){ //todo
    NSLog(@"removeDelayView");
    [UIView animateWithDuration:0.3 animations:^{
        actionSheet.alpha = 1;
    }completion:^(BOOL finished) {
        [actionSheet removeFromSuperview];
        //            actionSheet = nil;
    }];
    //    }
}

-(void)onActionDelayButtonClicked:(id)sender{
    NSLog(@"onActionDelayButtonClicked: %@", sender);
    UIButton *delayButton = sender;
    delayButton.selected = !delayButton.selected;
    rulesButtonViewClick = (RulesButtonsView*)[sender superview];
    delaySecs = [rulesButtonViewClick.subProperties.delay intValue];
    //    [self removeDelayView]; //check always in beginning
    if(delayButton.selected){
        pickerMinsRange = [[NSMutableArray alloc]init];
        pickerSecsRange = [[NSMutableArray alloc]init];
        for (int i = 0; i <= 4; i++) {
            [pickerMinsRange addObject:[NSString stringWithFormat:@"%d",i]];
        }
        for (int i = 0; i <= 59; i++) {
            [pickerSecsRange addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self setupPicker];
    } else{
        [self removeDelayView];
        delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
        [delayButton setBackgroundColor:[UIColor colorFromHexString:@"FF9500"]];
        SFIButtonSubProperties *buttonProperties = [self.rule.actions objectAtIndex:rulesButtonViewClick.subProperties.positionId];
        buttonProperties.delay = [NSString stringWithFormat:@"%d", [self getDelay]];
         delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
        NSLog(@"no of secs delay: %d", [self getDelay]);
        //        [rulesButtonViewClick setNewValue:[NSString stringWithFormat:@"%d", [self getDelay]]];
        [self.delegate updateActionsArray:self.rule.actions andDeviceIndexesForId:rulesButtonViewClick.subProperties.deviceId];
    }
}

-(UIPickerView*)createPickerView:(CGRect)frame{
    UIPickerView *chPicker = [[UIPickerView alloc] initWithFrame:frame];
    chPicker.dataSource = self;
    chPicker.delegate = self;
    chPicker.showsSelectionIndicator = NO;
    chPicker.backgroundColor = [UIColor whiteColor];
    return chPicker;
}

-(NSInteger)getSecsRow{
    int secsRow = 0;
    if(delaySecs <= 59){
        secsRow = delaySecs;
    }else if(delaySecs >= 60 && secs <= 3599){
        secsRow = delaySecs % 60;
    }
    return @(secsRow).integerValue;
}

-(NSInteger)getMinsRow{
    int minsRow = 0;
    if(delaySecs <= 59){
        minsRow = 0;
    }
    else if(delaySecs >= 60 && delaySecs <= 3599){
        minsRow = delaySecs/60;
    }
    else{
        minsRow = delaySecs/3600;
    }
    return @(minsRow).integerValue;
}

#pragma mark picker methods
- (void)setupPicker{
    NSLog(@"picker view called");
    int scrollViewHeight = self.parentViewController.triggersActionsScrollView.frame.size.height;
    UIPickerView *pickerRange = [self createPickerView:CGRectMake(55, 0, 100, 100)];
    mins = (int)[self getMinsRow];
    secs = (int)[self getSecsRow];
    [pickerRange selectRow:[self getMinsRow] inComponent:0 animated:YES];
    [pickerRange selectRow:[self getSecsRow] inComponent:1 animated:YES];
    
    actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0,scrollViewHeight + 40, self.parentViewController.view.frame.size.width, 100)];
    actionSheet.backgroundColor = [UIColor whiteColor];
//    actionSheet.backgroundColor = [UIColor grapeColor];
    UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 210, 100)];
//    subView.backgroundColor = [UIColor grayColor];
    UILabel *minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, subView.frame.size.height/2 - textHeight/2, 50,textHeight)];
    minsLabel.textAlignment = NSTextAlignmentCenter;
    minsLabel.text = @"Mins";
   minsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    UILabel *secsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, subView.frame.size.height/2 - textHeight/2, 50,textHeight)];
    secsLabel.text = @"Secs";
    secsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    secsLabel.textAlignment = NSTextAlignmentCenter;
    [subView addSubview:minsLabel];
    [subView addSubview:pickerRange];
    [subView addSubview:secsLabel];
    [actionSheet addSubview:subView];
    subView.center = CGPointMake(actionSheet.bounds.size.width/2,
                                 actionSheet.bounds.size.height/2);
    [self.parentViewController.view addSubview:actionSheet];
    //yourView represent the view that contains UIPickerView and toolbar
    NSLog(@"%@",NSStringFromCGRect(actionSheet.frame));
//    actionSheet.alpha = 0;
//    [UIView animateWithDuration:0.3 animations:^{
//        actionSheet.alpha = 1;
//    }completion:^(BOOL finished) {
//        
//    }];
}

#pragma mark UIPickerViewDelegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 20;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return pickerMinsRange.count;
    }else{
        return pickerSecsRange.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"title for row");
    if(component == 0){
        return [pickerMinsRange objectAtIndex:row];
    }else{
        return [pickerSecsRange objectAtIndex:row];
    }
    return @"";
}

// Set the width of the component inside the picker
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    NSLog(@"widthForComponent");
    return 30;
}

// Item picked
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0){
        mins = [[pickerMinsRange objectAtIndex:row] intValue];
    }else{
        secs = [[pickerSecsRange objectAtIndex:row] intValue];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    if(component == 0){
        label.text = [pickerMinsRange objectAtIndex:row];
    }else{
        label.text = [pickerSecsRange objectAtIndex:row];
    }
    label.textAlignment = NSTextAlignmentCenter; //Changed to NS as UI is deprecated.
    label.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    return label;
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag!=1) {
        actionSheet = nil;
        //        [self invite:pickerSelectedIndex];
    }
}


@end
