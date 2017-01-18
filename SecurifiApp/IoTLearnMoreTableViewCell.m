//
//  IoTLearnMoreTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 12/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "IoTLearnMoreTableViewCell.h"
#import "CommonMethods.h"
#import "UIFont+Securifi.h"

@interface IoTLearnMoreTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *issueTitle;
@property (weak, nonatomic) IBOutlet UITextView *issueDesc;

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
    NSLog(@"setIssueCell: type %@",type);
     if([type isEqualToString:@"2"] || [type isEqualToString:@"6"]){
         self.issueTitle.text = [CommonMethods type:type];
        self.issueDesc.attributedText = [self setLink:[CommonMethods getExplanationText:type] link:@"https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers" label:self.issueDesc];
        NSLog(@"text == %@",self.issueDesc.attributedText);
    }else{
        self.issueTitle.text = [CommonMethods type:type];
        self.issueDesc.text = [CommonMethods getExplanationText:type];
    }
}


- (void)setHelpCell:(NSString *)title{
    self.helpTitle.text = title;
}


- (NSAttributedString *)setLink:(NSString *)content link:(NSString *)link_str label:(UITextView *)label{
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: [UIColor blackColor],
                              NSFontAttributeName: [UIFont securifiFont:14], //has font name and size perhaps
                              };
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:content attributes:attribs];
    NSURL *link = [NSURL URLWithString:link_str];
    
    [attrStr addAttribute:NSLinkAttributeName value:link range:NSMakeRange(attrStr.length-5, 4)];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(attrStr.length-5, 4)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(attrStr.length-5, 4)];
    return attrStr;
}

@end
