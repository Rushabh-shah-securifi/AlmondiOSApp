//
// Created by Matthew Sinclair-Day on 5/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"

typedef NS_ENUM(unsigned int, SFIRouterTableViewActionsMode) {
    SFIRouterTableViewActionsMode_unknown = 1,
    SFIRouterTableViewActionsMode_enterReason,
    SFIRouterTableViewActionsMode_commandSuccess,
    SFIRouterTableViewActionsMode_commandError,
    SFIRouterTableViewActionsMode_firmwareNotSupported,
};

@protocol SFIRouterTableViewActions;

@interface SFIRouterSendLogsTableViewCell : SFICardTableViewCell

@property(weak) id <SFIRouterTableViewActions> delegate;

@property(nonatomic) SFIRouterTableViewActionsMode mode;

@end