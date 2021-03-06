//
//  SFILoginViewController.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFILoginViewController;

@protocol SFILoginViewDelegate

- (void)loginControllerDidCompleteLogin:(SFILoginViewController *)ctrl;

@end

@interface SFILoginViewController : UIViewController

@property(weak, nonatomic) id <SFILoginViewDelegate> delegate;

@property(weak, nonatomic) IBOutlet UITextField *emailID;
@property(weak, nonatomic) IBOutlet UITextField *password;
@property(strong, nonatomic) IBOutlet UILabel *headingLabel;
@property(strong, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property(weak, nonatomic) IBOutlet UIButton *forgotPwdButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;

- (IBAction)onLoginAction:(id)sender;

- (IBAction)onSignupButton:(id)sender;

- (IBAction)onForgetPasswordAction:(id)sender;

@end

