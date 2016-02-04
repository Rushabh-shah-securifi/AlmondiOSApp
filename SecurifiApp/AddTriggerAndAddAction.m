//
//  AddTriggerAndAddAction.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 18/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AddTriggerAndAddAction.h"
#import "AddRulesViewController.h"
#import "RulesDeviceNameButton.h"
#import "SensorIndexSupport.h"
#import "Colours.h"
#import "SFIColors.h"
#import "RulesConstants.h"
#import "SFIDeviceIndex.h"
#import "RulesNestThermostat.h"
#import "RulesHue.h"
#import "IndexValueSupport.h"
#import "SFIButtonSubProperties.h"
#import "RulesNestThermostat.h"
#import "RulesHue.h"
#import "V8HorizontalPickerView.h"
#import "V8HorizontalPickerViewProtocol.h"
#import "SFIPickerIndicatorView1.h"
#import "ValueFormatter.h"
#import "SFISubPropertyBuilder.h"

#import "RuleButton.h"
#import "DimmerButton.h"
#import "SwitchButton.h"
#import "RulesDeviceNameButton.h"
#import "TimeView.h"


@interface AddTriggerAndAddAction ()<RulesHueDelegate,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource>
@property (nonatomic)RulesHue *ruleHueObject;
@property TimeView *timeView;
@end

@implementation AddTriggerAndAddAction

V8HorizontalPickerView *picker;

//SFIRul *switchButtonClick;
bool isPresentHozPicker;
int minValue;
int maxValue;
NSString *newPickerValue;
int buttonClickCount;
NSMutableArray * pickerValuesArray2;

