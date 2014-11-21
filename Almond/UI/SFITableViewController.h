//
//  SFITableViewController.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

// Provides a base class for controllers attached to the main tab view.
// This controller places a Cloud Status bar button in the right corner and manages its state.
// A 'reveal' button is attached to the left corner for toggling the Reveal View controller.
// A HUD is attached to the navigation controller, and subclasses should use it.
// The controller is configured with the standard tint color and attribute style, and subclasses may find them by
// interrogating the navigation bar's button items and title attributes.
@interface SFITableViewController : UITableViewController

@property(nonatomic, readonly) MBProgressHUD *HUD;

- (void)showHUD:(NSString *)text;

// Enabled by default
@property(nonatomic) BOOL enableDrawer;

@end
