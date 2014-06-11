//
//  SFISignupViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFISignupViewController.h"
#import "SNLog.h"
#import "SFIOfflineDataManager.h"
#import "SFIDatabaseUpdateService.h"
#import "AlmondPlusConstants.h"
#import "SFIReachabilityManager.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

#define SIGNUP   1
#define LOGIN    2
#define REGEX_PASSWORD_ONE_UPPERCASE @"^(?=.*[A-Z]).*$"  //Should contains one or more uppercase letters
#define REGEX_PASSWORD_ONE_LOWERCASE @"^(?=.*[a-z]).*$"  //Should contains one or more lowercase letters
#define REGEX_PASSWORD_ONE_NUMBER @"^(?=.*[0-9]).*$"  //Should contains one or more number
#define REGEX_PASSWORD_ONE_SYMBOL @"^(?=.*[!@#$%&_]).*$"  //Should contains one or more symbol
#define REGEX_EMAIL @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$"

@interface SFISignupViewController ()
typedef enum {
    PasswordStrengthTypeTooShort,
    PasswordStrengthTypeWeak,
    PasswordStrengthTypeModerate,
    PasswordStrengthTypeStrong
} PasswordStrengthType;

@property(nonatomic, readonly) MBProgressHUD *HUD;
@property NSInteger state;
@property NSInteger cloudState;

@end

@implementation SFISignupViewController
@synthesize emailID;
@synthesize confirmPassword;
@synthesize password;
@synthesize headingLabel;
@synthesize subHeadingLabel;
@synthesize passwordStrengthIndicator;
@synthesize lblPasswordStrength;

#pragma mark - View lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
   self.state =  SIGNUP;

    //PY 181013 - Button tag
    self.footerButton.tag = 1; //Terms and Condition
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SignupResponseCallback:)
                                                 name:SIGN_UP_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];

    //PY 311013 Reconnection Logic
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDownNotifier:)
                                                 name:NETWORK_DOWN_NOTIFIER
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkUpNotifier:)
                                                 name:NETWORK_UP_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateResponseCallback:)
                                                 name:VALIDATE_RESPONSE_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetPasswordResponseCallback:)
                                                 name:RESET_PWD_RESPONSE_NOTIFIER
                                               object:nil];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SNLog Log:@"Method Name: %s", __PRETTY_FUNCTION__];


    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SIGN_UP_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];


    //PY 311013 Reconnection Logic
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_UP_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_DOWN_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VALIDATE_RESPONSE_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RESET_PWD_RESPONSE_NOTIFIER
                                                  object:nil];
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


#pragma mark - Keyboard Methods

- (void)resignKeyboard:(id)sender {

    if ([emailID isFirstResponder]) {
        [emailID resignFirstResponder];

    }
    else if ([password isFirstResponder]) {
        [password resignFirstResponder];
    }
    else if ([confirmPassword isFirstResponder]) {
        [confirmPassword resignFirstResponder];
    }
}

- (void)previousField:(id)sender {
    if ([emailID isFirstResponder]) {
        [confirmPassword becomeFirstResponder];
    }
    else if ([password isFirstResponder]) {
        [emailID becomeFirstResponder];
    }
    else if ([confirmPassword isFirstResponder]) {
        [password becomeFirstResponder];
    }
}

- (void)nextField:(id)sender {
    if ([emailID isFirstResponder]) {
        [password becomeFirstResponder];
    }
    else if ([password isFirstResponder]) {
        [confirmPassword becomeFirstResponder];
    }
    else if ([confirmPassword isFirstResponder]) {
        [emailID becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailID) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [textField resignFirstResponder];
        if (self.state == SIGNUP) {
            [self.confirmPassword becomeFirstResponder];
        }
        else {
            //Send Login command
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loginResponse:)
                                                         name:LOGIN_NOTIFIER
                                                       object:nil];
            [self sendLoginCommand];
        }
    }
    else if (textField == self.confirmPassword) {
        [textField resignFirstResponder];
        NSLog(@"Signup Action!!");
        //[self signupButtonHandler:nil];
        //Check password
        PasswordStrengthType pwdStrength = [self checkPasswordStrength:self.password.text];
        [self displayPasswordIndicator:pwdStrength];
    }
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification {
    //Assign new frame to your view
    [self.view setFrame:CGRectMake(0, -105, self.view.frame.size.width, self.view.frame.size.height)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.

}

- (void)keyboardDidHide:(NSNotification *)notification {
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.password) {
        PasswordStrengthType pwdStrength = [self checkPasswordStrength:self.password.text];
        [self displayPasswordIndicator:pwdStrength];
    }
    return TRUE;
}


