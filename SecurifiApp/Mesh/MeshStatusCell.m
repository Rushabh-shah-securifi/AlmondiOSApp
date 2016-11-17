//
//  MeshStatusCell.m
//  SecurifiApp
//
//  Created by Masood on 8/2/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshStatusCell.h"
@interface MeshStatusCell()
@property (weak, nonatomic) IBOutlet UILabel *keyLbl;
@property (weak, nonatomic) IBOutlet UILabel *valueLbl;

@end

@implementation MeshStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupCell:(NSString*)key value:(NSString *)value accType:(UITableViewCellAccessoryType)accType{
    self.keyLbl.text = key;
    self.valueLbl.text = value;
    self.accessoryType = accType;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
@end
