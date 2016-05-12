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

@interface DeviceHeaderView()
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

-(void)initialize:(GenericParams*)genericParams cellType:(CellType)cellType{
    NSLog(@"headerview - initialize");
    self.genericParams = genericParams;
    self.cellType = cellType;
    [self setUpDeviceCell];
}

-(void)setUpDeviceCell{
    NSLog(@"setUPSensorCell");
    self.view.backgroundColor = _genericParams.color;
    self.deviceName.text = self.genericParams.deviceName;
    self.settingButton.alpha = 1;
    [self setTamper];
    
    
    NSLog(@"device id %d, Icon text %@, icon: %@, index id %@, placement %@",_genericParams.headerGenericIndexValue.deviceID,_genericParams.headerGenericIndexValue.genericValue.iconText,_genericParams.headerGenericIndexValue.genericValue.icon,_genericParams.headerGenericIndexValue.genericIndex.ID,_genericParams.headerGenericIndexValue.genericIndex.placement);
    if(self.genericParams.isSensor){
        int deviceType = [Device getTypeForID:_genericParams.headerGenericIndexValue.deviceID];
        int deviceID = _genericParams.headerGenericIndexValue.deviceID;
        if(deviceType == SFIDeviceType_NestThermostat_57 || deviceType == SFIDeviceType_NestSmokeDetector_58 ){
            [self handleNestThermostatAndSmokeDectect:deviceType deviceID:deviceID genericValue:_genericParams.headerGenericIndexValue.genericValue];
        }
    }
    
    
    if(_genericParams.headerGenericIndexValue.genericValue.iconText){
        self.deviceImage.hidden = YES;
        self.deviceValueImgLable.hidden = NO;
        self.deviceValueImgLable.text = self.genericParams.headerGenericIndexValue.genericValue.iconText;
        self.deviceValue.text = self.genericParams.headerGenericIndexValue.genericValue.displayText;
    }else{
        self.deviceValueImgLable.hidden = YES;
        self.deviceImage.hidden = NO;
        self.deviceImage.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
        self.deviceValue.text = self.genericParams.headerGenericIndexValue.genericValue.displayText;
    }
    
    if(self.genericParams.headerGenericIndexValue.genericIndex.readOnly || self.cellType == ClientTable_Cell || _genericParams.headerGenericIndexValue.genericValue.iconText)
        self.deviceButton.userInteractionEnabled = NO;
    else
        self.deviceButton.userInteractionEnabled = YES;
    NSLog(@"setUpDeviceCell end");
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

-(void)handleNestThermostatAndSmokeDectect:(int)deviceType deviceID:(int)deviceID genericValue:(GenericValue*)genericValue{

    if(deviceType == SFIDeviceType_NestThermostat_57){
        BOOL isNestOnline = [[Device getValueForIndex:11 deviceID:deviceID] isEqualToString:@"true"];
//        BOOL isNestOnline = NO;
        if(!isNestOnline){
            genericValue.icon = @"offline_icon";
            genericValue.iconText = nil;
            genericValue.displayText = @"Offline";
            if(deviceType == SFIDeviceType_NestThermostat_57){
                self.tamperedImgView.hidden = NO;
                self.tamperedImgView.image = [UIImage imageNamed:@"nest_offline"];
            }
        }
    }else if(deviceType == SFIDeviceType_NestSmokeDetector_58){
        BOOL isSmokeOnline =  [[Device getValueForIndex:5 deviceID:deviceID] isEqualToString:@"true"];
        if(!isSmokeOnline){
            genericValue.icon = @"offline_icon";
            genericValue.iconText = nil;
            genericValue.displayText = @"Offline";
            if(deviceType == SFIDeviceType_NestThermostat_57){
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

-(NSString*)getSmokeStatus:(int)deviceID{
    NSString *status = @"NaN";
    NSString *emergency = @"emergency";
    NSString *warning = @"warning";
    NSString *replace = @"replace";
    
    NSString *coAlarm = [Device getValueForIndex:3 deviceID:deviceID];
    NSString *smokeAlarm = [Device getValueForIndex:4 deviceID:deviceID];
    NSString *batteryStat = [Device getValueForIndex:2 deviceID:deviceID];
    
    NSLog(@"coalarm: %@, smoke: %@", coAlarm, smokeAlarm);
    if([coAlarm isEqualToString:smokeAlarm]){
        status = [coAlarm isEqualToString:@"ok"]? @"OK": [NSString stringWithFormat:@"%@ %@", @"SMOKE & CO", coAlarm.uppercaseString];
    }else{
        if([coAlarm isEqualToString:emergency])
            status = @"CO EMERGENCY";
        else if([smokeAlarm isEqualToString:emergency])
            status = @"SMOKE EMERGENCY";
        else if([coAlarm isEqualToString:warning])
            status = @"CO WARNING";
        else if([smokeAlarm isEqualToString:warning])
            status = @"SMOKE WARNING";
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
        NSLog(@"gvalues: %@", genericIndexValues);
        if([Device getTypeForID:deviceID] == SFIDeviceType_NestThermostat_57){
            genericIndexValues = [RuleSceneUtil handleNestThermostatForSensor:deviceID genericIndexValues:genericIndexValues];
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
    NSLog(@"onSensorButtonClicked");
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
        NSLog(@"genericIndexObj ID %@ ",genericIndexObj.ID);
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