-(id)init{
    if(self == [super init]){
        NSLog(@"init method");
        isPresentHozPicker = NO;
        
        newPickerValue = @"50";
        self.selectedButtonsPropertiesArrayAction = [NSMutableArray new];
        isPresentHozPicker = NO;
        newPickerValue = [NSString new];
        self.selectedButtonsPropertiesArrayTrigger = [NSMutableArray new];
    }
    return self;
}
-(CGRect)adjustDeviceNameWidth:(NSString*)deviceName{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGRect textRect;
    
    textRect.size = [deviceName sizeWithAttributes:attributes];
    if(deviceName.length > 18){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
}

- (int)addDeviceName:(NSString *)deviceName deviceID:(int)deviceID deviceType:(unsigned int)deviceType  xVal:(int)xVal {
    double deviceButtonHeight = self.parentViewController.deviceListScrollView.frame.size.height;
    CGRect textRect = [self adjustDeviceNameWidth:deviceName];
    CGRect frame = CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight);
    RulesDeviceNameButton *deviceButton = [[RulesDeviceNameButton alloc]initWithFrame:frame];
    [deviceButton deviceProperty:self.isTrigger deviceType:deviceType deviceName:deviceName deviceId:deviceID];
    
    
    if([deviceName isEqualToString:@"Time"]){
        [deviceButton addTarget:self action:@selector(TimeEventClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else if([deviceName isEqualToString:@"Clients"])
        [deviceButton addTarget:self action:@selector(wifiClientsClicked:) forControlEvents:UIControlEventTouchUpInside];
    else
        [deviceButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentViewController.deviceListScrollView addSubview:deviceButton];

    return xVal + textRect.size.width +15;
}
-(void)TimeEventClicked:(id)sender{
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:sender];
    self.timeView = [[TimeView alloc]init];
//    self.timeView.ruleTime = self.ruleTime;
    self.timeView.delegate = self;
    self.timeView.ruleTime = [self getRuleTime];
    self.timeView.parentViewController = self.parentViewController;
    
    [self.timeView addTimeView];
    
}
-(NSMutableArray *)getTriggerAndActionDeviceList {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSMutableArray *deviceArray = [NSMutableArray new];
    for(SFIDevice *device in [toolkit deviceList:plus.almondplusMAC]){
        if(self.isTrigger && (device.deviceType != SFIDeviceType_HueLamp_48) && (device.deviceType != SFIDeviceType_NestSmokeDetector_58))
            [deviceArray addObject:device];
        else if (device.isActuator && !self.isTrigger )
            [deviceArray addObject:device];
        
    }
    return deviceArray;
 
}

-(void)addDeviceNameList:(BOOL)isTrigger{
    self.isTrigger = isTrigger;
    //clear view
         NSArray *viewsToRemove = [self.parentViewController.deviceListScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    int xVal = 15;
   
    xVal = [self addDeviceName:@"Mode" deviceID:1 deviceType:SFIDeviceType_BinarySwitch_0 xVal:xVal];
    if(self.isTrigger){//if Trigger Add time
        xVal = [self addDeviceName:@"Time" deviceID:0 deviceType:SFIDeviceType_BinarySwitch_0 xVal:xVal];
        xVal = [self addDeviceName:@"Clients" deviceID:0 deviceType:SFIDeviceType_WIFIClient xVal:xVal];
        //same way we can we can do for client in trigger
    }
    //for rest of the devices
    
    for(SFIDevice *device in [self getTriggerAndActionDeviceList]){
        xVal = [self addDeviceName:device.deviceName deviceID:device.deviceID deviceType:device.deviceType xVal:xVal];
    }
    self.parentViewController.deviceListScrollView.contentSize = CGSizeMake(xVal +10,self.parentViewController.deviceListScrollView.contentSize.height);
    [self.parentViewController.deviceIndexButtonScrollView flashScrollIndicators];
}



-(void)wifiClientsClicked:(RulesDeviceNameButton*)deviceButton{
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:deviceButton];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    int i =0;
    for(SFIConnectedDevice *connectedClient in toolkit.wifiClientParser){
        if(connectedClient.deviceUseAsPresence){
            int yScale = ROW_PADDING + (ROW_PADDING+frameSize)*i;
            [self addClientNameLabel:connectedClient.name yScale:yScale];
            
            SensorIndexSupport *Index=[[SensorIndexSupport alloc]init];
            NSArray *deviceIndexes= [Index getIndexesFor:SFIDeviceType_WIFIClient];
            
            SFIDeviceIndex *deviceIndex = deviceIndexes[0];
            for(IndexValueSupport *iVal in deviceIndex.indexValues){
                iVal.matchData = connectedClient.deviceMAC;
            }
            [self addMyButtonwithYScale:yScale withDeviceIndex:deviceIndexes deviceId:connectedClient.deviceID.intValue deviceType:SFIDeviceType_WIFIClient deviceName:connectedClient.name];
            i++;
        }
    }
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*i + ROW_PADDING);
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
    [self.parentViewController.deviceIndexButtonScrollView flashScrollIndicators];
    self.parentViewController.deviceIndexButtonScrollView.showsVerticalScrollIndicator = YES;
}

-(void)addClientNameLabel:(NSString*)clientName yScale:(int)yScale{
    UILabel *clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yScale-20, self.parentViewController.view.frame.size.width, 14)];
    clientNameLabel.text = clientName;
    clientNameLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:12];
    clientNameLabel.backgroundColor = [UIColor clearColor];
    clientNameLabel.textAlignment = NSTextAlignmentCenter;
    clientNameLabel.textColor = [UIColor lightGrayColor];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:clientNameLabel];
    
}

-(void)onDeviceButtonClick:(RulesDeviceNameButton *)sender{
    [self resetViews];
    sender.selected = YES;
    //toggeling
    [self toggleHighlightForDeviceNameButton:sender];
    
    SensorIndexSupport *Index=[[SensorIndexSupport alloc]init];
    NSMutableArray *deviceIndexes=[NSMutableArray arrayWithArray:[Index getIndexesFor:sender.deviceType]];//need
    
    if (!self.isTrigger &&[self istoggle:sender.deviceType]) {
        SFIDeviceIndex *temp = [self getToggelDeviceIndex];
        [deviceIndexes addObject : temp];
    }
    //to handle over flow in small devices
    if([self getDeviceIndexHavingExcessVals:deviceIndexes] != nil){
        [deviceIndexes addObject:[self newDeviceIndex:[self getDeviceIndexHavingExcessVals:deviceIndexes]]];
    }
    [self createDeviceIndexesLayoutForDeviceId:sender.deviceId deviceType:sender.deviceType deviceName:sender.deviceName deviceIndexes:deviceIndexes];
}

