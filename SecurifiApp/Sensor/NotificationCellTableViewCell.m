//
//  NotificationCellTableViewCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 01/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "NotificationCellTableViewCell.h"

@implementation NotificationCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)hideCheckButton:(BOOL)hide{
    self.chekButton.hidden = hide;
}

@end