#pragma mark - Class Methods - Handlers

- (IBAction)backClick:(id)sender {
    if ([emailID isFirstResponder]) {
        [emailID resignFirstResponder];

    }
    else if ([password isFirstResponder]) {
        [password resignFirstResponder];
    }

    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)doneHandler {
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    //    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIMainViewController"];
    //    [self presentViewController:mainView animated:YES completion:NULL];
    //PY 170913 - Use navigation controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signupButtonHandler:(id)sender {

    if (self.state == SIGNUP) {
        if ([emailID isFirstResponder]) {
            [emailID resignFirstResponder];

        }
        else if ([password isFirstResponder]) {
            [password resignFirstResponder];
        }
        else if ([confirmPassword isFirstResponder]) {
            [confirmPassword resignFirstResponder];
        }

        //If email is empty
        if ([emailID.text isEqualToString:@""]) {
            headingLabel.text = @"Oops!";
            subHeadingLabel.text = @"You forgot to enter your email id.";
        }
            //Valid email
        else if (![self validateEmail:emailID.text]) {
            //Email Address is invalid.
            headingLabel.text = @"Oops!";
            subHeadingLabel.text = @"You have entered an invalid email id.";
        }
            //If password empty
        else if ([password.text isEqualToString:@""]) {
            headingLabel.text = @"Oops!";
            subHeadingLabel.text = @"You forgot to enter your password.";
        }
        else if (password.text.length < 6) {
            headingLabel.text = @"Oops!";
            subHeadingLabel.text = @"The password should be atleast 6 characters long.";
        }
            //Match password and confirm password
        else if (![password.text isEqualToString:confirmPassword.text]) {
            headingLabel.text = @"Oops!";
            subHeadingLabel.text = @"There is a password mismatch.";
        }
        else {
            [self sendSignupCommand];
        }

    }
    else if (self.state == LOGIN) {
        if ([[emailID text] isEqualToString:@""] || [[password text] isEqualToString:@""]) {
            self.headingLabel.text = @"Oops";
            self.subHeadingLabel.text = @"Please enter Username and Password";
        }
        else {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loginResponse:)
                                                         name:LOGIN_NOTIFIER
                                                       object:nil];
            [self sendLoginCommand];
        }
    }
}


- (IBAction)footerButtonHandler:(id)sender {
    UIButton *btn = (UIButton *) sender;
    NSLog(@"Button Text: %@ Tag: %d", btn.currentTitle, btn.tag);
    switch (btn.tag) {
        case 1: {
            //Terms and Condition
            NSLog(@"Terms and Condition");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFITermsViewController"];
            [self presentViewController:mainView animated:YES completion:nil];
            break;
        }
        case 2:
            //Resend activation link
            NSLog(@"Resend activation link");
            [self sendReactivationRequest];
            break;
        case 3:
            //Signup using another email
            NSLog(@"Signup using another email");
            //Show sign up screen with empty
            [self displayScreenToSignup];
            break;
        default:
            break;
    }
}

- (IBAction)forgotPwdButtonHandler:(id)sender {
    NSLog(@"Forgot Button Handler");
    [self sendResetPasswordRequest];
}

- (IBAction)loginButtonHandler:(id)sender {
    NSLog(@"Login Button Handler");
   self.state =  LOGIN;
    self.headingLabel.text = @"Login";
    self.subHeadingLabel.text = @"Access your Almonds and \nyour home devices from anywhere.";
    [self displayScreenToLogin];
}


- (void)displayScreenToLogin {
   self.state =  LOGIN;

    self.password.text = @"";
    self.password.hidden = FALSE;
    self.confirmPassword.hidden = TRUE;
    self.loginButton.hidden = TRUE;
    self.forgotPwdButton.hidden = FALSE;
    self.lblPasswordStrength.hidden = TRUE;
    self.passwordStrengthIndicator.hidden = TRUE;
    self.footerLabel.text = @"Did not receive any email?";
    [self.footerButton setTitle:@"Resend activation link" forState:UIControlStateNormal];
    [self.footerButton setTitle:@"Resend activation link" forState:UIControlStateHighlighted];
    [self.footerButton setTitle:@"Resend activation link" forState:UIControlStateDisabled];
    [self.footerButton setTitle:@"Resend activation link" forState:UIControlStateSelected];
    //PY 181013 - Button tag
    self.footerButton.tag = 2; //Resend activation Link
}

