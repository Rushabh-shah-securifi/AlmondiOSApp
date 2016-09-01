//
//  SFIPasswordChangeViewController.m
//  Almond
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIPasswordChangeViewController.h"
#import "MBProgressHUD.h"

@interface SFIPasswordChangeViewController ()
@property(nonatomic) UITextField *activeTextField;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end


@implementation SFIPasswordChangeViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"password.hud.Changing password...", @"Changing password...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];

    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPasswordChangeResponseCallback:)
                                                 name:CHANGE_PWD_RESPONSE_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CHANGE_PWD_RESPONSE_NOTIFIER
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Handlers

- (IBAction)doneButtonHandler:(id)sender {
    //Send Password change command
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:10];
        [self sendUserPasswordChangeRequest];
    });
}

- (IBAction)cancelButtonHandler:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Password strength

- (void)displayPasswordIndicator:(PasswordStrengthType)pwdStrength {
    if (![self.confirmPassword.text isEqualToString:self.changedPassword.text]) {
        self.passwordStrengthIndicator.progress = 0.1;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Mismatch", @"Password: Mismatch");
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (pwdStrength == PasswordStrengthTypeTooShort) {
        self.passwordStrengthIndicator.progress = 0.2;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Too Short", @"Password: Too Short");
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (pwdStrength == PasswordStrengthTypeTooLong) {
        self.passwordStrengthIndicator.progress = 0.2;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Too Long", @"Password: Too Long");
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (pwdStrength == PasswordStrengthTypeWeak) {
        self.passwordStrengthIndicator.progress = 0.4;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:215 / 255.0f blue:0 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Weak", @"Password: Weak");
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if (pwdStrength == PasswordStrengthTypeModerate) {
        self.passwordStrengthIndicator.progress = 0.6;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:255 / 255.0f green:140 / 255.0f blue:48 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Medium", @"Password: Medium");
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if (pwdStrength == PasswordStrengthTypeStrong) {
        self.passwordStrengthIndicator.progress = 1;
        self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:34 / 255.0f green:139 / 255.0f blue:34 / 255.0f alpha:1.0f];
        self.lblPasswordStrength.text = NSLocalizedString(@"password-validation.strength-label.Password: Strong", @"Password: Strong");
        self.navigationItem.rightBarButtonItem.enabled = YES;
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
    if (textField == self.currentpassword) {
        [textField resignFirstResponder];
        [self.changedPassword becomeFirstResponder];
    }
    else if (textField == self.changedPassword) {
        [textField resignFirstResponder];
        [self.confirmPassword becomeFirstResponder];
    }
    else if (textField == self.confirmPassword) {
        [textField resignFirstResponder];

        SFICredentialsValidator *validator = [[SFICredentialsValidator alloc] init];
        PasswordStrengthType pwdStrength = [validator validatePassword:self.changedPassword.text];
        [self displayPasswordIndicator:pwdStrength];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)sendUserPasswordChangeRequest {
    NSString *oldPwd = self.currentpassword.text;
    NSString *newPwd = self.changedPassword.text;
    [[SecurifiToolkit sharedInstance] asyncRequestChangeCloudPassword:oldPwd changedPwd:newPwd];
}

- (void)userPasswordChangeResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ChangePasswordResponse *obj = (ChangePasswordResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });

    if (obj.isSuccessful) {
        //Dismiss this view
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        });
    }
    else {
        ELog(@"Failed to change password, reason:%d", obj.reasonCode);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"password.label-text.There was some error on cloud. Please try later.", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"Sorry! You are not registered with us yet.", @"Sorry! You are not registered with us yet.");
                break;

            case 3:
                failureReason = NSLocalizedString(@"You need to activate your account.", @"You need to activate your account.");
                break;

            case 4:
                failureReason = NSLocalizedString(@"You need to fill all the fields.", @"You need to fill all the fields.");
                break;

            case 5:
                failureReason = NSLocalizedString(@"The current password was incorrect.", @"The current password was incorrect.");
                break;

            case 6: {
                NSString *format = NSLocalizedString(@"The password should be %d - %d characters long.", @"The password should be %d - %d characters long.");
                failureReason = [NSString stringWithFormat:format, PWD_MIN_LENGTH, PWD_MAX_LENGTH];
            }
                break;

            default:
                failureReason = NSLocalizedString(@"Sorry! Password change was unsuccessful.", @"Sorry! Password change was unsuccessful.");
        }

        dispatch_async(dispatch_get_main_queue(), ^() {
            self.passwordStrengthIndicator.progress = 0.1;
            self.passwordStrengthIndicator.progressTintColor = [UIColor colorWithRed:220 / 255.0f green:20 / 255.0f blue:60 / 255.0f alpha:1.0f];
            self.lblPasswordStrength.text = failureReason;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        });
    }
}


@end
