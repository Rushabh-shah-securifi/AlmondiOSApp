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
#import "WeatherPicker.h"
#import "ActionSheetPicker.h"
#import "RuleButton.h"
#import "DimmerButton.h"
#import "SwitchButton.h"
#import "RulesDeviceNameButton.h"
#import "TimeView.h"
#import "RuleTextField.h"
#import "CommonMethods.h"
#import "UICommonMethods.h"
#import "RuleSceneUtil.h"
#import "GenericIndexValue.h"
#import "GenericIndexClass.h"
#import "GenericValue.h"
#import "Device.h"
#import "DeviceKnownValues.h"
#import "Slider.h"
#import "HueColorPicker.h"
#import "labelAndCheckButtonView.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "TriDimBtn.h"
#import "ColorComponentView.h"
#import "SliderComponentView.h"

@interface AddTriggerAndAddAction ()<RulesHueDelegate,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource,UITextFieldDelegate,TimeViewDelegate,HueColorPickerDelegate,DimmerButtonDelegate,ColorComponentViewDelegate, SliderComponentViewDelegate>
@property (nonatomic, strong)NSMutableArray *triggers;
@property (nonatomic, strong)NSMutableArray *actions;
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
DimmerButton *dimerButton;
labelAndCheckButtonView *labelView;

-(id)initWithParentView:(UIView*)parentView deviceIndexScrollView:(UIScrollView*)deviceIndexScrollView deviceListScrollView:(UIScrollView*)deviceListScrollView triggers:(NSMutableArray*)triggers actions:(NSMutableArray*)actions isScene:(BOOL)isScene{
    if(self == [super init]){
        isPresentHozPicker = NO;
        isPresentHozPicker = NO;
        newPickerValue = [NSString new];
        
        self.parentView = parentView;
        self.deviceIndexButtonScrollView = deviceIndexScrollView;
        self.deviceListScrollView = deviceListScrollView;
        self.triggers = triggers;
        self.actions = actions;
        self.isScene = isScene;
    }
    return self;
}

-(void)addDeviceNameList:(BOOL)isTrigger{
    self.isTrigger = isTrigger;
    //clear view
    NSArray *viewsToRemove = [self.deviceListScrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]])
            [v removeFromSuperview];
    }
    int xVal = 15;
    
    xVal = [self addDeviceName:@"Mode" deviceID:1 deviceType:0 xVal:xVal];
    if(self.isTrigger && !self.isScene){
        xVal = [self addDeviceName:@"Time" deviceID:0 deviceType:SFIDeviceType_BinarySwitch_0 xVal:xVal];
        xVal = [self addDeviceName:@"Network Devices" deviceID:0 deviceType:SFIDeviceType_WIFIClient xVal:xVal];
        xVal = [self addDeviceName:@"Weather" deviceID:-1 deviceType:SFIDeviceType_Weather xVal:xVal];
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Device *device in toolkit.devices){
        if([RuleSceneUtil showGenericDevice:device.type isTrigger:self.isTrigger isScene:self.isScene])
            xVal = [self addDeviceName:device.name deviceID:device.ID deviceType:device.type xVal:xVal];
    }
    if(!self.isTrigger){
        xVal = [self addDeviceName:@"Reboot Almond" deviceID:1 deviceType:SFIDeviceType_REBOOT_ALMOND xVal:xVal];
    }
    self.deviceListScrollView.contentSize = CGSizeMake(xVal +10,self.deviceListScrollView.contentSize.height);
    [self.deviceIndexButtonScrollView flashScrollIndicators];
}

- (int)addDeviceName:(NSString *)deviceName deviceID:(int)deviceID deviceType:(unsigned int)deviceType  xVal:(int)xVal {
    double deviceButtonHeight = self.deviceListScrollView.frame.size.height;
    CGRect textRect = [UICommonMethods adjustDeviceNameWidth:deviceName fontSize:deviceNameFontSize maxLength:deviceNameMaxLength];
    CGRect frame = CGRectMake(xVal, 0, textRect.size.width + 15, deviceButtonHeight);
    RulesDeviceNameButton *deviceButton = [[RulesDeviceNameButton alloc]initWithFrame:frame];
    [deviceButton deviceProperty:self.isTrigger deviceType:deviceType deviceName:deviceName deviceId:deviceID isScene:self.isScene];
    
    if([deviceName isEqualToString:@"Time"])
        [deviceButton addTarget:self action:@selector(TimeEventClicked:) forControlEvents:UIControlEventTouchUpInside];
    else if([deviceName isEqualToString:@"Network Devices"]){
        [deviceButton addTarget:self action:@selector(wifiClientsClicked:) forControlEvents:UIControlEventTouchUpInside];}
    else //includes mode, weather, reboot and devices
        [deviceButton addTarget:self action:@selector(onDeviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceListScrollView addSubview:deviceButton];
    
    return xVal + textRect.size.width +15;
}


-(void)TimeEventClicked:(id)sender{
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:sender];
    self.timeView = [[TimeView alloc]init];
    //    self.timeView.ruleTime = self.ruleTime;
    self.timeView.delegate = self;
    self.timeView.ruleTime = [self getRuleTime];
    self.timeView.deviceIndexButtonScrollView = self.deviceIndexButtonScrollView;
    
    [self.timeView addTimeView];
    
}

-(void)wifiClientsClicked:(RulesDeviceNameButton*)deviceButton{
    self.currentClickedButton = deviceButton;
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:deviceButton];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    int i =0;
    NSArray *clientsCopy = [toolkit.clients copy];
    for(Client *connectedClient in clientsCopy){
        if(connectedClient.deviceUseAsPresence){
            int yScale = ROW_PADDING + (ROW_PADDING+frameSize)*i;
            [self addClientNameLabel:connectedClient.name yScale:yScale];
            
            NSArray *genericIndexValues = [RuleSceneUtil getGenericIndexValueArrayForID:deviceButton.deviceId type:SFIDeviceType_WIFIClient isTrigger:self.isTrigger isScene:self.isScene triggers:self.triggers action:self.actions];
            
            GenericIndexValue *genericIndexVal = genericIndexValues[0];
            NSDictionary *genericValueDict = genericIndexVal.genericIndex.values;
            for(NSString *value in genericValueDict){
                GenericValue *gVal = genericValueDict[value];
                gVal.value = connectedClient.deviceMAC;
            }
            [self addMyButtonwithYScale:yScale withDeviceIndex:genericIndexValues deviceId:connectedClient.deviceID.intValue deviceType:SFIDeviceType_WIFIClient deviceName:connectedClient.name];
            i++;
        }
    }
    CGSize scrollableSize = CGSizeMake(self.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*i + ROW_PADDING + 20);
    [self.deviceIndexButtonScrollView setContentSize:scrollableSize];
    [self.deviceIndexButtonScrollView flashScrollIndicators];
    self.deviceIndexButtonScrollView.showsVerticalScrollIndicator = YES;
}


