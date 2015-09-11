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
@property(weak, nonatomic) IBOutlet UILabel *headingLabel;
@property(weak, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property(weak, nonatomic) IBOutlet UIButton *forgotPwdButton;
@property(weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)onLoginAction:(id)sender;

- (IBAction)onCreateAccountAction:(id)sender;

- (IBAction)onAddLocalAlmond:(id)sender;

- (IBAction)onForgetPasswordAction:(id)sender;

@end

