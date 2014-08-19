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
@property(nonatomic) BOOL lastEditedFieldWasPasswd;
@property(nonatomic) NSTimer *timeoutTimer;
@property(atomic) BOOL isLoggingIn;
@end

@implementation SFILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.labelText = @"One moment please...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];

    //PY 170913 - To stop the view from going below tab bar
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.emailID.clearsOnBeginEditing = NO;
    self.emailID.returnKeyType = UIReturnKeyNext;
    self.password.returnKeyType = UIReturnKeyDone;

    self.emailID.text = nil;
    self.password.text = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.emailID.delegate = self;
    self.password.delegate = self;

    [self tryEnableLostPwdButton];
    [self tryEnableLoginButton];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onNetworkDown:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onLoginResponse:)
                   name:kSFIDidCompleteLoginNotification
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHud];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.emailID.delegate = nil;
    self.password.delegate = nil;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self
                      name:NETWORK_DOWN_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:kSFIDidCompleteLoginNotification
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
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.loginButton.enabled = enabled;
    });
}

- (void)tryEnableLoginButton {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.loginButton.enabled = [self validateCredentials];
    });
}

- (void)tryEnableLostPwdButton {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.forgotPwdButton.enabled = (self.emailID.text.length > 0);
    });
}

- (BOOL)validateCredentials {
    return self.emailID.text.length > 0 && self.password.text.length > 0;
}

- (void)hideHud {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
        [self.HUD hide:YES afterDelay:1.0];
    });
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
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UITextField *other;
    if (self.emailID == textField) {
        other = self.password;
    }
    else {
        other = self.emailID;
    }

    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL enabled = str.length > 0 && other.text.length > 0;
    [self enableLoginButton:enabled];

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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // To prevent the Login Action being invoked when the keyboard hides after editing hte email address,
    // we keep track of the last edited one here.
    self.lastEditedFieldWasPasswd = (textField == self.password);
}

#pragma mark - Keyboard handler

- (void)onKeyboardDidShow:(id)notification {
    [self tryEnableLoginButton];
}

- (void)onKeyboardDidHide:(id)notice {
    BOOL valid = [self validateCredentials];

    if (valid && self.lastEditedFieldWasPasswd) {
        [self sendLoginWithEmailRequest];
    }

    [self tryEnableLoginButton];
    [self tryEnableLostPwdButton];
}

#pragma mark - UI Actions

- (void)onSignupButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFISignupViewController"];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:mainView];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)onForgetPasswordAction:(id)sender {
    [self.HUD show:YES];
    [self sendResetPasswordRequest];
}

- (IBAction)onLoginAction:(id)sender {
    [self.emailID endEditing:YES];
    [self.password endEditing:YES];

    if ([self validateCredentials]) {
        [self sendLoginWithEmailRequest];
    }
    else {
        [self setOopsMsg:@"Please enter Username and Password"];
    }
}

- (void)sendLoginWithEmailRequest {
    self.isLoggingIn = YES;
    [self showHudWithTimeout:10];

    [[SecurifiToolkit sharedInstance] asyncSendLoginWithEmail:self.emailID.text password:self.password.text];
    [self enableLoginButton:NO]; // will be reactivated in callback handler
}

- (void)markResetLoggingInState {
    self.isLoggingIn = NO;
}

- (void)showHudWithTimeout:(int)timeoutSecs {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutSecs
                                                                   target:self
                                                                 selector:@selector(onTimeout)
                                                                 userInfo:nil
                                                                  repeats:NO];
        [self.HUD show:YES];
    });
}

#pragma mark - Event handlers

- (void)onTimeout {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        [self hideHud];

        [self setOopsMsg:@"Sorry! Could not complete the request."];
        [self markResetLoggingInState];

        [self tryEnableLoginButton];
    });
}

- (void)onNetworkDown:(id)sender {
    [self hideHud];

    if (self.isLoggingIn) {
        [self setOopsMsg:@"Sorry! Could not complete the request."];
        [self markResetLoggingInState];
    }

    [self tryEnableLoginButton];
}

- (void)onLoginResponse:(id)sender {
    [self markResetLoggingInState];
    [self hideHud];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    // Login failed
    if ([notifier userInfo] == nil) {
        // Should never reach this path. UserInfo should be non-null.
        [self setOopsMsg:@"Sorry! Login was unsuccessful."];
        [SNLog Log:@"%s: login failed with nil userInfo ", __PRETTY_FUNCTION__];
        return;
    }

    LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

    if (!obj.isSuccessful) {
        NSLog(@"Login failure reason Code: %d", obj.reasonCode);

        switch (obj.reasonCode) {
            case 1: {
                [self setOopsMsg:@"The email was not found."];
                break;
            }
            case 2: {
                [self setOopsMsg:@"The password is incorrect."];
                break;
            }
            case 3: {
                //Display Activation Screen
                [self setHeadline:@"Almost there." subHeadline:@"You need to activate your account." loginButtonEnabled:NO];
                [self presentActivationScreen];

                break;
            }
            case 4: {
                [self setOopsMsg:@"The email or password is incorrect"];
                break;
            }
            default: {
                [self setOopsMsg:@"Sorry! Login was unsuccessful."];
            }
        }

        [self enableLoginButton:YES];

        return;
    }

    // If this far, then login was successful. Notify the delegate.
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
    [self hideHud];

    [SNLog Log:@"%s", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ResetPasswordResponse *obj = (ResetPasswordResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason];

    if (obj.isSuccessful == 0) {
        NSLog(@"Reason Code %d", obj.reasonCode);
        switch (obj.reasonCode) {
            case 1:
                [self setOopsMsg:@"The username was not found"];
                break;
            case 2:
                //Display Activation Screen
                [self setHeadline:@"Almost there." subHeadline:@"You need to activate your account." loginButtonEnabled:NO];
                [self presentActivationScreen];
                break;
            case 3:
                [self setOopsMsg:@"Sorry! Your password cannot be \nreset at the moment. Try again later."];
                break;
            case 4:
                [self setOopsMsg:@"The email ID is invalid."];
                break;
            case 5:
                [self setOopsMsg:@"Sorry! Your password cannot be \nreset at the moment. Try again later."];
                break;
            default:
                break;
        }

    }
    else {
        [self setHeadline:@"Almost there." subHeadline:@"Password reset link has been sent to your account." loginButtonEnabled:NO];
    }
}

- (void)presentActivationScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
    [self presentViewController:mainView animated:YES completion:nil];
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

// Shows the specified error message and enabled the Login Button
- (void)setOopsMsg:(NSString *)msg {
    [self setHeadline:@"Oops" subHeadline:msg loginButtonEnabled:YES];
}

- (void)setHeadline:(NSString *)headline subHeadline:(NSString*)subHeadline loginButtonEnabled:(BOOL)enabled {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.headingLabel.text = headline;
        self.subHeadingLabel.text = subHeadline;
        self.loginButton.enabled = enabled;
    });
}

@end
