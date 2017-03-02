//
//  ClientTypeTableViewCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "ClientTypeTableViewCell.h"
#import "SFIColors.h"
#import "UICommonMethods.h"

@interface ClientTypeTableViewCell()
@property (nonatomic) NSString *valueString;

@end
@implementation ClientTypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)writelabelName:(NSString*)name value:(NSString *)value icon:(NSString *)icon{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.clientTypeLabel.textColor = [UIColor blackColor];
    
    self.clientTypeLabel.text = [self ignoreCapitalizingSpecialWords:name];
    self.valueString = value;;
    self.clientTypeImage.image = [UICommonMethods imageNamed:icon withColor:[UIColor blackColor]];
    self.clientTypeCheck.hidden = YES;
}
- (NSString *)ignoreCapitalizingSpecialWords:(NSString *)name{
    NSArray *spclWords = @[@"ipad", @"ipod", @"mac", @"iphone"];
    if([spclWords containsObject:name.lowercaseString])
        return name;
    else
        return [name capitalizedString];
}
-(void)changeButtonColor:(NSString *)icon{
    self.contentView.backgroundColor = [SFIColors clientGreenColor];
    self.clientTypeLabel.textColor = [UIColor whiteColor];
    self.clientTypeImage.image = [UICommonMethods imageNamed:icon withColor:[UIColor whiteColor]];
    self.clientTypeCheck.hidden = NO;
}

@end