- (void)displayScreenToSignup {
   self.state =  SIGNUP;

    self.headingLabel.text = @"Securifi Cloud Account.";
    self.subHeadingLabel.text = @"Access your Almonds and\nyour home devices from anywhere.";

    self.emailID.enabled = TRUE;
    self.emailID.text = @"";
    self.password.text = @"";
    self.password.hidden = FALSE;
    self.confirmPassword.text = @"";
    self.confirmPassword.hidden = FALSE;
    self.loginButton.hidden = TRUE;
    self.forgotPwdButton.hidden = TRUE;
    self.lblPasswordStrength.text = @"";
    self.lblPasswordStrength.hidden = FALSE;
    self.passwordStrengthIndicator.hidden = FALSE;
    self.footerLabel.text = @"By tapping Continue you are indicating that \nyou have read and agreed to our";
    [self.footerButton setTitle:@"Terms and Conditions" forState:UIControlStateNormal];
    [self.footerButton setTitle:@"Terms and Conditions" forState:UIControlStateHighlighted];
    [self.footerButton setTitle:@"Terms and Conditions" forState:UIControlStateDisabled];
    [self.footerButton setTitle:@"Terms and Conditions" forState:UIControlStateSelected];
    //PY Button tag
    self.footerButton.tag = 1;

}


- (PasswordStrengthType)checkPasswordStrength:(NSString *)strPassword {
    NSInteger len = strPassword.length;
    //will contains password strength
    int strength = 0;

    if (len == 0) {
        return PasswordStrengthTypeTooShort;
    }
    else if (len < 6) {
        return PasswordStrengthTypeTooShort;
    }
    else if (len <= 9) {
        strength += 1;
    }
    else {
        strength += 2;
    }

    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_UPPERCASE caseSensitive:YES];
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_LOWERCASE caseSensitive:YES];
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_NUMBER caseSensitive:YES];
    strength += [self validateString:strPassword withPattern:REGEX_PASSWORD_ONE_SYMBOL caseSensitive:YES];

    if (strength < 3) {
        return PasswordStrengthTypeWeak;
    }
    else if (3 <= strength && strength < 6) {
        return PasswordStrengthTypeModerate;
    }
    else {
        return PasswordStrengthTypeStrong;
    }
}

// Validate the input string with the given pattern and
// return the result as a boolean
- (int)validateString:(NSString *)string withPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:((caseSensitive) ? 0 : NSRegularExpressionCaseInsensitive) error:&error];

    NSAssert(regex, @"Unable to create regular expression");

    NSRange textRange = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];

    BOOL didValidate = 0;

    // Did we find a matching range
    if (matchRange.location != NSNotFound) {
        didValidate = 1;
    }

    return didValidate;
}

- (void)displayPasswordIndicator:(PasswordStrengthType)pwdStrength {
    if (pwdStrength == PasswordStrengthTypeTooShort) {
        passwordStrengthIndicator.progress = 0.2;
        passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        lblPasswordStrength.text = @"Too Short";
    }
    else if (pwdStrength == PasswordStrengthTypeWeak) {
        passwordStrengthIndicator.progress = 0.4;
        passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:215 / 255.0f blue:0 / 255.0f alpha:1.0f];
        lblPasswordStrength.text = @"Weak";
    }
    else if (pwdStrength == PasswordStrengthTypeModerate) {
        passwordStrengthIndicator.progress = 0.6;
        passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:140 / 255.0f blue:48 / 255.0f alpha:1.0f];
        lblPasswordStrength.text = @"Medium";
    }
    else if (pwdStrength == PasswordStrengthTypeStrong) {
        passwordStrengthIndicator.progress = 1;
        passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:34 / 255.0f green:139 / 255.0f blue:34 / 255.0f alpha:1.0f];
        lblPasswordStrength.text = @"Strong";
    }
}

