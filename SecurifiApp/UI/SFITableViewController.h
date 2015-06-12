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
// It also places a Notification status button and manages its state.
// A 'reveal' button is attached to the left corner for toggling the Reveal View controller.
// A HUD is attached to the navigation controller, and subclasses should use it.
// The controller is configured with the standard tint color and attribute style, and subclasses may find them by
// interrogating the navigation bar's button items and title attributes.
// Subclasses must call markAlmondMac any time the almond being managed is changed.
@interface SFITableViewController : UITableViewController

@property(nonatomic, readonly) MBProgressHUD *HUD;

@property(nonatomic, readonly) BOOL isHudHidden;

// Current almond mac being displayed
@property(nonatomic, readonly) NSString *almondMac;

// declares the almond mac being displayed
- (void)markAlmondMac:(NSString *)almondMac;

- (void)showHUD:(NSString *)text;

// convenience method for showing a standard "loading router data..." message
- (void)showLoadingRouterDataHUD;

// convenience method for showing a standard "loading sensor data..." message
- (void)showLoadingSensorDataHUD;

// convenience method for showing a standard "updating settings..." message
- (void)showUpdatingSettingsHUD;

// Disabled by default; when YES, a status button indicating the number of open Notifications is shown, allowing
// the user to tap to present the Notification Viewer.
@property(nonatomic, readonly) BOOL enableNotificationsView;
@property(nonatomic, readonly) BOOL enableNotificationsHomeAwayMode;

// Enabled by default; when NO, the Reveal button is disabled. Useful when the UI needs to be locked during updates.
@property(nonatomic) BOOL enableDrawer;

@end
