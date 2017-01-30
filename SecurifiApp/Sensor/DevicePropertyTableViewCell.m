//
//  DevicePropertyTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DevicePropertyTableViewCell.h"
#import "SFIColors.h"

@interface DevicePropertyTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *leftLabelView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@end

@implementation DevicePropertyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setUpCell:(NSDictionary *)cellDict indexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    [self resetViews];
    [self setLeftValue:@"thermostat".capitalizedString];
    [self setRightValue:@"35˚".capitalizedString];
    
    if(section == 0){
        self.imgView.hidden = NO;
        self.textField.hidden = NO;
    }
    else if(section == 1){
        [self setRightValue:@"Living room"];
        self.leftLabelView.hidden = NO;
        self.rightLabel.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        self.leftLabelView.hidden = NO;
        self.rightLabel.hidden = NO;
        if(section == 2){
            self.rightLabel.textColor = [SFIColors ruleBlueColor];
        }
        
    }
        
}


- (void)setLeftValue:(NSString *)value{
    self.textField.text = value;
    self.leftLabelView.text = value;
}

- (void)setRightValue:(NSString *)value{
    self.rightLabel.text = value;
}

- (void)resetViews{
    self.imgView.hidden = YES;
    self.textField.hidden = YES;
    self.leftLabelView.hidden = YES;
    
    self.rightLabel.hidden = YES;
    self.rightLabel.textColor = [UIColor blackColor];
    
    self.accessoryType = UITableViewCellAccessoryNone;
}
@end
