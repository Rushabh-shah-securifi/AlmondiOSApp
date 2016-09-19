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
    self.Switch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpCell:(NSString *)label andImage:(UIImage *)image isHideSwich:(BOOL)isHide indexPath:(NSInteger)tag isOnSwitch:(BOOL)isEnable{
    self.lable.text = label;
    self.imageView.image = image;
    self.Switch.tag = tag;
    if(isHide == NO){
        self.Switch.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        self.Switch.hidden = NO;
        [self.Switch setOn:isEnable];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
}
- (IBAction)switchAction:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
    BOOL state = [sender isOn];
    [self.delegate switchPressed:state andTag:actionSwitch.tag saveNewValue:YES];
}

@end
