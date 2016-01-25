//
//  AddActions.m
//  RulesUI
//
//  Created by Masood on 01/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "AddActions.h"
#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "Colours.h"
#import "SFIDeviceIndex.h"
//#import "SensorIndexSupport.h"
#import "RuleSensorIndexSupport.h"
#import "IndexValueSupport.h"
//#import "SFIDimmerButton.h"
#import "SFIRulesSwitchButton.h"
#import "ValueFormatter.h"
#import "RulesConstants.h"
#import "SFIButtonSubProperties.h"
#import "RulesDeviceNameButton.h"
#import "RuleBuilder.h"
#import "SFIDimmerButtonAction.h"
#import "SFIRulesActionButton.h"
#import "RulesNestThermostat.h"
#import "RulesHue.h"
#import "V8HorizontalPickerView.h"
#import "V8HorizontalPickerViewProtocol.h"
#import "SFIPickerIndicatorView1.h"//from UI Its for picker indicator view

@interface AddActions()<RulesHueDelegate,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource,RuleViewDelegate>
@property (nonatomic, strong)RulesHue *rulesHueObject;

@end

@implementation AddActions

SFIDimmerButtonAction *actionIndexDimButton;
SFIRulesActionButton *indexSwitchButton;
SFIRulesActionButton *switchButtonClick;
V8HorizontalPickerView *pickerAction;
int buttonClickCount;
bool isPresentActHozPicker;
NSString *newPickerValue;
NSMutableArray * pickerValuesArray2;

-(id)init{
    if(self == [super init]){
        NSLog(@"init method");
        self.deviceDict = [NSMutableDictionary new]; //perhaps to be deleted
        isPresentActHozPicker = NO;
        newPickerValue = [NSString new];
        self.selectedButtonsPropertiesArray = [NSMutableArray new];
    }
    return self;
}



-(void)createDeviceListButton:(RulesDeviceNameButton*)deviceButton title:(NSString*)title{
    [deviceButton setTitle:title forState:UIControlStateNormal];
    deviceButton.titleLabel.numberOfLines = 1;
    deviceButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:3];
    //    deviceButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [deviceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deviceButton setTitleShadowColor:[UIColor blueColor] forState:UIControlStateNormal];
    deviceButton.titleLabel.font = [UIFont systemFontOfSize:12];
    deviceButton.backgroundColor = [UIColor clearColor];
    deviceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}


-(int)createModeButtonWithWidth:(double)deviceButtonWidth andHeight:(double)deviceButtonHeight xVal:(int)xVal{
    NSString *title = @"Mode";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    CGRect textRect;
    textRect.size = [title sizeWithAttributes:attributes];
    
    RulesDeviceNameButton *modeButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];
    
    [self createDeviceListButton:modeButton title:@"Mode"];
    modeButton.deviceId = 0;
    modeButton.deviceType = SFIDeviceType_BinarySwitch_0;
    
    [modeButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentViewController.deviceListScrollView addSubview:modeButton];
    xVal += textRect.size.width + 15;
    return xVal;
}

