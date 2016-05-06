//
//  clientTypeCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "clientTypeCell.h"
#import "UIFont+Securifi.h"
@interface clientTypeCell()
@property (nonatomic) UILabel *labelName;
@property (nonatomic) UIButton *button;
@property (nonatomic) UIButton *btnSelect;
@property (nonatomic) NSString *valueString;
@end
@implementation clientTypeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setupLabel{
    self.labelName = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 20)];
    self.labelName.textColor = [UIColor whiteColor];
    self.labelName.font = [UIFont securifiFont:14];
    NSLog(@"cell frame width: %f", self.frame.size.width);
    self.btnSelect = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 40, 5, 25 , 25)];
    self.btnSelect.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnSelect.layer.borderWidth = 2.0f;
    self.btnSelect.layer.cornerRadius = self.btnSelect.frame.size.height/2;
    self.btnSelect.backgroundColor = [UIColor redColor];
    [self.btnSelect addTarget:self action:@selector(typeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:self.btnSelect];
}
-(void)writelabelName:(NSString*)name value:(NSString *)value{
    self.labelName.text = name;
    self.valueString = value;
    self.btnSelect.backgroundColor = [UIColor clearColor];
    
}

-(void)typeButtonClicked:(id)sender{
    self.btnSelect.backgroundColor = [UIColor whiteColor];
    [self.delegate selectedTypes:self.valueString];
    
}
-(void)changeButtonColor{
    self.btnSelect.backgroundColor = [UIColor whiteColor];
}
@end
