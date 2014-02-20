//
//  SFISignupViewController.h
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SFISignupViewController : UIViewController{
    MBProgressHUD               *HUD;
}
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *emailID;
//@property (nonatomic, retain) UIToolbar *keyboardToolbar;
//@property (weak, nonatomic) IBOutlet UILabel *logMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet UIButton *footerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPwdButton;
@property NSInteger state;
@property NSInteger cloudState;

- (IBAction)signupButtonHandler:(id)sender;
- (IBAction)footerButtonHandler:(id)sender;
- (IBAction)forgotPwdButtonHandler:(id)sender;
- (IBAction)loginButtonHandler:(id)sender;
@end
