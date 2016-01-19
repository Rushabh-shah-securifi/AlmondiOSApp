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
#import "RuleSensorIndexSupport.h"
#import "Colours.h"
#import "RulesConstants.h"
#import "SFIDeviceIndex.h"
#import "RulesNestThermostat.h"
#import "RulesHue.h"
#import "IndexValueSupport.h"
#import "SFIButtonSubProperties.h"
#import "RulesDeviceNameButton.h"
#import "RulesView.h"
#import "SFIDimmerButtonAction.h"
#import "SFIRulesActionButton.h"
#import "RulesNestThermostat.h"
#import "RulesHue.h"
#import "V8HorizontalPickerView.h"
#import "V8HorizontalPickerViewProtocol.h"
#import "SFIPickerIndicatorView1.h"


@interface AddTriggerAndAddAction ()<RulesHueDelegate,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource>
@property (nonatomic)RulesHue *ruleHueObject;


@end

@implementation AddTriggerAndAddAction

SFIDimmerButtonAction *actionIndexDimButton;
SFIRulesActionButton *actionIndexSwitchButton;
V8HorizontalPickerView *picker;
SFIDimmerButtonAction *triggerDimmerButtonClick;
SFIRulesActionButton *triggerIndexSwitchButton;//
NSMutableArray *selectedDays;
NSMutableArray *selectedDayTags;
//SFIRul *switchButtonClick;
bool isPresentHozPicker;
NSString *newPickerValue;
int buttonClickCount;
NSMutableArray * pickerValuesArray2;
NSArray *dayArray;
NSMutableString *selectedDayString;
-(id)init{
    if(self == [super init]){
        NSLog(@"init method");
//        self.deviceDict = [NSMutableDictionary new]; //perhaps to be deleted
        isPresentHozPicker = NO;
        newPickerValue = [NSString new];
        self.selectedButtonsPropertiesArray = [NSMutableArray new];
        isPresentHozPicker = NO;
        selectedDayString = [NSMutableString new];
        newPickerValue = [NSString new];
        self.selectedButtonsPropertiesArray = [NSMutableArray new];
        dayArray = [[NSArray alloc]initWithObjects:@"Su",@"Mo",@"Tu",@"We",@"Th",@"Fr",@"Sa", nil];
        selectedDayTags = [NSMutableArray new];
        selectedDays = [NSMutableArray new];

    }
    return self;
}
-(void)displayTriggerActionDeviceName:(NSArray *)deviceListArray{
    NSLog(@"displayTriggerDeviceList");
    //clear view
    NSArray *viewsToRemove = [self.parentViewController.deviceListScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    int xVal = 15;
    double deviceButtonHeight = self.parentViewController.deviceListScrollView.frame.size.height;
    
    //timebutton
    
    if(self.isTrigger){//if Trigger Add time
        xVal = [self createTimerButtonWithHeight:deviceButtonHeight xVal:xVal];
        //same way we can we can do for client in trigger
    }
    //for rest of the devices
    for(SFIDevice *device in deviceListArray){
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGRect textRect;
        
        textRect.size = [device.deviceName sizeWithAttributes:attributes];
        if(device.deviceName.length > 18){
            NSString *temp=@"123456789012345678";
            textRect.size = [temp sizeWithAttributes:attributes];
        }
        
        RulesDeviceNameButton *deviceButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];
        
        [self createDeviceListButton:deviceButton title:device.deviceName];
        deviceButton.device = device;
        
        [deviceButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];//color diff for trigger and action...
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController.deviceListScrollView addSubview:deviceButton];
        });
        
        
        xVal += textRect.size.width +15;
    }
    self.parentViewController.deviceListScrollView.contentSize = CGSizeMake(xVal +10,self.parentViewController.deviceListScrollView.contentSize.height);
    
}
-(int) createTimerButtonWithHeight:(double)deviceButtonHeight xVal:(int)xVal{
    NSString *title = @"Time";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGRect textRect;
    textRect.size = [title sizeWithAttributes:attributes];
    
    RulesDeviceNameButton *timeButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];
    
    [self createDeviceListButton:timeButton title:@"Time"];
    [timeButton addTarget:self action:@selector(TimeEventClicked:) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parentViewController.deviceListScrollView addSubview:timeButton];
    });
    
    xVal += textRect.size.width + 15;
    return xVal;
}

