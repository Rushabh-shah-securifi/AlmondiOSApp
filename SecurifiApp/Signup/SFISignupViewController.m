//
//  SFISignupViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "SFISignupViewController.h"
#import "Analytics.h"
#import "UIFont+Securifi.h"


#define CONTINUE_BUTTON_SIGNUP              1
#define CONTINUE_BUTTON_LOGIN               2

#define FOOTER_TERMS_CONDS                  1
#define FOOTER_RESEND_ACTIVATION_LINK       2
#define FOOTER_SIGNUP_DIFF_EMAIL            3

@interface SFISignupViewController () <UITextFieldDelegate>
@property(nonatomic) UIWebView *webview;
@property(nonatomic) UITextField *activeTextField;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property BOOL acceptedLicenseTerms;
@end

@implementation SFISignupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"password.hud.Changing password...", @"Changing password...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = NSLocalizedString(@"signup.navbar-title.Sign up", @"Sign up");

    self.scrollView.scrollEnabled = NO;
    self.scrollView.scrollsToTop = NO;

    [self showTermsAndConditions];
    [[Analytics sharedInstance] markSignUpForm];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.password.delegate = self;
    self.emailID.delegate = self;
    self.confirmPassword.delegate = self;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onSignupResponseCallback:)
                   name:SIGN_UP_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(validateResponseCallback:)
                   name:VALIDATE_RESPONSE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(keyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(keyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.emailID.delegate = nil;
    self.password.delegate = nil;
    self.confirmPassword.delegate = nil;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:SIGN_UP_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:VALIDATE_RESPONSE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:UIKeyboardDidShowNotification
                    object:nil];

    [center removeObserver:self
                      name:UIKeyboardDidHideNotification
                    object:nil];
}

- (void)showTermsAndConditions {
    UIBarButtonItem *declineButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"signup.barbutton.Decline", @"Decline") style:UIBarButtonItemStylePlain target:self action:@selector(onDeclineAction:)];
    self.navigationItem.leftBarButtonItem = declineButton;

    UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"signuo.barbutton.Accept", @"Accept") style:UIBarButtonItemStylePlain target:self action:@selector(onAcceptedTermsAndConditions)];
    self.navigationItem.rightBarButtonItem = acceptButton;

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"termsofuse" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:nil];

    self.webview = webView;
    self.scrollView.alpha = 0.0;
    [self.view addSubview:webView];
}

- (void)showSignupForm {
    [self displayScreenToSignup];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"signup.barbutton.Continue", @"Continue") style:UIBarButtonItemStylePlain target:self action:@selector(onContinueAction:)];
    continueButton.tag = CONTINUE_BUTTON_SIGNUP;
    self.navigationItem.rightBarButtonItem = continueButton;
    [self enableContinueButton:NO];

    [UIView animateWithDuration:0.5
                     animations:^() {
                         self.webview.alpha = 0.0;
                         self.scrollView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self.webview removeFromSuperview];
                         self.webview = nil;
                     }];
}

- (void)onAcceptedTermsAndConditions {
    self.acceptedLicenseTerms = YES;
    [self showSignupForm];
}

#pragma mark - Modes

- (void)displayScreenToSignup {
    self.emailID.text = @"";
    self.password.text = @"";
    self.confirmPassword.text = @"";
    self.lblPasswordStrength.text = @"";
    self.lblPasswordStrength.hidden = NO;
    self.passwordStrengthIndicator.hidden = NO;

    [self setStandardHeadline];
    [self setContinueButtonTag:CONTINUE_BUTTON_SIGNUP];
    [self setFooterForTag:FOOTER_TERMS_CONDS];
}

- (void)displayScreenToLogin {
    // Do not null out email text field because it is needed for re-sending confirmation email
    self.lblPasswordStrength.text = @"";
    self.lblPasswordStrength.hidden = YES;
    self.passwordStrengthIndicator.hidden = YES;

    [self setAlmostDoneHeadline];
    [self setContinueButtonTag:CONTINUE_BUTTON_LOGIN];
    [self setFooterForTag:FOOTER_RESEND_ACTIVATION_LINK];
}

- (void)setStandardHeadline {
    self.headingLabel.text = NSLocalizedString(@"signup.headline-text.Securifi Cloud Account.", @"Securifi Cloud Account.");
    self.subHeadingLabel.text = NSLocalizedString(@"signup.headline-text.Access your Almonds", @"Access your Almonds and\nyour home devices from anywhere.");
}

- (void)setSigningUpHeadline {
    self.headingLabel.text = NSLocalizedString(@"signup.headline-text.Signing up.", @"Signing up.");
    self.subHeadingLabel.text = NSLocalizedString(@"signup.subheadline-text.Please wait one moment...", @"Please wait one moment...");
}

