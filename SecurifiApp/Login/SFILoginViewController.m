//
//  SFILoginViewController.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <SecurifiToolkit/SFIAlmondLocalNetworkSettings.h>
#import "SFILoginViewController.h"
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "SFIActivationViewController.h"
#import "UIFont+Securifi.h"
#import "RouterNetworkSettingsEditor.h"
#import "SFISignupViewController.h"
#import "UIColor+Securifi.h"
#import "KeyChainAccess.h"
#import "ResetPasswordRequest.h"
#import "Login.h"
#import "HTTPRequest.h"
#import "ConnectionStatus.h"
#import "UIViewController+Securifi.h"
#import "AlmondManagement.h"

@interface SFILoginViewController () <UITextFieldDelegate, RouterNetworkSettingsEditorDelegate, SFISignupViewControllerDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) BOOL lastEditedFieldWasPasswd;
@property(nonatomic) NSTimer *timeoutTimer;
@property(atomic) BOOL isLoggingIn;
@property(atomic) GenericCommand *loginCmd;
@end

@implementation SFILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginCmd =nil;

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.labelText = NSLocalizedString(@"hud.One moment please...", @"One moment please...");
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

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
    [self setStandardLoginMsg];
    
    switch (self.mode) {
        case SFILoginViewControllerMode_localLinkOption:
            break;
        case SFILoginViewControllerMode_switchToLocalConnection: {
            NSString *title = NSLocalizedString(@"login.local.Switch to Local Connection", @"login.local.Switch to Local Connection");
            [self.localActionButton setTitle:title forState:UIControlStateNormal];
            break;
        }
        case SFILoginViewControllerMode_accountCreated: {
            NSString *headline = NSLocalizedString(@"signup.headline-text.Almost done.", @"Almost done.");
            NSString *subHeadline = NSLocalizedString(@"signup.headline-text.An activation link was sent to your email", @"An activation link was sent to your email. \n Follow it, then tap Continue to login.");
            [self setHeadline:headline subHeadline:subHeadline loginButtonEnabled:NO];

            self.createAccountButton.hidden = YES;

            self.localActionLabel.text = NSLocalizedString(@"LoginViewController Did not receive any email?",@"Did not receive any email?");
            [self.localActionButton setTitle:NSLocalizedString(@"LoginViewController Resend Activation Link",@"Resend Activation Link") forState:UIControlStateNormal];
            break;
        }
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onConnectionStatusChanged:) name:CONNECTION_STATUS_CHANGE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onResetPasswordResponse:) name:RESET_PWD_RESPONSE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onValidateResponseCallback:) name:VALIDATE_RESPONSE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onLoginResponse:) name:kSFIDidCompleteLoginNotification object:nil];
    [center addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [center postNotificationName:LOGIN_PAGE_NOTIFIER object:nil];
    [[Analytics sharedInstance] markLoginForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHud];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.emailID.delegate = nil;
    self.password.delegate = nil;

    if (self.isBeingDismissed) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];

        [self.HUD removeFromSuperview];
        _HUD = nil;
    }
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
    NSString *emailId = self.emailID.text;
    [self tryEnableLostPwdButton:emailId];
}

- (void)tryEnableLostPwdButton:(const NSString *)emailId {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.forgotPwdButton.enabled = (emailId.length > 0);
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
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
    if(self.emailID == textField && range.location == 0 && [string isEqualToString:@" "]){
        // Returning no here to restrict whitespace as first char
        return NO;
    }
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];

    UITextField *other;
    if (self.emailID == textField) {
        other = self.password;
        [self tryEnableLostPwdButton:str];
    }
    else {
        other = self.emailID;
    }

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
    if (self.lastEditedFieldWasPasswd && !self.isLoggingIn) {
        NSLog(@"lastEditedFieldWasPasswd");
//        [self trySendLoginRequest:NO];
    }

    [self tryEnableLoginButton];
    [self tryEnableLostPwdButton];
}

#pragma mark - UI Actions

- (void)onCreateAccountAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];

    SFISignupViewController *ctrl = (SFISignupViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SFISignupViewController"];
    ctrl.delegate = self;

    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:navCtrl animated:YES completion:nil];
}


