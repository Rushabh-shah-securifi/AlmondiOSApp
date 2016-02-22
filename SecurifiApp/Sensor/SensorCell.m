//
//  SensorCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorCell.h"

@implementation SensorCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSLog(@"reuseIdentifier");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}
- (void)awakeFromNib {
    // Initialization code
    NSLog(@"awake nib %@",self.device.deviceName);
    
    self.deviceNameLable.text = @"locked";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)cellInfo{
    self.deviceNameLable.text = self.device.deviceName;
}
- (IBAction)onSettingClicked:(id)sender {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    AddRulesViewController * addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
//    addRuleController.delegate = self;
//    addRuleController.indexPathRow = (int)[self.rules count]; //index path, when you are creating a new entry
//    [self.navigationController pushViewController:addRuleController animated:YES];
}

@end
