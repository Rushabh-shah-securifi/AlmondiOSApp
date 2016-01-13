//
//  AddTriggers.m
//  RulesUI
//
//  Created by Masood on 01/12/15.
//  Copyright © 2015 Masood. All rights reserved.


#import "AddTriggers.h"
#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "Colours.h"
#import "SFIDeviceIndex.h"
//#import "SensorIndexSupport.h"
#import "RuleSensorIndexSupport.h"
#import "IndexValueSupport.h"
//#import "SFIDimmerButton.h"
#import "SFIRulesDimmerButton.h"
#import "SFIRulesSwitchButton.h"
#import "ValueFormatter.h"
#import "RulesConstants.h"
#import "SFIButtonSubProperties.h"
#import "RulesDeviceNameButton.h"
#import "RulesView.h"
#import "RulesNestThermostat.h"
#import "V8HorizontalPickerView.h"
#import "V8HorizontalPickerViewProtocol.h"
#import "SFIPickerIndicatorView1.h"


@interface AddTriggers()<V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource>
@property (nonatomic,strong)NSMutableDictionary *buttonsSubDict;
@property (nonatomic,strong)NSMutableDictionary *buttonsDict;


@end

@implementation AddTriggers
V8HorizontalPickerView *picker;
SFIRulesDimmerButton *dimmerButtonClick;
NSString *newPickerValue;
SFIRulesSwitchButton *switchButtonClick;
bool isPresentHozPicker;
NSMutableArray * pickerValuesArray;
NSMutableString *selectedDayString;
NSArray *dayArray;

NSMutableArray *selectedDays;
NSMutableArray *selectedDayTags;

-(id)init{
    if(self == [super init]){
        NSLog(@"init method");
        isPresentHozPicker = NO;
        selectedDayString = [NSMutableString new];
        newPickerValue = [NSString new];
        self.selectedButtonsPropertiesArray = [NSMutableArray new];
        dayArray = [[NSArray alloc]initWithObjects:@"Su",@"Mo",@"Tu",@"We",@"Th",@"Fr",@"Sa", nil];
        selectedDayTags = [NSMutableArray new];
        selectedDays = [NSMutableArray new];
        self.selectedWiFiClientProperty = [NSMutableArray new];
    }
    return self;
}

-(void)createDeviceListButton:(RulesDeviceNameButton*)deviceButton title:(NSString*)title{
    
    
    [deviceButton setTitle:title forState:UIControlStateNormal];
    deviceButton.titleLabel.numberOfLines = 1;
     deviceButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:3];
//    deviceButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [deviceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deviceButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    deviceButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    deviceButton.backgroundColor = [UIColor clearColor];
    deviceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

-(int) createTimerButtonWithWidth:(double)deviceButtonWidth andHeight:(double)deviceButtonHeight xVal:(int)xVal{
    NSString *title = @"Time";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    CGRect textRect;
    textRect.size = [title sizeWithAttributes:attributes];
    
    RulesDeviceNameButton *timeButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];
    
    [self createDeviceListButton:timeButton title:@"Time"];
    [timeButton addTarget:self action:@selector(TimeEventClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.parentViewController.deviceListScrollView addSubview:timeButton];
    xVal += textRect.size.width + 15;
    return xVal;
}

-(int)createModeButtonWithWidth:(double)deviceButtonWidth andHeight:(double)deviceButtonHeight xVal:(int)xVal{
    NSString *title = @"Mode";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    CGRect textRect;
    textRect.size = [title sizeWithAttributes:attributes];
    
    RulesDeviceNameButton *modeButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];
    
    [self createDeviceListButton:modeButton title:@"Mode"];
    [modeButton addTarget:self action:@selector(modeClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.parentViewController.deviceListScrollView addSubview:modeButton];
    xVal += textRect.size.width + 15;
    
    return xVal;

}

-(int) createclientsButtonWithWidth:(double)deviceButtonWidth andHeight:(double)deviceButtonHeight xVal:(int)xVal{
    NSString *title = @"Clients";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    CGRect textRect;
    textRect.size = [title sizeWithAttributes:attributes];

    RulesDeviceNameButton *wifiClientButton = [[RulesDeviceNameButton alloc] initWithFrame:CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight)];
    
    [self createDeviceListButton:wifiClientButton title:@"Clients"];
    [wifiClientButton addTarget:self action:@selector(wifiClientsClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentViewController.deviceListScrollView addSubview:wifiClientButton];
    xVal += textRect.size.width + 15;
    return xVal;

}

