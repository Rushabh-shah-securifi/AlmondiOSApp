//
//  CustomCellTableViewCell.m
//  RulesUI
//
//  Created by Securifi-Mac2 on 03/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "CustomCellTableViewCell.h"
@interface CustomCellTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *myView; //lable-buttons-view
@property (weak, nonatomic) IBOutlet UIView *containView; //scrollview + lable-buttons-view
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *DeleteButton;

@end

@implementation CustomCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.activeDeactiveSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.DeleteButton.imageEdgeInsets = UIEdgeInsetsMake(5,13,5,13);
    self.editButton.imageEdgeInsets = UIEdgeInsetsMake(3,13,3,10);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)onEditButtonClick:(id)sender {
    NSLog(@"onEditButtonClick");
    [self.delegate editRule:self];
}


- (IBAction)onDeleteButtonClick:(id)sender{
    NSLog(@"onDeleteButtonClick");
    [self.delegate deleteRule:self];
    
}

- (IBAction)onActivateButtonTap:(id)sender {
    NSLog(@"onActivateButtonTap");
    self.activeDeactiveSwitch.selected = !self.activeDeactiveSwitch.selected;
    
    
    [self.delegate activateRule:self];
}


@end
