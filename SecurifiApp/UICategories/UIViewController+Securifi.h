//
//  UIViewController(SFIViewController).h
//
//  Created by sinclair on 11/9/14.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (Securifi)

// Show a "toast" message at the bottom of the screen
- (void)showToast:(NSString *)msg;

- (void)showMidToast:(NSString *)msg;

// Shows a standard "Saving..." toast message
- (void)showSavingToast;

@end
