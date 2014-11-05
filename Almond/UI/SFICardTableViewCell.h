//
//  SFICardTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFICardView;

@interface SFICardTableViewCell : UITableViewCell

@property SFICardView *cardView;
@property CGFloat margin;

- (void)markReuse;

@end
