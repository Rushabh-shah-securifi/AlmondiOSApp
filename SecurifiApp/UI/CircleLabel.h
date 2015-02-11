//
// Created by Matthew Sinclair-Day on 2/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CircleLabel : UILabel

@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic, retain) UIColor *rectColor;

- (void)setTarget:(id)target touchAction:(SEL)action;
@end