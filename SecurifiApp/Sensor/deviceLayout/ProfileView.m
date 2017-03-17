//
//  ProfileView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 16/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "ProfileView.h"
@interface ProfileView ()
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *userDP;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UIButton *active;
@property (weak, nonatomic) IBOutlet UILabel *activeLbl;

@property (weak, nonatomic) IBOutlet UIButton *dataUsage;
@property (weak, nonatomic) IBOutlet UILabel *dataUsageLbl;

@property (weak, nonatomic) IBOutlet UIButton *webHistory;
@property (weak, nonatomic) IBOutlet UILabel *webHistoryLbl
;

@property (weak, nonatomic) IBOutlet UIButton *more;
@property (weak, nonatomic) IBOutlet UILabel *moreLbl;

@end


@implementation ProfileView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:self options:nil];
        [self addSubview:self.view];//iconWhiteCheckmark.
        [self setButtonImages];
        //        [self stretchToSuperView:self.view];
        //        self.genericIndexValue = genericIndexValue;
        //        self.isSensor = isSensor;
        //
        //        [self updateUIValue];
    }
    return self;
}
//-(id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    if(self){
//        [[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:self options:nil];
//        [self addSubview:self.view];
//      
//    }
//    return  self;
//}
-(void)setButtonImages{
    [self.userDP setImage:[UIImage imageNamed:@"ic_add_a_photo"]];
    [self.active setImage:[UIImage imageNamed:@"internet-green-compressed"] forState:UIControlStateNormal];
    [self.dataUsage setImage:[UIImage imageNamed:@"data-usage-green-compressed"] forState:UIControlStateNormal];
    [self.webHistory setImage:[UIImage imageNamed:@"web-history-green-compressed"] forState:UIControlStateNormal];
    [self.more setImage:[UIImage imageNamed:@"kids-green-compressed"] forState:UIControlStateNormal];
}
- (IBAction)userMoreClicked:(id)sender {
    [self.delegate callUserPropertyViewController];
}
@end