-(void)displayActionDeviceList{
    NSLog(@"displayActionDeviceList");
    //clear view
    NSArray *viewsToRemove = [self.parentViewController.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    NSLog(@"display actions");
    int xVal = 0;
    double deviceButtonWidth = (self.parentViewController.view.frame.size.width)/3;
    double deviceButtonHeight = self.parentViewController.deviceListScrollView.frame.size.height;
    
    //mode button
    xVal = [self createModeButtonWithWidth:deviceButtonWidth andHeight:deviceButtonHeight xVal:xVal];
    
    for(SFIDevice *device in self.parentViewController.actuatorDeviceArray){
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGRect textRect;
        textRect.size = [device.deviceName sizeWithAttributes:attributes];
        if(device.deviceName.length > 18){
            NSString *temp=@"123456789012345678";
            textRect.size = [temp sizeWithAttributes:attributes];
        }
        RulesDeviceNameButton *deviceButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];

        [deviceButton setTitle:device.deviceName forState:UIControlStateNormal];
        deviceButton.titleLabel.numberOfLines = 1;
//        deviceButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        deviceButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:12];
        [deviceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        deviceButton.backgroundColor = [UIColor clearColor];
        deviceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        deviceButton.deviceId = device.deviceID;
        deviceButton.deviceType = device.deviceType;

        [deviceButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.parentViewController.deviceListScrollView addSubview:deviceButton];
        xVal += textRect.size.width + 15;
    }
    self.parentViewController.deviceListScrollView.contentSize = CGSizeMake(xVal + 10,self.parentViewController.deviceListScrollView.contentSize.height);
}

#pragma mark click handlers
-(void)onDeviceButtonClick:(RulesDeviceNameButton *)sender{
    //clear view
    NSArray *viewsToRemove = [self.parentViewController.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    //toggeling
    UIScrollView *scrollView = self.parentViewController.deviceListScrollView;
    for(RulesDeviceNameButton *button in [scrollView subviews]){
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [sender setTitleColor:[UIColor colorFromHexString:@"FF9500"] forState:UIControlStateNormal];
    [sender setTitleShadowColor:[UIColor colorFromHexString:@"FF9500"] forState:UIControlStateNormal];
    
    RuleSensorIndexSupport *Index=[[RuleSensorIndexSupport alloc]init];
    NSMutableArray *deviceIndexes=[NSMutableArray arrayWithArray:[Index getIndexesFor:sender.deviceType]];//need
    if ([self istoggle:sender.deviceType]) {
        SFIDeviceIndex *temp = [self getToggelDeviceIndex];
        [deviceIndexes addObject : temp];
    }
    [self createDeviceIndexesLayoutForDeviceId:sender.deviceId deviceType:sender.deviceType deviceIndexes:deviceIndexes];
}

-(void) createDeviceIndexesLayoutForDeviceId:(int)deviceId deviceType:(SFIDeviceType)deviceType deviceIndexes:(NSArray*)deviceIndexes{
    int numberOfCells = [self maxCellId:deviceIndexes];
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*numberOfCells + ROW_PADDING);
    
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
    
    //nest_thermostat - 57
    if(deviceType == SFIDeviceType_NestThermostat_57){
        RulesNestThermostat *rulesNestThermostatObject = [[RulesNestThermostat alloc]init];
        SFIDeviceValue *nestThermostatDeviceValue;
        for(int i=0; i < [self.parentViewController.deviceArray count]; i++){
            SFIDevice *nestThermostatDevice = self.parentViewController.deviceArray[i];
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
        self.rulesHueObject = [[RulesHue alloc] init];
        self.rulesHueObject.delegate = self;
        self.rulesHueObject.parentViewController = self.parentViewController;
        self.rulesHueObject.selectedButtonsPropertiesArray = self.selectedButtonsPropertiesArray;
        
        [self.rulesHueObject createHueCellLayoutWithDeviceId:deviceId deviceType:deviceType deviceIndexes:deviceIndexes scrollView:self.parentViewController.deviceIndexButtonScrollView cellCount:numberOfCells indexesDictionary:deviceIndexesDict];
        return;
    }
    
    //else for rest of the devices
    for(int i = 0; i < numberOfCells; i++){
        [self addMyButtonwithYScale:ROW_PADDING+(ROW_PADDING+frameSize)*i withDeviceIndex:[deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d", i+1]] deviceId:deviceId deviceType:deviceType];
    }
}


- (UIView *)addMyButtonwithYScale:(int)yScale withDeviceIndex:(NSArray *)deviceIndexes deviceId:(int)deviceId deviceType:(int)deviceType{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            self.parentViewController.view.frame.size.width,
                                                            frameSize)];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:view];
    //view.backgroundColor = [UIColor yellowColor];
    int i=0;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        NSMutableArray *btnary=[[NSMutableArray alloc]init];
        int indexValCounter = 0;
        if(deviceIndex.isEditableIndex)
        {
            for (IndexValueSupport *iVal in deviceIndex.indexValues) {
                i++;
                indexValCounter++;
                
                if ([iVal.layoutType isEqualToString:@"dimButton"]){
                    SFIDimmerButtonAction *dimbtn=[[SFIDimmerButtonAction alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y , dimFrameWidth, dimFrameHeight)];
                    dimbtn.tag=indexValCounter;
                    
                    dimbtn.valueType=deviceIndex.valueType;
                    dimbtn.minValue = iVal.minValue;
                    dimbtn.maxValue = iVal.maxValue;
                    dimbtn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData];
                    dimbtn.selected=NO;
                    [dimbtn addTarget:self action:@selector(onDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    
                    //get previous value
                    NSString *matchData = iVal.matchData;
                    BOOL isSelected = NO;
                    int buttonClickCount = 0;
                    for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
                        if(dimButtonProperty.deviceId == deviceId && dimButtonProperty.index == deviceIndex.indexID){
                            matchData = dimButtonProperty.matchData;
                            NSLog(@"dim match data: %@", matchData);
                            isSelected = YES;
                            buttonClickCount++;
                        }
                    }
                    [dimbtn setupValues:matchData Title:iVal.displayText suffix:iVal.valueFormatter.suffix];
                    dimbtn.selected = isSelected;
                    
                    dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                                view.bounds.size.height/2);
                    dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
                    [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
                    
                    if(buttonClickCount > 0){
                        [dimbtn setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                    }
                    [btnary addObject:dimbtn];
                    [view addSubview:dimbtn];
                }
                
                else{
                    SFIRulesActionButton *btnBinarySwitchOn = [[SFIRulesActionButton alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
                    btnBinarySwitchOn.tag = indexValCounter;
                    btnBinarySwitchOn.valueType=deviceIndex.valueType;
                    btnBinarySwitchOn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData];
                    
                    [btnBinarySwitchOn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBinarySwitchOn setupValues:[UIImage imageNamed:iVal.iconName] Title:iVal.displayText];
                    //set perv. count and highlight
                    int buttonClickCount = 0;
                    for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
                        if(switchButtonProperty.deviceId == deviceId && switchButtonProperty.index == deviceIndex.indexID && [switchButtonProperty.matchData isEqualToString:iVal.matchData]){
                            btnBinarySwitchOn.selected = YES;
                            buttonClickCount++;
                        }
                    }
                    
                    
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
                        if([childView isKindOfClass:[SFIDimmerButtonAction class]]){
                            if(i==2){
                                btnWidth = dimFrameWidth;
                            }
                            if(i==3){
                                btnWidth = 0;
                                btnBinarySwitchOn.frame = CGRectMake(btnBinarySwitchOn.frame.origin.x + frameSize/2 ,
                                                                     btnBinarySwitchOn.frame.origin.y,
                                                                     btnBinarySwitchOn.frame.size.width,
                                                                     btnBinarySwitchOn.frame.size.height);
                            }
                            if(i == 4){
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
                    if(buttonClickCount > 0){
                        [btnBinarySwitchOn setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                    }
                    [btnary addObject:btnBinarySwitchOn];
                    [view addSubview:btnBinarySwitchOn];
                    
                } //outer else
            } //inner for loop, indexvalues
        }
        //if condition
    }//outer for loop deviceindexes
    return view;
}

#pragma mark onbuttonClick methods

-(void) addButtonToArray:(sfi_id)buttonId index:(int)buttonIndex matchData:(NSString*)buttonMatchData{
    
    SFIButtonSubProperties *highlightedButtonProperties = [self addSubPropertiesFordeviceID:buttonId index:buttonIndex matchData:buttonMatchData];
    [self.selectedButtonsPropertiesArray addObject:highlightedButtonProperties];
}

-(void) deleteButtonFromArray:(sfi_id)buttonId index:(int)buttonIndex matchData:(NSString*)buttonMatchData{
    SFIButtonSubProperties *toBeDeletedProperty;
    for(SFIButtonSubProperties *buttonProperties in self.selectedButtonsPropertiesArray){
        if(buttonProperties.deviceId == buttonId && buttonProperties.index == buttonIndex && [buttonProperties.matchData isEqualToString:buttonMatchData]){
            toBeDeletedProperty = buttonProperties;
        }
    }
    [self.selectedButtonsPropertiesArray removeObject:toBeDeletedProperty];
    
}
//mode
#pragma mark mode method
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
        button.selected = NO;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    currentButton.selected = YES;
    [currentButton setTitleColor:[UIColor colorFromHexString:@"757575"] forState:UIControlStateNormal];
    [currentButton setTitleShadowColor:[UIColor colorFromHexString:@"757575"] forState:UIControlStateNormal];
}


/*checkpoint*/

- (void)onButtonClick:(id)sender{
    NSLog(@"onButtonClick");
    if(isPresentActHozPicker == YES){
        [pickerAction removeFromSuperview];
    }
    
    indexSwitchButton = (SFIRulesActionButton *)sender;
    indexSwitchButton.selected = YES ;
   
    sfi_id buttonId = indexSwitchButton.subProperties.deviceId;
    int buttonIndex = indexSwitchButton.subProperties.index;
    NSString *buttonMatchdata = indexSwitchButton.subProperties.matchData;

    //Add button properties to array
    [self addButtonToArray:buttonId index:buttonIndex matchData:buttonMatchdata];
    
    int buttonClickCount = 0;
    for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
        if(dimButtonProperty.deviceId == buttonId && dimButtonProperty.index == buttonIndex && [dimButtonProperty.matchData isEqualToString:buttonMatchdata]){
            buttonClickCount++;
        }
    }
    [indexSwitchButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    
    // delegate
    [self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
}

-(void)onDimmerButtonClick:(id)sender{
    actionIndexDimButton = (SFIDimmerButtonAction *)sender;
    
    if(isPresentActHozPicker == NO){
        pickerValuesArray2 = [NSMutableArray new];
        for (int i=(int)actionIndexDimButton.minValue; i<=(int)actionIndexDimButton.maxValue; i++) {
            [pickerValuesArray2 addObject:[NSString stringWithFormat:@"%d",i]];
    //    [self setupPicker:actionIndexDimButton];
        }
        NSLog(@" pickerview add");
        [self horizontalpicker:actionIndexDimButton ];
    }
    else{
        actionIndexDimButton.selected = YES;
        [UIView animateWithDuration:0.3 animations:^{
            [pickerAction removeFromSuperview];
        }];
        
        [actionIndexDimButton setNewValue:newPickerValue];
        NSLog(@"dimmer button click: %d", actionIndexDimButton.selected);
        
        sfi_id buttonId = actionIndexDimButton.subProperties.deviceId;
        int buttonIndex = actionIndexDimButton.subProperties.index;
        
        //add button to array
        actionIndexDimButton.subProperties.matchData = actionIndexDimButton.dimValue;
        [self.selectedButtonsPropertiesArray addObject:indexSwitchButton.subProperties];
        
        
        buttonClickCount = 0;
        for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
            if(dimButtonProperty.deviceId == buttonId && dimButtonProperty.index == buttonIndex){
                buttonClickCount++;
            }
        }
        
        [actionIndexDimButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
        //delegate
        [self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
        isPresentActHozPicker = NO;
    }
}

- (void)horizontalpicker:(SFIDimmerButtonAction*)dimButton{
    const int control_height = 30;
    NSLog(@"viedidload");
    // Picker
    pickerAction = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    pickerAction.tag = 1; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    pickerAction.frame = CGRectMake(self.parentViewController.deviceIndexButtonScrollView.frame.origin.x + 10,  dimButton.frame.origin.y + dimButton.frame.size.height +25, self.parentViewController.view.frame.size.width -20 , control_height);
    pickerAction.layer.cornerRadius = 4;
    pickerAction.layer.borderWidth = 1.5;
    pickerAction.layer.borderColor = [UIColor colorFromHexString:@"FF9500"].CGColor;
    pickerAction.backgroundColor = [UIColor whiteColor];
    pickerAction.selectedTextColor = [UIColor colorFromHexString:@"FF9500"];
    pickerAction.elementFont = [UIFont systemFontOfSize:11];
    pickerAction.elementFont = [UIFont fontWithName:@"AvenirLTStd-Roman" size:11];
    pickerAction.textColor = [UIColor blackColor];
    pickerAction.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    pickerAction.delegate = self;
    pickerAction.dataSource = self;
    //  [picker scrollToElement:dimButton.dimValue.intValue animated:YES];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:pickerAction];
    // width depends on propertyType
    const NSInteger element_width = [self horizontalPickerView:pickerAction widthForElementAtIndex:0];
    SFIPickerIndicatorView1 *indicatorView = [[SFIPickerIndicatorView1 alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    pickerAction.selectionPoint = CGPointMake((pickerAction.frame.size.width) / 2, 0);
    indicatorView.color1 = [UIColor colorFromHexString:@"FF9500"];
    pickerAction.selectionIndicatorView = indicatorView;
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
    
    isPresentActHozPicker = YES;
    
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

-(SFIButtonSubProperties*) addSubPropertiesFordeviceID:(sfi_id)deviceID index:(int)index matchData:(NSString*)matchData{
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.index = index;
    subProperties.matchData = matchData;
    
    return subProperties;
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

//to display toggle icon
-(BOOL)istoggle:(SFIDeviceType)deviceType{
    switch (deviceType) {
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
    [self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
}
@end
