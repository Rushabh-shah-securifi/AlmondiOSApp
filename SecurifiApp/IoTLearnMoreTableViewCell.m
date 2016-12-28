//
//  IoTLearnMoreTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 12/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "IoTLearnMoreTableViewCell.h"
#import "CommonMethods.h"

@interface IoTLearnMoreTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *issueTitle;
@property (weak, nonatomic) IBOutlet UILabel *issueDesc;

@property (weak, nonatomic) IBOutlet UILabel *helpTitle;
@end
@implementation IoTLearnMoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIssueCell:(NSString *)type{
    self.issueDesc.text = [CommonMethods type:type];
    self.issueDesc.text = [CommonMethods getExplanationText:type];
}

- (void)setHelpCell:(NSString *)title{
    self.helpTitle.text = title;
}
@end