-(void)createDeviceListButton:(RulesDeviceNameButton*)deviceButton title:(NSString*)title{
    
    
    [deviceButton setTitle:title forState:UIControlStateNormal];
    deviceButton.titleLabel.numberOfLines = 1;
    deviceButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:12];
    //    deviceButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [deviceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deviceButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    deviceButton.backgroundColor = [UIColor clearColor];
    deviceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}
-(void)onDeviceButtonClick:(RulesDeviceNameButton *)sender{
    NSLog(@"onDeviceButtonClick: %@",sender.device);
    [self resetViews];
    //toggeling
    [self toggleHighlightForDeviceNameButton:sender];
    
    RuleSensorIndexSupport *Index=[[RuleSensorIndexSupport alloc]init];
    NSArray *deviceIndexes=[Index getIndexesFor:sender.device.deviceType];//need device type
    [self createDeviceIndexesLayout:sender.device deviceIndexes:deviceIndexes];
    
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
        //[button setSelected:NO];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    currentButton.selected = YES;
    if(self.isTrigger){
        [currentButton setTitleColor:[UIColor colorFromHexString:@"02a8f3"] forState:UIControlStateNormal];
        [currentButton setTitleShadowColor:[UIColor colorFromHexString:@"02a8f3"] forState:UIControlStateNormal];//for trigger blue color
    }
    else{
        [currentButton setTitleColor:[UIColor colorFromHexString:@"FF9500"] forState:UIControlStateNormal];//for action orange color
        [currentButton setTitleShadowColor:[UIColor colorFromHexString:@"FF9500"] forState:UIControlStateNormal];
    }
}
-(void) createDeviceIndexesLayout:(SFIDevice*)device deviceIndexes:(NSArray*)deviceIndexes{
    int numberOfCells = [self maxCellId:deviceIndexes];
    
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*numberOfCells + ROW_PADDING);
    
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
    if(device.deviceType == SFIDeviceType_NestThermostat_57){
        RulesNestThermostat *rulesNestThermostatObject = [[RulesNestThermostat alloc]init];
        SFIDeviceValue *nestThermostatDeviceValue;
        for(int i=0; i < [self.parentViewController.deviceArray count]; i++){
            SFIDevice *nestThermostatDevice = self.parentViewController.deviceArray[i];
            if(nestThermostatDevice.deviceID == device.deviceID){
                nestThermostatDeviceValue = self.parentViewController.deviceValueArray[i];
                break;
            }
        }
        deviceIndexes = [rulesNestThermostatObject createNestThermostatDeviceIndexes:deviceIndexes device:device deviceValue:nestThermostatDeviceValue];
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
    if(device.deviceType == SFIDeviceType_HueLamp_48){
        self.ruleHueObject = [[RulesHue alloc] init];
        self.ruleHueObject.delegate = self;
        self.ruleHueObject.parentViewController = self.parentViewController;
        self.ruleHueObject.selectedButtonsPropertiesArray = self.selectedButtonsPropertiesArray;
        
        [self.ruleHueObject createHueCellLayout:device deviceIndexes:deviceIndexes scrollView:self.parentViewController.deviceIndexButtonScrollView cellCount:numberOfCells indexesDictionary:deviceIndexesDict];
        return;
    }
    //else for rest of the devices
    for(int i = 0; i < numberOfCells; i++){
        UIView *cellView = [self addMyActionButtonwithYScale:ROW_PADDING+(ROW_PADDING+frameSize)*i  withDeviceIndex:[deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d", i+1]] device:device];
        //        cellView.backgroundColor = [UIColor redColor];
        NSLog(@"cell view children: %@", cellView.subviews);
    }

}
- (UIView *)addMyActionButtonwithYScale:(int)yScale withDeviceIndex:(NSArray *)deviceIndexes device:(SFIDevice*)device{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            self.parentViewController.view.frame.size.width,
                                                            frameSize)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parentViewController.deviceIndexButtonScrollView addSubview:view];
    });
    
    //view.backgroundColor = [UIColor yellowColor];
    int i=0;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        int indexValCounter = 0;
        if(self.isTrigger){
            deviceIndex.isEditableIndex = YES;
        }
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
                    dimbtn.subProperties = [self addSubPropertiesFordeviceID:device.deviceID index:deviceIndex.indexID matchData:iVal.matchData];
                    dimbtn.selected=NO;
                    
                    if(self.isTrigger){
                        [dimbtn changeStylewithColor:[UIColor colorFromHexString:@"02a8f3"]];
                        [dimbtn addTarget:self action:@selector(onTriggerDimmerIndexButton:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else{
                        [dimbtn changeStylewithColor:[UIColor colorFromHexString:@"FF9500"]];
                        [dimbtn addTarget:self action:@selector(onActionDimmerIndexButton:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    //get previous value
                    NSString *matchData = iVal.matchData;
                    BOOL isSelected = NO;
                    int buttonClickCount = 0;
                    for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
                        if(dimButtonProperty.deviceId == device.deviceID && dimButtonProperty.index == deviceIndex.indexID){
                            matchData = dimButtonProperty.matchData;
                            NSLog(@"dim match data: %@", matchData);
                            isSelected = YES;
                            buttonClickCount++;
                        }
                    }
                    ////[dimbtn setupValues:matchData Title:iVal.displayText suffix:iVal.valueFormatter.suffix];
                    dimbtn.selected = isSelected;
                    if(self.isTrigger){
                        [dimbtn changeStylewithColor:[UIColor colorFromHexString:@"02a8f3"]];
                    }
                    else{
                        [dimbtn changeStylewithColor:[UIColor colorFromHexString:@"FF9500"]];
                    }
                    
                    
                    dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                                view.bounds.size.height/2);
                    dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
                    [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
                    
                    if(buttonClickCount > 0){
                        [dimbtn setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [view addSubview:dimbtn];
                    });
                    
                }
                
                else{
                    SFIRulesActionButton *btnBinarySwitchOn = [[SFIRulesActionButton alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
                    btnBinarySwitchOn.tag = indexValCounter;
                    btnBinarySwitchOn.valueType=deviceIndex.valueType;
                    btnBinarySwitchOn.subProperties = [self addSubPropertiesFordeviceID:device.deviceID index:deviceIndex.indexID matchData:iVal.matchData];
                    
                    if(self.isTrigger){
                    [btnBinarySwitchOn addTarget:self action:@selector(onTriggerIndexButton:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else{
                        [btnBinarySwitchOn addTarget:self action:@selector(onActionIndexButton:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    
                    [btnBinarySwitchOn setupValues:[UIImage imageNamed:iVal.iconName] Title:iVal.displayText];
                    //set perv. count and highlight
                    int buttonClickCount = 0;
                    for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
                        if(switchButtonProperty.deviceId == device.deviceID && switchButtonProperty.index == deviceIndex.indexID && [switchButtonProperty.matchData isEqualToString:iVal.matchData]){
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

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [view addSubview:btnBinarySwitchOn];
                    });
                    
                    
                } //outer else
            } //inner for loop, indexvalues
        }
        //if condition
    }//outer for loop deviceindexes
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

-(SFIButtonSubProperties*) addSubPropertiesFordeviceID:(sfi_id)deviceID index:(int)index matchData:(NSString*)matchData{
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.index = index;
    subProperties.matchData = matchData;
    
    return subProperties;
}
-(void)onTriggerIndexButton:(id)sender{
    NSLog(@"onButtonClick");
    if(isPresentHozPicker == YES){
        [picker removeFromSuperview];
    }
    triggerIndexSwitchButton = (SFIRulesActionButton *)sender;
    UIView *superView = [sender superview];
    
    if(triggerIndexSwitchButton.device.deviceType == SFIDeviceType_MultiLevelSwitch_2){
        [self devicetype2:triggerIndexSwitchButton];
        return;
    }
    
    
    sfi_id buttonId = triggerIndexSwitchButton.subProperties.deviceId;
    int buttonIndex = triggerIndexSwitchButton.subProperties.index;
    NSString *buttonMatchdata = triggerIndexSwitchButton.subProperties.matchData;
    
    
    for(UIView *childView in [superView subviews]){
        if([childView isKindOfClass:[SFIDimmerButtonAction class]]){
            continue;
        }else{
            SFIRulesActionButton *switchButton = (SFIRulesActionButton*)childView;
            if(buttonIndex == switchButton.subProperties.index){
                if (switchButton.tag == triggerIndexSwitchButton.tag)
                {
                    switchButton.selected = !switchButton.selected;
                    [switchButton changeStylewithColor:[UIColor colorFromHexString:@"02a8f3"]];
                }else{
                    switchButton.selected = NO;
                    [switchButton changeStylewithColor:[UIColor colorFromHexString:@"757575"]];
                }
            }
        }
    }
    
    //store seleted button in dictionary
    if (triggerIndexSwitchButton.selected) {
        //remove previous
        NSMutableArray *toBeDeletedSubProperties = [[NSMutableArray alloc] init];
        for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
            if((switchButtonProperty.deviceId == buttonId) && (switchButtonProperty.index == buttonIndex)){
                [toBeDeletedSubProperties addObject:switchButtonProperty];
            }
            //break;
        }
        [self.selectedButtonsPropertiesArray removeObjectsInArray:toBeDeletedSubProperties];
        //add current
        [self addButtonToArray:buttonId index:buttonIndex matchData:buttonMatchdata];
    }
    
    //remove button on deselection
    else if (triggerIndexSwitchButton.selected == NO){//rs
        SFIButtonSubProperties *toBeDeletedProperty;
        for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
            if(switchButtonProperty.deviceId == buttonId && switchButtonProperty.index == buttonIndex && [switchButtonProperty.matchData isEqualToString:buttonMatchdata]){
                toBeDeletedProperty = switchButtonProperty;
            }
            //break;
        }
        [self.selectedButtonsPropertiesArray removeObject:toBeDeletedProperty];
    }
    
    
    
    
    //     delegate triggersIndexDict dict
    [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
    
    //outer else

}
-(void)onTriggerDimmerIndexButton:(id)sender{
    triggerDimmerButtonClick = (SFIDimmerButtonAction *)sender;
   
    triggerDimmerButtonClick.selected=!triggerDimmerButtonClick.selected;
    [triggerDimmerButtonClick changeStylewithColor:[UIColor colorFromHexString:@"02a8f3"]];
    
        if(triggerDimmerButtonClick.device.deviceType == SFIDeviceType_MultiLevelSwitch_2){
            [self devicetype2:triggerDimmerButtonClick];// for device type 2
        }
    else{
        
        sfi_id dimId = triggerDimmerButtonClick.subProperties.deviceId;
        int dimIndex = triggerDimmerButtonClick.subProperties.index;
        NSLog(@" dim value %ld ,max value %ld",(long)triggerDimmerButtonClick.minValue,(long)triggerDimmerButtonClick.maxValue);
        if(triggerDimmerButtonClick.selected){
            pickerValuesArray2 = [NSMutableArray new];
            for (int i=(int)triggerDimmerButtonClick.minValue; i<=(int)triggerDimmerButtonClick.maxValue; i++) {
                [pickerValuesArray2 addObject:[NSString stringWithFormat:@"%d",i]];
            }
            //[self setupPicker:dimmerButtonClick.dimValue];
            [self horizontalpicker:triggerDimmerButtonClick];
        }
        else{
            [triggerDimmerButtonClick setNewValue:triggerDimmerButtonClick.subProperties.matchData]; //set initial value
            NSLog(@" deselected ");
            //delete property
            SFIButtonSubProperties *toBeDeletedProperty;
            for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){
                if(dimButtonProperty.deviceId == dimId && dimButtonProperty.index == dimIndex){
                    toBeDeletedProperty = dimButtonProperty;
                    NSLog(@"if- deselected dimindex %d",dimIndex);
                }
                //break;
            }
            [self.selectedButtonsPropertiesArray removeObject:toBeDeletedProperty];
            
            if(isPresentHozPicker == YES){
                [UIView animateWithDuration:2 animations:^{
                    [picker removeFromSuperview];
                }];
                triggerDimmerButtonClick.selected = YES;
                [triggerDimmerButtonClick changeStylewithColor:[UIColor colorFromHexString:@"02a8f3"]];
                //store in array
                sfi_id dimId = triggerDimmerButtonClick.subProperties.deviceId;
                int dimIndex = triggerDimmerButtonClick.subProperties.index;
                [triggerDimmerButtonClick setNewValue:newPickerValue];
                [self addButtonToArray:dimId index:dimIndex matchData:newPickerValue];
                
                //delegate triggers dict
                [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
                isPresentHozPicker = NO;
                
                
            }
            else if (isPresentHozPicker == NO){
                [UIView animateWithDuration:2 animations:^{
                    [picker removeFromSuperview];
                }];
                
            }
            
        }
        
        //delegate triggers dict
        [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
    }//outer else

}
-(void)onActionIndexButton:(id)sender{
    NSLog(@"onButtonClick");
    if(isPresentHozPicker == YES){
        [picker removeFromSuperview];
    }
    
    actionIndexSwitchButton = (SFIRulesActionButton *)sender;
    actionIndexSwitchButton.selected = YES ;
    [actionIndexSwitchButton changeStylewithColor:[UIColor colorFromHexString:@"FF9500"]];
    
    sfi_id buttonId = actionIndexSwitchButton.subProperties.deviceId;
    int buttonIndex = actionIndexSwitchButton.subProperties.index;
    NSString *buttonMatchdata = actionIndexSwitchButton.subProperties.matchData;
    
    //Add button properties to array
    [self addButtonToArray:buttonId index:buttonIndex matchData:buttonMatchdata];
    
    int buttonClickCount = 0;
    for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
        if(dimButtonProperty.deviceId == buttonId && dimButtonProperty.index == buttonIndex && [dimButtonProperty.matchData isEqualToString:buttonMatchdata]){
            buttonClickCount++;
        }
    }
    [actionIndexSwitchButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    
    // delegate
    [self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArray];//need to assign delegate in addview controller

    
}
-(void)onActionDimmerIndexButton:(id)sender{
    
    actionIndexDimButton = (SFIDimmerButtonAction *)sender;
    if(isPresentHozPicker == NO){
        
        
        
        pickerValuesArray2 = [NSMutableArray new];
        for (int i=(int)actionIndexDimButton.minValue; i<=(int)actionIndexDimButton.maxValue; i++) {
            [pickerValuesArray2 addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
        NSLog(@" pickerview add");
        [self horizontalpicker:actionIndexDimButton ];
    }
    else{
        actionIndexDimButton.selected = YES;
        [actionIndexDimButton changeStylewithColor:[UIColor colorFromHexString:@"FF9500"]];
        [UIView animateWithDuration:0.3 animations:^{
            [picker removeFromSuperview];
        }];
        
        [actionIndexDimButton setNewValue:newPickerValue];
        NSLog(@"dimmer button click: %d", actionIndexDimButton.selected);
        
        sfi_id buttonId = actionIndexDimButton.subProperties.deviceId;
        int buttonIndex = actionIndexDimButton.subProperties.index;
        
        //add button to array
        [self addButtonToArray:buttonId index:buttonIndex matchData:actionIndexDimButton.dimValue];
        
        
        buttonClickCount = 0;
        for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
            if(dimButtonProperty.deviceId == buttonId && dimButtonProperty.index == buttonIndex){
                buttonClickCount++;
            }
        }
        
        [actionIndexDimButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
        //delegate
        [self.delegate updateActionsButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
        isPresentHozPicker = NO;
        
        
    }
    
    
    
}
-(void)devicetype2:(id)sender{
}
#pragma mark horizontalpicker methods
- (void)horizontalpicker:(SFIDimmerButtonAction*)dimButton{
    const int control_height = 30;
    NSLog(@"viedidload");
    // Picker
    picker = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    picker.tag = 1; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    picker.frame = CGRectMake(self.parentViewController.deviceIndexButtonScrollView.frame.origin.x + 10,  dimButton.frame.origin.y + dimButton.frame.size.height +25, self.parentViewController.view.frame.size.width -20 , control_height);
    picker.layer.cornerRadius = 4;
    picker.layer.borderWidth = 1.5;
    picker.layer.borderColor = [UIColor colorFromHexString:@"FF9500"].CGColor;
    picker.backgroundColor = [UIColor whiteColor];
    picker.selectedTextColor = [UIColor colorFromHexString:@"FF9500"];
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
    indicatorView.color1 = [UIColor colorFromHexString:@"FF9500"];
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



-(void) addButtonToArray:(sfi_id)buttonId index:(int)buttonIndex matchData:(NSString*)buttonMatchData{
    
    SFIButtonSubProperties *highlightedButtonProperties = [self addSubPropertiesFordeviceID:buttonId index:buttonIndex matchData:buttonMatchData];
    [self.selectedButtonsPropertiesArray addObject:highlightedButtonProperties];
}
-(BOOL)istoggle:(SFIDevice*)device{
    switch (device.deviceType) {
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

#pragma mark timeElement

-(void)TimeEventClicked:(id)sender{
    NSLog(@"time trigger ");
    [self toggleHighlightForDeviceNameButton:sender];
    self.parentViewController.TimeSectionView.hidden = NO;
    self.parentViewController.deviceIndexButtonScrollView.hidden = YES;
    self.parentViewController.timeSegmentSelector.hidden = NO;
    self.parentViewController.lowerInformationLabel.text = @"The rule will trigger any time when sensor change their state";
    self.parentViewController.lowerInformationLabel.textAlignment = NSTextAlignmentCenter;
    self.parentViewController.lowerInformationLabel.hidden = NO;
    self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 0; //Default
    self.parentViewController.timerPikerPrecisely.hidden = YES;
    self.parentViewController.timePikerBetween1.hidden = YES;
    self.parentViewController.timePikerBetween2.hidden = YES;
    self.parentViewController.dayView.hidden = YES;
    self.parentViewController.andLabel.hidden = YES;
    [self.parentViewController.timeSegmentSelector addTarget:self action:@selector(timeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    
    if(self.ruleTime != nil){
        NSLog(@"TimeEventClicked - not nil");
        if(self.ruleTime.segmentType == Precisely1){
            self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 1;
        } else if(self.ruleTime.segmentType == Between1){
            self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 2;
        }
        [self timeSegmentControl:self.parentViewController.timeSegmentSelector];
    }
}

-(void)setTime{ //on edit or revisit
    NSLog(@"setTime");
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: self.ruleTime.hours];
    [components setMinute: self.ruleTime.mins];
    
    NSDate *existingTriggerTime = [gregorian dateFromComponents: components];
    self.parentViewController.timerPikerPrecisely.date = existingTriggerTime;
}


-(void)setTimeRange{//on edit
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: self.ruleTime.hours];
    [components setMinute: self.ruleTime.mins];
    
    NSDate *timeFrom = [gregorian dateFromComponents: components];
    self.parentViewController.timePikerBetween1.date = timeFrom;
    
    NSDate *timeTo = [timeFrom dateByAddingTimeInterval:((self.ruleTime.range+1)*60)];
    self.parentViewController.timePikerBetween2.date = timeTo;
}

- (void)timeSegmentControl:(UISegmentedControl *)segment{ //segment clicked
    NSLog(@" segment control index %ld",(long)segment.selectedSegmentIndex);
    switch (segment.selectedSegmentIndex) {
            //by default segment
        case 0:
        {
            self.parentViewController.timerPikerPrecisely.hidden = YES;
            self.parentViewController.timePikerBetween1.hidden = YES;
            self.parentViewController.timePikerBetween2.hidden = YES;
            self.parentViewController.andLabel.hidden = YES;
            self.parentViewController.dayView.hidden = YES;
            self.parentViewController.lowerInformationLabel.text = @"The rule will trigger any time when sensor change their state";
            self.parentViewController.lowerInformationLabel.textAlignment = NSTextAlignmentCenter;
            self.parentViewController.lowerInformationLabel.hidden = NO;
            [self updateTimeForAnyTimeSegment]; //no selector, calling method
        }
            break;
            //precisely
        case 1:{
            [self getDayView];
            //set previous values
            if(self.ruleTime != nil && self.ruleTime.segmentType == Precisely1){
                [self setTime];
            }
            
            self.parentViewController.lowerInformationLabel.hidden = YES;
            self.parentViewController.timerPikerPrecisely.hidden = NO;
            self.parentViewController.timePikerBetween1.hidden = YES;
            self.parentViewController.timePikerBetween2.hidden = YES;
            [self.parentViewController.timerPikerPrecisely addTarget:self action:@selector(preciselyTimeGetter:) forControlEvents:UIControlEventValueChanged];
            self.parentViewController.andLabel.hidden = YES;
        }
            break;
            //between
        case 2:{
            [self getDayView];
            //set previous values
            if(self.ruleTime != nil && self.ruleTime.segmentType == Between1){
                [self setTimeRange];
            }
            self.parentViewController.lowerInformationLabel.hidden = YES;
            self.parentViewController.timerPikerPrecisely.hidden = YES;
            self.parentViewController.timePikerBetween1.hidden = NO;
            self.parentViewController.timePikerBetween2.hidden = NO;
            self.parentViewController.andLabel.hidden = NO;
            [self.parentViewController.timePikerBetween1 addTarget:self action:@selector(betweenTimeGetter:) forControlEvents:UIControlEventValueChanged];
            [self.parentViewController.timePikerBetween2 addTarget:self action:@selector(betweenTimeGetter:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        default:
            break;
    }
}

-(void)updateTimeForAnyTimeSegment{
    self.ruleTime = [RulesTimeElement new];
    self.ruleTime.segmentType = AnyTime1;
}


-(void)setLableText{
    NSLog(@"setLabelText");
    int segmentType = (int)self.parentViewController.timeSegmentSelector.selectedSegmentIndex;
    
    NSLog(@"SegmentType: %d", segmentType);
    if(segmentType == Precisely1){
        NSDate *date =self.parentViewController.timerPikerPrecisely.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        NSString *time = [dateFormat stringFromDate:date];
        self.parentViewController.lowerInformationLabel.text =[NSString stringWithFormat:@"The Rule will trigger when sensor change their state at precisely at %@ on %@.",time
                                                               ,[[selectedDays valueForKey:@"description"] componentsJoinedByString:@", "]];
    }else if(segmentType == Between1){
        NSDate *dateFrom =self.parentViewController.timePikerBetween1.date;
        NSDate *dateTo = self.parentViewController.timePikerBetween2.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        NSString *timeFrom = [dateFormat stringFromDate:dateFrom];
        NSString *timeTo = [dateFormat stringFromDate:dateTo];
        self.parentViewController.lowerInformationLabel.text =[NSString stringWithFormat:@"The Rule will trigger when sensor changes their state between %@ to %@ on %@.",timeFrom, timeTo,[[selectedDays valueForKey:@"description"] componentsJoinedByString:@", "]];
    }
    self.parentViewController.lowerInformationLabel.textAlignment = NSTextAlignmentCenter;
    self.parentViewController.lowerInformationLabel.hidden = NO;
    
}

-(void) storeTimeParams:(NSDate *) date{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitWeekday  | NSCalendarUnitMonth  fromDate:date];
    self.ruleTime.hours = [comp hour];
    self.ruleTime.mins = [comp minute];
    self.ruleTime.dayOfMonth = @([comp day]).stringValue; //0 - 31
    self.ruleTime.dayOfWeek =  @([comp weekday]-1).stringValue; // 0 - 6
    self.ruleTime.monthOfYear = @([comp month]).stringValue; // 1 - 12
    self.ruleTime.isPresent = YES;
    
    
    NSLog(@"dayofweeek: %@ - hours: %ld - mins: %ld", self.ruleTime.dayOfWeek, (long)self.ruleTime.hours, (long)self.ruleTime.mins);
}

//precisely - onclickof time
-(void)preciselyTimeGetter:(id)timerPikerPrecisely{ //segment click
    self.ruleTime = [[RulesTimeElement alloc]init];
    NSDate *date =self.parentViewController.timerPikerPrecisely.date;
    self.ruleTime.segmentType = Precisely1;
    self.ruleTime.date = [date dateByAddingTimeInterval:0];
    [self storeTimeParams:date];
    [self setLableText];
    //
    [self.delegate updateTimeElementsButtonsPropertiesArray:self.ruleTime];
    //
}

//range - on click of either of times
-(void)betweenTimeGetter:(UIDatePicker *)timeBetweenPicker{
    self.ruleTime = [[RulesTimeElement alloc]init];
    NSDate *timeFrom =self.parentViewController.timePikerBetween1.date;
    NSDate *timeto =self.parentViewController.timePikerBetween2.date;
    
    NSTimeInterval secondsBetween = [timeto timeIntervalSinceDate:timeFrom];
    self.ruleTime.dateFrom = [timeFrom dateByAddingTimeInterval:0];
    self.ruleTime.dateTo = [timeto dateByAddingTimeInterval:0];
    self.ruleTime.range = secondsBetween/60;
    NSLog(@"range: %ld", (long)self.ruleTime.range);
    self.ruleTime.segmentType = Between1;
    [self storeTimeParams:timeFrom];
    [self setLableText];
    [self.delegate updateTimeElementsButtonsPropertiesArray:self.ruleTime];
    
}

-(void) setDayButtonProperties:(RulesDeviceNameButton*)dayButton withRadius:(double)dayButtonWidth{
    CALayer * l1 = [dayButton layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:dayButtonWidth/2];
    l1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
    dayButton.titleLabel.textColor = [UIColor whiteColor];
    dayButton.backgroundColor = [UIColor grayColor];
    dayButton.titleLabel.textAlignment  = NSTextAlignmentCenter;
}

-(void)setHighlight:(RulesDeviceNameButton*)dayButton{
    for (NSNumber* tag in selectedDayTags) {
        if ([tag isEqualToNumber:@(dayButton.tag)]) {
            dayButton.selected = YES;
        }
    }
}

-(void)getDayView{
    NSLog(@"getDayView");
    int xVal = 4;
    self.parentViewController.dayView.hidden = NO;
    double dayButtonWidth = self.parentViewController.dayView.frame.size.width/8.5; //kept 8.5 because we are giving pDDING OF 8 BETWEEN each button
    //    UIView *dayView = [[UIView alloc]initWithFrame:CGRectMake(self.parentViewController.dayView.frame.origin.x, self.parentViewController.dayView.frame.origin.y,(dayButtonWidth*7)+(8*6),self.parentViewController.dayView.frame.size.height)];
    int tag = 0;
    for(NSString* day in dayArray){
        RulesDeviceNameButton *dayButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, dayButtonWidth, dayButtonWidth)];
        [self setDayButtonProperties:dayButton withRadius:dayButtonWidth];
        [dayButton setTitle:day forState:UIControlStateNormal];
        dayButton.tag = tag;
        [self setHighlight:dayButton];
        [dayButton addTarget:self action:@selector(dayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.parentViewController.dayView addSubview:dayButton];
        xVal += dayButtonWidth + 8;
        tag++;
        
    }
    
}


-(void)dayBtnClicked:(RulesDeviceNameButton*)sender{
    sender.selected = !sender.selected;
    [sender changeStyle];
    NSLog(@" sender tag %ld %d",(long)sender.tag,sender.selected);
    if(sender.selected){
        //required to highlight previous values
        //here adding every case "," for creating string selectedDayString as = "0,1,2,3......"
        [selectedDayTags addObject:@(sender.tag)];
        switch (sender.tag) {
            case 0:{
                [selectedDays addObject:@"Sun"];
                [selectedDayString appendString:@","];//rushabh
                [selectedDayString appendString:@(sender.tag).stringValue];//rushabh
            }
                break;
            case 1:{
                [selectedDays addObject:@"Mon"];
                [selectedDayString appendString:@","];
                [selectedDayString appendString:@(sender.tag).stringValue];
            }
                break;
            case 2:{
                [selectedDays addObject:@"Tue"];
                [selectedDayString appendString:@","];
                [selectedDayString appendString:@(sender.tag).stringValue];
            }
                break;
            case 3:{
                [selectedDays addObject:@"Wed"];
                [selectedDayString appendString:@","];
                [selectedDayString appendString:@(sender.tag).stringValue];
            }
                break;
            case 4:{
                [selectedDays addObject:@"Thu"];
                [selectedDayString appendString:@","];
                [selectedDayString appendString:@(sender.tag).stringValue];
            }
                break;
            case 5:{
                [selectedDays addObject:@"Fri"];
                [selectedDayString appendString:@","];
                [selectedDayString appendString:@(sender.tag).stringValue];
            }
                break;
            case 6:{
                [selectedDays addObject:@"Sat"];
                [selectedDayString appendString:@","];
                [selectedDayString appendString:@(sender.tag).stringValue];
            }
                break;
            default:
                break;
        }
    }
    else{
        [selectedDayTags removeObject:@(sender.tag)];
        switch (sender.tag) {
            case 0:{
                [selectedDays removeObject:@"Sun"];
            }
                break;
            case 1:{
                [selectedDays removeObject:@"Mon"];
            }
                break;
            case 2:{
                [selectedDays removeObject:@"Tue"];
            }
                break;
            case 3:{
                [selectedDays removeObject:@"Wed"];
            }
                break;
            case 4:{
                [selectedDays removeObject:@"Thu"];
            }
                break;
            case 5:{
                [selectedDays removeObject:@"Fri"];
            }
                break;
            case 6:{
                [selectedDays removeObject:@"Sat"];
            }
                break;
            default:
                break;
        }
    }
    NSLog(@"selectedDays: %@",selectedDays);
    
    NSString *temp = [selectedDayString substringFromIndex:1];
    NSLog(@" selected days steing %@",temp);
    self.ruleTime.dayOfWeek = temp;//rushab
    
    [self setLableText];
}


@end
