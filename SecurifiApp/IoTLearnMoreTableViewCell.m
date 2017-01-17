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
//    if([type isEqualToString:@"10"]){
//        self.issueTitle.text = @"";
//        NSAttributedString * attString = [CommonMethods getAttributedString:@"It appears that your device is behaving suspiciously. It may be doing so for the following reasons: \n\nWrong selection of device type: Make sure you have assigned the correct device type for the device behaving suspiciously. You can change the device type by going to the Network Devices section in the Almond App -> click on the wrench icon -> select the type of the device. \n\nYour device is compromised and the outbound traffic coming out of it is not normal. We suggest that you block the device, reset it and connect to the network again. In case the suspicious activity continues, remove the device from your network and contact your device vendor." subText:@"Wrong selection of device type:" fontSize:self.issueDesc.font.pointSize];
//        attString = [CommonMethods getAttributedStringWithAttribute:attString subText:@"Your device is compromised" fontSize:self.issueDesc.font.pointSize];
//        self.issueDesc.attributedText = attString;
//    }
     if([type isEqualToString:@"2"] || [type isEqualToString:@"6"]){
        
         self.issueTitle.text = [CommonMethods type:type];
        NSLog(@"text == %@",[CommonMethods getExplanationText:type]);
        self.issueDesc.attributedText = [self setLink:[CommonMethods getExplanationText:type] link:@"https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers" label:self.issueDesc];
    }
    else{
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
