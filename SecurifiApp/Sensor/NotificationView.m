//
//  NotificationView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 06/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "NotificationView.h"
@interface NotificationView ()
@property (weak, nonatomic) IBOutlet NSObject *view;

@property (weak, nonatomic) IBOutlet UISwitch *enableDisableSwitch;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *alwaysLbl;
@property (weak, nonatomic) IBOutlet UIImageView *alwaysImg;
@property (weak, nonatomic) IBOutlet UIImageView *awayImg;
@property (weak, nonatomic) IBOutlet UILabel *awayLbl;

@end
@implementation NotificationView

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
@end
