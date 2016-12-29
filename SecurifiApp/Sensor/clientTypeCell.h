//
//  clientTypeCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol clientTypeCellDelegate
-(void)selectedTypes:(NSString*)typeName;
@end
@interface clientTypeCell : UITableViewCell
@property (nonatomic) UIColor *color;
@property (nonatomic) UIImageView *iconView;
@property (nonatomic,weak) id<clientTypeCellDelegate> delegate;
-(void)setupLabel;
-(void)writelabelName:(NSString*)name value:(NSString*)value;
-(void)changeButtonColor;

@end
