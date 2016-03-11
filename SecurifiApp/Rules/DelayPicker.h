//
//  DelayPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 22/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DelayPicker : NSObject
@property(nonatomic) bool isPresentDelayPicker;
@property (strong, nonatomic) UIScrollView *deviceIndexButtonScrollView;
@property (strong, nonatomic) UIScrollView *triggersActionsScrollView;
@property (strong, nonatomic) UIView *parentView;

-(void)removeDelayView;
-(void)addPickerForButton:(UIButton*)delayButton;
@end