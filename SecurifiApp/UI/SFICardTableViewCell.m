//
//  SFICardTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"
#import "SFICardView.h"

@implementation SFICardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.margin = 10;
    }

    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)computedLayoutHeight {
    CGFloat padding = 2 * self.margin;
    return [self.cardView computedLayoutHeight] + padding;
}

- (void)markReuse {
    [self.cardView removeFromSuperview];
    self.cardView = [[SFICardView alloc] initWithFrame:self.frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.cardView.superview) {
        return;
    }

    CGRect rect = self.bounds;
    rect = CGRectInset(rect, self.margin, 0);

    self.cardView.frame = rect;
    [self.contentView addSubview:self.cardView];
}

@end