-(SFIDeviceIndex*)getDeviceIndexHavingExcessVals:(NSArray*)deviceIndexes{
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
        NSArray *indexVals = deviceIndex.indexValues;
        if(indexVals.count > 4){
            return deviceIndex;
        }
    }
    return nil;
}
-(SFIDeviceIndex *)newDeviceIndex:(SFIDeviceIndex*)deviceIndex{
    //device index has more than 4 Values -> split = 4 + remaining
    NSArray *deviceIndexVals = deviceIndex.indexValues;
    NSInteger indexValCount = [deviceIndexVals count];
    NSMutableArray *NewDeviceIndexVal = [[NSMutableArray alloc]init];
    NSMutableArray *firstFourIndexVals = [[NSMutableArray alloc]init];
    for(int i = 0; i < indexValCount; i++){
        if (i<4) {
            [firstFourIndexVals addObject:[deviceIndexVals objectAtIndex:i]];
        }else{
            [NewDeviceIndexVal addObject:[deviceIndexVals objectAtIndex:i]];
        }
    }

    //remove indexvalues from device index
    deviceIndex.indexValues = firstFourIndexVals;
    SFIDeviceIndex *newDeviceIndex=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BARRIER_OPERATOR];
    newDeviceIndex.indexValues = NewDeviceIndexVal;
    newDeviceIndex.indexID = deviceIndex.indexID;
    newDeviceIndex.cellId = 2;
    newDeviceIndex.isEditableIndex=deviceIndex.isEditableIndex;
    return newDeviceIndex;
}


-(void)resetViews{
    self.parentViewController.TimeSectionView.hidden = YES;
    self.parentViewController.deviceIndexButtonScrollView.hidden = NO;
    
    //clear view
    NSArray *viewsToRemove = [self.parentViewController.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]]) { //to avoid removing scroll indicators
            [v removeFromSuperview];
        }
    }
}
-(void)toggleHighlightForDeviceNameButton:(RulesDeviceNameButton *)currentButton{
    UIScrollView *scrollView = self.parentViewController.deviceListScrollView;
    for(RulesDeviceNameButton *button in [scrollView subviews]){
        if([button isKindOfClass:[UIImageView class]]){
            continue;
        }
        button.selected = NO;
    }
    currentButton.selected = YES;
    
    }

