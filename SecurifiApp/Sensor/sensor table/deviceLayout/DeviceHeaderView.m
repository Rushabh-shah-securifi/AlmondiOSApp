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

-(void)initializeSensorCellWithGenericParams:(GenericParams*)genericParams cellType:(CellType)cellType{
    self.genericParams = genericParams;
    self.cellType = cellType;
}

-(void)setUpDeviceCell{
    NSLog(@"setUPSensorCell");
    self.deviceName.text = self.genericParams.deviceName;
    NSLog(@"icon: %@", self.genericParams.headerGenericIndexValue.genericValue.icon);
    if(_genericParams.headerGenericIndexValue.genericValue.iconText){
        self.deviceImage.hidden = YES;
        self.deviceValueImgLable.hidden = NO;
        self.deviceValueImgLable.text = self.genericParams.headerGenericIndexValue.genericValue.icon;
    }else{
        self.deviceValueImgLable.hidden = YES;
        self.deviceImage.hidden = NO;
        self.deviceValue.text = self.genericParams.headerGenericIndexValue.genericValue.displayText;
        self.deviceImage.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
    }
}

-(void)setUpClientCell{
    // set up images and labels for clients
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
        [self.delegate delegateDeviceButtonClickWithGenericProperies:self.genericParams.headerGenericIndexValue];
    }
}

@end
