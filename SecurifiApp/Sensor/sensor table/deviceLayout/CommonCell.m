//
//  CommonCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 10/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CommonCell.h"
#import "GenericIndexUtil.h"
#import "AlmondJsonCommandKeyConstants.h"
@interface CommonCell()
@property (weak, nonatomic) IBOutlet UILabel *deviceValueImgLable;
    

@end

@implementation CommonCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"CommonCell" owner:self options:nil];
        [self addSubview:self.view];
        [self stretchToSuperView:self.view];
        
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
    [[NSBundle mainBundle] loadNibNamed:@"CommonCell" owner:self options:nil];
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

- (IBAction)settingButtonClicked:(id)sender {
    if(self.cellType == ClientTable_Cell){
        [self.delegate delegateSensorTable];
    }
    else if (self.cellType == ClientEdit_Cell){
        [self.delegate delegateClientEditTable];
    }
    else if(self.cellType == SensorTable_Cell){
        NSArray* genericIndexValues = [GenericIndexUtil getGenericIndexValuesByPlacementForDevice:self.device placement:DETAIL];
        [self.delegate delegateSensorTable:self.device withGenericIndexValues:genericIndexValues];
    }
}
-(void)setUpClientCell{
    // set up images and labels for clients
}


-(void)setUPSensorCell{
    // setup images
    GenericValue *genericValue = [GenericIndexUtil getHeaderGenericValueForDevice:self.device];
    self.deviceName.text = self.device.name;
    NSLog(@"icon: %@", genericValue.icon);
    if(genericValue.isIconText){
        self.deviceImage.hidden = YES;
        self.deviceValueImgLable.hidden = NO;
        self.deviceValueImgLable.text = genericValue.icon;
//        [self addDeviceValueImgLabel:genericValue.icon suffix:@"%"];
    }else{
        self.deviceValueImgLable.hidden = YES;
        self.deviceImage.hidden = NO;
        self.deviceValue.text = genericValue.displayText;
        self.deviceImage.image = [UIImage imageNamed:genericValue.icon];
    }
}

-(void)addDeviceValueImgLabel:(NSString*)text suffix:(NSString*)suffix{
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:20.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:12.0f],NSBaselineOffsetAttributeName:@(10)} range:NSMakeRange(text.length,suffix.length)];
    [self.deviceValueImgLable setAttributedText:strTemp];
}
@end