- (void)setAlmostDoneHeadline {
    self.headingLabel.text = NSLocalizedString(@"signup.headline-text.Almost done.", @"Almost done.");
    self.subHeadingLabel.text = NSLocalizedString(@"signup.headline-text.An activation link was sent to your email", @"An activation link was sent to your email. \n Follow it, then tap Continue to login.");
}

- (void)setFooterForTag:(int)tag {
    NSString *label;
    NSString *button;

    switch (tag) {
        case FOOTER_TERMS_CONDS: {
            label = nil;
            button = nil;
            break;
        }

        case FOOTER_RESEND_ACTIVATION_LINK:
            label = @"";
            button = NSLocalizedString(@"signup.footerbutton.Resend the activation email", @"Resend the activation email");
            break;

        case FOOTER_SIGNUP_DIFF_EMAIL: {
            label = NSLocalizedString(@"signup.footerlabel.Do you want to create another account?", @"Do you want to create another account?");
            button = NSLocalizedString(@"signup.footerbutton.Signup using another email", @"Signup using another email");
            break;
        }

        default: {
            return;
        }
    }

    self.footerLabel.text = label;
    self.footerButton.tag = tag;

    if (button) {
        [self.footerButton setTitle:button forState:UIControlStateNormal];
        [self.footerButton setTitle:button forState:UIControlStateHighlighted];
        [self.footerButton setTitle:button forState:UIControlStateDisabled];
        [self.footerButton setTitle:button forState:UIControlStateSelected];
        self.footerButton.hidden = NO;
    }
    else {
        self.footerButton.hidden = YES;
    }

}

- (void)tryEnableContinueButton {
    BOOL valid = [self validateSignupValues];
    BOOL enabled = self.acceptedLicenseTerms && valid;

    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)enableContinueButton:(BOOL)enabled {
    enabled = self.acceptedLicenseTerms && enabled;
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)setContinueButtonTag:(int)tag {
    self.navigationItem.rightBarButtonItem.tag = tag;
}

- (int)continueButtonTag {
    return (int) self.navigationItem.rightBarButtonItem.tag;
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

- (void)keyboardDidShow:(NSNotification *)aNotification {
    [self enableContinueButton:NO];

    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect fieldRect = self.activeTextField.frame;
    fieldRect = CGRectOffset(fieldRect, 0, 3 * CGRectGetHeight(fieldRect));

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;

    if (!CGRectContainsPoint(aRect, fieldRect.origin)) {
        [self.scrollView scrollRectToVisible:fieldRect animated:YES];
    }
}

- (void)keyboardDidHide:(NSNotification *)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect rect = self.headingLabel.frame;
    if (!CGRectContainsPoint(self.view.frame, rect.origin)) {
        [self.scrollView scrollRectToVisible:rect animated:YES];
    }
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;//textField.text.length > 0;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailID) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [textField resignFirstResponder];
        [self.confirmPassword becomeFirstResponder];
    }
    else if (textField == self.confirmPassword) {
        [textField resignFirstResponder];
        SFICredentialsValidator *validator = [[SFICredentialsValidator alloc] init];
        PasswordStrengthType pwdStrength = [validator validatePassword:self.password.text];
        [self displayPasswordIndicator:pwdStrength];
        [self tryEnableContinueButton];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Class Methods - Handlers

- (void)dismissKeyboard {
    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }
    else if ([self.confirmPassword isFirstResponder]) {
        [self.confirmPassword resignFirstResponder];
    }
}

- (BOOL)validateSignupValues {
    SFICredentialsValidator *validator = [[SFICredentialsValidator alloc] init];
    if (self.emailID.text.length == 0) {
        [self setOopsMessage:NSLocalizedString(@"You forgot to enter your email ID.", @"You forgot to enter your email ID.")];
        return NO;
    }
    else if (![validator validateEmail:self.emailID.text]) {
        //Email Address is invalid.
        [self setOopsMessage:NSLocalizedString(@"You have entered an invalid email ID.", @"You have entered an invalid email ID.")];
        return NO;
    }
    else if (self.password.text.length == 0) {
        //If password empty
        [self setOopsMessage:NSLocalizedString(@"You forgot to enter your password.", @"You forgot to enter your password.")];
        return NO;
    }
    else if (self.password.text.length < PWD_MIN_LENGTH) {
        NSString *format = NSLocalizedString(@"The password should be %d - %d characters long.", @"The password should be %d - %d characters long.");
        [self setOopsMessage:[NSString stringWithFormat:format, PWD_MIN_LENGTH, PWD_MAX_LENGTH]];
        return NO;
    }
    else if (self.password.text.length > PWD_MAX_LENGTH) {
        NSString *format = NSLocalizedString(@"The password should be %d - %d characters long.", @"The password should be %d - %d characters long.");
        [self setOopsMessage:[NSString stringWithFormat:format, PWD_MIN_LENGTH, PWD_MAX_LENGTH]];
        return NO;
    }
    else if (![self.password.text isEqualToString:self.confirmPassword.text]) {
        //Match password and confirm password
        [self setOopsMessage:NSLocalizedString(@"There is a password mismatch.", @"There is a password mismatch.")];
        return NO;
    }
    else {
        [self setStandardHeadline];
        return YES;
    }
}

