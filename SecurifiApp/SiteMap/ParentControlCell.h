//
//  ParentControlCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ParentControlCellDelegate
-(void)switchPressed:(BOOL)isOn andTag:(NSInteger)tag;

@end
@interface ParentControlCell : UITableViewCell
@property (nonatomic)id<ParentControlCellDelegate> delegate;
-(void)setUpCell:(NSString *)label andImage:(UIImage *)image isHideSwich:(BOOL)isHide indexPath:(NSInteger)tag;

@end
