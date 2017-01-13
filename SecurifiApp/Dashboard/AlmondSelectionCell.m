//
//  AlmondSeclectionCellTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 9/6/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondSelectionCell.h"
#import "UICommonMethods.h"
#import "Colours.h"

@interface AlmondSelectionCell()
@property (nonatomic)UILabel *almond;
@property (nonatomic)UIImageView *imgView;
@end

@implementation AlmondSelectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initializeCell:(CGRect)tableFrame{
    self.frame = CGRectMake(0, 0, CGRectGetWidth(tableFrame), 40);
    NSLog(@"cell bound width: %f, cell frame width: %f", self.bounds.size.width, self.frame.size.width);
    NSLog(@"cell height: %f", CGRectGetHeight(self.frame));
    
    self.almond = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 150, 40)];
    [UICommonMethods setLableProperties:self.almond text:@"" textColor:[UIColor blackColor] fontName:@"Avenir-Roman" fontSize:18 alignment:NSTextAlignmentLeft];
    [self addSubview:self.almond];
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-30, 8, 20, 20)];
    [self addSubview:self.imgView];
}

- (void)setUpCell:(NSString *)almondName isCurrent:(BOOL)isCurrent{
    self.almond.text = almondName;
    if(isCurrent)
        self.imgView.image = [UIImage imageNamed:@"check_box_blue"];
    else
        self.imgView.image = [UIImage imageNamed:@"check_box_outline"];
}
@end
