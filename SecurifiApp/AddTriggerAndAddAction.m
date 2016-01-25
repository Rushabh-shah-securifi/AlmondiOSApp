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

#import "RuleBuilder.h"

#import "RulesNestThermostat.h"
#import "RulesHue.h"
#import "V8HorizontalPickerView.h"
#import "V8HorizontalPickerViewProtocol.h"
#import "SFIPickerIndicatorView1.h"
#import "ValueFormatter.h"

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
NSString *newPickerValue;
int buttonClickCount;
NSMutableArray * pickerValuesArray2;

-(id)init{
    if(self == [super init]){
        NSLog(@"init method");
        isPresentHozPicker = NO;
        
        newPickerValue = [NSString new];
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
    }else
    [deviceButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentViewController.deviceListScrollView addSubview:deviceButton];

    NSLog(@" devicename button %@",deviceButton);
    NSLog(@" device name %@",deviceButton.deviceName);
    
    return xVal + textRect.size.width +15;
}
-(void)TimeEventClicked:(id)sender{
    NSLog(@"time trigger ");
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:sender];
    self.timeView = [[TimeView alloc]init];
    self.timeView.ruleTime = self.ruleTime;
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
   
    xVal = [self addDeviceName:@"Mode" deviceID:0 deviceType:SFIDeviceType_BinarySwitch_0 xVal:xVal];
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
    
}