- (BOOL)validateEmail:(NSString *)emailString {
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:REGEX_EMAIL options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    if (regExMatches == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - Reconnection

- (void)networkUpNotifier:(id)sender {
    [SNLog Log:@"Method Name: %s Signup controller :In networkUP notifier", __PRETTY_FUNCTION__];
    self.cloudState = [[SecurifiToolkit sharedInstance] getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.cloudState];

    //PY 311013 Reconnection Logic
    if (self.cloudState == SDK_UNINITIALIZED) {
        [[SecurifiToolkit sharedInstance] initSDKCloud];
        [self.HUD hide:YES];
    }
    [SNLog Log:@"Method Name: %s State Again : %d", __PRETTY_FUNCTION__, self.cloudState];
}


- (void)networkDownNotifier:(id)sender {
    self.cloudState = [[SecurifiToolkit sharedInstance] getConnectionState];
    [SNLog Log:@"Method Name: %s DOWN State : %d", __PRETTY_FUNCTION__, self.cloudState];
    if (self.cloudState == NETWORK_DOWN) {
        [self.HUD hide:YES];
        self.HUD.labelText = @"Network Down";
        [self.HUD hide:YES afterDelay:1];
    }
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    //Reachability *reachability = (Reachability *)[notification object];
    if ([SFIReachabilityManager isReachable]) {
        NSLog(@"Reachable");

        [self.HUD hide:YES];
        self.HUD.labelText = @"Reconnecting...";
        [self.HUD hide:YES afterDelay:1];

        [[SecurifiToolkit sharedInstance] initSDK];
    }
    else {
        NSLog(@"Unreachable");
    }
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)sendLoginCommand {
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    Login *loginCommand = [[Login alloc] init];
    loginCommand.UserID = [NSString stringWithString:emailID.text];
    loginCommand.Password = [NSString stringWithString:password.text];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:loginCommand.UserID forKey:EMAIL];
    [prefs synchronize];

    cloudCommand.commandType = LOGIN_COMMAND;
    cloudCommand.command = loginCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- LoginCommand", __PRETTY_FUNCTION__];

        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];
        }

        [SNLog Log:@"Method Name: %s Before Writing to socket -- LoginCommand", __PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}

- (void)loginResponse:(id)sender {

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Login failed
    if ([notifier userInfo] == nil) {
        [SNLog Log:@"In Method Name: %s TEMP Pass failed", __PRETTY_FUNCTION__];

    }
    else {
        [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];

        LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

        [SNLog Log:@"In Method Name: %s UserID %@", __PRETTY_FUNCTION__, obj.userID];
        [SNLog Log:@"In Method Name: %s TempPass %@", __PRETTY_FUNCTION__, obj.tempPass];
        [SNLog Log:@"In Method Name: %s isSuccessful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
        [SNLog Log:@"In Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.reason];
        //[SNLog Log:@"In Method Name: %s Reason : %d", __PRETTY_FUNCTION__,obj.reasonCode];
        NSLog(@"Reason Code: %d", obj.reasonCode);

        if (obj.isSuccessful == 0) {


            NSString *failureReason;
//            UIStoryboard *storyboard;
//            UIViewController *mainView;
            switch (obj.reasonCode) {
                case 1:
                    failureReason = @"The email was not found.";
                    break;
                case 2:
                    failureReason = @"The password is incorrect.";
                    break;
                case 3:
                    failureReason = @"The email is not activated.";
//                    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//                    mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
//                    [self presentViewController:mainView animated:YES completion:nil];
                    break;
                case 4:
                    failureReason = @"The email or password is incorrect";
                    break;
                default:
                    failureReason = @"Sorry! Login was unsuccessful.";
            }
            self.headingLabel.text = @"Oops";
            self.subHeadingLabel.text = failureReason;

        }
        else if (obj.isSuccessful == 1) {
            [SNLog Log:@"In Method Name: %s Login Successful -- Load different view", __PRETTY_FUNCTION__];

            self.HUD.dimBackground = YES;
            self.HUD.labelText = @"Loading your personal data.";
            [self.HUD show:YES];

            //Retrieve Almond List, Device List and Device Value - Before displaying the screen
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(AlmondListResponseCallback:)
                                                         name:ALMOND_LIST_NOTIFIER
                                                       object:nil];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SFIDatabaseUpdateService stopDatabaseUpdateService];
                [SFIDatabaseUpdateService startDatabaseUpdateService];
            });

            [self loadAlmondList];
        }
    }
}


- (void)sendSignupCommand {
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    Signup *signupCommand = [[Signup alloc] init];
    signupCommand.UserID = [NSString stringWithString:emailID.text];
    signupCommand.Password = [NSString stringWithString:password.text];

    cloudCommand.commandType = SIGNUP_COMMAND;
    cloudCommand.command = signupCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];


        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}

