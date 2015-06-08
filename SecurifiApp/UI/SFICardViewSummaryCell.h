//
// Created by Matthew Sinclair-Day on 2/4/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFICardTableViewCell.h"

@interface SFICardViewSummaryCell : SFICardTableViewCell

// card title
@property(nonatomic, copy) NSString *title;

// summary messages to be shown
@property(nonatomic) NSArray *summaries;

// for setting an "edit" button; when editTarget and editSelector are not nil, then a button is shown
@property(nonatomic) BOOL expanded;
@property(nonatomic) id editTarget;
@property(nonatomic) SEL editSelector;

@end