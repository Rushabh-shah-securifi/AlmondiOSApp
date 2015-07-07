//
// Created by Matthew Sinclair-Day on 7/6/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlertView;
@class AlertViewAction;

@protocol AlertViewDelegate

- (void)alertView:(AlertView *)view didSelectAction:(AlertViewAction*)action;

- (void)alertViewDidCancel:(AlertView *)view;

@end


@interface AlertView : UIView

@property(nonatomic, weak) id <AlertViewDelegate> delegate;

@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSArray *actions; // AlertViewActions

@end