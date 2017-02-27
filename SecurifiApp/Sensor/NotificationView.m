//
//  NotificationView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 06/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "NotificationView.h"
@interface NotificationView ()

@property (weak, nonatomic) IBOutlet UISwitch *enableDisableSwitch;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *alwaysLbl;
@property (weak, nonatomic) IBOutlet UIImageView *alwaysImg;
@property (weak, nonatomic) IBOutlet UIImageView *awayImg;
@property (weak, nonatomic) IBOutlet UILabel *awayLbl;
@property (weak, nonatomic) IBOutlet UIView *alwaysView;

@property (weak, nonatomic) IBOutlet UIView *awayView;

@end
@implementation NotificationView

- (id)initWithFrame:(CGRect)frame andGenericIndexValue:(GenericIndexValue *)genericIndexValue{
    self = [super initWithFrame:frame];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"NotificationView" owner:self options:nil];
        [self addSubview:self.view];
        [self stretchToSuperView:self.view];
        self.genericIndexValue = genericIndexValue;
        [self updateUIValue];
    }
    return self;
}
-(void)updateUIValue{
    if([self.genericIndexValue.genericValue.value isEqualToString:@"1"]){
        [self alwaysClickedUIupdate];
    }
    else if ([self.genericIndexValue.genericValue.value isEqualToString:@"3"]){
        [self awayClickedUIupdate];
    }
    else{
        [self notificationButtonSwitchOFF];
    }
}
- (IBAction)notificationAlwaysButtonClicked:(id)sender {
    [self alwaysClickedUIupdate];
    [self.delegate save:@"1" forGenericIndexValue:self.genericIndexValue];
    // send command delegate
}
- (IBAction)notificationAwayButtonClicked:(id)sender {
    [self awayClickedUIupdate];
    [self.delegate save:@"3" forGenericIndexValue:self.genericIndexValue];
    
    // send command delegate
}
- (IBAction)notificationEnableDisableSwitch:(id)sender {
    UISwitch *notificationSwitch = (UISwitch *)sender;
    if(notificationSwitch.on){
        [self notificationButtonSwitchON];
        [self.delegate save:@"1" forGenericIndexValue:self.genericIndexValue];
    }
    else{
        [self notificationButtonSwitchOFF];
        [self.delegate save:@"0" forGenericIndexValue:self.genericIndexValue];
    }
    
}
-(void)notificationButtonSwitchON{
    self.awayView.hidden = NO;
    self.alwaysView.hidden = NO;
}
-(void)notificationButtonSwitchOFF{
    self.awayView.hidden = YES;
    self.alwaysView.hidden = YES;
}
-(void)alwaysClickedUIupdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alwaysLbl.textColor = [UIColor blueColor];
        self.alwaysImg.hidden = NO;
        self.awayLbl.textColor = [UIColor blackColor];
        self.awayImg.hidden = YES;

    });
   }
-(void)awayClickedUIupdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.awayLbl.textColor = [UIColor blueColor];
        self.awayImg.hidden = NO;
        self.alwaysLbl.textColor = [UIColor blackColor];
        self.alwaysImg.hidden = YES;
        
    });
    
}

//-(id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    if(self){
//        [[NSBundle mainBundle] loadNibNamed:@"NotificationView" owner:self options:nil];
//        [self addSubview:self.view];
//        [self stretchToSuperView:self.view];
//    }
//    return  self;
//}
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
