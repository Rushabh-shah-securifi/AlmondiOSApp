//
//  SFILoginViewController.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFILoginViewController;

typedef NS_ENUM(unsigned int, SFILoginViewControllerMode) {
    SFILoginViewControllerMode_localLinkOption = 0,             // show a button allowing local conn info to be provided
    SFILoginViewControllerMode_switchToLocalConnection          // show a button to change app to 'local conn mode' and dismiss the login process
};

@protocol SFILoginViewDelegate

- (void)loginControllerDidCompleteLogin:(SFILoginViewController *)ctrl;

@end

@interface SFILoginViewController : UIViewController

@property(nonatomic, weak) id <SFILoginViewDelegate> delegate;

@property(nonatomic, weak) IBOutlet UITextField *emailID;
@property(nonatomic, weak) IBOutlet UITextField *password;
@property(nonatomic, weak) IBOutlet UILabel *headingLabel;
@property(nonatomic, weak) IBOutlet UILabel *subHeadingLabel;
@property(nonatomic, weak) IBOutlet UIButton *forgotPwdButton;
@property(nonatomic, weak) IBOutlet UIButton *loginButton;

@property(nonatomic, weak) IBOutlet UIButton *localActionButton;
@property(nonatomic) enum SFILoginViewControllerMode mode;

- (IBAction)onLoginAction:(id)sender;

- (IBAction)onCreateAccountAction:(id)sender;

- (IBAction)onAddLocalAlmond:(id)sender;

- (IBAction)onForgetPasswordAction:(id)sender;

@end

