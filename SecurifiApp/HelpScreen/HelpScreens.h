//
//  HelpScreens.h
//  SecurifiApp
//
//  Created by Masood on 7/15/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HelpScreensDelegate
- (void)resetViewDelegate;
- (void)onSkipTapDelegate;
@optional
- (void)onShowMeTapDelegate;
- (void)onGoToHelpCenterTapDelegate;
@end

@interface HelpScreens : UIView

@property(nonatomic) NSDictionary *startScreen;

@property(nonatomic)id<HelpScreensDelegate> delegate;
- (void)addHelpPromptSubView:(CGRect)frame;

- (void)addHelpItem:(CGRect)frame;

- (void)expandView;

-(void)resetBottonConstraint;

- (void)initailizeFirstScreen;

- (void)addGotItView:(CGRect)frame;

- (void)onSkipTapDelegate;

@end