-(void)onWeatherClick:(RulesDeviceNameButton*)weatherBtn{
    self.currentClickedButton = weatherBtn;
    [self resetViews];
    [self toggleHighlightForDeviceNameButton:weatherBtn];
    UIView *pickerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , self.deviceListScrollView.frame.size.width, 10)];
    [self.parentView addSubview:pickerView];

    
   NSArray *rows = @[@[NSLocalizedString(@"AddTriggerAction Day", @"Day"), NSLocalizedString(@"night", @"Night")],@[@"C", @"Db", @"D", @"Eb", @"E", @"F", @"Gb", @"G", @"Ab", @"A", @"Bb", @"B"]];
    NSArray *initialSelection = @[@2, @4];
    [ActionSheetMultipleStringPicker showPickerWithTitle:NSLocalizedString(@"AddTriggerAction Select scale", @"Select scale")
                                                    rows:rows
                                        initialSelection:initialSelection
                                               doneBlock:^(ActionSheetMultipleStringPicker *picker,
                                                           NSArray *selectedIndexes,
                                                           NSArray *selectedValues) {
                                                   NSLog(@"%@", selectedIndexes);
                                                   NSLog(@"%@", [selectedValues componentsJoinedByString:@", "]);
                                               }
                                             cancelBlock:^(ActionSheetMultipleStringPicker *picker) {
                                                 NSLog(@"picker = %@", picker);
                                             } origin:(UIView *)pickerView];

    // You can also use self.view if you don't have a sender
    
}

-(void)addClientNameLabel:(NSString*)clientName yScale:(int)yScale{
    UILabel *clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yScale-15, self.parentView.frame.size.width, 14)];
    clientNameLabel.text = clientName;
    clientNameLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:12];
    clientNameLabel.backgroundColor = [UIColor clearColor];
    clientNameLabel.textAlignment = NSTextAlignmentCenter;
    clientNameLabel.textColor = [UIColor lightGrayColor];
    [self.deviceIndexButtonScrollView addSubview:clientNameLabel];
    
}

-(void)onDeviceButtonClick:(RulesDeviceNameButton *)deviceBtn{
    [self resetViews];
    self.currentClickedButton = deviceBtn;
    deviceBtn.selected = YES;
    //toggeling
    [self toggleHighlightForDeviceNameButton:deviceBtn];
    
    [self createDeviceIndexesLayoutForDeviceId:deviceBtn.deviceId deviceType:deviceBtn.deviceType deviceName:deviceBtn.deviceName];
}


-(void)resetViews{
    self.deviceIndexButtonScrollView.hidden = NO;
    
    //clear view
    NSArray *viewsToRemove = [self.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]]) { //to avoid removing scroll indicators
            [v removeFromSuperview];
        }
    }
}

-(void)toggleHighlightForDeviceNameButton:(RulesDeviceNameButton *)currentButton{
    UIScrollView *scrollView = self.deviceListScrollView;
    for(RulesDeviceNameButton *button in [scrollView subviews]){
        if([button isKindOfClass:[UIImageView class]]){
            continue;
        }
        button.selected = NO;
    }
    currentButton.selected = YES;
    
}

//on devicelist button click, calling this method
-(void) createDeviceIndexesLayoutForDeviceId:(int)deviceId deviceType:(int)deviceType deviceName:(NSString*)deviceName{
    NSLog(@"");
    NSArray *genericIndexValues = [RuleSceneUtil getGenericIndexValueArrayForID:deviceId type:deviceType isTrigger:self.isTrigger isScene:_isScene triggers:self.triggers action:self.actions];
    
    if(deviceType == SFIDeviceType_NestThermostat_57){
        genericIndexValues = [RulesNestThermostat handleNestThermostat:deviceId genericIndexValues:genericIndexValues modeFilter:_isScene triggers:_triggers];
    }else if(deviceType == SFIDeviceType_HueLamp_48){
        genericIndexValues = [RulesHue handleHue:deviceId genericIndexValues:genericIndexValues modeFilter:self.isScene triggers:self.triggers];
    }else if(deviceType == SFIDeviceType_AlmondSiren_63){
        genericIndexValues = [self handleSiren:deviceId genericIndexValues:genericIndexValues modeFilter:self.isScene triggers:self.triggers];
    }
    
    else if(deviceType == SFIDeviceType_Weather){
        genericIndexValues =[self handleWeather:deviceId genericIndexValues:genericIndexValues triggers:self.triggers];
    }

    NSDictionary *genericIndexValDic = [RuleSceneUtil getIndexesDicForArray:genericIndexValues isTrigger:self.isTrigger isScene:self.isScene];
    int numberOfCells = (int)[self maxCellId:genericIndexValDic];
    NSLog(@"GenericIndexValueDict after: %@", genericIndexValDic);
    
    if(deviceType == SFIDeviceType_HueLamp_48){
        self.ruleHueObject = [[RulesHue alloc] initWithPropertiesTrigger:self.triggers action:self.actions isScene:self.isScene];
        self.ruleHueObject.delegate = self;
        [self.ruleHueObject createHueCellLayoutWithDeviceId:deviceId deviceType:deviceType deviceIndexes:nil deviceName:deviceName scrollView:self.deviceIndexButtonScrollView cellCount:numberOfCells indexesDictionary:genericIndexValDic];
        return;
    }

    NSArray *sortedKeys = [genericIndexValDic.allKeys sortedArrayUsingSelector:@selector(compare:)];
    int j=0;
    for(NSString *row in sortedKeys){
        NSArray *array = genericIndexValDic[row];
        if(array!=nil && array.count>0){
            
            [self addMyButtonwithYScale:ROW_PADDING+(ROW_PADDING+frameSize)*j withDeviceIndex:array deviceId:deviceId deviceType:deviceType deviceName:deviceName];
            if([self shouldDoubleFrame:array])
                j++;
            j++;
        }
    }
    CGSize scrollableSize = CGSizeMake(self.deviceIndexButtonScrollView.frame.size.width,
                                       (frameSize + ROW_PADDING )*j + ROW_PADDING +60);
    
    [self.deviceIndexButtonScrollView setContentSize:scrollableSize];
    [self.deviceIndexButtonScrollView flashScrollIndicators];
    self.deviceIndexButtonScrollView.showsVerticalScrollIndicator = YES;
}
#pragma mark handleWeather
-(NSArray*)handleWeather:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues triggers:(NSMutableArray*)triggers{
    NSLog(@"handle weather");
    NSMutableArray *newGenericIndexValues = [[NSMutableArray alloc] init];
    for(GenericIndexValue *genIndexVal in genericIndexValues){
        GenericIndexValue *newGenericIndexVal = nil;
        if(genIndexVal.index == 2)//condition
            newGenericIndexVal = [self handleConditionIndex:genIndexVal triggers:triggers deviceid:deviceID];
        if(newGenericIndexVal == nil)
            [newGenericIndexValues addObject:genIndexVal];
        else
            [newGenericIndexValues addObject:newGenericIndexVal];
    }
    return newGenericIndexValues;
}

