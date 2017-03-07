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

- (void)setupCell:(NSString *)region currentRegion:(NSString *)currentRegion{
    self.regionLbl.text = region;
    
    if([region isEqualToString:currentRegion]){
        _roundBtn.backgroundColor = [UIColor grayColor];
    }
    else{
        _roundBtn.backgroundColor = [UIColor whiteColor];
        
        _roundBtn.layer.borderWidth = 2.0;
        _roundBtn.layer.borderColor = [UIColor grayColor].CGColor;
    }
}

- (IBAction)onRegionSelect:(id)sender {
    _roundBtn.backgroundColor = [UIColor grayColor];
    [self.delegate onRegionSelectedDelegate:self.regionLbl.text];
}

@end
