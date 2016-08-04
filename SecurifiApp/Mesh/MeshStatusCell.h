//
//  MeshStatusCell.h
//  SecurifiApp
//
//  Created by Masood on 8/2/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeshStatusCell : UITableViewCell
- (void)setupCell:(NSString*)key value:(NSString *)value accType:(UITableViewCellAccessoryType)accType;
@end
