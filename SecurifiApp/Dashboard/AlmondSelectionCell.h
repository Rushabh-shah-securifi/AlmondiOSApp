//
//  AlmondSeclectionCellTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 9/6/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlmondSelectionCell : UITableViewCell
- (void)initializeCell:(CGRect)frame;
- (void)setUpCell:(NSString *)almondName isCurrent:(BOOL)isCurrent;
@end
