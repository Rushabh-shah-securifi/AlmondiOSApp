//
//  DrawerViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class DrawerViewController;

@protocol DrawerViewControllerDelegate

- (void) drawerViewController:(DrawerViewController*)ctrl didSelectAlmond:(SFIAlmondPlus *)almond;

@end

@interface DrawerViewController : UITableViewController <UITabBarControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak) id<DrawerViewControllerDelegate> delegate;

@end
