//
//  clientTypeCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface clientTypeCell : UITableViewCell
@property (nonatomic) UIColor *color;
-(void)setupLabel;
-(void)writelabelName:(NSString*)name;
@end
