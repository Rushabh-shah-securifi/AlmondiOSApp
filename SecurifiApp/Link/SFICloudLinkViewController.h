//
//  SFICloudLinkViewController.h
//  SecurifiApp
//
//  Created by Matthew Sinclair-Day on 7/18/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SFICloudLinkViewController : UITableViewController

+ (UIViewController*)cloudLinkController;

// Enables ability for user to link directly to Almond via Local Link
// Defaults to NO; user will be forced to link via Cloud
@property(nonatomic) BOOL enableLocalAlmondLink;

@end