//on devicelist button click, calling this method
-(void) createDeviceIndexesLayoutForDeviceId:(int)deviceId deviceType:(SFIDeviceType)deviceType deviceName:(NSString*)deviceName deviceIndexes:(NSArray*)deviceIndexes{
    int numberOfCells = [self maxCellId:deviceIndexes];
    
    if(deviceType == SFIDeviceType_NestThermostat_57){
        RulesNestThermostat *rulesNestThermostatObject = [[RulesNestThermostat alloc]init];
        
        SFIDeviceValue *nestThermostatDeviceValue;
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = [toolkit currentAlmond];
        
        for(SFIDeviceValue *deviceValue in [toolkit deviceValuesList:plus.almondplusMAC]){
            if(deviceValue.deviceID == deviceId){
                nestThermostatDeviceValue = deviceValue;
                break;
            }
        }
        deviceIndexes = [rulesNestThermostatObject createNestThermostatDeviceIndexes:deviceIndexes deviceValue:nestThermostatDeviceValue];
        numberOfCells = [self maxCellId:deviceIndexes];//recalculating for nest
    }
    
    //dict - array of indexes for cellid
    NSMutableDictionary *deviceIndexesDict = [NSMutableDictionary new];
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
        [self addArrayToDictionary:deviceIndexesDict deviceIndex:deviceIndex];
    }
  
    //huelamp - 58
    if(deviceType == SFIDeviceType_HueLamp_48){
        self.ruleHueObject = [[RulesHue alloc] init];
        self.ruleHueObject.delegate = self;
        self.ruleHueObject.parentViewController = self.parentViewController;
        self.ruleHueObject.selectedButtonsPropertiesArray = self.selectedButtonsPropertiesArrayAction;
        
        
        [self.ruleHueObject createHueCellLayoutWithDeviceId:deviceId deviceType:deviceType deviceIndexes:deviceIndexes deviceName:deviceName scrollView:self.parentViewController.deviceIndexButtonScrollView cellCount:numberOfCells indexesDictionary:deviceIndexesDict];
        return;
    }
    //else for rest of the devices
    int j=0;
    for(int i = 0; i < numberOfCells; i++){
        NSArray *array = [deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d",i+1]];
        if(array!=nil && array.count>0){
            [self addMyButtonwithYScale:ROW_PADDING+(ROW_PADDING+frameSize)*j withDeviceIndex:array deviceId:deviceId deviceType:deviceType deviceName:deviceName];
            j++;
        }
    }
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*numberOfCells + ROW_PADDING);
    
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
    [self.parentViewController.deviceIndexButtonScrollView flashScrollIndicators];
    self.parentViewController.deviceIndexButtonScrollView.showsVerticalScrollIndicator = YES;
}
-(void)addArrayToDictionary:(NSMutableDictionary *)deviceIndexesDict deviceIndex:(SFIDeviceIndex *)deviceIndex{
    if(self.isTrigger ||(!self.isTrigger && deviceIndex.isEditableIndex)){
        NSMutableArray *augArray = [deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d",deviceIndex.cellId]];
        if(augArray != nil){
            [augArray addObject:deviceIndex];
            [deviceIndexesDict setValue:augArray forKey:[NSString stringWithFormat:@"%d",deviceIndex.cellId]];
        }else{
            NSMutableArray *tempArray = [NSMutableArray new];
            [tempArray addObject:deviceIndex];
            [deviceIndexesDict setValue:tempArray forKey:[NSString stringWithFormat:@"%d",deviceIndex.cellId]];
        }
    }
}
-(RulesTimeElement *)getRuleTime{
    NSLog(@"HOW MANY TIMES");
    for(SFIButtonSubProperties *subProperties in self.selectedButtonsPropertiesArrayTrigger){
        if([subProperties.eventType isEqualToString:@"TimeTrigger"]){
            return subProperties.time;
        }
    }
    SFIButtonSubProperties *subProperties=[SFIButtonSubProperties new];
    subProperties.time = [[RulesTimeElement alloc]init];
    subProperties.eventType = @"TimeTrigger";
    [self.selectedButtonsPropertiesArrayTrigger addObject:subProperties];
    return subProperties.time;
}
- (NSMutableDictionary *)setButtonSelection:(RuleButton *)ruleButton isSlider:(BOOL)isSlider deviceIndex:(SFIDeviceIndex *)deviceIndex deviceId:(int)deviceId matchData:(NSString *)matchData{
    NSMutableDictionary *result= [NSMutableDictionary new];
    
    int count = 0;
   // NSString *matchData=nil;
    NSMutableArray *list=(self.isTrigger)?self.selectedButtonsPropertiesArrayTrigger:self.selectedButtonsPropertiesArrayAction;
    for(SFIButtonSubProperties *subProperty in list){ //to do - you can add count property to subproperties and iterate array in reverse
        if(subProperty.deviceId == deviceId && subProperty.index == deviceIndex.indexID && subProperty.matchData == matchData ){
            matchData = subProperty.matchData;
            ruleButton.selected = YES;
            if(!self.isTrigger)
                count++;
            
        }
    }
    
    [result setValue:matchData forKey:@"matchData"];
    [result setValue:@(count).stringValue forKey:@"count"];
    return result;
}

- (void)buildDimButton:(SFIDeviceIndex *)deviceIndex iVal:(IndexValueSupport *)iVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view {
    NSLog(@"subView in view count %ld ",(unsigned long)[view subviews].count);
    DimmerButton *dimbtn=[[DimmerButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y , dimFrameWidth, dimFrameHeight)];
    dimbtn.tag=i;
    
    dimbtn.valueType=deviceIndex.valueType;
    dimbtn.minValue = iVal.minValue;
    dimbtn.maxValue = iVal.maxValue;
    dimbtn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
    
    [dimbtn addTarget:self action:@selector(onDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [dimbtn setupValues:iVal.matchData Title:iVal.displayText suffix:iVal.valueFormatter.suffix isTrigger:self.isTrigger];
    //NSMutableDictionary *result=[self setButtonSelection:dimbtn isSlider:YES deviceIndex:deviceIndex deviceId:deviceId matchData:dimbtn.subProperties.matchData];
    NSLog(@"dimBtn selected %d",dimbtn.selected);
    
    //get previous value
    
    
    
    dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                view.bounds.size.height/2);
    dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
    [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
    dimbtn.selected=[self setActionButtonCount:dimbtn isSlider:YES matchData:iVal.matchData buttonIndex:deviceIndex.indexID buttonId:deviceId];
    if(dimbtn.selected)
        [dimbtn setNewValue:[self setUpNewValueForSelectedButton:dimbtn.subProperties]];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    [view addSubview:dimbtn];
}
-(NSString*)setUpNewValueForSelectedButton:(SFIButtonSubProperties *)dimmButtonSubProperty{
    NSMutableArray *list=self.isTrigger?self.selectedButtonsPropertiesArrayTrigger:self.selectedButtonsPropertiesArrayAction;
    NSString *newValue = @"";
    for(SFIButtonSubProperties *buttonSubProperty in list){
        if(buttonSubProperty.deviceId == dimmButtonSubProperty.deviceId && buttonSubProperty.index == dimmButtonSubProperty.index){
            newValue = buttonSubProperty.matchData;
            return newValue;
        }
    }
    return newValue;
}

- (void)buildSwitchButton:(SFIDeviceIndex *)deviceIndex deviceType:(int)deviceType deviceName:(NSString *)deviceName iVal:(IndexValueSupport *)iVal deviceId:(int)deviceId i:(int)i view:(UIView *)view {
    
    SwitchButton *btnBinarySwitchOn = [[SwitchButton alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
    btnBinarySwitchOn.tag = i;
    btnBinarySwitchOn.valueType=deviceIndex.valueType;
    btnBinarySwitchOn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:iVal.eventType deviceName:deviceName deviceType:deviceType];
    
    btnBinarySwitchOn.deviceType = deviceType;
    [btnBinarySwitchOn addTarget:self action:@selector(onSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    [btnBinarySwitchOn setupValues:[UIImage imageNamed:iVal.iconName] topText:nil bottomText:iVal.displayText isTrigger:self.isTrigger];

    //set perv. count and highlight
    
    btnBinarySwitchOn.selected=[self setActionButtonCount:btnBinarySwitchOn isSlider:NO matchData:iVal.matchData buttonIndex:deviceIndex.indexID buttonId:deviceId];

    btnBinarySwitchOn.center = CGPointMake(view.bounds.size.width/2,
                                           view.bounds.size.height/2);
    btnBinarySwitchOn.frame = CGRectMake(btnBinarySwitchOn.frame.origin.x + ((i-1) * (frameSize/2))+textHeight/2 ,
                                         btnBinarySwitchOn.frame.origin.y,
                                         btnBinarySwitchOn.frame.size.width,
                                         btnBinarySwitchOn.frame.size.height);
    
    int btnWidth = frameSize;
    for (int j = 1; j < i; j++) {
        UIView *childView = [view subviews][j-1];
        
        //handling combination of dimmberbutton and switch button
        if([childView isKindOfClass:[DimmerButton class]]){
            btnWidth = i==2 ? dimFrameWidth: (i==3?0:btnWidth) ;
            if(i==3 || i==4){
                btnBinarySwitchOn.frame = CGRectMake(btnBinarySwitchOn.frame.origin.x + frameSize/2 ,
                                                     btnBinarySwitchOn.frame.origin.y,
                                                     btnBinarySwitchOn.frame.size.width,
                                                     btnBinarySwitchOn.frame.size.height);
            }
            
        }
        //handling combination of dimmberbutton and switch button
        childView.frame = CGRectMake(childView.frame.origin.x -  (btnWidth/2),
                                     childView.frame.origin.y,
                                     childView.frame.size.width,
                                     childView.frame.size.height);
    }
    //dispatch_async(dispatch_get_main_queue(), ^{
    [view addSubview:btnBinarySwitchOn];
}

- (UIView *)addMyButtonwithYScale:(int)yScale withDeviceIndex:(NSArray *)deviceIndexes deviceId:(int)deviceId deviceType:(int)deviceType deviceName:(NSString*)deviceName{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            self.parentViewController.view.frame.size.width,
                                                            frameSize)];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:view];
    int i=0;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        for (IndexValueSupport *iVal in deviceIndex.indexValues) {
            i++;
            if ([iVal.layoutType isEqualToString:@"dimButton"])
                [self buildDimButton:deviceIndex iVal:iVal deviceType:deviceType deviceName:deviceName deviceId:deviceId i:i view:view];
            else
                [self buildSwitchButton:deviceIndex deviceType:deviceType deviceName:deviceName iVal:iVal deviceId:deviceId i:i view:view];
                
        }
    }
    return view;
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
-(int)maxCellId:(NSArray*)deviceIndexes{
    int numberOfCells = -1;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        if(numberOfCells < deviceIndex.cellId){
            numberOfCells = deviceIndex.cellId;
        }
    }
    return numberOfCells;
}
-(SFIDeviceIndex *)getToggelDeviceIndex{
    IndexValueSupport *indexValue =[[IndexValueSupport alloc]init];
    indexValue.displayText = @"TOGGLE";
    indexValue.iconName = @"toggle_icon.png";
    indexValue.matchData = @"toggle";
    NSArray *indexvaluearray = [[NSArray alloc]initWithObjects:indexValue, nil];
    
    
    SFIDeviceIndex *deviceIndex = [[SFIDeviceIndex alloc]init];
    deviceIndex.cellId = 1;
    deviceIndex.indexID = 1;
    //    deviceIndex.valueType = SFIDevicePropertyType_SWITCH_BINARY;
    deviceIndex.indexValues = indexvaluearray;
    deviceIndex.isEditableIndex = YES;
    return deviceIndex;
}

-(SFIButtonSubProperties*) addSubPropertiesFordeviceID:(sfi_id)deviceID index:(int)index matchData:(NSString*)matchData andEventType:(NSString *)eventType deviceName:(NSString*)deviceName deviceType:(SFIDeviceType)deviceType{ //overLoaded
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.index = index;
    subProperties.matchData = matchData;
    subProperties.eventType = eventType;
    subProperties.deviceName = deviceName;
    subProperties.deviceType = deviceType;
    return subProperties;
}

- (void)toggleTriggerIndex:(int)buttonIndex superView:(UIView *)superView indexButton:(SwitchButton*)indexButton {
    for(UIView *childView in [superView subviews]){
        if([childView isKindOfClass:[DimmerButton class]]){
            continue;
        }else{
            SwitchButton *switchButton = (SwitchButton*)childView;
            if(buttonIndex == switchButton.subProperties.index){
                if (switchButton.tag == indexButton.tag)
                {
                    switchButton.selected = !switchButton.selected;
                }else{
                    switchButton.selected = NO;
                   
                }
            }
        }
    }
}

- (void)removeTriggerIndex:(int)buttonIndex buttonId:(sfi_id)buttonId {
    NSMutableArray *toBeDeletedSubProperties = [[NSMutableArray alloc] init];
    
    for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArrayTrigger){
        if((switchButtonProperty.deviceId == buttonId) && (switchButtonProperty.index == buttonIndex)){
            [toBeDeletedSubProperties addObject:switchButtonProperty];
        }
    }
    
    [self.selectedButtonsPropertiesArrayTrigger removeObjectsInArray:toBeDeletedSubProperties];
}

- (BOOL)setActionButtonCount:(RuleButton *)indexButton isSlider:(BOOL)isSlider matchData:(NSString *)buttonMatchdata buttonIndex:(int)buttonIndex buttonId:(sfi_id)buttonId {
    int buttonClickCount = 0;
    BOOL selected=NO;
    NSMutableArray *list=self.isTrigger?self.selectedButtonsPropertiesArrayTrigger:self.selectedButtonsPropertiesArrayAction;
    for(SFIButtonSubProperties *dimButtonProperty in list){
        if(dimButtonProperty.deviceId==indexButton.subProperties.deviceId && dimButtonProperty.index==indexButton.subProperties.index && [SFISubPropertyBuilder compareEntry:isSlider matchData:indexButton.subProperties.matchData eventType:indexButton.subProperties.eventType buttonProperties:dimButtonProperty]){
            buttonClickCount++;
            NSLog(@"INSIDE COMPARE ENTRY %d",buttonClickCount);
            selected=YES;
        }
        //        [SFISubPropertyBuilder compareEntry:iVal buttonProperties:indexButton.subProperties];
        //        if(dimButtonProperty.deviceId == buttonId && dimButtonProperty.index == buttonIndex && (isSlider ||(!isSlider && [dimButtonProperty.matchData isEqualToString:buttonMatchdata]))){
        //            buttonClickCount++;
        //            NSLog(@" button count %d",buttonClickCount);
        //        }
    }
    if(selected &&!self.isTrigger)
        [indexButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    return selected;
}

-(void)onSwitchButtonClick:(id)sender{
    if(isPresentHozPicker == YES){
        [picker removeFromSuperview];
    }
    
    SwitchButton * indexSwitchButton = (SwitchButton *)sender;
    
    sfi_id buttonId = indexSwitchButton.subProperties.deviceId;
    int buttonIndex = indexSwitchButton.subProperties.index;
    NSString *buttonMatchdata = indexSwitchButton.subProperties.matchData;
    if(!self.isTrigger){
        indexSwitchButton.selected = YES ;
        [self.selectedButtonsPropertiesArrayAction addObject:[indexSwitchButton.subProperties createNew]];
        [self.delegate updateTriggerAndActionDelegatePropertie:!self.isTrigger];
    }else{
        [self toggleTriggerIndex:buttonIndex superView:[sender superview] indexButton:indexSwitchButton];
        [self removeTriggerIndex:buttonIndex buttonId:buttonId];
        if (indexSwitchButton.selected)
            [self.selectedButtonsPropertiesArrayTrigger addObject:indexSwitchButton.subProperties];
        [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
    }
    [self setActionButtonCount:indexSwitchButton isSlider:NO matchData:buttonMatchdata buttonIndex:buttonIndex buttonId:buttonId];
    
}

-(void)showPicker:(DimmerButton* )dimmer{
    [self removePickerFromView];
    dimmer.pickerVisibility=YES;
    minValue=dimmer.minValue;
    maxValue=dimmer.maxValue;
    isPresentHozPicker=YES;
    pickerValuesArray2 = [NSMutableArray new];
    for (int i=(int)dimmer.minValue; i<=(int)dimmer.maxValue; i++) {
        [pickerValuesArray2 addObject:[NSString stringWithFormat:@"%d",i]];
    }
    isPresentHozPicker = YES;
    [self horizontalpicker:dimmer];
    
}
-(void)removePickerFromView{
    isPresentHozPicker=NO;
    [UIView animateWithDuration:2 animations:^{
        [picker removeFromSuperview];
    }];
}
-(void)removePicker:(DimmerButton* )dimmer{
    
    dimmer.pickerVisibility=NO;
    [self removePickerFromView];
    //Store Values
    if(newPickerValue.length==0)
        newPickerValue=@"0";
    [dimmer setNewValue:newPickerValue];

    SFIButtonSubProperties *newProperty=dimmer.subProperties;
    if(!self.isTrigger){
        newProperty=[dimmer.subProperties createNew];
        newProperty.matchData = newPickerValue;
    }else
        dimmer.subProperties.matchData = newPickerValue;
    
    [self addObject:newProperty];
    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
    [self setActionButtonCount:dimmer isSlider:YES matchData:newPickerValue buttonIndex:dimmer.subProperties.index buttonId:dimmer.subProperties.deviceId];
}
-(void)addObject:(SFIButtonSubProperties *)subProperty{
    if(self.isTrigger)
         [self.selectedButtonsPropertiesArrayTrigger addObject:subProperty];
    else
       [self.selectedButtonsPropertiesArrayAction addObject:subProperty];
}

-(void)onDimmerButtonClick:(id)sender{
    DimmerButton* dimmer = (DimmerButton *)sender;
    if(self.isTrigger){
        if(!dimmer.selected){
            [self showPicker:dimmer];
            dimmer.selected=YES;
        }else{
            if(dimmer.pickerVisibility)
                [self removePicker:dimmer];
            else{
                dimmer.selected=NO;
                [self removeTriggerIndex: dimmer.subProperties.index buttonId:dimmer.subProperties.deviceId];
                [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
            }
        }
    }else{
        dimmer.selected=YES;
        if(dimmer.pickerVisibility){
            [self removePicker:dimmer];
        }else
            [self showPicker:dimmer];
        
    }
}
#pragma mark horizontalpicker methods
- (void)horizontalpicker:(DimmerButton*)dimButton{
    isPresentHozPicker = YES;
    const int control_height = 30;
    // Picker
    picker = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    picker.tag = 1; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    picker.frame = CGRectMake(self.parentViewController.deviceIndexButtonScrollView.frame.origin.x + 10,  dimButton.frame.origin.y + dimButton.frame.size.height +25, self.parentViewController.view.frame.size.width -20 , control_height);
    picker.layer.cornerRadius = 4;
    picker.layer.borderWidth = 1.5;
    picker.backgroundColor = [UIColor whiteColor];
    
    if(self.isTrigger){
    picker.layer.borderColor = [SFIColors ruleBlueColor].CGColor;
    picker.selectedTextColor = [SFIColors ruleBlueColor];
    }
    else{
        picker.layer.borderColor = [SFIColors ruleOrangeColor].CGColor;
        picker.selectedTextColor = [SFIColors ruleOrangeColor];
    }
    picker.elementFont = [UIFont systemFontOfSize:11];
    picker.elementFont = [UIFont fontWithName:@"AvenirLTStd-Roman" size:11];
    picker.textColor = [UIColor blackColor];
    picker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    picker.delegate = self;
    picker.dataSource = self;
    //  [picker scrollToElement:dimButton.dimValue.intValue animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.parentViewController.deviceIndexButtonScrollView addSubview:picker];
    });
    // width depends on propertyType
    const NSInteger element_width = [self horizontalPickerView:picker widthForElementAtIndex:0];
    SFIPickerIndicatorView1 *indicatorView = [[SFIPickerIndicatorView1 alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    picker.selectionPoint = CGPointMake((picker.frame.size.width) / 2, 0);
    if(self.isTrigger){
    indicatorView.color1 = [SFIColors ruleBlueColor];
    }
    else{
    indicatorView.color1 = [SFIColors ruleOrangeColor];
    }
    picker.selectionIndicatorView = indicatorView;
    
    
}
#pragma mark - V8HorizontalPickerView methods

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    return 40;
}

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return pickerValuesArray2.count;
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    index = index + minValue;
    //return [NSString stringWithFormat:@"%ld\u00B0", (long) index];
    return @(index).stringValue;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    newPickerValue = pickerValuesArray2[index];
    isPresentHozPicker = YES;
}

-(BOOL)istoggle:(SFIDeviceType)devicetype{
    switch (devicetype) {
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelSwitch_2:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_ZigbeeDoorLock_28:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50:
        case SFIDeviceType_MultiSwitch_43:
        {
            return  YES;
        }
            break;
            
        default:
        {
            return NO;
        }
            break;
    }
    
}

#pragma mark delegate methods - hue
-(void)updateArray{
    //[self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArrayAction];
    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
}
#pragma mark delegate methods - TimeView
-(void)AddOrUpdateTime{
    NSLog(@"In AddOrUpdate");
    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
}
@end