-(void)wifiClientsClicked:(RulesDeviceNameButton*)deviceButton{
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:deviceButton];
    int i =0;
    NSLog(@"wifi clients array: %@", self.parentViewController.wifiClientsArray);
    for(SFIConnectedDevice *connectedClient in self.parentViewController.wifiClientsArray){
        if(connectedClient.deviceUseAsPresence){
            int yScale = ROW_PADDING + (ROW_PADDING+frameSize)*i;
            [self addClientNameLabel:connectedClient.name yScale:yScale];
            
            SensorIndexSupport *Index=[[SensorIndexSupport alloc]init];
            NSArray *deviceIndexes= [Index getIndexesFor:deviceButton.deviceType];
            
            SFIDeviceIndex *deviceIndex = deviceIndexes[0];
            deviceIndex.indexID = connectedClient.deviceID.intValue;
            for(IndexValueSupport *iVal in deviceIndex.indexValues){
                iVal.matchData = connectedClient.deviceMAC;
            }
            [self addMyButtonwithYScale:yScale withDeviceIndex:deviceIndexes deviceId:0 deviceType:SFIDeviceType_WIFIClient deviceName:connectedClient.name];
            i++;
        }
    }
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*i + ROW_PADDING);
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
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
    NSLog(@" on device name button clicked");
    [self resetViews];
    //toggeling
    [self toggleHighlightForDeviceNameButton:sender];
    
    SensorIndexSupport *Index=[[SensorIndexSupport alloc]init];
    NSMutableArray *deviceIndexes=[NSMutableArray arrayWithArray:[Index getIndexesFor:sender.deviceType]];//need
    
    if(self.isAction){
    if ([self istoggle:sender.deviceType]) {
        SFIDeviceIndex *temp = [self getToggelDeviceIndex];
        [deviceIndexes addObject : temp];
    }
    }
    [self createDeviceIndexesLayoutForDeviceId:sender.deviceId deviceType:sender.deviceType deviceName:sender.deviceName deviceIndexes:deviceIndexes];
}
-(void)resetViews{
    self.parentViewController.TimeSectionView.hidden = YES;
    self.parentViewController.deviceIndexButtonScrollView.hidden = NO;
    
    //clear view
    NSArray *viewsToRemove = [self.parentViewController.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}
-(void)toggleHighlightForDeviceNameButton:(RulesDeviceNameButton *)currentButton{
    UIScrollView *scrollView = self.parentViewController.deviceListScrollView;
    for(RulesDeviceNameButton *button in [scrollView subviews]){
        NSLog(@"toggle  toggleHighlightForDeviceNameButton %@",button);
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
    
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*numberOfCells + ROW_PADDING);
    
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
    
    if(deviceType == SFIDeviceType_NestThermostat_57){
        RulesNestThermostat *rulesNestThermostatObject = [[RulesNestThermostat alloc]init];
        SFIDeviceValue *nestThermostatDeviceValue;
        for(int i=0; i < [[self getTriggerAndActionDeviceList] count]; i++){
            SFIDevice *nestThermostatDevice = [self getTriggerAndActionDeviceList][i];
            if(nestThermostatDevice.deviceID == deviceId){
                nestThermostatDeviceValue = self.parentViewController.deviceValueArray[i];
                break;
            }
        }
        deviceIndexes = [rulesNestThermostatObject createNestThermostatDeviceIndexes:deviceIndexes deviceValue:nestThermostatDeviceValue];
        numberOfCells = [self maxCellId:deviceIndexes];//recalculating for nest
    }
    
    //dict - array of indexes for cellid
    NSMutableDictionary *deviceIndexesDict = [NSMutableDictionary new];
    for(SFIDeviceIndex *deviceIndex in deviceIndexes){
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
    
    //huelamp - 58
    if(deviceType == SFIDeviceType_HueLamp_48){
        self.ruleHueObject = [[RulesHue alloc] init];
        self.ruleHueObject.delegate = self;
        self.ruleHueObject.parentViewController = self.parentViewController;
        self.ruleHueObject.selectedButtonsPropertiesArray = self.selectedButtonsPropertiesArrayAction;
        
        
        [self.ruleHueObject createHueCellLayoutWithDeviceId:deviceId deviceType:deviceType deviceIndexes:deviceIndexes scrollView:self.parentViewController.deviceIndexButtonScrollView cellCount:numberOfCells indexesDictionary:deviceIndexesDict];
        return;
    }
    //else for rest of the devices
    for(int i = 0; i < numberOfCells; i++){
        [self addMyButtonwithYScale:ROW_PADDING+(ROW_PADDING+frameSize)*i withDeviceIndex:[deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d", i+1]] deviceId:deviceId deviceType:deviceType deviceName:deviceName];
        //        cellView.backgroundColor = [UIColor redColor];
    }

}
- (NSMutableDictionary *)setButtonSelection:(RuleButton *)ruleButton isSlider:(BOOL)isSlider deviceIndex:(SFIDeviceIndex *)deviceIndex deviceId:(int)deviceId matchData:(NSString *)matchData{
    NSMutableDictionary *result= [NSMutableDictionary new];
    
    int count = 0;
   // NSString *matchData=nil;
    UIColor * selectedColor= (self.isTrigger )? [SFIColors ruleBlueColor]: [SFIColors ruleOrangeColor];
    NSMutableArray *list=(self.isTrigger)?self.selectedButtonsPropertiesArrayTrigger:self.selectedButtonsPropertiesArrayAction;
    for(SFIButtonSubProperties *subProperty in list){ //to do - you can add count property to subproperties and iterate array in reverse
        if(subProperty.deviceId == deviceId && subProperty.index == deviceIndex.indexID && subProperty.matchData == matchData){
            matchData = subProperty.matchData;
            ruleButton.selected = YES;
            if(!self.isTrigger)
                count++;
            if(!isSlider)
                [ruleButton changeBGColor:selectedColor];
        }
    }
    
    [result setValue:matchData forKey:@"matchData"];
    [result setValue:@(count).stringValue forKey:@"count"];
    return result;
}

- (void)buildDimButton:(SFIDeviceIndex *)deviceIndex iVal:(IndexValueSupport *)iVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view {
    DimmerButton *dimbtn=[[DimmerButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y , dimFrameWidth, dimFrameHeight)];
    dimbtn.tag=i;
    
    dimbtn.valueType=deviceIndex.valueType;
    dimbtn.minValue = iVal.minValue;
    dimbtn.maxValue = iVal.maxValue;
    dimbtn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
    dimbtn.selected=NO;
    
    NSString * selectedColor= (self.isTrigger )? @"02a8f3": @"FF9500";
    [dimbtn changeStylewithColor:self.isTrigger];
    [dimbtn addTarget:self action:@selector(onDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableDictionary *result=[self setButtonSelection:dimbtn isSlider:YES deviceIndex:deviceIndex deviceId:deviceId matchData:dimbtn.subProperties.matchData];
    
    int buttonClickCount;
    if(self.isAction){
        buttonClickCount =[[result valueForKey:@"count"] integerValue];
    }
    NSString *matchData = [result valueForKey:@"matchData"];
    if(matchData==nil)
        matchData=iVal.matchData;
    
    //get previous value
    [dimbtn setupValues:matchData Title:iVal.displayText suffix:iVal.valueFormatter.suffix];
    
    dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                view.bounds.size.height/2);
    dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
    [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
    
    if(buttonClickCount > 0 && self
       .isAction){
        [dimbtn setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    }
    //dispatch_async(dispatch_get_main_queue(), ^{
    [view addSubview:dimbtn];
}

- (void)buildSwitchButton:(SFIDeviceIndex *)deviceIndex deviceType:(int)deviceType deviceName:(NSString *)deviceName iVal:(IndexValueSupport *)iVal deviceId:(int)deviceId i:(int)i view:(UIView *)view {
    SwitchButton *btnBinarySwitchOn = [[SwitchButton alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
    btnBinarySwitchOn.tag = i;
    btnBinarySwitchOn.valueType=deviceIndex.valueType;
    btnBinarySwitchOn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:iVal.eventType deviceName:deviceName deviceType:deviceType];
    
    btnBinarySwitchOn.deviceType = deviceType;
    
    [btnBinarySwitchOn addTarget:self action:@selector(onSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    [btnBinarySwitchOn setupValues:[UIImage imageNamed:iVal.iconName] topText:nil bottomText:iVal.displayText inUpperScroll:NO];

    //set perv. count and highlight
    
    NSMutableDictionary *result=[self setButtonSelection:btnBinarySwitchOn isSlider:NO deviceIndex:deviceIndex deviceId:deviceId matchData:btnBinarySwitchOn.subProperties.matchData];
    int buttonClickCount =[[result valueForKey:@"count"] integerValue];
    btnBinarySwitchOn.center = CGPointMake(view.bounds.size.width/2,
                                           view.bounds.size.height/2);
    btnBinarySwitchOn.frame = CGRectMake(btnBinarySwitchOn.frame.origin.x + ((i-1) * (frameSize/2))+textHeight/2 ,
                                         btnBinarySwitchOn.frame.origin.y,
                                         btnBinarySwitchOn.frame.size.width,
                                         btnBinarySwitchOn.frame.size.height);
    
    int btnWidth = frameSize;
    for (int j = 1; j < i; j++) {
        NSLog(@" [view subviews][j-1] %d",i);
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
    if(buttonClickCount > 0 && self.isAction){
        [btnBinarySwitchOn setButtoncounter:buttonClickCount isCountImageHiddn:NO];
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
        if(self.isTrigger)
            deviceIndex.isEditableIndex = YES;
        if(deviceIndex.isEditableIndex)
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
    NSLog(@"shiftButtonsByWidth");
    NSLog(@"subview count: %lu, i: %d", (unsigned long)[[view subviews] count], i);
    for (int j = 1; j < i; j++) {
        NSLog(@"j: %d", j);
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
    indexValue.displayText = @"Toggle";
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
                    [switchButton changeStylewithColor:self.isTrigger];
                }else{
                    switchButton.selected = NO;
                    [switchButton changeStylewithColor:self.isTrigger];
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

- (void)setActionButtonCount:(RuleButton *)indexButton isSlider:(BOOL)isSlider matchData:(NSString *)buttonMatchdata buttonIndex:(int)buttonIndex buttonId:(sfi_id)buttonId {
    int buttonClickCount = 0;
    for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArrayAction){ //to do - you can add count property to subproperties and iterate array in reverse
        if(dimButtonProperty.deviceId == buttonId && dimButtonProperty.index == buttonIndex && (isSlider ||(!isSlider && [dimButtonProperty.matchData isEqualToString:buttonMatchdata]))){
            buttonClickCount++;
        }
    }
    [indexButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
}

-(void)onSwitchButtonClick:(id)sender{
    
    NSLog(@"onButtonClick");
    if(isPresentHozPicker == YES){
        [picker removeFromSuperview];
    }
    
    SwitchButton * indexSwitchButton = (SwitchButton *)sender;
    
    sfi_id buttonId = indexSwitchButton.subProperties.deviceId;
    int buttonIndex = indexSwitchButton.subProperties.index;
    NSString *buttonMatchdata = indexSwitchButton.subProperties.matchData;
    [indexSwitchButton changeStylewithColor:self.isTrigger];
    if(!self.isTrigger){
        indexSwitchButton.selected = YES ;
        
        [self.selectedButtonsPropertiesArrayAction addObject:indexSwitchButton.subProperties];
        [self setActionButtonCount:indexSwitchButton isSlider:NO matchData:buttonMatchdata buttonIndex:buttonIndex buttonId:buttonId];
        [self.delegate updateTriggerAndActionDelegatePropertie:!self.isTrigger];
    }else{
        [self toggleTriggerIndex:buttonIndex superView:[sender superview] indexButton:indexSwitchButton];
        [self removeTriggerIndex:buttonIndex buttonId:buttonId];
        NSLog(@"triggers list after: %@", self.selectedButtonsPropertiesArrayTrigger);
        if (indexSwitchButton.selected)
            [self.selectedButtonsPropertiesArrayTrigger addObject:indexSwitchButton.subProperties];
        //[self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArrayTrigger];
        [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
    }
    
}
-(void)onDimmerButtonClick:(id)sender{
   DimmerButton* dimmer = (DimmerButton *)sender;
    if(self.isTrigger){
        dimmer.selected=!dimmer.selected;
        [dimmer changeStylewithColor:self.isTrigger];
    }
    
    
    sfi_id dimId = dimmer.subProperties.deviceId;
    int dimIndex = dimmer.subProperties.index;
    NSLog(@" dim value %ld ,max value %ld",(long)dimmer.minValue,(long)dimmer.maxValue);
    if(dimmer.selected){
        pickerValuesArray2 = [NSMutableArray new];
        for (int i=(int)dimmer.minValue; i<=(int)dimmer.maxValue; i++) {
            [pickerValuesArray2 addObject:[NSString stringWithFormat:@"%d",i]];
        }
        //[self setupPicker:dimmerButtonClick.dimValue];
        [self horizontalpicker:dimmer];
    }
    else{
        [dimmer setNewValue:dimmer.subProperties.matchData]; //set initial value
        NSLog(@" deselected ");
        if(self.isTrigger)
            [self removeTriggerIndex:dimIndex buttonId:dimId];
        if(isPresentHozPicker == YES){
            dimmer.selected = YES;
            [dimmer setNewValue:newPickerValue];
            dimmer.subProperties.matchData = newPickerValue;
            [dimmer changeStylewithColor:self.isTrigger];
            if(self.isTrigger){
                 [self.selectedButtonsPropertiesArrayTrigger addObject:dimmer.subProperties];
                [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArrayTrigger];
            }
            else{
                [self setActionButtonCount:dimmer isSlider:YES matchData:nil buttonIndex:dimIndex buttonId:dimId];
                [self.selectedButtonsPropertiesArrayTrigger addObject:[dimmer.subProperties createNew]];
                [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArrayAction];
            }
            isPresentHozPicker = NO;
            
        }
        [UIView animateWithDuration:2 animations:^{
            [picker removeFromSuperview];
        }];
    }
    
}
#pragma mark horizontalpicker methods
- (void)horizontalpicker:(DimmerButton*)dimButton{
    const int control_height = 30;
    NSLog(@"viedidload");
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
    return @(index).stringValue;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    NSLog(@"pickerview:");
    
    newPickerValue = pickerValuesArray2[index];
    
    isPresentHozPicker = YES;
    
}

-(BOOL)istoggle:(SFIDeviceType)devicetype{
    switch (devicetype) {
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelSwitch_2:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_StandardWarningDevice_21:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_ZigbeeDoorLock_28:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50:{
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
    [self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArrayAction];
}

@end
