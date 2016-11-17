//
// Created by Matthew Sinclair-Day on 5/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

@class TableHeaderView;

@protocol TableHeaderViewDelegate

- (void)dismissHeaderView:(TableHeaderView *)view;

@end


// Provides a standard layout and behavior for placing "message" headers in table view
@interface TableHeaderView : UIView

// returns an instance for informing the user that a new router firmware version is available
+ (instancetype)newAlmondVersionMessage;

@property(weak) id <TableHeaderViewDelegate> delegate;

@property(copy) NSString *headline;
@property(copy) NSString *message;

@end