- (void)SignupResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    SignupResponse *obj = (SignupResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"Method Name: %s Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.Reason];
    //[SNLog Log:@"Method Name: %s Reason : %d", __PRETTY_FUNCTION__, obj.reasonCode];
    NSLog(@"Reason Code %d", obj.reasonCode);
    if (obj.isSuccessful == 0) {
        //PY 181013: Reason Code
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The email ID is invalid.";
                break;
            case 2:
                failureReason = @"The password should be atleast 6 characters long.";
                break;
            case 3:
                failureReason = @"An account already exists with this email.";
                self.forgotPwdButton.hidden = FALSE;
                self.loginButton.hidden = FALSE;
                self.password.hidden = TRUE;
                self.confirmPassword.hidden = TRUE;
                self.emailID.enabled = FALSE;
                self.footerLabel.text = @"Do you want to create another account?";
                //self.footerButton.titleLabel.text = @"Signup using another email";
                [self.footerButton setTitle:@"Signup using another email" forState:UIControlStateNormal];
                [self.footerButton setTitle:@"Signup using another email" forState:UIControlStateHighlighted];
                [self.footerButton setTitle:@"Signup using another email" forState:UIControlStateDisabled];
                [self.footerButton setTitle:@"Signup using another email" forState:UIControlStateSelected];
                //PY 181013 - Button tag
                self.footerButton.tag = 3; //Signup using another email.
                break;
            case 4:
                //                failureReason = @"Your user has been created. Please try to login.";
                //                self.forgotPwdButton.hidden = FALSE;
                //                self.loginButton.hidden = FALSE;
                //                self.password.hidden = TRUE;
                //                self.confirmPassword.hidden = TRUE;
                //                self.emailID.enabled = FALSE;
                //Ready for login
                self.headingLabel.text = @"Almost done.";
                self.subHeadingLabel.text = @"An activation link was sent to your email. \n Follow it, then login below.";
                [self displayScreenToLogin];
                break;
            case 5:
                failureReason = @"The email or password was incorrect.";
                break;
            default:
                failureReason = @"Sorry! Signup was unsuccessful.";
        }
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;


    }
    else {
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"bundle:nil];
        //        UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SFIMainViewController"];
        //        [self presentViewController:viewController animated:YES completion:NULL];

        //Login Screen
        self.headingLabel.text = @"Almost done.";
        self.subHeadingLabel.text = @"An activation link was sent to your email. \n Follow it, then login below.";
        [self displayScreenToLogin];
        //PY 170913 - Use navigation controller
        //[self.navigationController popViewControllerAnimated:YES];


    }
    //NSString *log = [NSString stringWithFormat:@"%@\n\n%@ : %d",emailID.text,@"Registered",obj.isSuccessful];

    /*
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle:@"User Registration"
     message:log
     delegate:self
     cancelButtonTitle:NSLocalizedString(@"OK", @"")
     otherButtonTitles: nil];
     
     [alert
     performSelector:@selector(show)
     onThread:[NSThread mainThread]
     withObject:nil
     waitUntilDone:NO];
     */
}


- (void)loadAlmondList {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];

    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = almondListCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}

- (void)AlmondListResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received Almond List response", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
        [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];
        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
    }

    self.HUD.hidden = YES;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"InitialSlide"];
    [self presentViewController:mainView
                       animated:YES
                     completion:nil];
}

- (void)sendReactivationRequest {
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSString *email = [prefs objectForKey:EMAIL];
//    NSLog(@"Email : %@", email);

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = emailID.text;

    cloudCommand.commandType = VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];

        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];
        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}

- (void)validateResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"Method Name: %s Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.reason];

    if (obj.isSuccessful == 0) {
        NSLog(@"Reason Code %d", obj.reasonCode);
        //PY 181013: Reason Code
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The username was not found";
                break;
            case 2:
                failureReason = @"The account is already validated";
                break;
            case 3:
                failureReason = @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.";
                break;
            case 4:
                failureReason = @"The email ID is invalid.";
                break;
            case 5:
                failureReason = @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.";
                break;
            default:break;
        }
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }
    else {
        self.headingLabel.text = @"Almost there";
        self.subHeadingLabel.text = @"Reactivation link has been sent to your account.";
    }
}

- (void)sendResetPasswordRequest {
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    ResetPasswordRequest *resetCommand = [[ResetPasswordRequest alloc] init];
    resetCommand.email = emailID.text;

    cloudCommand.commandType = RESET_PASSWORD_REQUEST;
    cloudCommand.command = resetCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];


        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}

- (void)resetPasswordResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ResetPasswordResponse *obj = (ResetPasswordResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"Method Name: %s Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.reason];

    if (obj.isSuccessful == 0) {
        NSLog(@"Reason Code %d", obj.reasonCode);

        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The username was not found";
                break;
            case 2: {
                //Display Activation Screen
                self.headingLabel.text = @"Almost there.";
                failureReason = @"You need to activate your account.";

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

                UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                [self presentViewController:mainView animated:YES completion:nil];
                break;
            }
            case 3:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            case 4:
                failureReason = @"The email ID is invalid.";
                break;
            case 5:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            default:break;
        }
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }
    else {
        self.headingLabel.text = @"Almost there";
        self.subHeadingLabel.text = @"Password reset link has been sent to your account.";
    }
}

@end
