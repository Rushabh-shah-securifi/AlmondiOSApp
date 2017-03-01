//
//  TimeZoneTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 3/1/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "TimeZoneTableViewCell.h"

@interface TimeZoneTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@end
@implementation TimeZoneTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupCell:(NSString *)country time:(NSString *)time{
    self.countryLabel.text = country;
    self.timeLbl.text = time;

}
@end
