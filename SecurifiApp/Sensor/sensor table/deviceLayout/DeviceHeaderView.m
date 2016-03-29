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


-(void)setUpClientCell{
    // set up images and labels for clients
}


-(void)setUPSensorCell{
    NSLog(@"setUPSensorCell");
    NSLog(@"icon: %@", self.genericIndexValue.genericValue.icon);
    self.deviceName.text = self.device.name;
    if(_genericIndexValue.genericValue.iconText){
        self.deviceImage.hidden = YES;
        self.deviceValueImgLable.hidden = NO;
        self.deviceValueImgLable.text = self.genericIndexValue.genericValue.icon;
    }else{
        self.deviceValueImgLable.hidden = YES;
        self.deviceImage.hidden = NO;
        self.deviceValue.text = self.genericIndexValue.genericValue.displayText;
        self.deviceImage.image = [UIImage imageNamed:self.genericIndexValue.genericValue.icon];
    }
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
        NSArray* genericIndexValues = [GenericIndexUtil getGenericIndexValuesByPlacementForDevice:self.device placement:DETAIL];
        NSLog(@" genericIndexValues %ld",genericIndexValues.count);
        GenericParams *genericParams = [[GenericParams alloc]initWithGenericIndexValue:self.genericIndexValue indexValueList:genericIndexValues device:self.device color:self.color];
        [self.delegate delegateDeviceSettingButtonClick:genericParams];
    }
    else if(self.cellType == ClientTable_Cell){
        [self.delegate delegateClientSettingButtonClick];
    }
    else if (self.cellType == ClientEdit_Cell){
        [self.delegate delegateClientEditTable];
    }
    
}

- (IBAction)onSensorButtonClicked:(id)sender {
    NSLog(@"onSensorButtonClicked");
    if(self.cellType == SensorTable_Cell){
        //change image to load
        GenericIndexValue *genericIndexValue = [GenericIndexUtil getHeaderGenericIndexValueForDevice:self.device];
        [self.delegate delegateDeviceButtonClickWithGenericProperies:genericIndexValue];
    }
}

@end
