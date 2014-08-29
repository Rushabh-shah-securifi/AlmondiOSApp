//
//  SFISignupViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFISignupViewController.h"
#import "SNLog.h"
#import "MBProgressHUD.h"
#import "Analytics.h"

#define PWD_MIN_LENGTH 6
#define PWD_MAX_LENGTH 32

#define CONTINUE_BUTTON_SIGNUP              1
#define CONTINUE_BUTTON_LOGIN               2

#define FOOTER_TERMS_CONDS                  1
#define FOOTER_RESEND_ACTIVATION_LINK       2
#define FOOTER_SIGNUP_DIFF_EMAIL            3

#define REGEX_PASSWORD_ONE_UPPERCASE @"^(?=.*[A-Z]).*$"  //Should contains one or more uppercase letters
#define REGEX_PASSWORD_ONE_LOWERCASE @"^(?=.*[a-z]).*$"  //Should contains one or more lowercase letters
#define REGEX_PASSWORD_ONE_NUMBER @"^(?=.*[0-9]).*$"  //Should contains one or more number
#define REGEX_PASSWORD_ONE_SYMBOL @"^(?=.*[!@#$%&_]).*$"  //Should contains one or more symbol
#define REGEX_EMAIL @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$"

@interface SFISignupViewController () <UITextFieldDelegate>
typedef enum {
    PasswordStrengthTypeTooShort,
    PasswordStrengthTypeTooLong,
    PasswordStrengthTypeWeak,
    PasswordStrengthTypeModerate,
    PasswordStrengthTypeStrong
} PasswordStrengthType;

@property(nonatomic) UIWebView *webview;
@property(nonatomic) UITextField *activeTextField;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property BOOL acceptedLicenseTerms;
@end

@implementation SFISignupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = @"Sign up";

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    self.scrollView.scrollEnabled = NO;
    self.scrollView.scrollsToTop = NO;

    [self showTermsAndConditions];
    [[Analytics sharedInstance] markSignUpForm];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.emailID.delegate = self;
    self.password.delegate = self;
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
    UIBarButtonItem *declineButton = [[UIBarButtonItem alloc] initWithTitle:@"Decline" style:UIBarButtonItemStylePlain target:self action:@selector(onDeclineAction:)];
    self.navigationItem.leftBarButtonItem = declineButton;

    UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStylePlain target:self action:@selector(onAcceptedTermsAndConditions)];
    self.navigationItem.rightBarButtonItem = acceptButton;

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"termsofuse" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:nil];

    self.webview = webView;
    self.scrollView.alpha = 0.0;
    [self.view addSubview:webView];
}

- (void)showSignupForm {
    [self displayScreenToSignup];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStylePlain target:self action:@selector(onContinueAction:)];
    continueButton.tag = CONTINUE_BUTTON_SIGNUP;
    self.navigationItem.rightBarButtonItem = continueButton;
    [self enableContinueButton:NO];

    [UIView animateWithDuration:0.5 animations:^() {
        self.webview.alpha = 0.0;
        self.scrollView.alpha = 1.0;

    } completion:^(BOOL finished) {
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
    self.headingLabel.text = @"Securifi Cloud Account.";
    self.subHeadingLabel.text = @"Access your Almonds and\nyour home devices from anywhere.";
}

- (void)setSigningUpHeadline {
    self.headingLabel.text = @"Signing up.";
    self.subHeadingLabel.text = @"Please wait one moment...";
}

- (void)setAlmostDoneHeadline {
    self.headingLabel.text = @"Almost done.";
    self.subHeadingLabel.text = @"An activation link was sent to your email. \n Follow it, then tap Continue to login.";
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
            button = @"Resend the activation email";
            break;

        case FOOTER_SIGNUP_DIFF_EMAIL: {
            label = @"Do you want to create another account?";
            button = @"Signup using another email";
            break;
        }

        default:   {
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

        PasswordStrengthType pwdStrength = [self checkPasswordStrength:self.password.text];
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
    if (self.emailID.text.length == 0) {
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = @"You forgot to enter your email ID.";
        return NO;
    }
    else if (![self validateEmail:self.emailID.text]) {
        //Email Address is invalid.
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = @"You have entered an invalid email ID.";
        return NO;
    }
    else if (self.password.text.length == 0) {
        //If password empty
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = @"You forgot to enter your password.";
        return NO;
    }
    else if (self.password.text.length < PWD_MIN_LENGTH) {
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = [NSString stringWithFormat:@"The password should be %d - %d characters long.", PWD_MIN_LENGTH, PWD_MAX_LENGTH];
        return NO;
    }
    else if (self.password.text.length > PWD_MAX_LENGTH) {
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = [NSString stringWithFormat:@"The password should be %d - %d characters long.", PWD_MIN_LENGTH, PWD_MAX_LENGTH];
        return NO;
    }
    else if (![self.password.text isEqualToString:self.confirmPassword.text]) {
        //Match password and confirm password
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = @"There is a password mismatch.";
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

- (PasswordStrengthType)checkPasswordStrength:(NSString *)strPassword {
    NSInteger len = strPassword.length;
    //will contains password strength
    int strength = 0;

    if (len == 0) {
        return PasswordStrengthTypeTooShort;
    }
    else if (len < PWD_MIN_LENGTH) {
        return PasswordStrengthTypeTooShort;
    }
    else if (len > PWD_MAX_LENGTH) {
        return PasswordStrengthTypeTooLong;
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
        self.passwordStrengthIndicator.progress = 0.2;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = @"Password: Too Short";
    }
    else if (pwdStrength == PasswordStrengthTypeTooLong) {
        self.passwordStrengthIndicator.progress = 0.2;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = @"Password: Too Long";
    }
    else if (pwdStrength == PasswordStrengthTypeWeak) {
        self.passwordStrengthIndicator.progress = 0.4;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:215 / 255.0f blue:0 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = @"Password: Weak";
    }
    else if (pwdStrength == PasswordStrengthTypeModerate) {
        self.passwordStrengthIndicator.progress = 0.6;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:140 / 255.0f blue:48 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = @"Password: Medium";
    }
    else if (pwdStrength == PasswordStrengthTypeStrong) {
        self.passwordStrengthIndicator.progress = 1;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:34 / 255.0f green:139 / 255.0f blue:34 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = @"Password: Strong";
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

#pragma mark - Cloud Command : Sender and Receivers

- (void)sendSignupCommand {
    [self setSigningUpHeadline];

    Signup *signupCommand = [[Signup alloc] init];
    signupCommand.UserID = [NSString stringWithString:self.emailID.text];
    signupCommand.Password = [NSString stringWithString:self.password.text];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = SIGNUP_COMMAND;
    cloudCommand.command = signupCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onSignupResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    SignupResponse *obj = (SignupResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.Reason];

    if (obj.isSuccessful) {
        [self displayScreenToLogin];
    }
    else {
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The email ID is invalid.";
                break;

            case 2:
                failureReason = [NSString stringWithFormat:@"The password should be %d - %d characters long.", PWD_MIN_LENGTH, PWD_MAX_LENGTH];
                break;

            case 3:
                failureReason = @"An account already exists with this email.";
                [self setFooterForTag:FOOTER_SIGNUP_DIFF_EMAIL];
                break;

            case 4:
                //Ready for login
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
}

- (void)sendReactivationRequest {
    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = self.emailID.text;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)validateResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason];

    if (obj.isSuccessful) {
        [self displayScreenToLogin];
    }
    else {
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
            default:
                break;
        }
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}


@end
