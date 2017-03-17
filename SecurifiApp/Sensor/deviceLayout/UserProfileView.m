//
//  UserProfileView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "UserProfileView.h"


@interface UserProfileView ()
@property (strong, nonatomic) IBOutlet UserProfileView *view;
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

@implementation UserProfileView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"UserProfileView" owner:self options:nil];
        [self addSubview:self.view];//iconWhiteCheckmark
//        [self stretchToSuperView:self.view];
//        self.genericIndexValue = genericIndexValue;
//        self.isSensor = isSensor;
//        
//        [self updateUIValue];
    }
    return self;
}

@end
