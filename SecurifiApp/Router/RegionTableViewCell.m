//
//  RegionTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 3/6/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "RegionTableViewCell.h"

@interface RegionTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *regionLbl;
@property (weak, nonatomic) IBOutlet UIButton *roundBtn;

@end
@implementation RegionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupCell{
    if(arc4random() % 5 == 2){
        _roundBtn.backgroundColor = [UIColor whiteColor];
        
        _roundBtn.layer.borderWidth = 2.0;
        _roundBtn.layer.borderColor = [UIColor grayColor].CGColor;
    }else{
        _roundBtn.backgroundColor = [UIColor grayColor];
    }
}
@end
