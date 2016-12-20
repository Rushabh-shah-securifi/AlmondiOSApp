//
//  DeviceHeaderView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 10/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DeviceHeaderView.h"
#import "GenericIndexUtil.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "RulesNestThermostat.h"
#import "RuleSceneUtil.h"
#import "Colours.h"
#import "CommonMethods.h"
#import "UIFont+Securifi.h"

@interface DeviceHeaderView()
@property (weak, nonatomic) IBOutlet UIButton *parentrolBtn;
@property (weak, nonatomic) IBOutlet UILabel *label2;


@property (weak, nonatomic) IBOutlet UIImageView *wifiSignalImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceValueImgLable;
@end

@implementation DeviceHeaderView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"DeviceHeaderView" owner:self options:nil];
        [self addSubview:self.view];
        [self stretchToSuperView:self.view];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
    [[NSBundle mainBundle] loadNibNamed:@"DeviceHeaderView" owner:self options:nil];
    [self addSubview:self.view];
    [self stretchToSuperView:self.view];    
    }
    return  self;
}
- (void) stretchToSuperView:(UIView*) view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString *formatTemplate = @"%@:|[view]|";
    view.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSString * axis in @[@"H",@"V"]) {
        NSString * format = [NSString stringWithFormat:formatTemplate,axis];
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        [view.superview addConstraints:constraints];
    }
    
}

-(void)initialize:(GenericParams*)genericParams cellType:(CellType)cellType isSiteMap:(BOOL)enableSiteMap{
    //NSLog(@"headerview - initialize");
    self.genericParams = genericParams;
    self.cellType = cellType;
    [self setUpDeviceCell:enableSiteMap];
}

