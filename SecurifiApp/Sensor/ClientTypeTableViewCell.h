//
//  ClientTypeTableViewCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClientTypeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *clientTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *clientTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *clientTypeCheck;
-(void)writelabelName:(NSString*)name value:(NSString *)value icon:(NSString *)icon;
-(void)changeButtonColor:(NSString *)icon;
@end
