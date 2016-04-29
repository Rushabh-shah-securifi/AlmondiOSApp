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
#import "Colours.h"

@interface DeviceHeaderView()<UIAlertViewDelegate>
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
    self.genericParams = genericParams;
    self.cellType = cellType;
    [self setUpDeviceCell];
}

-(void)setUpDeviceCell{
    NSLog(@"setUPSensorCell");
    self.view.backgroundColor = _genericParams.color;
    self.deviceName.text = self.genericParams.deviceName;
    self.settingButton.alpha = 1;
    NSLog(@"Icon text %@ vs index id %@ device id %d placement %@",_genericParams.headerGenericIndexValue.genericValue.iconText,_genericParams.headerGenericIndexValue.genericIndex.ID,_genericParams.headerGenericIndexValue.deviceID,_genericParams.headerGenericIndexValue.genericIndex.placement);
    if(_genericParams.headerGenericIndexValue.genericValue.iconText){
        self.deviceImage.hidden = YES;
        self.deviceValueImgLable.hidden = NO;
        self.deviceValueImgLable.text = self.genericParams.headerGenericIndexValue.genericValue.iconText;
    }else{
        self.deviceValueImgLable.hidden = YES;
        self.deviceImage.hidden = NO;
        self.deviceValue.text = self.genericParams.headerGenericIndexValue.genericValue.displayText;
        self.deviceImage.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
       
    }
    self.lowBatteryImgView.hidden = YES;
    self.tamperedImgView.hidden = YES;
    if(self.genericParams.isSensor)
        [self isTamper];
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
    if(self.cellType == SensorTable_Cell){
        NSArray* genericIndexValues = [GenericIndexUtil getDetailListForDevice:self.genericParams.headerGenericIndexValue.deviceID];
        self.genericParams.indexValueList = genericIndexValues;
        [self.delegate delegateDeviceSettingButtonClick:_genericParams];
    }
    else if(self.cellType == ClientTable_Cell){
        NSArray* genericIndexValues = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
        self.genericParams.indexValueList = genericIndexValues;
        [self.delegate delegateClientSettingButtonClick:self.genericParams];
        
    }
    else if (self.cellType == ClientProperty_Cell){
        [self.delegate delegateClientEditTable];
    }
    
}

- (IBAction)onSensorButtonClicked:(id)sender {
    NSLog(@"onSensorButtonClicked");
    if(self.cellType == SensorTable_Cell || self.cellType == SensorEdit_Cell){
        //to do change image to load
        [self changeImage];
        [self.delegate toggle:self.genericParams.headerGenericIndexValue];
    }
}
-(void)changeImage{
    self.deviceImage.image = [UIImage imageNamed:@"00_wait_icon"];
    self.deviceValue.text = NSLocalizedString(@"tableviewcell-Updating sensor data.\nPlease wait.", @"Updating sensor data.\nPlease wait.");;
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
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(batteryTapped:)];
                singleTap.numberOfTapsRequired = 1;
                [self.lowBatteryImgView setUserInteractionEnabled:YES];
                [self.lowBatteryImgView addGestureRecognizer:singleTap];
            }
        }
        if([genericIndexObj.ID isEqualToString:@"12"]){//tampered
            if ([genericIndexValue.genericValue.value isEqualToString:@"true"]) {
                self.lowBatteryImgView.hidden = NO;
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tamperTapped:)];
                singleTap.numberOfTapsRequired = 1;
                [self.tamperedImgView setUserInteractionEnabled:YES];
                [self.tamperedImgView addGestureRecognizer:singleTap];
            }
        }
    }
}
-(void)tamperTapped:(id)sender{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to dismiss tamper ?"
//                                                    message:@""
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"YES", nil];
//    alert.delegate = self;
//    [alert show];
    
    NSLog(@"tamperTapped  ");
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        self.tamperedImgView.hidden = YES;
        // make is tamper value to false
        // delegate reload table
    }
}

-(void)batteryTapped:(id)sender{
    NSLog(@"batteryTapped");
}
@end
