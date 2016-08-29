//
//  ParentControlCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ParentControlCell.h"
@interface ParentControlCell()

@property (weak, nonatomic) IBOutlet UISwitch *Switch;
@property (weak, nonatomic) IBOutlet UILabel *lable;
@property (weak, nonatomic) IBOutlet UIImageView *Image;

@end

@implementation ParentControlCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpCell:(NSString *)label andImage:(UIImage *)image isHideSwich:(BOOL)isHide{
    self.lable.text = label;
    if(isHide == YES){
        self.Switch.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
        
    
}

@end
