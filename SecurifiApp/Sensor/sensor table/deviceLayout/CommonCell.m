//
//  CommonCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 10/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CommonCell.h"
#import "GenericIndexUtil.h"

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
         NSMutableArray *genericIndexes = [GenericIndexUtil getGenericIndexesForDevice:self.device];
        [self.delegate delegateSensorTable:self.device withGenericIndex:(NSMutableArray *)genericIndexes];
    }
    
}
-(void)setUpClientCell{
    // set up images and labels for clients
}
-(void)setUPSensorCell{
    // setup images
}
@end
