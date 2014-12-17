//
//  SFILogoutAllViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFILogoutAllViewController;

@protocol SFILogoutAllDelegate

- (void)logoutAllControllerDidLogoutAll:(SFILogoutAllViewController*)ctrl;

- (void)logoutAllControllerDidCancel:(SFILogoutAllViewController*)ctrl;

@end

@interface SFILogoutAllViewController : UIViewController

@property(weak, nonatomic) id<SFILogoutAllDelegate> delegate;

@property(weak, nonatomic) IBOutlet UITextField *password;
@property(weak, nonatomic) IBOutlet UITextField *emailID;
@property(weak, nonatomic) IBOutlet UILabel *logMessageLabel;

- (IBAction)onLogoutAll:(id)sender;

@end

