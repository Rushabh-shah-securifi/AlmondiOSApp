//
//  SFICardTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFICardView;

// Provides a standard table cell for managing a CardView layout
@interface SFICardTableViewCell : UITableViewCell

// The card view used for laying out forms
@property(nonatomic) SFICardView *cardView;

// Margin placed along the left and right side of the card; defaults to 10px
@property(nonatomic)  CGFloat margin;

// Can be called after layouts to provide a preferred height for the table view cell
- (CGFloat)computedLayoutHeight;

// Called each time prior to laying out the cell
- (void)markReuse;

@end
