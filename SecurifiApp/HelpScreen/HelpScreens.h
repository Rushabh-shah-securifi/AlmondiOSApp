//
//  HelpScreens.h
//  SecurifiApp
//
//  Created by Masood on 7/15/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpViewController.h"

@protocol HelpScreensDelegate
- (void)resetViewDelegate;
- (void)onSkipTapDelegate;
@optional
- (void)onShowMeTapDelegate;
- (void)onGoToHelpCenterTapDelegate;
@end

@interface HelpScreens : UIView

@property(nonatomic) NSDictionary *startScreen;
@property(nonatomic) BOOL isOnMainScreen;

@property(nonatomic)id<HelpScreensDelegate> delegate;

+ (HelpScreens *)initializeHelpScreen:(UIView *)navView isOnMainScreen:(BOOL)isOnMainScreen startScreen:(NSDictionary *)startScreen;

+ (void)initializeGotItView:(HelpScreens *)helpView navView:(UIView *)navView;

+ (void)initializeWifiPresence:(HelpScreens *)helpView view:(UIView *)mainView tabHt:(CGFloat)tabHeight;

+ (void)addTriggerHelpPage:(HelpScreens *)helpView startScreen:(NSDictionary *)startScreen navView:(UIView*)navView;

- (void)addHelpPromptSubView:(CGRect)frame;

- (void)addHelpItem:(CGRect)frame;

- (void)expandView;

- (void)resetBottonConstraint;

- (void)initailizeFirstScreen;

- (void)addGotItView:(CGRect)frame;

- (void)addDashboard:(CGRect)frame;

- (void)addScene:(CGRect)frame;

- (void)addSecuriti:(CGRect)frame;

@end
