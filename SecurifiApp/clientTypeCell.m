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
    NSLog(@"setupLabel");
    self.labelName = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 20)];
    self.labelName.textColor = [UIColor whiteColor];
    self.labelName.font = [UIFont securifiFont:14];
    
    UIButton *btnSelect = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, 5, 25 , 25)];
    
    btnSelect.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSelect.layer.borderWidth = 2.0f;
    btnSelect.layer.cornerRadius = btnSelect.frame.size.height/2;
    btnSelect.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:btnSelect];
}
-(void)writelabelName:(NSString*)name{
    self.labelName.text = name;
    

}

@end
