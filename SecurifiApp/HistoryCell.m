//
//  HistoryCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

- (void)awakeFromNib {
//    self.webImg.image = [UIImage imageNamed:@"favicon.ico"];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCell:(NSString *)httpUrlReq Image:(UIImage*)image{
    dispatch_async(dispatch_get_main_queue(), ^() {
    self.webImg.image = image;
    NSArray * properties = [httpUrlReq componentsSeparatedByString:@"/"];
    NSLog(@"_httpString %@,%@,%@,%@,%@",httpUrlReq,properties[0],properties[1],properties[2],properties[3]);
    self.siteName.text = properties[2];
    });
}

@end
