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
    _HUD.labelText = @"One moment please...";
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    //PY 170913 - To stop the view from going below tab bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.emailID.delegate = self;
    self.password.delegate = self;

    self.emailID.text = nil;
    self.password.text = nil;

    self.emailID.clearsOnBeginEditing = NO;
    self.password.returnKeyType = UIReturnKeyDone;

    [self tryEnableLostPwdButton];
    [self enableLoginButton:NO];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.emailID.delegate = nil;
    self.password.delegate = nil;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
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
    self.loginButton.enabled = enabled;
}

- (void)tryEnableLostPwdButton {
    self.forgotPwdButton.enabled = (self.emailID.text.length > 0);
}

- (BOOL)validateCredentials {
    return self.emailID.text.length > 0 && self.password.text.length > 0;
}

- (void)hideHud {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
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
//    [self tryEnableLostPwdButton];
}

#pragma mark - Keyboard handler

- (void)onKeyboardDidShow:(id)notification {
    [self enableLoginButton:NO];
}

- (void)onKeyboardDidHide:(id)notice {
    BOOL valid = [self validateCredentials];

    if (valid) {
        [self sendLoginWithEmailRequest];
    }

    [self enableLoginButton:NO];
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
    [self.HUD show:YES];

    [[SecurifiToolkit sharedInstance] asyncSendLoginWithEmail:self.emailID.text password:self.password.text];
    self.loginButton.enabled = NO;
}

#pragma mark - Event handlers

- (void)onLoginResponse:(id)sender {
    [self hideHud];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Login failed
    if ([notifier userInfo] == nil) {
        [SNLog Log:@"In %s: TEMP Pass failed", __PRETTY_FUNCTION__];
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
