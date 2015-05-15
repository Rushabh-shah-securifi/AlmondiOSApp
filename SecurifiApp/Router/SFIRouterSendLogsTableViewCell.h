//
// Created by Matthew Sinclair-Day on 5/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"

@protocol SFIRouterTableViewActions;

@interface SFIRouterSendLogsTableViewCell : SFICardTableViewCell

@property(weak) id <SFIRouterTableViewActions> delegate;

@end