- (IBAction)onAddLocalAlmond:(id)sender {
    enum SFILoginViewControllerMode mode = self.mode;
    switch (mode) {
        case SFILoginViewControllerMode_localLinkOption: {
            RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
            editor.delegate = self;
            editor.makeLinkedAlmondCurrentOne = YES;
            editor.fromLoginPage = YES;
            UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
            [self presentViewController:ctrl animated:YES completion:nil];
            break;
        }
        case SFILoginViewControllerMode_switchToLocalConnection: {
            SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
            [AlmondManagement writeCurrentAlmond:[[AlmondManagement localLinkedAlmondList] objectAtIndex:0]];
            [toolkit setConnectionMode:SFIAlmondConnectionMode_local];
            [self.delegate loginControllerDidCompleteLogin:self];
            break;
        }
        case SFILoginViewControllerMode_accountCreated: {
            // in this mode, the button means: resend the activiation link
            [self sendReactivationRequest];
            break;
        }
    }
}

- (IBAction)onForgetPasswordAction:(id)sender {
    if(self.emailID.text.length == 0){
        [self showToast:@"Please enter your email address."];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.HUD show:YES];
    });
    
    [self sendResetPasswordRequest];
}

- (IBAction)onLoginAction:(id)sender {
    [self trySendLoginRequest:YES];

    if (self.emailID.isEditing || self.password.isEditing) {
        // Will dismiss keyboard, which will cause onKeyboardDidHide to issue the login request when the Password
        // field was the last edited. So, we change the state here before dismissing the keyboard.
        //
        // Note potential race condition: cannot completely rely on timing of self.isLoggingIn on trysendLoginRequest:
        // to lockout keyboard event handler, so we use this method instead.

        self.lastEditedFieldWasPasswd = NO;

        // Dismiss keyboard
        [self.emailID endEditing:YES];
        [self.password endEditing:YES];
    }

    [self tryEnableLoginButton];
    [self tryEnableLostPwdButton];
}

- (void)trySendLoginRequest:(BOOL)showOops {
    if ([self validateCredentials]) {
        [self sendLoginWithEmailRequest];
    }
    else if (showOops) {
        [self setOopsMsg:NSLocalizedString(@"Please enter Username and Password", @"Please enter Username and Password")];
    }
}

- (void)sendLoginWithEmailRequest {
    self.isLoggingIn = YES;
    [self showHudWithTimeout:10];

    [self asyncSendLoginWithEmail:self.emailID.text password:self.password.text];
    [self enableLoginButton:NO]; // will be reactivated in callback handler
}

- (void)asyncSendLoginWithEmail:(NSString *)email password:(NSString *)password {
    SecurifiToolkit* toolKit = [SecurifiToolkit sharedInstance];
    if ([toolKit isShutdown]) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }
    
    toolKit.scoreboard.loginCount++;
    NSLog(@"i am called");
    [toolKit tearDownLoginSession];
    [KeyChainAccess setSecEmail:email];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kPREF_USER_DEFAULT_LOGGED_IN_ONCE];
    
    Login *loginCommand = [Login new];
    loginCommand.UserID = email;
    loginCommand.Password = password;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_LOGIN_COMMAND;
    cmd.command = loginCommand;
    _loginCmd = nil;
    
    if([toolKit currentConnectionMode] != SFIAlmondConnectionMode_cloud ||
       [ConnectionStatus getConnectionStatus]!=(int)(ConnectionStatusType*)CONNECTED_TO_NETWORK){
        [toolKit asyncInitCloud];
        _loginCmd = cmd;
    }else
        [toolKit asyncSendToNetwork:cmd];
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
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self hideHud];

        [self setOopsMsg:NSLocalizedString(@"Sorry! Could not complete the request.", @"Sorry! Could not complete the request.")];
        [self markResetLoggingInState];

        [self tryEnableLoginButton];
    });
}

