//
//  SFILoginViewController.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFILoginViewController.h"
#import "SNLog.h"
#import "MBProgressHUD.h"

@interface SFILoginViewController () <UITextFieldDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation SFILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    //PY 170913 - To stop the view from going below tab bar
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self enableLoginButton:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.emailID.delegate = self;
    self.password.delegate = self;

    self.emailID.text = nil;
    self.password.text = nil;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onLoginResponse:)
                   name:LOGIN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(resetPasswordResponseCallback:)
                   name:RESET_PWD_RESPONSE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.emailID.delegate = nil;
    self.password.delegate = nil;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:LOGIN_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:RESET_PWD_RESPONSE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:UIKeyboardDidShowNotification
                    object:nil];

    [center removeObserver:self
                      name:UIKeyboardDidHideNotification
                    object:nil];

}

- (void)enableLoginButton:(BOOL)enabled {
    self.loginButton.enabled = enabled;
}

- (BOOL)validateCredentials {
    return self.emailID.text.length > 0 && self.password.text.length > 0;
}

#pragma mark - Orientation Handling

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // do nothing
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return textField.text.length > 0;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailID) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }

    if (textField == self.password) {
        [textField resignFirstResponder];
    }

    return YES;
}

#pragma mark - Keyboard handler

- (void)onKeyboardDidShow:(id)notification {
    [self enableLoginButton:NO];
}

- (void)onKeyboardDidHide:(id)notice {
    BOOL valid = [self validateCredentials];
    [self enableLoginButton:valid];
}

#pragma mark - UI Actions

- (void)onSignupButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFISignupViewController"];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:mainView];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)onForgetPasswordAction:(id)sender {
    [self sendResetPasswordRequest];
}

- (IBAction)onLoginAction:(id)sender {
    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];
    }

    if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }

    if (self.emailID.text.length == 0 || self.password.text.length == 0) {
        self.headingLabel.text = @"Oops";
        self.subHeadingLabel.text = @"Please enter Username and Password";
    }
    else {
        [[SecurifiToolkit sharedInstance] asyncSendLoginWithEmail:self.emailID.text password:self.password.text];
    }
}

#pragma mark - Event handlers

- (void)onLoginResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Login failed
    if ([notifier userInfo] == nil) {
        [SNLog Log:@"In %s: TEMP Pass failed", __PRETTY_FUNCTION__];
        return;
    }

    LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"In %s: UserID %@", __PRETTY_FUNCTION__, obj.userID];
    [SNLog Log:@"In %s: TempPass %@", __PRETTY_FUNCTION__, obj.tempPass];
    [SNLog Log:@"In %s: isSuccessful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"In %s: Reason : %@", __PRETTY_FUNCTION__, obj.reason];
    [SNLog Log:@"In %s: Reason Code : %d", __PRETTY_FUNCTION__, obj.reasonCode];

    if (!obj.isSuccessful) {
        NSLog(@"Login failure reason Code: %d", obj.reasonCode);
        self.headingLabel.text = @"Oops";

        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1: {
                failureReason = @"The email was not found.";
                break;
            }
            case 2: {
                failureReason = @"The password is incorrect.";
                break;
            }
            case 3: {
                //Display Activation Screen
                self.headingLabel.text = @"Almost there.";
                failureReason = @"You need to activate your account.";

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                [self presentViewController:mainView animated:YES completion:nil];

                break;
            }
            case 4:
                failureReason = @"The email or password is incorrect";
                break;
            default:
                failureReason = @"Sorry! Login was unsuccessful.";
        }

        self.subHeadingLabel.text = failureReason;

        return;
    }

    [self.delegate loginControllerDidCompleteLogin:self];
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)sendResetPasswordRequest {
    NSString *email = [[SecurifiToolkit sharedInstance] loginEmail];
    NSLog(@"Email : %@", email);

    ResetPasswordRequest *resetCommand = [[ResetPasswordRequest alloc] init];
    resetCommand.email = self.emailID.text;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = RESET_PASSWORD_REQUEST;
    cloudCommand.command = resetCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)resetPasswordResponseCallback:(id)sender {
    [SNLog Log:@"%s", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ResetPasswordResponse *obj = (ResetPasswordResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason];

    if (obj.isSuccessful == 0) {
        NSLog(@"Reason Code %d", obj.reasonCode);
        NSString *failureReason;
        UIStoryboard *storyboard;
        UIViewController *mainView;

        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The username was not found";
                break;
            case 2:
                //Display Activation Screen
                self.headingLabel.text = @"Almost there.";
                failureReason = @"You need to activate your account.";
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                [self presentViewController:mainView animated:YES completion:nil];
                break;
            case 3:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            case 4:
                failureReason = @"The email ID is invalid.";
                break;
            case 5:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            default:
                break;
        }

        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }
    else {
        self.headingLabel.text = @"Almost there.";
        self.subHeadingLabel.text = @"Password reset link has been sent to your account.";
    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
