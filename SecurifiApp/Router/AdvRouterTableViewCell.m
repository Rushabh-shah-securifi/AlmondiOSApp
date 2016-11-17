//
//  AdvRouterTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvRouterTableViewCell.h"
@interface AdvRouterTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *downArrow;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;

@end
@implementation AdvRouterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFeatureTitle:(NSString *)title{
    self.title.text = title;
}

- (void)setFeatureSubTitle:(NSString *)subTitle{
    self.subTitle.text = subTitle;
}

@end