-(GenericIndexValue*)handleConditionIndex:(GenericIndexValue*)genericIndexValue triggers:(NSArray*)triggers deviceid:(int)deviceID{
    GenericIndexClass *newGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexValue.genericIndex];
    
    
    NSDictionary *currentGenericValueDict = genericIndexValue.genericIndex.values;
    
    NSString *matchData = nil;
   
    for(SFIButtonSubProperties *subProperty in self.triggers){
        if(subProperty.deviceType == SFIDeviceType_Weather && subProperty.index == 2){
            matchData = subProperty.matchData;
        }
    }
    NSLog(@"matchData = %@",matchData);
    NSString *value;
    if(matchData == nil){
        value = @"condition";
    }else{
        value = matchData;
    }
    
    NSMutableDictionary *newGenericValueDict = [NSMutableDictionary new];
    
    for(NSString *keyValue in currentGenericValueDict){
        GenericValue *gVal = currentGenericValueDict[keyValue];
        NSLog(@"gval value: %@, subproperty value: %@", gVal.value, matchData);
        if([gVal.value isEqualToString:value]){
            [newGenericValueDict setValue:gVal forKey:keyValue];
            break;
        }
    }
    
    newGenericIndex.values = newGenericValueDict;
    genericIndexValue.genericIndex = newGenericIndex;
    return genericIndexValue;
}

-(BOOL)shouldDoubleFrame:(NSArray*)genericIndexVals{
    int count = 0;
    for(GenericIndexValue *genIndexVal in genericIndexVals){
        count += genIndexVal.genericIndex.values.count;
    }
    if(count >= 5){
        return YES;
    }
    return NO;
}

//huelamp - 58
//    if(deviceType == SFIDeviceType_HueLamp_48){
//        self.ruleHueObject = [[RulesHue alloc] initWithPropertiesTrigger:self.triggers action:self.actions isScene:self.isScene];
//        self.ruleHueObject.delegate = self;
//        [self.ruleHueObject createHueCellLayoutWithDeviceId:deviceId deviceType:deviceType deviceIndexes:deviceIndexes deviceName:deviceName scrollView:self.deviceIndexButtonScrollView cellCount:numberOfCells indexesDictionary:deviceIndexesDict];
//        return;
//    }


-(RulesTimeElement *)getRuleTime{
    for(SFIButtonSubProperties *subProperties in self.triggers){
        if([subProperties.eventType isEqualToString:@"TimeTrigger"]){
            return subProperties.time;
        }
    }
    SFIButtonSubProperties *subProperties=[SFIButtonSubProperties new];
    subProperties.time = [[RulesTimeElement alloc]init];
    subProperties.eventType = @"TimeTrigger";
    subProperties.valid = YES;
    [self.triggers insertObject:subProperties atIndex:0];
    return subProperties.time;
}
- (NSMutableDictionary *)setButtonSelection:(RuleButton *)ruleButton isSlider:(BOOL)isSlider deviceIndex:(SFIDeviceIndex *)deviceIndex deviceId:(int)deviceId matchData:(NSString *)matchData{
    NSMutableDictionary *result= [NSMutableDictionary new];
    
    int count = 0;
    // NSString *matchData=nil;
    NSMutableArray *list=(self.isTrigger)?self.triggers:self.actions;
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
- (BOOL) isAllDigits:(NSString *)string
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && string.length > 0;
}

-(void)showAlert:(NSString *)string{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Oops")  message:string
        delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles: nil];
    [alert show];
}
#pragma mark RuleTextField delegate
- (void)textFieldDidEndEditing:(RuleTextField *)textField{
    
    NSLog(@" textvalue %ld, text: %@",(unsigned long)[textField.text integerValue], textField.text);
    if(textField.text.length == 0)
        [self showAlert:NSLocalizedString(@"TextInput Please Enter Number", @"Please Enter Number")];
    
    else if ([self isAllDigits:textField.text]) {
        int type = dimerButton.subProperties.deviceType;
        if( (type == SFIDeviceType_StandardWarningDevice_21)  && ([textField.text integerValue] >= 65536 || [textField.text integerValue] < 0 )){
            NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 65535");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 65535",locStr]];
            if(self.isTrigger)
                dimerButton.selected = NO;
        }
        else if((type == SFIDeviceType_AlmondBlink_64 || type == SFIDeviceType_AlmondSiren_63) && ([textField.text integerValue] > 99999 || [textField.text integerValue] < 0 )){
            NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 99999");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 99999",locStr]];
            if(self.isTrigger)
                dimerButton.selected = NO;
        }
        else if( dimerButton.subProperties.deviceType == SFIDeviceType_ZWtoACIRExtender_54 && ([textField.text integerValue] > 999 || [textField.text integerValue] < 0 )){
            NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 999");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 999",locStr]];
            if(self.isTrigger)
                dimerButton.selected = NO;
        }else if( dimerButton.subProperties.deviceType == SFIDeviceType_Weather && ([textField.text integerValue] > 9999 || [textField.text integerValue] < 0 )){
            NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 9999");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 9999",locStr]];
            if(self.isTrigger)
                dimerButton.selected = NO;
        }
        else if( dimerButton.subProperties.deviceType == SFIDeviceType_ColorDimmableLight_32 && ([textField.text integerValue] > 9000 || [textField.text integerValue] < 1000 )){
            NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 1000 - 9000");
            [self showAlert:[NSString stringWithFormat:@"%@ 1000 - 9000",locStr]];
            if(self.isTrigger)
                dimerButton.selected = NO;
        }
        else
        {
            NSLog(@"textfield text %@",textField.text);
            newPickerValue = textField.text;
            textField.subProperties.matchData = textField.text;
          
             if(!self.isTrigger){
                 [self.actions addObject:[textField.subProperties createNew]];
                 [self.delegate updateTriggerAndActionDelegatePropertie:!self.isTrigger];
                 [self setActionButtonCount:dimerButton isSlider:YES];
                 dimerButton.selected = YES;
             }
             else{
                
                 NSLog(@"onSwitchButtonClick - istrigger");
                if (dimerButton.selected)
                 [self.triggers addObject:textField.subProperties];
//                 else
//                     [self removeTriggerIndex:textField.subProperties.index buttonId:textField.subProperties.index deviceType:textField.subProperties.deviceType matchData:textField.text];
                 
                  [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
             }
   
        }

    }
    else {
        [self showAlert:NSLocalizedString(@"TextInput Please enter numbers only", @"Please enter numbers only")];
        // ( or ) are present
    }
    
}
- (BOOL)textFieldShouldEndEditing:(RuleTextField *)textField{
    return YES;
}
-(BOOL)textFieldShouldReturn:(RuleTextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)onStdWarnDimmerButtonClick:(id)sender{
    NSLog(@"onStdWarnDimmerButtonClick ::");
    DimmerButton* dimmer = (DimmerButton *)sender;
    dimmer.selected = YES;
    [dimmer.textField resignFirstResponder];
    [self setActionButtonCount:dimmer isSlider:YES];
}
- (void)textFieldDidBeginEditing:(RuleTextField *)textField {
    if(self.isTrigger || self.isScene)
        dimerButton.selected = !dimerButton.selected;
    
    if (!dimerButton.selected && (self.isTrigger || self.isScene)){
        [self removeTriggerIndex:textField.subProperties.index buttonId:textField.subProperties.deviceId deviceType:textField.subProperties.deviceType matchData:textField.text];
        [textField resignFirstResponder];
    }
    
    textField.placeholder = @"";
    textField.text = @"";
}