- (void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if(statusIntValue == (int)(ConnectionStatusType*)NO_NETWORK_CONNECTION){
        [self setSorryMsg:NSLocalizedString(@"Unable to establish Internet route to cloud service.", @"Unable to establish Internet route to cloud service.")];
        
    }else if(statusIntValue == (int)(ConnectionStatusType*)CONNECTED_TO_NETWORK){
        if ([toolkit isCloudReachable]) {
            if(_loginCmd!=nil){
                [toolkit asyncSendToNetwork:_loginCmd];
                _loginCmd=nil;
                return;
            }
            [self setStandardLoginMsg];
        }
    }
    
    [self markResetLoggingInState];
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
        [self setOopsMsg:NSLocalizedString(@"Sorry! Login was unsuccessful.", @"Sorry! Login was unsuccessful.")];
        ELog(@"Login response: failed with nil userInfo");
        return;
    }

    LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

    if (obj.isSuccessful) {
        // If this far, then login was successful. Notify the delegate.
        [self.delegate loginControllerDidCompleteLogin:self];
        return;
    }

    ELog(@"Login failure reason Code: %d", obj.reasonCode);

    switch (obj.reasonCode) {
        case 1: {
            [self setOopsMsg:NSLocalizedString(@"The email was not found.", @"The email was not found.")];
            break;
        }
        case 2: {
            [self setOopsMsg:NSLocalizedString(@"The password is incorrect.", @"The password is incorrect.")];
            break;
        }
        case 3: {
            //Display Activation Screen
            [self setHeadline:NSLocalizedString(@"Almost there.", @"Almost there.") subHeadline:NSLocalizedString(@"You need to activate your account.", @"You need to activate your account.") loginButtonEnabled:YES];
            [self presentActivationScreen];
            break;
        }
        case 4: {
            [self setOopsMsg:NSLocalizedString(@"The email or password is incorrect", @"The email or password is incorrect")];
            break;
        }
        default: {
            [self setOopsMsg:NSLocalizedString(@"Sorry! Login was unsuccessful.", @"Sorry! Login was unsuccessful.")];
        }
    }
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)sendResetPasswordRequest {
    NSString *email = self.emailID.text;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [[SecurifiToolkit sharedInstance] asyncRequestResetCloudPassword:email];
}


- (void)onResetPasswordResponse:(id)sender {
    [self hideHud];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if ([[data valueForKey:@"success"] boolValue] == YES) {
        [self setHeadline:NSLocalizedString(@"Almost there.", @"Almost there.") subHeadline:NSLocalizedString(@"Password reset link has been sent to your account.", @"Password reset link has been sent to your account.") loginButtonEnabled:NO];
    }
    else {
        NSString *failureReason;
        if([[data valueForKey:@"reason"] isEqualToString:@"Email Taken"]){
            failureReason = @"Fail";
        }
        else {
            failureReason = @"Fail";
        }
    }
    
//    ResetPasswordResponse *obj = (ResetPasswordResponse *) [data valueForKey:@"data"];

//    if (obj.isSuccessful) {
//        [self setHeadline:NSLocalizedString(@"Almost there.", @"Almost there.") subHeadline:NSLocalizedString(@"Password reset link has been sent to your account.", @"Password reset link has been sent to your account.") loginButtonEnabled:NO];
//    }
//    else {
//        switch (obj.reasonCode) {
//            case 1:
//                [self setOopsMsg:NSLocalizedString(@"sensor.activation.The username was not found", @"The username was not found")];
//                break;
//            case 2:
//                //Display Activation Screen
//                [self setHeadline:NSLocalizedString(@"Almost there.", @"Almost there.") subHeadline:NSLocalizedString(@"You need to activate your account.", @"You need to activate your account.") loginButtonEnabled:NO];
//                [self presentActivationScreen];
//                break;
//            case 3:
//            case 5:
//                [self setOopsMsg:NSLocalizedString(@"Sorry! Your password cannot be reset at the moment. Try again later.", @"Sorry! Your password cannot be reset at the moment. Try again later.")];
//                break;
//            case 4:
//                [self setOopsMsg:NSLocalizedString(@"The email ID is invalid.", @"The email ID is invalid.")];
//                break;
//            default:
//                break;
//        }
//    }
}

- (void)sendReactivationRequest {
    [self showHudWithTimeout:10];

    NSString *email = self.emailID.text;
    if (email.length == 0) {
        return;
    }
    
    HTTPRequest *request = [HTTPRequest new];
    [request sendAsyncHTTPRequestResendActivationLink:email];
}