-(void)displayTriggerDeviceList{
    NSLog(@"displayTriggerDeviceList");
    //clear view
    NSArray *viewsToRemove = [self.parentViewController.deviceListScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    int xVal = 15;
    double deviceButtonWidth = (self.parentViewController.view.frame.size.width)/6;
    double deviceButtonHeight = self.parentViewController.deviceListScrollView.frame.size.height;
   
    //timebutton
    
    xVal = [self createTimerButtonWithWidth:deviceButtonWidth andHeight:deviceButtonHeight xVal:xVal];;
    
    //wifi cilent button
    xVal = [self createclientsButtonWithWidth:deviceButtonWidth andHeight:deviceButtonHeight xVal:xVal];;

    //mode button
    
    xVal = [self createModeButtonWithWidth:deviceButtonWidth andHeight:deviceButtonHeight xVal:xVal];;
    
   
    
    //Rest of the devices
    for(SFIDevice *device in self.parentViewController.deviceArray){
//        if(device.deviceType == SFIDeviceType_HueLamp_48){
//            [self.parentViewController.deviceArray removeObject:device];
//            continue;
//        }
//        self.parentViewController.deviceArray removeobjects
        
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
       
        [deviceButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.parentViewController.deviceListScrollView addSubview:deviceButton];
        
        xVal += textRect.size.width +15;
    }
    self.parentViewController.deviceListScrollView.contentSize = CGSizeMake(xVal +10,self.parentViewController.deviceListScrollView.contentSize.height);
}



//on devicelist button click, calling this method
-(void) createDeviceIndexesLayout:(SFIDevice*)device deviceIndexes:(NSArray*)deviceIndexes{
    int numberOfCells = [self maxCellId:deviceIndexes];
    
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*numberOfCells + ROW_PADDING);
    //NSLog(@" scrollableSize %@",scrollableSize);
    
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
    
    //nest_thermostat - 57
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
    self.buttonsSubDict = [NSMutableDictionary new];
    
    
    //else for rest of the devices
    for(int i = 0; i < numberOfCells; i++){
        UIView *cellView = [self addMyButtonwithYScale:ROW_PADDING+(ROW_PADDING+frameSize)*i  withDeviceIndex:[deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d", i+1]] device:device];
        //        cellView.backgroundColor = [UIColor redColor];
        NSLog(@"cell view children: %@", cellView.subviews);
    }
    
}


- (UIView *)addMyButtonwithYScale:(int)yScale withDeviceIndex:(NSArray *)deviceIndexes device:(SFIDevice*)device{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            self.parentViewController.view.frame.size.width,
                                                            frameSize)];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:view];
    
    int i=0;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        NSMutableArray *btnary=[[NSMutableArray alloc]init];
        int indexValCounter = 0;
        for (IndexValueSupport *iVal in deviceIndex.indexValues) {
            i++;
            indexValCounter++;
            
            if ([iVal.layoutType isEqualToString:@"dimButton"]){
                NSLog(@"painting dimmer button");
                SFIRulesDimmerButton *dimbtn=[[SFIRulesDimmerButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, dimFrameWidth, dimFrameHeight)];
                dimbtn.tag=indexValCounter;
                dimbtn.valueType=deviceIndex.valueType;
                dimbtn.minValue = iVal.minValue; //required for picker view
                dimbtn.maxValue = iVal.maxValue;
                dimbtn.subProperties = [self addSubPropertiesFordeviceID:device.deviceID index:deviceIndex.indexID matchData:iVal.matchData];
                dimbtn.device = device;
                dimbtn.selected=NO;
                [dimbtn addTarget:self action:@selector(onDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];

                //get previous value
                NSString *matchData = iVal.matchData;
                BOOL isSelected = NO;
                for(SFIButtonSubProperties *dimButtonProperty in self.selectedButtonsPropertiesArray){ //to do - you can add count property to subproperties and iterate array in reverse
                    if(dimButtonProperty.deviceId == device.deviceID && dimButtonProperty.index == deviceIndex.indexID){
                        matchData = dimButtonProperty.matchData;
                        NSLog(@"dim match data: %@", matchData);
                        isSelected = YES;
                    }
                    
                }
                
                //setvalues
                [dimbtn setupValues:matchData Title:iVal.displayText suffix:iVal.valueFormatter.suffix];
                //highlight after setting up values
                dimbtn.selected = isSelected;
                
                dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                            view.bounds.size.height/2);
                dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
                [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
                
                NSLog(@"dim button x coord: %f", dimbtn.frame.origin.x);
                
                [btnary addObject:dimbtn];
                [view addSubview:dimbtn];
            }
            
            else{
                NSLog(@"painting rules switch button");
                SFIRulesSwitchButton *btnBinarySwitchOn = [[SFIRulesSwitchButton alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
                btnBinarySwitchOn.tag = indexValCounter;
                btnBinarySwitchOn.valueType=deviceIndex.valueType;
                btnBinarySwitchOn.device = device;
                btnBinarySwitchOn.subProperties = [self addSubPropertiesFordeviceID:device.deviceID index:deviceIndex.indexID matchData:iVal.matchData];
                
                [btnBinarySwitchOn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [btnBinarySwitchOn setupValues:[UIImage imageNamed:iVal.iconName] Title:iVal.displayText];
                
                //get previous highligh
                for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
                    if(switchButtonProperty.deviceId == device.deviceID && switchButtonProperty.index == deviceIndex.indexID && [switchButtonProperty.matchData isEqualToString:iVal.matchData]){
                        btnBinarySwitchOn.selected = YES;
                    }
                    //break;
                }
                //re-arraninging
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
                    if([childView isKindOfClass:[SFIRulesDimmerButton class]]){
                        if(i==2){
                            NSLog(@"iskindofclass");
                            btnWidth = dimFrameWidth;
                        }
                        if(i==3){
                            btnWidth = 0;
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
                    NSLog(@"child view btn: %@, x coord: %f", childView, childView.frame.origin.x);
                }
                NSLog(@"toggle button x coord: %f", btnBinarySwitchOn.frame.origin.x);
                [btnary addObject:btnBinarySwitchOn];
                [view addSubview:btnBinarySwitchOn];
            } //outer else
        } //inner for loop, indexvalues
        [self.buttonsSubDict setValue:btnary forKey:[NSString stringWithFormat:@"%d",deviceIndex.indexID]];
    }//outer for loop deviceindexes
    NSLog(@"self.buttonsSubDict: %@", self.buttonsSubDict);
    return view;
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

-(void) addButtonToArray:(sfi_id)buttonId index:(int)buttonIndex matchData:(NSString*)buttonMatchData{
    
    SFIButtonSubProperties *highlightedButtonProperties = [self addSubPropertiesFordeviceID:buttonId index:buttonIndex matchData:buttonMatchData];
    [self.selectedButtonsPropertiesArray addObject:highlightedButtonProperties];
    
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
    [currentButton setTitleColor:[UIColor colorFromHexString:@"02a8f3"] forState:UIControlStateNormal];
    [currentButton setTitleShadowColor:[UIColor colorFromHexString:@"02a8f3"] forState:UIControlStateNormal];
}

#pragma mark click handlers
-(void)onDeviceButtonClick:(RulesDeviceNameButton *)sender{
    NSLog(@"onDeviceButtonClick: %@",sender.device);
    [self resetViews];
    //toggeling
    [self toggleHighlightForDeviceNameButton:sender];
    
    RuleSensorIndexSupport *Index=[[RuleSensorIndexSupport alloc]init];
    NSArray *deviceIndexes=[Index getIndexesFor:sender.device.deviceType];//need device type
    [self createDeviceIndexesLayout:sender.device deviceIndexes:deviceIndexes];
    
}

- (void)onButtonClick:(id)sender{
    NSLog(@"onButtonClick");
    if(isPresentHozPicker == YES){
        [picker removeFromSuperview];
    }
    switchButtonClick = (SFIRulesSwitchButton *)sender;
    UIView *superView = [sender superview];
    
    if(switchButtonClick.device.deviceType == SFIDeviceType_MultiLevelSwitch_2){
        [self devicetype2:switchButtonClick];
        return;
    }
    
    
    sfi_id buttonId = switchButtonClick.subProperties.deviceId;
    int buttonIndex = switchButtonClick.subProperties.index;
    NSString *buttonMatchdata = switchButtonClick.subProperties.matchData;
    

    for(UIView *childView in [superView subviews]){
        if([childView isKindOfClass:[SFIRulesDimmerButton class]]){
            continue;
        }else{
            SFIRulesSwitchButton *switchButton = (SFIRulesSwitchButton*)childView;
            if(buttonIndex == switchButton.subProperties.index){
                if (switchButton.tag == switchButtonClick.tag)
                {
                    switchButton.selected = !switchButton.selected;
                }else{
                    switchButton.selected = NO;
                }
            }
        }
    }
    
    //store seleted button in dictionary
    if (switchButtonClick.selected) {
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
    else if (switchButtonClick.selected == NO){//rs
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


-(void)onDimmerButtonClick:(id)sender{
    
    dimmerButtonClick = (SFIRulesDimmerButton *)sender;
    
    dimmerButtonClick.selected=!dimmerButtonClick.selected;
    if(dimmerButtonClick.device.deviceType == SFIDeviceType_MultiLevelSwitch_2){
        [self devicetype2:dimmerButtonClick];
    }
    else{
        
    sfi_id dimId = dimmerButtonClick.subProperties.deviceId;
    int dimIndex = dimmerButtonClick.subProperties.index;
    NSLog(@" dim value %ld ,max value %ld",(long)dimmerButtonClick.minValue,(long)dimmerButtonClick.maxValue);
    if(dimmerButtonClick.selected){
        pickerValuesArray = [NSMutableArray new];
        for (int i=(int)dimmerButtonClick.minValue; i<=(int)dimmerButtonClick.maxValue; i++) {
            [pickerValuesArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        //[self setupPicker:dimmerButtonClick.dimValue];
        [self horizontalpicker:dimmerButtonClick];
    }
    else{
        [dimmerButtonClick setNewValue:dimmerButtonClick.subProperties.matchData]; //set initial value
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
            dimmerButtonClick.selected = YES;
            //store in array
            sfi_id dimId = dimmerButtonClick.subProperties.deviceId;
            int dimIndex = dimmerButtonClick.subProperties.index;
            [dimmerButtonClick setNewValue:newPickerValue];
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

- (void)horizontalpicker:(SFIRulesDimmerButton*)dimButton{
    const int control_height = 30;
    NSLog(@"viedidload");
    // Picker
    picker = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    picker.tag = 1; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    picker.frame = CGRectMake(self.parentViewController.deviceIndexButtonScrollView.frame.origin.x + 10,  dimButton.frame.origin.y + dimButton.frame.size.height +25, self.parentViewController.view.frame.size.width -20 , control_height);
    picker.layer.cornerRadius = 4;
    picker.layer.borderWidth = 1.5;
    picker.layer.borderColor = [UIColor colorFromHexString:@"02a8f3"].CGColor;
    picker.backgroundColor = [UIColor whiteColor];
    picker.selectedTextColor = [UIColor colorFromHexString:@"02a8f3"];
    picker.elementFont = [UIFont systemFontOfSize:11];
    picker.elementFont = [UIFont fontWithName:@"AvenirLTStd-Roman" size:11];
    picker.textColor = [UIColor blackColor];
    picker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    picker.delegate = self;
    picker.dataSource = self;
  //  [picker scrollToElement:dimButton.dimValue.intValue animated:YES];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:picker];
    // width depends on propertyType
    const NSInteger element_width = [self horizontalPickerView:picker widthForElementAtIndex:0];
    SFIPickerIndicatorView1 *indicatorView = [[SFIPickerIndicatorView1 alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    picker.selectionPoint = CGPointMake((picker.frame.size.width) / 2, 0);
    indicatorView.color1 = [UIColor colorFromHexString:@"02a8f3"];
    picker.selectionIndicatorView = indicatorView;
    
    
}
#pragma mark - V8HorizontalPickerView methods

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    return 40;
}

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return pickerValuesArray.count;
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    return @(index).stringValue;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    NSLog(@"pickerview:");
    
    newPickerValue = pickerValuesArray[index];

    isPresentHozPicker = YES;
    
}

-(void)devicetype2:(id)sender{
    NSLog(@"device type 2");
    if([sender isKindOfClass:[SFIRulesSwitchButton class]]){
         switchButtonClick = (SFIRulesSwitchButton *)sender;
        sfi_id buttonId = switchButtonClick.subProperties.deviceId;
        int buttonIndex = switchButtonClick.subProperties.index;
        NSString *buttonMatchdata = switchButtonClick.subProperties.matchData;
        NSLog(@"button index %d ",buttonIndex);
        UIView *superView = [sender superview];
        for(UIView *childView in [superView subviews]){
            if([childView isKindOfClass:[SFIRulesDimmerButton class]]){
                continue;
            }else{
                SFIRulesSwitchButton *switchButton = (SFIRulesSwitchButton*)childView;
                if(buttonIndex == switchButton.subProperties.index){
                    if (switchButton.tag == switchButtonClick.tag)
                    {
                        switchButton.selected = !switchButton.selected;
                    }else{
                        switchButton.selected = NO;
                    }
                }
            }
        }

        if(switchButtonClick.selected){
            for (SFIRulesDimmerButton *button in [self.parentViewController.deviceIndexButtonScrollView subviews])
            {
                if([button isKindOfClass:[SFIRulesDimmerButton class]])
                button.selected = NO;
            }
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
        else if (switchButtonClick.selected == NO){//rs
            SFIButtonSubProperties *toBeDeletedProperty;
            for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
                if(switchButtonProperty.deviceId == buttonId && switchButtonProperty.index == buttonIndex && [switchButtonProperty.matchData isEqualToString:buttonMatchdata]){
                    toBeDeletedProperty = switchButtonProperty;
                }
                //break;
            }
            [self.selectedButtonsPropertiesArray removeObject:toBeDeletedProperty];
            
            
        }
   
    }
    
    else if([sender isKindOfClass:[SFIRulesDimmerButton class]]){
         dimmerButtonClick = (SFIRulesDimmerButton *)sender;
        sfi_id dimId = dimmerButtonClick.subProperties.deviceId;
        int dimIndex = dimmerButtonClick.subProperties.index;
        
        if(dimmerButtonClick.selected){
            pickerValuesArray = [NSMutableArray new];
            for (int i=(int)dimmerButtonClick.minValue; i<=(int)dimmerButtonClick.maxValue; i++) {
                [pickerValuesArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
            for (SFIRulesSwitchButton *button in [self.parentViewController.deviceIndexButtonScrollView subviews])
            {
                if([button isKindOfClass:[SFIRulesSwitchButton class]]){
//                    NSLog(@"button.selected = NO ");
                    button.selected = NO;
                NSLog(@"button.selected = NO ");
            }
                switchButtonClick.selected = NO;// must be solved
            //[self setupPicker:dimmerButtonClick.dimValue];
            [self horizontalpicker:dimmerButtonClick];

            }
        }
        else if(dimmerButtonClick.selected == NO){
//            [dimmerButtonClick setNewValue:dimmerButtonClick.subProperties.matchData]; //set initial value
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
                dimmerButtonClick.selected = YES;
                //store in array
                sfi_id dimId = dimmerButtonClick.subProperties.deviceId;
                int dimIndex = dimmerButtonClick.subProperties.index;
                [dimmerButtonClick setNewValue:newPickerValue];
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
        
//         [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
    }
     [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
    }

#pragma mark time elements

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
        if(self.ruleTime.segmentType == Precisely){
            self.parentViewController.timeSegmentSelector.selectedSegmentIndex = 1;
        } else if(self.ruleTime.segmentType == Between){
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
            if(self.ruleTime != nil && self.ruleTime.segmentType == Precisely){
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
            if(self.ruleTime != nil && self.ruleTime.segmentType == Between){
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
    self.ruleTime.segmentType = AnyTime;
}


-(void)setLableText{
    NSLog(@"setLabelText");
    int segmentType = (int)self.parentViewController.timeSegmentSelector.selectedSegmentIndex;
    
    NSLog(@"SegmentType: %d", segmentType);
    if(segmentType == Precisely){
        NSDate *date =self.parentViewController.timerPikerPrecisely.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm aa"];
        NSString *time = [dateFormat stringFromDate:date];
        self.parentViewController.lowerInformationLabel.text =[NSString stringWithFormat:@"The Rule will trigger when sensor change their state at precisely at %@ on %@.",time
                                    ,[[selectedDays valueForKey:@"description"] componentsJoinedByString:@", "]];
    }else if(segmentType == Between){
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
    self.ruleTime.segmentType = Precisely;
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
    self.ruleTime.segmentType = Between;
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
//mode
#pragma mark mode method
-(void)modeClicked:sender{
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:sender];
    
    [self addMode];
}


-(void)addMode{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            ROW_PADDING,
                                                            self.parentViewController.view.frame.size.width,
                                                            frameSize)];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:view];
    SFIRulesSwitchButton *homeButton=[[SFIRulesSwitchButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
    homeButton.tag=1;
    [homeButton addTarget:self action:@selector(onModeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [homeButton setupValues:[UIImage imageNamed:@"home_icon"] Title:@"Home"];//
    homeButton.subProperties = [self addSubPropertiesFordeviceID:0 index:1 matchData:@"home"];
    
    //get previous highligh
    for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
        if(switchButtonProperty.deviceId == 0 && switchButtonProperty.index == 1 && [switchButtonProperty.matchData isEqualToString:@"home"]){
            homeButton.selected = YES;
        }
        //break;
    }
    
    homeButton.center = CGPointMake(view.bounds.size.width/2,
                                       view.bounds.size.height/2);
    homeButton.frame = CGRectMake(homeButton.frame.origin.x - (frameSize/2)+textHeight/2 ,
                                     homeButton.frame.origin.y,
                                     homeButton.frame.size.width,
                                     homeButton.frame.size.height);
    
    [view addSubview:homeButton];
    
    SFIRulesSwitchButton *awayButton=[[SFIRulesSwitchButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
    awayButton.tag=2;
    [awayButton addTarget:self action:@selector(onModeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [awayButton setupValues:[UIImage imageNamed:@"away_icon"] Title:@"Away"];//
    awayButton.subProperties = [self addSubPropertiesFordeviceID:0 index:1 matchData:@"away"];
    
    //get previous highligh
    for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
        if(switchButtonProperty.deviceId == 0 && switchButtonProperty.index == 1 && [switchButtonProperty.matchData isEqualToString:@"away"]){
            awayButton.selected = YES;
        }
        //break;
    }
    awayButton.center = CGPointMake(view.bounds.size.width/2,
                                        view.bounds.size.height/2);
    awayButton.frame = CGRectMake(awayButton.frame.origin.x + (frameSize/2)+textHeight/2 ,
                                      awayButton.frame.origin.y,
                                      awayButton.frame.size.width,
                                      awayButton.frame.size.height);
    [view addSubview:awayButton];
}

-(void)onModeButtonClicked:(id)sender{ // to be redirected to onButtonClick upon changin logic of onButtonClick
    UIView *parentView = [sender superview];
    switchButtonClick = sender;
    
    sfi_id buttonId = switchButtonClick.subProperties.deviceId;
    int buttonIndex = switchButtonClick.subProperties.index;
    NSString *buttonMatchdata = switchButtonClick.subProperties.matchData;
    NSLog(@" button matchdata %@",buttonMatchdata);
    for(SFIRulesSwitchButton* button in [parentView subviews]){
        if(button.tag == switchButtonClick.tag){
            button.selected = !button.selected;
        }else{
            button.selected = NO;
        }
    }
    if(switchButtonClick.selected){
        //remove previous
        NSMutableArray *toBeDeletedSubProperties = [[NSMutableArray alloc] init];
        for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
            if(switchButtonProperty.deviceId == buttonId){
                [toBeDeletedSubProperties addObject:switchButtonProperty];
            }
            //break;
        }
        [self.selectedButtonsPropertiesArray removeObjectsInArray:toBeDeletedSubProperties];
        //add current
        [self addButtonToArray:buttonId index:buttonIndex matchData:buttonMatchdata];
  
    }
    
    else{
        SFIButtonSubProperties *toBeDeletedProperty;
        for(SFIButtonSubProperties *switchButtonProperty in self.selectedButtonsPropertiesArray){
            if(switchButtonProperty.deviceId == buttonId && switchButtonProperty.index == buttonIndex && [switchButtonProperty.matchData isEqualToString:buttonMatchdata]){
                toBeDeletedProperty = switchButtonProperty;
            }
            //break;
        }
        [self.selectedButtonsPropertiesArray removeObject:toBeDeletedProperty];

    }
    [self.delegate updateTriggersButtonsPropertiesArray:self.selectedButtonsPropertiesArray];
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

// wifi client
#pragma mark wifiClient methods
-(void)wifiClientsClicked:(id)sender{
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:sender];
    
    int i =0;
    
        NSLog(@"wifi clients array: %@", self.parentViewController.wifiClientsArray);
    for(SFIConnectedDevice *connectedClient in self.parentViewController.wifiClientsArray){
        if(connectedClient.deviceUseAsPresence){
            [self addWiFiClient:connectedClient withY:ROW_PADDING + (ROW_PADDING+frameSize)*i];
            i++;
        }
    }
    CGSize scrollableSize = CGSizeMake(self.parentViewController.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*i + ROW_PADDING);
    //NSLog(@" scrollableSize %@",scrollableSize);
    
    [self.parentViewController.deviceIndexButtonScrollView setContentSize:scrollableSize];
}

-(void)addWiFiClient:(SFIConnectedDevice*)connectedClient withY:(int)yScale{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            self.parentViewController.view.frame.size.width,
                                                            frameSize)];
    [self.parentViewController.deviceIndexButtonScrollView addSubview:view];
    
    UILabel *clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.origin.x, -20, view.frame.size.width, 14)];
    clientNameLabel.text = connectedClient.name;
    clientNameLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    clientNameLabel.font = [UIFont systemFontOfSize:12];
    clientNameLabel.backgroundColor = [UIColor clearColor];
    clientNameLabel.textAlignment = NSTextAlignmentCenter;
    clientNameLabel.textColor = [UIColor lightGrayColor];
    [view addSubview:clientNameLabel];
    //join
    SFIRulesSwitchButton *clientBtnJoin=[[SFIRulesSwitchButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
    clientBtnJoin.tag=1;
    clientBtnJoin.generic = (SFIConnectedDevice*)connectedClient;
    [clientBtnJoin addTarget:self action:@selector(onWiFIClientButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [clientBtnJoin setupValues:[UIImage imageNamed:@"device-joining"] Title:@"JOIN"];//
    clientBtnJoin.subProperties = [self addSubPropertiesFordeviceID:connectedClient.deviceID.intValue index:0 matchData:connectedClient.deviceMAC andEventType:@"ClientJoined"];
    
    //get previous highligh - using different button to differtiate buttons
    for(SFIButtonSubProperties *switchButtonProperty in self.selectedWiFiClientProperty){
        if(switchButtonProperty.deviceId == connectedClient.deviceID.intValue && [switchButtonProperty.eventType isEqualToString:@"ClientJoined"]){
            clientBtnJoin.selected = YES;
        }
        //break;
    }
    clientBtnJoin.center = CGPointMake(view.bounds.size.width/2,
                                       view.bounds.size.height/2);
    clientBtnJoin.frame = CGRectMake(clientBtnJoin.frame.origin.x - (frameSize/2)+textHeight/2 ,
                                     clientBtnJoin.frame.origin.y,
                                     clientBtnJoin.frame.size.width,
                                     clientBtnJoin.frame.size.height);
    
    
    [view addSubview:clientBtnJoin];
    
    //leave
    SFIRulesSwitchButton *clientBtnLeave=[[SFIRulesSwitchButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y, frameSize, frameSize)];
    clientBtnLeave.tag=2;
    clientBtnLeave.generic = (SFIConnectedDevice*)connectedClient;
    [clientBtnLeave addTarget:self action:@selector(onWiFIClientButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [clientBtnLeave setupValues:[UIImage imageNamed:@"device-leaving"] Title:@"LEAVE"];//
    clientBtnLeave.subProperties = [self addSubPropertiesFordeviceID:connectedClient.deviceID.intValue index:0 matchData:connectedClient.name andEventType:@"ClientLeft"];
    //get previous highligh
    for(SFIButtonSubProperties *switchButtonProperty in self.selectedWiFiClientProperty){
        if(switchButtonProperty.deviceId == connectedClient.deviceID.intValue && [switchButtonProperty.eventType isEqualToString:@"ClientLeft"]){
            clientBtnLeave.selected = YES;
        }
        //break;
    }
    
    clientBtnLeave.center = CGPointMake(view.bounds.size.width/2,
                                        view.bounds.size.height/2);
    clientBtnLeave.frame = CGRectMake(clientBtnLeave.frame.origin.x + (frameSize/2)+textHeight/2 ,
                                      clientBtnLeave.frame.origin.y,
                                      clientBtnLeave.frame.size.width,
                                      clientBtnLeave.frame.size.height);
    [view addSubview:clientBtnLeave];
}

-(void)onWiFIClientButtonClicked:(SFIRulesSwitchButton*)sender{
    
    UIView *parentView = [sender superview];
    switchButtonClick = sender; //need to change to wifi client button
//    connectedDevice - you dont need this, that why we are storing subproperties while painting button
    int deviceId = switchButtonClick.subProperties.deviceId; //clientid
    int index = switchButtonClick.subProperties.index; //0
    NSString *MAC = switchButtonClick.subProperties.matchData; //mac
    
    //toggle highlight
    for(id subView in [parentView subviews]){
        if([subView isKindOfClass:[UILabel class]]){
            continue;
        }
        SFIRulesSwitchButton *button = subView;
        if(button.tag == switchButtonClick.tag){
            button.selected = !button.selected;
        }else{
            button.selected = NO;
        }
    }
    //store properties
    if(switchButtonClick.selected){
        //rushabh
        //if tag = 1 join ,tag = 2 leave
        NSString *eventType = [NSString new];
        if(sender.tag == 1){
            eventType = @"ClientJoined";
        }
        else if(sender.tag == 2){
            eventType = @"ClientLeft";
        }
        //remove previous
        BOOL isFound = NO;
        NSMutableArray *toBeDeletedSubProperties = [[NSMutableArray alloc] init];
        for(SFIButtonSubProperties *switchButtonProperty in self.selectedWiFiClientProperty){
            if(switchButtonProperty.deviceId == deviceId){ //can deviceid and clientid be same - any ways you are removing from selected wificlientproperty
                [toBeDeletedSubProperties addObject:switchButtonProperty];
                isFound = YES;
            }
            //break;
        }
//        if(isFound){
             [self.selectedWiFiClientProperty removeObjectsInArray:toBeDeletedSubProperties];
//        }
       
        //add current
        [self storeWiFiClientProperty:deviceId index:index matchData:MAC withEventType:eventType];
        //rushabh
    }
    else{
        //just remove
        SFIButtonSubProperties *toBeDeletedProperty;
        for(SFIButtonSubProperties *switchButtonProperty in self.selectedWiFiClientProperty){
            if(switchButtonProperty.deviceId == deviceId && switchButtonProperty.index == index && [switchButtonProperty.matchData isEqualToString:MAC]){
                toBeDeletedProperty = switchButtonProperty;
            }
            //break;
        }
        [self.selectedWiFiClientProperty removeObject:toBeDeletedProperty];
    }
    
    [self.delegate updateWifiClientsButtonsPropertiesArray:self.selectedWiFiClientProperty];//rushabh
}

//rushabh
-(void)storeWiFiClientProperty:(int)deviceId index:(int)index matchData:(NSString*)MAC withEventType:(NSString *)eventType{
    SFIButtonSubProperties *highlightedButtonProperties = [self addSubPropertiesFordeviceID:deviceId index:index matchData:MAC andEventType:eventType];//here index 0 constant for wificlient - Mas - index we are setting in properties it self
    [self.selectedWiFiClientProperty addObject:highlightedButtonProperties];
}
//rushabh

-(SFIButtonSubProperties*) addSubPropertiesFordeviceID:(sfi_id)deviceID index:(int)index matchData:(NSString*)matchData andEventType:(NSString *)eventType{ //overLoaded
     SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
     subProperties.deviceId = deviceID;
     subProperties.index = index;
     subProperties.matchData = matchData;
     subProperties.eventType = eventType;
 
     return subProperties;
 }


@end