- (void)buildDimButton:(GenericIndexValue *)genericIndexVal gVal:(GenericValue*)gVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view {
    DimmerButton *dimbtn=[[DimmerButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,0 , dimFrameWidth, dimFrameHeight)];
    dimbtn.delegate = self;
    dimbtn.tag=i;
//    dimbtn.valueType=deviceIndex.valueType;
    dimbtn.minValue = genericIndexVal.genericIndex.formatter.min;
    dimbtn.maxValue = genericIndexVal.genericIndex.formatter.max;
    dimbtn.factor = genericIndexVal.genericIndex.formatter.factor;
    dimbtn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:genericIndexVal.index matchData:gVal.iconText andEventType:nil deviceName:deviceName deviceType:deviceType];
    if(deviceType == SFIDeviceType_Weather)
        dimbtn.subProperties.type = @"WeatherTrigger";
//    if(self.isTrigger){
//        dimbtn.dimbutton.minValue = genericIndexVal.genericIndex.formatter.min;
//        dimbtn.dimbutton.maxValue = genericIndexVal.genericIndex.formatter.max;
//        dimbtn.dimbutton.factor=genericIndexVal.genericIndex.formatter.factor;
//        dimbtn.dimbutton.subProperties = [self addSubPropertiesFordeviceID:deviceId index:genericIndexVal.index matchData:gVal.iconText andEventType:nil deviceName:deviceName deviceType:deviceType];
//            [dimbtn.dimbutton addTarget:self action:@selector(onDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    else
    [dimbtn addTarget:self action:@selector(onDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [dimbtn setupValues:gVal.iconText Title:gVal.displayText suffix:genericIndexVal.genericIndex.formatter.units isTrigger:self.isTrigger isScene:self.isScene];
    //NSMutableDictionary *result=[self setButtonSelection:dimbtn isSlider:YES deviceIndex:deviceIndex deviceId:deviceId matchData:dimbtn.subProperties.matchData];
    dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                dimbtn.center.y);
    dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
    [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
    dimbtn.selected=[self setActionButtonCount:dimbtn isSlider:YES];
    if(self.isTrigger)
        [self getSelectedMatchData:dimbtn.subProperties];
    [view addSubview:dimbtn];
}

-(void)getSelectedMatchData:(SFIButtonSubProperties*)subProperty{
    NSMutableArray *list=self.isTrigger?self.triggers:self.actions;
    for(SFIButtonSubProperties *buttonSubProperty in list){
        if(buttonSubProperty.deviceId == subProperty.deviceId && buttonSubProperty.index == subProperty.index){
            subProperty.matchData = buttonSubProperty.matchData;
        }
    }
}

-(void)setSelectedCondition:(SFIButtonSubProperties*)subProperty{
    NSMutableArray *list=self.isTrigger?self.triggers:self.actions;
    for(SFIButtonSubProperties *buttonSubProperty in list){
        if(buttonSubProperty.deviceId == subProperty.deviceId && buttonSubProperty.index == subProperty.index){
            buttonSubProperty.condition = subProperty.condition;
            [self updateArray];
        }
        
    }
}
-(void)buildSlider:(GenericIndexValue *)genericIndexValue gVal:(GenericValue *)gVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view{
    SFIButtonSubProperties *subproperties = [self addSubPropertiesFordeviceID:deviceId index:genericIndexValue.index matchData:gVal.value andEventType:nil deviceName:deviceName deviceType:deviceType];
    SliderComponentView *colComp = [[SliderComponentView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 15) lableTitle:@"Brightness" isScene:self.isScene list:self.isTrigger?self.triggers:self.actions subproperties:subproperties genricIndexVal:genericIndexValue];
    colComp.delegate = self;
    [view addSubview:colComp];
}

-(void)buildColorComponent:(GenericIndexValue *)genericIndexValue gVal:(GenericValue *)gVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view{
    SFIButtonSubProperties *subproperties = [self addSubPropertiesFordeviceID:deviceId index:genericIndexValue.index matchData:gVal.value andEventType:nil deviceName:deviceName deviceType:deviceType ];
    ColorComponentView *colComp = [[ColorComponentView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 15) setUpValue:@"Hue" ButtonTitle:NSLocalizedString(@"select", @"Select") andIsScene:self.isScene list:self.isTrigger?self.triggers:self.actions subproperties:subproperties genricIndexVal:genericIndexValue];

    colComp.delegate = self;
    [view addSubview:colComp];
}

-(void)buildHueColorPicker:(GenericIndexValue *)genericIndexValue gVal:(GenericValue *)gVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view{
    labelView = [[labelAndCheckButtonView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, 20)];
    labelView.isScene = self.isScene;
    [labelView setUpValues:genericIndexValue.genericIndex.groupLabel withSelectButtonTitle:NSLocalizedString(@"select", @"Select")];
    [labelView.selectButton addTarget:self action:@selector(onHueColorPickerSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    HueColorPicker *huePicker = [[HueColorPicker alloc]initWithFrame:CGRectMake(0, 20, view.frame.size.width, view.frame.size.height -20) color:[SFIColors ruleOrangeColor] genericIndexValue:genericIndexValue];
    huePicker.subProperties = [self addSubPropertiesFordeviceID:deviceId index:genericIndexValue.index matchData:gVal.value andEventType:nil deviceName:deviceName deviceType:deviceType];
    huePicker.delegate = self;
    [view addSubview:labelView];
    [view addSubview:huePicker];
}

#pragma mark delegate colorComponent
-(void)subpropertiesUpdate:(SFIButtonSubProperties*)subproperties isSelected:(BOOL)isSelected{
    if(self.isScene){
        [self removeTriggerIndex: subproperties.index buttonId:subproperties.deviceId deviceType:subproperties.deviceType matchData:@""];
        if(isSelected){
            [self.triggers addObject:subproperties];
        }
        [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
    }
    else{
        [self.actions addObject:[subproperties createNew]];
        [self.delegate updateTriggerAndActionDelegatePropertie:!self.isTrigger];
    }
}

- (void)buildTextButton:(GenericIndexValue *)genericIndexValue gVal:(GenericValue *)gVal deviceType:(int)deviceType deviceName:(NSString *)deviceName deviceId:(int)deviceId i:(int)i view:(UIView *)view indexName:(NSString*)indexName{
    NSLog(@"indexname = %@ ",indexName);
    DimmerButton *dimbtn=[[DimmerButton alloc]initWithFrame:CGRectMake(view.frame.origin.x,0 , dimFrameWidth, dimFrameHeight)];
    dimbtn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:
                            genericIndexValue.index matchData:gVal.value andEventType:nil deviceName:deviceName deviceType:deviceType];
    
    if(deviceType == SFIDeviceType_Weather)
        dimbtn.subProperties.type = @"WeatherTrigger";
    dimbtn.delegate = self;
    
    [dimbtn addTarget:self action:@selector(onStdWarnDimmerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [dimbtn setUpTextField:gVal.displayText displayText:indexName suffix:@"" isScene:self.isScene isTrigger:self.isTrigger]; // ?
    dimbtn.textField.delegate = self;
    dimbtn.textField.returnKeyType = UIReturnKeyDone;
    dimbtn.center = CGPointMake(view.bounds.size.width/2,
                                dimbtn.center.y);
    dimbtn.frame=CGRectMake(dimbtn.frame.origin.x + ((i-1) * (dimFrameWidth/2))+textHeight/2, dimbtn.frame.origin.y, dimbtn.frame.size.width, dimbtn.frame.size.height);
    [self shiftButtonsByWidth:dimFrameWidth View:view forIteration:i];
    dimbtn.isTrigger = self.isTrigger;
    dimerButton = dimbtn;
    dimbtn.selected=[self setActionButtonCount:dimbtn isSlider:YES];
    
    [view addSubview:dimbtn];
    
}

- (void)buildSwitchButton:(GenericIndexValue *)genericIndexValue deviceType:(int)deviceType deviceName:(NSString *)deviceName gVal:(GenericValue *)gVal deviceId:(int)deviceId i:(int)i view:(UIView *)view buttonY:(float)buttonY{
    
    SwitchButton *btnBinarySwitchOn = [[SwitchButton alloc] initWithFrame:CGRectMake(0,buttonY, indexButtonFrameSize, indexButtonFrameSize)];
    [view addSubview:btnBinarySwitchOn];
    btnBinarySwitchOn.tag = i;
//    btnBinarySwitchOn.valueType=deviceIndex.valueType;
    btnBinarySwitchOn.subProperties = [self addSubPropertiesFordeviceID:deviceId index:genericIndexValue.index matchData:gVal.value andEventType:gVal.eventType deviceName:deviceName deviceType:deviceType];
    NSLog(@"gval.value: %@, icon: %@", gVal.value, gVal.icon);
    btnBinarySwitchOn.deviceType = deviceType;
    
    if(deviceType == SFIDeviceType_REBOOT_ALMOND){
        btnBinarySwitchOn.subProperties.type = @"NetworkResult";
    }else if(deviceType == SFIDeviceType_Weather)
        btnBinarySwitchOn.subProperties.type = @"WeatherTrigger";
        
    [btnBinarySwitchOn addTarget:self action:@selector(onSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    if(gVal.icon != nil)
    [btnBinarySwitchOn setupValues:[UIImage imageNamed:gVal.icon] topText:nil bottomText:gVal.displayText isTrigger:self.isTrigger isDimButton:NO insideText:gVal.displayText isScene:self.isScene];
    
    //set perv. count and highlight
    
    btnBinarySwitchOn.selected=[self setActionButtonCount:btnBinarySwitchOn isSlider:NO];
    
    btnBinarySwitchOn.center = CGPointMake(view.bounds.size.width/2,
                                           btnBinarySwitchOn.center.y);
    
    btnBinarySwitchOn.frame = [self getNewFrameForPosition:i button:btnBinarySwitchOn];
    
    int btnWidth = frameSize;
    int j;
    j = i>=5? 5: 1;
    for (; j<i; j++) {
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
}

-(CGRect)getNewFrameForPosition:(int)i button:(SwitchButton*)btnBinarySwitchOn{
    if(i >=5){
        i = i - 4;
    }
    return CGRectMake(btnBinarySwitchOn.frame.origin.x + ((i-1) * (frameSize/2))+textHeight/2 ,
                      btnBinarySwitchOn.frame.origin.y,
                      btnBinarySwitchOn.frame.size.width,
                      btnBinarySwitchOn.frame.size.height);
}

- (UIView *)addMyButtonwithYScale:(int)yScale withDeviceIndex:(NSArray *)deviceIndexValues deviceId:(int)deviceId deviceType:(int)deviceType deviceName:(NSString*)deviceName{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            self.parentView.frame.size.width,
                                                            indexButtonFrameSize)];
    [self.deviceIndexButtonScrollView addSubview:view];
    int i=0;
    
    for (GenericIndexValue *indexValue in deviceIndexValues) {
        NSLog(@"yscale index: %d", indexValue.index);
        GenericIndexClass *genericIndex =indexValue.genericIndex;
        
        NSDictionary *genericValueDic;
        if(genericIndex.values == nil){
            genericValueDic = [self formatterDict:genericIndex];
            NSLog(@"genericValueDic val = %@",genericValueDic);
        }else{
            genericValueDic = genericIndex.values;
        }
        NSArray *genericValueKeys = genericValueDic.allKeys;
        
        for (NSString *value in genericValueKeys) {
            GenericValue *genericVal = genericValueDic[value];
            if(![RuleSceneUtil showGenericValue:genericVal isScene:_isScene isTrigger:self.isTrigger])
                continue;
            i++;
            NSLog(@"genericIndex.ID = %@",genericIndex.ID);
            NSLog(@"layouttype %@",genericIndex.layoutType );
            NSString *indexName = [genericValueDic.allKeys objectAtIndex:0] == nil?genericIndex.groupLabel:[genericValueDic.allKeys objectAtIndex:0];
            
            if  ([genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"]){
                indexName = [indexName isEqualToString:@"0"]?genericIndex.groupLabel:indexName;
                [self buildTextButton:indexValue gVal:genericVal deviceType:deviceType deviceName:deviceName deviceId:deviceId i:i view:view indexName:indexName];
                break;// not allowing more than one time paintion of textButton
            }
            else if ([genericIndex.layoutType isEqualToString:@"HueColorPicker"]){
                [self buildHueColorPicker:indexValue gVal:genericVal deviceType:deviceType deviceName:deviceName deviceId:deviceId i:i view:view];
            }
            else if([genericIndex.layoutType isEqualToString:@"HUE"]){
                [self buildColorComponent:indexValue gVal:genericVal deviceType:deviceType deviceName:deviceName deviceId:deviceId i:i view:view];
            }
            else if ([genericIndex.layoutType isEqualToString:@"BrighnessSlider"] || [genericIndex.layoutType isEqualToString:@"HUE_ONLY"]){
                [self buildSlider:indexValue gVal:genericVal deviceType:deviceType deviceName:deviceName deviceId:deviceId i:i view:view];
            }
            else if ([genericIndex.layoutType isEqualToString:SINGLE_TEMP] || [genericIndex.layoutType isEqualToString:SLIDER] || [genericIndex.layoutType isEqualToString:TEXT_VIEW] || [genericIndex.layoutType isEqualToString:@"SLIDER_ICON"])
                [self buildDimButton:indexValue gVal:genericVal deviceType:deviceType deviceName:deviceName deviceId:deviceId i:i view:view];//HUE_ZB
            
            else{
                if(i >= 5){
                    view.frame = CGRectMake(0, yScale, self.parentView.frame.size.width, indexButtonFrameSize * 2);
                    [self buildSwitchButton:indexValue deviceType:deviceType deviceName:deviceName gVal:genericVal deviceId:deviceId i:i view:view buttonY:indexButtonFrameSize];
                }else{
                    [self buildSwitchButton:indexValue deviceType:deviceType deviceName:deviceName gVal:genericVal deviceId:deviceId i:i view:view buttonY:0];
                }
            }
        }
    }
    return view;
}

-(NSDictionary*)formatterDict:(GenericIndexClass*)genericIndex{
    NSLog(@"genericIndex.formatter.min %d",genericIndex.formatter.min);
    NSMutableDictionary *genericValueDic = [[NSMutableDictionary alloc]init];
    [genericValueDic setValue:[[GenericValue alloc]initWithDisplayText:genericIndex.groupLabel iconText:@(genericIndex.formatter.min).stringValue value:@"" excludeFrom:@"" transformedValue:@"0" prefix:@""] forKey:genericIndex.groupLabel];
    return genericValueDic;
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

-(NSInteger)maxCellId:(NSDictionary*)genericIndexValDic{
    return  [[genericIndexValDic allKeys]count];
}

-(SFIButtonSubProperties*) addSubPropertiesFordeviceID:(sfi_id)deviceID index:(int)index matchData:(NSString*)matchData andEventType:(NSString *)eventType deviceName:(NSString*)deviceName deviceType:(int)deviceType{ //overLoaded
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.index = index;
    subProperties.matchData = matchData;
    subProperties.eventType = eventType;
    subProperties.deviceName = deviceName;
    subProperties.deviceType = deviceType;
    subProperties.valid = YES;
    
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
- (void)removeTriggerIndex:(int)buttonIndex buttonId:(sfi_id)buttonId deviceType:(unsigned int)deviceType matchData:(NSString *)matchData{
    NSLog(@"buttonID : %d,devicetype = %d, matchData %@ index %d",buttonId,deviceType,matchData,buttonIndex );
    NSMutableArray *toBeDeletedSubProperties = [[NSMutableArray alloc] init];
    if(deviceType == SFIDeviceType_WIFIClient){
        for(SFIButtonSubProperties *switchButtonProperty in self.triggers){
                       if([switchButtonProperty.matchData isEqualToString:matchData] && (switchButtonProperty.index == buttonIndex)){
                [toBeDeletedSubProperties addObject:switchButtonProperty];
            }
        }

    }
    else if(deviceType == SFIDeviceType_Weather){
        for(SFIButtonSubProperties *switchButtonProperty in self.triggers){
            if(switchButtonProperty.deviceType == SFIDeviceType_Weather && switchButtonProperty.index == buttonIndex){
                [toBeDeletedSubProperties addObject:switchButtonProperty];
            }
        }
    }
    else{
        for(SFIButtonSubProperties *switchButtonProperty in self.triggers){
            NSLog(@"IndexID : %d,devicetype = %d, matchData %@ dviceID %d",switchButtonProperty.index,switchButtonProperty.deviceType,switchButtonProperty.matchData,switchButtonProperty.deviceId );

            if((switchButtonProperty.deviceType == deviceType) && (switchButtonProperty.deviceId == buttonId) && (switchButtonProperty.index == buttonIndex)){
                NSLog(@"inside");
                [toBeDeletedSubProperties addObject:switchButtonProperty];
            }
        }
    }
    [self.triggers removeObjectsInArray:toBeDeletedSubProperties];
    NSLog(@"self triggers count: %ld", (unsigned long)self.triggers.count);
}

- (BOOL)setActionButtonCount:(RuleButton *)indexButton isSlider:(BOOL)isSlider{
    int buttonClickCount = 0;
    BOOL selected=NO;
    NSMutableArray *list=self.isTrigger?self.triggers:self.actions;
    if(indexButton.subProperties.deviceType == SFIDeviceType_WIFIClient){
        for(SFIButtonSubProperties *dimButtonProperty in list){
            if([dimButtonProperty.matchData isEqualToString:indexButton.subProperties.matchData] && (dimButtonProperty.index == indexButton.subProperties.index) && [dimButtonProperty.eventType isEqualToString:indexButton.subProperties.eventType]){
                selected=YES;
            }
        }
    }
    else{
        for(SFIButtonSubProperties *dimButtonProperty in list){
            if(dimButtonProperty.deviceId==indexButton.subProperties.deviceId && dimButtonProperty.index==indexButton.subProperties.index && [CommonMethods compareEntry:isSlider matchData:indexButton.subProperties.matchData eventType:indexButton.subProperties.eventType buttonProperties:dimButtonProperty]){
                buttonClickCount++;
                selected=YES;
                [indexButton setNewValue:dimButtonProperty.displayedData subProperties:dimButtonProperty];
            }
        }
    }
    if(selected &&!self.isTrigger)
        [indexButton setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    return selected;
}

-(void)onSwitchButtonClick:(id)sender{
    NSLog(@"onSwitchButtonClick trigger count %ld",self.triggers.count);
    if(isPresentHozPicker == YES){
        [picker removeFromSuperview];
    }
    
    SwitchButton * indexSwitchButton = (SwitchButton *)sender;
    
    sfi_id buttonId = indexSwitchButton.subProperties.deviceId;
    int buttonIndex = indexSwitchButton.subProperties.index;
    NSString *matchData = indexSwitchButton.subProperties.matchData;
    if(!self.isTrigger){
        indexSwitchButton.selected = YES ;
        [self.actions addObject:[indexSwitchButton.subProperties createNew]];
        [self.delegate updateTriggerAndActionDelegatePropertie:!self.isTrigger];
    }else{
        NSLog(@"onSwitchButtonClick - istrigger");
        [self toggleTriggerIndex:buttonIndex superView:[sender superview] indexButton:indexSwitchButton];
        [self removeTriggerIndex:buttonIndex buttonId:buttonId deviceType:indexSwitchButton.subProperties.deviceType matchData:matchData];
        if (indexSwitchButton.selected)
            [self.triggers addObject:indexSwitchButton.subProperties];
        
        
        if(self.isScene && indexSwitchButton.subProperties.deviceType == SFIDeviceType_NestThermostat_57 && indexSwitchButton.subProperties.index == 2){
            [RulesNestThermostat removeTemperatureIndexes:indexSwitchButton.subProperties.deviceId mode:indexSwitchButton.subProperties.matchData entries:self.triggers];
            [self.delegate redrawDeviceIndexView:indexSwitchButton.subProperties.deviceId clientEvent:@""];
        }else if(self.isScene && indexSwitchButton.subProperties.deviceType == SFIDeviceType_AlmondSiren_63 && indexSwitchButton.subProperties.index == 1){
            [self removeSirenEntriesOnDisable:buttonId value:matchData entries:self.triggers];
            [self.delegate redrawDeviceIndexView:indexSwitchButton.subProperties.deviceId clientEvent:@""];
        }
        
        
        else if(self.isScene && indexSwitchButton.subProperties.deviceType == SFIDeviceType_HueLamp_48 && indexSwitchButton.subProperties.index == 2){
            [self.delegate redrawDeviceIndexView:indexSwitchButton.subProperties.deviceId clientEvent:@""];
        }else if(indexSwitchButton.subProperties.deviceType == SFIDeviceType_Weather){
            if (indexSwitchButton.selected){
                    [self presentWeatherPicker:indexSwitchButton];
                    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
            }
                else{
                    [self.delegate redrawDeviceIndexView:indexSwitchButton.subProperties.deviceId clientEvent:@""];
                }
            
        }else{
            [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
        }
        
    }
    [self setActionButtonCount:indexSwitchButton isSlider:NO];
}

-(void)presentWeatherPicker:(SwitchButton *)indexSwitchButton{
    SFIButtonSubProperties *subproperties = indexSwitchButton.subProperties;
    NSArray *allKeys = [[NSArray alloc]init];
    NSMutableArray *displayArr = [[NSMutableArray alloc]init];
    NSMutableArray *valueArr = [[NSMutableArray alloc]init];
    NSArray *rows ;
    NSLog(@"index wth : %d",subproperties.index);
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if(subproperties.index == 2){
        GenericIndexClass *genericIndexObj = [toolkit.genericIndexes valueForKey:@"-34"];
        allKeys = genericIndexObj.values.allKeys;
        NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        for (NSString *key in sortedKeys) {
            GenericValue *gVal = [genericIndexObj.values valueForKey:key];
            if([key isEqualToString:@"condition"])
                continue;
            [displayArr addObject:gVal.displayText];
            [valueArr addObject:key];
        }
        rows = @[displayArr];
    }
    
    if(subproperties.index == 1){
        for(int i=0;i<60;i++){
            [displayArr addObject:@(i).stringValue];
        }
rows = @[displayArr,@[NSLocalizedString(@"before", @"Before"),NSLocalizedString(@"after", @"After")]];
    }
    
//    valueArr enumerateObjectsUsingBlock:
    NSLog(@"subproperties match data %@",subproperties.matchData);
    NSString *title = (subproperties.index == 2)?NSLocalizedString(@"sunnycondition", @"Condition"):NSLocalizedString(@"Minutes", @"Minutes");
    NSArray *initialSelection = @[@0,@0];
    [ActionSheetMultipleStringPicker showPickerWithTitle:title
                                                    rows:rows
                                        initialSelection:initialSelection
                                               doneBlock:^(ActionSheetMultipleStringPicker *picker,
                                                           NSArray *selectedIndexes,
                                                           NSArray *selectedValues) {
                                                   [self onDoneButtonClick:selectedIndexes values:selectedValues property:subproperties display:displayArr values:valueArr];
                                               }
                                             cancelBlock:^(ActionSheetMultipleStringPicker *picker) {
                                                 [self removeTriggerIndex:subproperties.index buttonId:subproperties.deviceId deviceType:indexSwitchButton.subProperties.deviceType matchData:subproperties.matchData];
                                                 [self.delegate redrawDeviceIndexView:subproperties.deviceId clientEvent:@""];
                                                 indexSwitchButton.selected = NO;
                                                 NSLog(@"picker = %@", picker);
                                             } origin:(UIView *)self.parentView];
    NSLog(@"done");

}

-(void)onDoneButtonClick:(NSArray*)selectedIndexes values:(NSArray*)selectedValues property:(SFIButtonSubProperties*)subproperties display:(NSArray*)displayArr values:(NSArray*)valueArr{
    NSLog(@"%@", selectedIndexes);// array of NSString
    NSLog(@"%@", [selectedValues componentsJoinedByString:@", "]);
    NSString *posIndex = [selectedIndexes objectAtIndex:0];
    
    if(selectedIndexes.count == 1){
        subproperties.matchData = [valueArr objectAtIndex:[posIndex integerValue]];
    }
    
    else{
        NSString *pos = [selectedIndexes objectAtIndex:1];
        NSLog(@"subproperty index: %d", subproperties.index);
        if([pos integerValue] == 1)//night and after
        {
            subproperties.delay = [displayArr objectAtIndex:[posIndex integerValue]];
        }
        else{// day and before
            NSLog(@"displayArr %@",displayArr);
            subproperties.delay =[NSString stringWithFormat:@"-%@",[displayArr objectAtIndex:[posIndex integerValue]]];
        }
    }
    
    [self updateWeatherMatchData:subproperties];
    [self.delegate redrawDeviceIndexView:subproperties.deviceId clientEvent:@""];

}

-(void)updateWeatherMatchData:(SFIButtonSubProperties*)subproperties{
    for(SFIButtonSubProperties *properties in self.triggers){
        if(properties.deviceType == SFIDeviceType_Weather && (properties.index == subproperties.index))
        {
            properties.matchData = subproperties.matchData;
            properties.deviceType = SFIDeviceType_Weather;
        }
    }
}
#pragma mark layoutType
-(BOOL)isTextLayout:(NSString*)genericLayout{
    
    return YES;
}


-(void)showPicker:(DimmerButton* )dimmer{
    [self removePickerFromView];
    dimmer.pickerVisibility=YES;
    minValue=(int)dimmer.minValue;
    maxValue=(int)dimmer.maxValue;
    isPresentHozPicker=YES;
    pickerValuesArray2 = [NSMutableArray new];
    for (int i=(int)dimmer.minValue; i<=(int)dimmer.maxValue; i++) {
        [pickerValuesArray2 addObject:[NSString stringWithFormat:@"%d",i]];
    }
    isPresentHozPicker = YES;
    [self horizontalpicker:dimmer];
}

-(void)changeMinMaxValuesOfNestRangeLowHighForIndex:(int)index value:(int)value dimSuperView:(UIView*)superView{
    NSArray *deviceIndexButtons = [superView subviews];
    if(index == 5){
        for (UIView *v in deviceIndexButtons) {
            if ([v isKindOfClass:[DimmerButton class]]) { //to avoid removing scroll indicators
                DimmerButton *dim = (DimmerButton*)v;
                if(dim.subProperties.index == 6){
                    if(dim.subProperties.matchData.intValue - value < 3){
                        [dim setNewValue:@(value+3).stringValue subProperties:dim.subProperties];
                        //                        dim.subProperties.matchData = @(value+3).stringValue;
                        [self updateMatchData:dim.subProperties newValue:@(value+3).stringValue dimButton:dim];
                    }
                }
            }
        }
        
    }else if(index == 6){
        for (UIView *v in deviceIndexButtons) {
            if ([v isKindOfClass:[DimmerButton class]]) { //to avoid removing scroll indicators
                DimmerButton *dim = (DimmerButton*)v;
                if(dim.subProperties.index == 5){
                    if(value - dim.subProperties.matchData.intValue < 3){
                        [dim setNewValue:@(value-3).stringValue subProperties:dim.subProperties];
                        //                        dim.subProperties.matchData = @(value-3).stringValue;
                        [self updateMatchData:dim.subProperties newValue:@(value-3).stringValue dimButton:dim];
                    }
                }
            }
        }
        
    }
    
//    for (UIView *v in deviceIndexButtons) {
//        if ([v isKindOfClass:[DimmerButton class]]) { //to avoid removing scroll indicators
//            DimmerButton *dim = (DimmerButton*)v;
//            if(dim.subProperties.index == 6 && index == 5){
//                if(dim.subProperties.matchData.intValue - value < 3){
//                    [dim setNewValue:@(value+3).stringValue];
//                    [self updateMatchData:dim.subProperties newValue:@(value+3).stringValue];
//                }
//            }else if(dim.subProperties.index == 5 && index == 6){
//                if(value - dim.subProperties.matchData.intValue < 3){
//                    [dim setNewValue:@(value-3).stringValue];
//                    [self updateMatchData:dim.subProperties newValue:@(value-3).stringValue];
//                }
//            }
//        }
//    }
    
    
}


-(void)updateMatchData:(SFIButtonSubProperties *)dimmButtonSubProperty newValue:(NSString*)newValue dimButton:(DimmerButton*)dimBtn{
    NSMutableArray *list=self.isTrigger?self.triggers:self.actions;
    for(SFIButtonSubProperties *buttonSubProperty in list){
        if(buttonSubProperty.deviceId == dimmButtonSubProperty.deviceId && buttonSubProperty.index == dimmButtonSubProperty.index){
            NSLog(@"newvalue: %@", newValue);
            buttonSubProperty.matchData = [dimBtn scaledValue:newValue];
            buttonSubProperty.displayedData = newValue;
        }
    }
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
        newPickerValue=@(dimmer.minValue).stringValue;
    
    SFIButtonSubProperties *newProperty=dimmer.subProperties;
    if(!self.isTrigger){
        newProperty=[dimmer.subProperties createNew];
        newProperty.matchData = [dimmer scaledValue:newPickerValue];
        newProperty.displayedData=newPickerValue;
    }else{
        NSLog(@"dim factor: %f", dimmer.factor);
        dimmer.subProperties.matchData = [dimmer scaledValue:newPickerValue];
        dimmer.subProperties.displayedData = newPickerValue;
    }
    if(dimmer.subProperties.deviceType == SFIDeviceType_NestThermostat_57 && self.isTrigger){
        [self changeMinMaxValuesOfNestRangeLowHighForIndex:dimmer.subProperties.index value:dimmer.subProperties.matchData.intValue dimSuperView:[dimmer superview]];
    }
    [self addObject:newProperty];
    [self setActionButtonCount:dimmer isSlider:YES];
    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
}
-(void)addObject:(SFIButtonSubProperties *)subProperty{
    if(self.isTrigger)
        [self.triggers addObject:subProperty];
    else
        [self.actions addObject:subProperty];
}

-(void)onDimmerButtonClick:(id)sender{
    NSLog(@"onDimmerButtonClick");
    DimmerButton* dimmer = (DimmerButton *)sender;
    
    if(self.isTrigger){
        if(!dimmer.selected){
            [self showPicker:dimmer];
            dimmer.selected=YES;
        }else{
            if(dimmer.pickerVisibility){
                [self removePicker:dimmer];
                newPickerValue = @"";
            }
            else{
                dimmer.selected=NO;
                [self removeTriggerIndex: dimmer.subProperties.index buttonId:dimmer.subProperties.deviceId deviceType:dimmer.subProperties.deviceType matchData:@""];
                [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
            }
            
        }
    }else{
        dimmer.selected=YES;
        if(dimmer.pickerVisibility){
            [self removePicker:dimmer];
            newPickerValue = @"";
        }else
            [self showPicker:dimmer];
        
    }
}

-(void)onHueColorPickerSelectButtonClick:(id)sender{
    NSLog(@"onHueColorPickerSelectButtonClick ");
    if([labelView.genericIndexValue.genericIndex.ID isEqualToString:@"32"])
        [labelView setSelected:YES];
}

#pragma mark horizontalpicker methods
- (void)horizontalpicker:(DimmerButton*)dimButton{
    isPresentHozPicker = YES;
    const int control_height = 30;
    // Picker
    picker = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    picker.tag = 1; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    UIView *parentView = [dimButton superview];
    picker.frame = CGRectMake(self.deviceIndexButtonScrollView.frame.origin.x + 10,  parentView.frame.origin.y + parentView.frame.size.height, self.parentView.frame.size.width -20 , control_height);
    picker.layer.cornerRadius = 4;
    picker.layer.borderWidth = 1.5;
    picker.backgroundColor = [UIColor whiteColor];
    
    if(self.isTrigger && !self.isScene){
        picker.layer.borderColor = [SFIColors ruleBlueColor].CGColor;
        picker.selectedTextColor = [SFIColors ruleBlueColor];
    }
    else{
        picker.layer.borderColor = [SFIColors ruleOrangeColor].CGColor;
        picker.selectedTextColor = [SFIColors ruleOrangeColor];
    }
    picker.elementFont = [UIFont systemFontOfSize:11];
    picker.elementFont = [UIFont fontWithName:@"AvenirLTStd-Roman" size:13];
    picker.textColor = [UIColor blackColor];
    picker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    picker.delegate = self;
    picker.dataSource = self;
   
//    [picker scrollToElement:dimButton.dimValue.intValue animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceIndexButtonScrollView addSubview:picker];
    });
    // width depends on propertyType
    const NSInteger element_width = [self horizontalPickerView:picker widthForElementAtIndex:0];
    SFIPickerIndicatorView1 *indicatorView = [[SFIPickerIndicatorView1 alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    picker.selectionPoint = CGPointMake((picker.frame.size.width) / 2, 0);
    if(self.isTrigger && !self.isScene){
        indicatorView.color1 = [SFIColors ruleBlueColor];
    }
    else{
        indicatorView.color1 = [SFIColors ruleOrangeColor];
    }
    picker.selectionIndicatorView = indicatorView;
     [picker scrollToElement:0 animated:YES];
    
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
    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
}
#pragma mark delegate methods - TimeView
-(void)AddOrUpdateTime{
    [self.delegate updateTriggerAndActionDelegatePropertie:self.isTrigger];
}

#pragma mark siren cases
-(NSArray *)handleSiren:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues modeFilter:(BOOL)modeFilter triggers:(NSMutableArray*)triggers{
    NSLog(@"entries: %@", triggers);
    NSMutableArray *newGenIndexVals = [genericIndexValues mutableCopy];
    if(modeFilter){
        NSString *matchData = nil;
        for(SFIButtonSubProperties *subProperty in triggers){
            if(subProperty.deviceId == deviceID && subProperty.index == 1){
                matchData = subProperty.matchData;
            }
        }
        NSLog(@"siren md: %@", matchData);
        if(matchData == nil)
            return newGenIndexVals;
        
        if([matchData isEqualToString:@"false"]){
            NSMutableArray *toberemoved = [NSMutableArray new];
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index != 1)
                    [toberemoved addObject:genIndexVal];
            }
            [newGenIndexVals removeObjectsInArray:toberemoved];
        }
    }
    NSLog(@"Siren new generic index vals: %@", newGenIndexVals);
    return newGenIndexVals;
}

-(void)removeSirenEntriesOnDisable:(int)deviceID value:(NSString*)value entries:(NSMutableArray*)entries{
    if([value isEqualToString:@"true"])
        return;
    
    NSMutableArray *toBeDeletedEntries = [NSMutableArray new];
    
    for(SFIButtonSubProperties *entry in entries){
        if(entry.deviceId == deviceID && entry.index != 1)
            [toBeDeletedEntries addObject:entry];
    }
    [entries removeObjectsInArray:toBeDeletedEntries];
}

@end