- (void)onValidateResponseCallback:(id)sender {
    [self hideHud];
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if ([[data valueForKey:@"success"] boolValue] == YES) {
        [self setHeadline:NSLocalizedString(@"Almost there.", @"Almost there.") subHeadline:NSLocalizedString(@"Password reset link has been sent to your account.", @"Password reset link has been sent to your account.") loginButtonEnabled:YES];
    }
    else {
        NSString *failureReason = data[@"reason"];
        if([[data valueForKey:@"reason"] isEqualToString:@"Already Validated"]){
            failureReason = NSLocalizedString(@"The account is already validated", @"The account is already validated");
        }else if([[data valueForKey:@"reason"] isEqualToString:@"EmailServer Down"]|| [[data valueForKey:@"reason"] isEqualToString:@"Database error"]){
            failureReason = NSLocalizedString(@"Sorry! Cannot send reactivation link", @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.");
        }else if([[data valueForKey:@"reason"] isEqualToString:@"No such user"]){
            failureReason = NSLocalizedString(@"The username was not found", @"The username was not found");
        }
        //        switch (obj.reasonCode) {
        //            case 1:
        //                failureReason = NSLocalizedString(@"The username was not found", @"The username was not found");
        //                break;
        //            case 2:
        //                failureReason = NSLocalizedString(@"The account is already validated", @"The account is already validated");
        //                break;
        //            case 3:
        //            case 5:
        //                failureReason = NSLocalizedString(@"Sorry! Cannot send reactivation link", @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.");
        //                break;
        //            case 4:
        //                failureReason = NSLocalizedString(@"The email ID is invalid.", @"The email ID is invalid.");
        //                break;
        //            default:
        //                break;
        //        }
        
        [self setOopsMsg:failureReason];
    }
}

- (void)presentActivationScreen {
    dispatch_async(dispatch_get_main_queue(), ^() {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SFIActivationViewController *ctrl = (SFIActivationViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
        ctrl.emailID = self.emailID.text;
        [self presentViewController:ctrl animated:YES completion:nil];
    });
}

// Shows the specified error message and enabled the Login Button
- (void)setOopsMsg:(NSString *)msg {
    [self setHeadline:NSLocalizedString(@"Oops!", @"Oops!") subHeadline:msg loginButtonEnabled:YES];
}

// Shows the specified error message and enabled the Login Button
- (void)setSorryMsg:(NSString *)msg {
    [self setHeadline:NSLocalizedString(@"Sorry!", @"Sorry!") subHeadline:msg loginButtonEnabled:YES];
}

// Shows the specified error message and enabled the Login Button
- (void)setLoginMsg:(NSString *)msg {
    [self setHeadline:NSLocalizedString(@"Login", @"Login") subHeadline:msg loginButtonEnabled:YES];
}

- (void)setStandardLoginMsg {
    [self setLoginMsg:NSLocalizedString(@"Monitor and Control your home from anywhere.", @"Monitor and Control\nyour home from anywhere.")];
}

- (void)setHeadline:(NSString *)headline subHeadline:(NSString *)subHeadline loginButtonEnabled:(BOOL)enabled {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.headingLabel.text = headline;
        self.subHeadingLabel.text = subHeadline;
        self.loginButton.enabled = enabled;
    });
}

#pragma mark - RouterNetworkSettingsEditorDelegate methods

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [self networkSettingsEditorDidChangeSettings:editor settings:newSettings];
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    dispatch_async(dispatch_get_main_queue(), ^() {
    [editor.navigationController dismissViewControllerAnimated:YES completion:^() {
        [self.delegate loginControllerDidCompleteLogin:self];
        }];
    });
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [editor.navigationController dismissViewControllerAnimated:YES completion:^() {
            [self.delegate loginControllerDidCompleteLogin:self];
        }];

    });
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {

}

#pragma mark - SFISignupViewControllerDelegate methods

- (void)signupControllerDidComplete:(SFISignupViewController *)ctrl email:(NSString *)email {
    self.emailID.text = email;

    UIColor *color = [UIColor securifiScreenGreen];
    self.view.backgroundColor = color;
    [self.loginButton setTitleColor:color forState:UIControlStateNormal];

    self.mode = SFILoginViewControllerMode_accountCreated;
}


@end
