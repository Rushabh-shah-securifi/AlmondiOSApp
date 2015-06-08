//
// Created by Matthew Sinclair-Day on 6/8/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFICardViewSummaryCell.h"

@protocol SFIRouterTableViewActions;

@interface SFIRouterVersionTableViewCell : SFICardTableViewCell

@property(nonatomic, weak) id <SFIRouterTableViewActions> delegate;

@end