-(void)setUpDeviceCell:(BOOL)enableSiteMap{
    //NSLog(@"setUPSensorCell");
    self.view.backgroundColor = _genericParams.color;
    self.deviceName.text = self.genericParams.deviceName;
    self.settingButton.alpha = 1;
    self.deviceValue.hidden = NO;
    if(self.cellType == ClientTable_Cell ||  self.cellType == ClientProperty_Cell || self.cellType == ClientEditProperties_cell){
         [self setWiFiSignalIcon];
        self.deviceValue.hidden = NO;
        if(self.cellType == ClientTable_Cell && enableSiteMap){
            self.parentrolBtn.hidden = NO;
            self.deviceValue.hidden = NO;
        }
        
        else{
            self.parentrolBtn.hidden = YES;
            self.deviceValue.hidden = YES;
        }
    }
    else{
        self.parentrolBtn.hidden = YES;
        self.wifiSignalImageView.hidden = YES;
        self.deviceValue.hidden = NO;
    }

    
    [self setTamper];
   
    
    
    int deviceType = [Device getTypeForID:_genericParams.headerGenericIndexValue.deviceID];
    int deviceID = _genericParams.headerGenericIndexValue.deviceID;

    if(self.genericParams.isSensor){
        Device *div = [Device getDeviceForID:deviceID];
        self.label2.text = div.location;
        if(deviceType == SFIDeviceType_NestThermostat_57 || deviceType == SFIDeviceType_NestSmokeDetector_58 ){
            [self handleNestThermostatAndSmokeDectect:deviceType deviceID:deviceID genericValue:_genericParams.headerGenericIndexValue.genericValue];
        }else if(deviceType == SFIDeviceType_MultiLevelSwitch_2){
            [self handleZwaveDimmerType_2];
        }
    }
    
    
    if(_genericParams.headerGenericIndexValue.genericValue.iconText){
        self.deviceImage.hidden = YES;
        self.deviceValueImgLable.hidden = NO;
        self.deviceValueImgLable.attributedText = [CommonMethods getAttributeString:self.genericParams.headerGenericIndexValue.genericValue.iconText fontSize:20 LightFont:NO];
        
        self.deviceValue.text = self.genericParams.headerGenericIndexValue.genericValue.displayText;
    }else{
        self.deviceValueImgLable.hidden = YES;
        self.deviceImage.hidden = NO;
        self.deviceImage.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
        
        if(self.genericParams.isSensor && (deviceType == SFIDeviceType_HueLamp_48 || deviceType == SFIDeviceType_ColorDimmableLight_32)&& [[Device getValueForIndex:2 deviceID:deviceID] isEqualToString:@"true"]){
            self.deviceImage.image = [self.deviceImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            if(deviceType == SFIDeviceType_HueLamp_48)// 0 - 65535 for blink, hue
                [self.deviceImage setTintColor:[UIColor colorFromHexString:[CommonMethods getColorHex:[Device getValueForIndex:3 deviceID:deviceID]]]];
            else //0 - 255 only for color dimmable
                [self.deviceImage setTintColor:[UIColor colorFromHexString:[CommonMethods getDimmableHex:[Device getValueForIndex:3 deviceID:deviceID]]]];
        }
        self.deviceValue.text = self.genericParams.headerGenericIndexValue.genericValue.displayText;
    }
    
    if(self.genericParams.headerGenericIndexValue.genericValue.toggleValue == nil || self.genericParams.headerGenericIndexValue.genericValue.toggleValue.length == 0)
        self.deviceButton.userInteractionEnabled = NO;
    else
        self.deviceButton.userInteractionEnabled = YES;
    
    
    if(self.cellType == ClientTable_Cell)
    {
        Client *client = [Client findClientByID:@(deviceID).stringValue];
        if(client.webHistoryEnable == NO){
            self.parentrolBtn.imageView.image = [UIImage imageNamed:@"icon_history_off"];
            NSLog(@"icon_history_off");
            self.deviceValue.text = @"Web History Off";
            [self.parentrolBtn removeTarget:nil
                                     action:NULL
                           forControlEvents:UIControlEventTouchUpInside];
            [self.parentrolBtn addTarget:self action:@selector(onParentalControllClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            self.parentrolBtn.imageView.image = [UIImage imageNamed:@"icon_history_on"];
            NSLog(@"icon_history_on");
            self.deviceValue.text = @"Web History On";
            [self.parentrolBtn removeTarget:nil
                                     action:NULL
                           forControlEvents:UIControlEventTouchUpInside];
            [self.parentrolBtn addTarget:self action:@selector(onParentalControllClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if(client.is_IoTDeviceType == YES){
            [self.parentrolBtn removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventTouchUpInside];
            [self.parentrolBtn addTarget:self action:@selector(onIoTControllClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            if(client.iot_serviceEnable == YES){
                self.parentrolBtn.imageView.image = [UIImage imageNamed:@"ic_security_black"];
                
                NSLog(@"ic_security_black");
                self.deviceValue.text = @"IoT service on";
            }
            else{
                self.parentrolBtn.imageView.image = [UIImage imageNamed:@"ic_insecure_black"];
                NSLog(@"ic_insecure_black");
                self.deviceValue.text = @"IoT service off";
            }
        }
    }
    
    
}

- (void)onParentalControllClicked:(id)sender {
    [self.delegate patenalControlClickDelegate:self.genericParams];
}
- (void)onIoTControllClicked:(id)sender {
    [self.delegate onIoTControllClickedDelegate:self.genericParams];
}

-(void)resetHeaderView{
    self.deviceName.text = @"";
    self.deviceValue.text = @"";
}

-(void)setTamper{
    self.lowBatteryImgView.hidden = YES;
    self.tamperedImgView.hidden = YES;
    if(self.genericParams.isSensor)
        [self isTamper];
}

-(void)handleZwaveDimmerType_2{
    GenericValue *genericValue = self.genericParams.headerGenericIndexValue.genericValue;
    if(genericValue){
        if([genericValue.value isEqualToString:@"0"]){
            genericValue.icon = @"switch_off";
            genericValue.displayText = NSLocalizedString(@"deviceHeaderView Off", @"Off");
            genericValue.toggleValue = @"100";
        }else{//dimmer
            self.genericParams.headerGenericIndexValue.genericIndex.icon = @"dimmer";
            genericValue.toggleValue = @"0";
        }
    }
    
}
-(void)handleNestThermostatAndSmokeDectect:(int)deviceType deviceID:(int)deviceID genericValue:(GenericValue*)genericValue{
    if(deviceType == SFIDeviceType_NestThermostat_57){
        BOOL isNestOnline = [[Device getValueForIndex:11 deviceID:deviceID] isEqualToString:@"true"];
        BOOL isUsingEmergencyHeat = [[Device getValueForIndex:14 deviceID:deviceID] isEqualToString:@"true"];
//        BOOL isNestOnline = NO;
        if(!isNestOnline){
            genericValue.icon = @"offline_icon";
            genericValue.iconText = nil;//
            genericValue.displayText = NSLocalizedString(@"offline", @"Offline");
            if(deviceType == SFIDeviceType_NestThermostat_57){
                self.tamperedImgView.hidden = NO;
                self.tamperedImgView.image = [UIImage imageNamed:@"nest_offline"];
            }
        }else if(isUsingEmergencyHeat){
            genericValue.displayText = [genericValue.displayText stringByAppendingString:[NSString stringWithFormat:@", %@", NSLocalizedString(@"emergency_heat", @"USING EMERGENCY HEAT")]];
        }
    }else if(deviceType == SFIDeviceType_NestSmokeDetector_58){
        BOOL isSmokeOnline =  [[Device getValueForIndex:5 deviceID:deviceID] isEqualToString:@"true"];
        if(!isSmokeOnline){
            genericValue.icon = @"offline_icon";
            genericValue.iconText = nil;
            genericValue.displayText = NSLocalizedString(@"offline", @"Offline");
            if(deviceType == SFIDeviceType_NestSmokeDetector_58){
                self.tamperedImgView.hidden = NO;
                self.tamperedImgView.image = [UIImage imageNamed:@"nest_offline"];
            }
        }
        else if(isSmokeOnline){
            genericValue.icon = @"nest_protect_icon";
            genericValue.displayText = [self getSmokeStatus:deviceID];
        }
    }
}
-(void)setWiFiSignalIcon{
    NSArray* genericIndexValues;
    int deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    Client *client = [Client findClientByID:@(deviceID).stringValue];
    if(self.cellType == ClientTable_Cell)
    {
        
        if(client.webHistoryEnable == NO){
            self.parentrolBtn.imageView.image = [UIImage imageNamed:@"icon_history_off"];
            
            NSLog(@"icon_history_off");
            
        }
        else{
            self.parentrolBtn.imageView.image = [UIImage imageNamed:@"icon_history_on"];
            NSLog(@"icon_history_on");
            
        }
    }
//    self.label2.text = client.isActive?@"Active":
    genericIndexValues = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:@(deviceID).stringValue];
    NSArray *arr = genericIndexValues;
//    self.genericParams.indexValueList = genericIndexValues;
    
    NSLog(@"self.genericParams.indexValueList count = %ld",(unsigned long)self.genericParams.indexValueList.count);
    for (GenericIndexValue *genericIndexValue in arr) {
        NSLog(@"genericIndexValue.genericIndex.ID %@ value %@",genericIndexValue.genericIndex.ID,genericIndexValue.genericValue.value);

        if([genericIndexValue.genericIndex.ID isEqualToString:@"-16"] && [genericIndexValue.genericValue.value isEqualToString:@"wireless"]){
            self.wifiSignalImageView.hidden = NO;
            self.wifiSignalImageView.image = [UIImage imageNamed:@"wifi_icon"];
            NSLog(@"wifi_icon...");
        }
        else if([genericIndexValue.genericIndex.ID isEqualToString:@"-16"] && ![genericIndexValue.genericValue.value isEqualToString:@"wireless"]){
        self.wifiSignalImageView.hidden = YES;
//        self.wifiSignalImageView.image = [UIImage imageNamed:@"wired-icon"];
            NSLog(@"wired-icon...");
        }
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-13"] && (self.cellType == ClientTable_Cell || self.cellType == ClientProperty_Cell || self.cellType == ClientEditProperties_cell)){
            self.label2.text = genericIndexValue.genericValue.value;
        }
    }
}

-(NSString*)getSmokeStatus:(int)deviceID{
    NSString *status = @"NaN";
    NSString *emergency = NSLocalizedString(@"emergency", @"emergency");
    NSString *warning =  NSLocalizedString(@"warning", @"warning");
    NSString *replace = NSLocalizedString(@"replace", @"replace");
    
    NSString *coAlarm = [Device getValueForIndex:3 deviceID:deviceID];
    NSString *smokeAlarm = [Device getValueForIndex:4 deviceID:deviceID];
    NSString *batteryStat = [Device getValueForIndex:2 deviceID:deviceID];
    
    //NSLog(@"coalarm: %@, smoke: %@", coAlarm, smokeAlarm);
    if([coAlarm isEqualToString:smokeAlarm]){
        status = [coAlarm isEqualToString:@"ok"]? NSLocalizedString(@"ok", @"OK"): [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"smoke_and_co", @"SMOKE & CO"), coAlarm.uppercaseString];
    }else{
        if([coAlarm isEqualToString:emergency])
            status = NSLocalizedString(@"deviceHeaderView CO EMERGENCY", @"CO EMERGENCY");
        else if([smokeAlarm isEqualToString:emergency])
            status = NSLocalizedString(@"smoke_emergency", @"SMOKE EMERGENCY");
        else if([coAlarm isEqualToString:warning])
            status = NSLocalizedString(@"deviceHeaderView CO WARNING", @"CO WARNING");
        else if([smokeAlarm isEqualToString:warning])
            status = NSLocalizedString(@"smoke_warning", @"SMOKE WARNING");
    }
    if([coAlarm isEqualToString:emergency] || [smokeAlarm isEqualToString:emergency]){
        self.tamperedImgView.hidden = NO;
        self.tamperedImgView.image = [UIImage imageNamed:@"icon_tampered_red"];
    }
    else if([coAlarm isEqualToString:warning] || [smokeAlarm isEqualToString:warning]){
        self.tamperedImgView.hidden = NO;
        self.tamperedImgView.image = [UIImage imageNamed:@"icon_tampered_yellow"];
    }
    
    if([batteryStat isEqualToString:replace]){
        self.lowBatteryImgView.hidden = NO;
        self.lowBatteryImgView.image = [UIImage imageNamed:@"low_battery_badge"];
    }
    return status;
}

-(void)addDeviceValueImgLabel:(NSString*)text suffix:(NSString*)suffix{
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:20.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:12.0f],NSBaselineOffsetAttributeName:@(10)} range:NSMakeRange(text.length,suffix.length)];
    [self.deviceValueImgLable setAttributedText:strTemp];
    
}

#pragma mark button click
- (IBAction)settingButtonClicked:(id)sender {
    self.settingButton.alpha = 0.5;
    NSArray* genericIndexValues;
    int deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    if(self.cellType == SensorTable_Cell){
        genericIndexValues = [GenericIndexUtil getDetailListForDevice:deviceID];
        //NSLog(@"gvalues: %@", genericIndexValues);
        if([Device getTypeForID:deviceID] == SFIDeviceType_NestThermostat_57){ //mk move this to util
            genericIndexValues = [RulesNestThermostat handleNestThermostatForSensor:deviceID genericIndexValues:genericIndexValues];
            
        }
        self.genericParams.indexValueList = genericIndexValues;
        [self.delegate delegateDeviceSettingButtonClick:_genericParams];
    }
    else if(self.cellType == ClientTable_Cell){
        genericIndexValues = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:@(deviceID).stringValue];
        self.genericParams.indexValueList = genericIndexValues;
        [self.delegate delegateClientSettingButtonClick:self.genericParams];
        
    }
    else if(self.cellType == SensorEdit_Cell || self.cellType == ClientEditProperties_cell){
        [self.delegate delegateDeviceEditSettingClick];
    }
    else if (self.cellType == ClientProperty_Cell){
        [self.delegate delegateClientPropertyEditSettingClick];
    }
}

- (IBAction)onSensorButtonClicked:(id)sender {
    //NSLog(@"onSensorButtonClicked");
    if(self.cellType == SensorTable_Cell || self.cellType == SensorEdit_Cell){
        //to do change image to load
        [self reloadIconImage];
        [self.delegate toggle:self.genericParams.headerGenericIndexValue];
    }
}
-(void)reloadIconImage{
    self.deviceImage.hidden = NO;
    self.deviceValueImgLable.hidden = YES;
    self.deviceImage.image = [UIImage imageNamed:@"00_wait_icon"];
    self.deviceValue.text = @"Updating device data.\nPlease wait.";
}

-(void)isTamper{
    Device *device = [Device getDeviceForID:self.genericParams.headerGenericIndexValue.deviceID];
    NSArray* genericIndexValues = [GenericIndexUtil getGenericIndexValuesByPlacementForDevice:device placement:@"Badge"];
    
    for(GenericIndexValue *genericIndexValue in genericIndexValues){
        GenericIndexClass *genericIndexObj = genericIndexValue.genericIndex;
        //NSLog(@"genericIndexObj ID %@ ",genericIndexObj.ID);
        if([genericIndexObj.ID isEqualToString:@"9"]){//battery
            if ([genericIndexValue.genericValue.value isEqualToString:@"true"]){
                self.tamperedImgView.hidden = NO;
                self.tamperedImgView.image = [UIImage imageNamed:@"icon_tampered_orange"];
            }
        }
        if([genericIndexObj.ID isEqualToString:@"12"]){//tampered
            if ([genericIndexValue.genericValue.value isEqualToString:@"true"]) {
                self.lowBatteryImgView.hidden = NO;
                self.lowBatteryImgView.image = [UIImage imageNamed:@"low_battery_badge"];
            }
        }
    }
}


@end