- (IBAction)onContinueAction:(id)sender {
    [self dismissKeyboard];

    int tag = [self continueButtonTag];

    if (tag == CONTINUE_BUTTON_LOGIN) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (tag == CONTINUE_BUTTON_SIGNUP) {
        if ([self validateSignupValues]) {
            [self sendSignupCommand];
        }
    }
}

- (void)onDeclineAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[Analytics sharedInstance] markDeclineSignupLicense];
}

- (IBAction)onCancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)footerButtonHandler:(id)sender {
    UIButton *btn = (UIButton *) sender;
    switch (btn.tag) {
        case FOOTER_TERMS_CONDS: {
            // do nothing
            break;
        }
        case FOOTER_RESEND_ACTIVATION_LINK: {
            [self sendReactivationRequest];
            break;
        }
        case FOOTER_SIGNUP_DIFF_EMAIL: {
            [self displayScreenToSignup];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Password strength

- (void)displayPasswordIndicator:(PasswordStrengthType)pwdStrength {
    if (pwdStrength == PasswordStrengthTypeTooShort) {
        self.passwordStrengthIndicator.progress = 0.2;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Too Short", @"Password: Too Short");
    }
    else if (pwdStrength == PasswordStrengthTypeTooLong) {
        self.passwordStrengthIndicator.progress = 0.2;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Too Long", @"Password: Too Long");
    }
    else if (pwdStrength == PasswordStrengthTypeWeak) {
        self.passwordStrengthIndicator.progress = 0.4;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:215 / 255.0f blue:0 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Weak", @"Password: Weak");
    }
    else if (pwdStrength == PasswordStrengthTypeModerate) {
        self.passwordStrengthIndicator.progress = 0.6;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:140 / 255.0f blue:48 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Medium", @"Password: Medium");
    }
    else if (pwdStrength == PasswordStrengthTypeStrong) {
        self.passwordStrengthIndicator.progress = 1;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:34 / 255.0f green:139 / 255.0f blue:34 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Strong", @"Password: Strong");
    }
}


#pragma mark - Cloud Command : Sender and Receivers

- (void)sendSignupCommand {
    [self setSigningUpHeadline];

    Signup *signupCommand = [[Signup alloc] init];
    signupCommand.UserID = [NSString stringWithString:self.emailID.text];
    signupCommand.Password = [NSString stringWithString:self.password.text];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_SIGNUP_COMMAND;
    cloudCommand.command = signupCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onSignupResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    SignupResponse *obj = (SignupResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.Reason);

    if (obj.isSuccessful) {
        [self displayScreenToLogin];
    }
    else {
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"The email ID is invalid.", @"The email ID is invalid.");
                break;

            case 2: {
                NSString *format = NSLocalizedString(@"The password should be %d - %d characters long.", @"The password should be %d - %d characters long.");
                failureReason = [NSString stringWithFormat:format, PWD_MIN_LENGTH, PWD_MAX_LENGTH];
                break;
            }

            case 3: {
                failureReason = NSLocalizedString(@"An account already exists with this email.", @"An account already exists with this email.");
                [self setFooterForTag:FOOTER_SIGNUP_DIFF_EMAIL];
                break;
            }

            case 4:
                //Ready for login
                [self displayScreenToLogin];
                break;

            case 5:
                failureReason = NSLocalizedString(@"The email or password was incorrect.", @"The email or password was incorrect.");
                break;

            default:
                failureReason = NSLocalizedString(@"Sorry! Signup was unsuccessful.", @"Sorry! Signup was unsuccessful.");
        }

        [self setOopsMessage:failureReason];
    }
}

- (void)sendReactivationRequest {
    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = self.emailID.text;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)validateResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);

    if (obj.isSuccessful) {
        [self displayScreenToLogin];
    }
    else {
        DLog(@"Reason Code %d", obj.reasonCode);

        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"The username was not found", @"The username was not found");
                break;
            case 2:
                failureReason = NSLocalizedString(@"The account is already validated", @"The account is already validated");
                break;
            case 3:
            case 5:
                failureReason = NSLocalizedString(@"Sorry! Cannot send reactivation link", @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.");
                break;
            case 4:
                failureReason = NSLocalizedString(@"The email ID is invalid.", @"The email ID is invalid.");
                break;
            default:
                break;
        }

        [self setOopsMessage:failureReason];
    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

- (void)setOopsMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.headingLabel.text = NSLocalizedString(@"Oops!", @"Oops!");
        self.subHeadingLabel.text = msg;
    });
}

@end
