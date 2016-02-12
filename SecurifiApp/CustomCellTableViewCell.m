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
}

-(void)setSwitchFrame{
//    (a)Scale and then translate?
//    Something like :
    
//    CGAffineTransform t = CGAffineTransformMakeScale(2, 2);
//    t = CGAffineTransformTranslate(t, width/2, height/2);
//    self.transform = t;
////    (b)Set the anchor point (which is probably what you want really)
//    
//    [self layer].anchorPoint = CGPointMake(0.0f, 0.0f);
//    self.transform = CGAffineTransformMakeScale(2, 2);
////    (c)Set the center again to make sure it's in the same place?
//    CGPoint center = self.center;
//    self.transform = CGAffineTransformMakeScale(2, 2);
//    self.center = center;
}

- (IBAction)onEditButtonClick:(id)sender {
    [self.delegate editRule:self];
}


- (IBAction)onDeleteButtonClick:(id)sender{
    [self.delegate deleteRule:self];
    
}

- (IBAction)onActivateButtonTap:(id)sender {
    self.activeDeactiveSwitch.selected = !self.activeDeactiveSwitch.selected;
    [self.delegate activateRule:self];
}


@end
