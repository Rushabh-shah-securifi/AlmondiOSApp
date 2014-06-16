//
//  SFILogoutAllViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFILogoutAllViewController.h"
#import "SNLog.h"

@implementation SFILogoutAllViewController

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LogoutAllResponseCallback:)
                                                 name:LOGOUT_ALL_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGOUT_ALL_NOTIFIER object:nil];
}

#pragma mark - Keyboard Methods

- (void)resignKeyboard:(id)sender {
    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }
}

- (void)previousField:(id)sender {
    if ([self.emailID isFirstResponder]) {
        [self.password becomeFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.emailID becomeFirstResponder];
    }
}

- (void)nextField:(id)sender {
    if ([self.emailID isFirstResponder]) {
        [self.password becomeFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.emailID becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailID) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)backClick:(id)sender {
    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cloud commands

- (void)LogoutAllResponseCallback:(id)sender {
    [SNLog Log:@"In %s: ", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"%s: Received Logout response", __PRETTY_FUNCTION__];

        LogoutAllResponse *obj = (LogoutAllResponse *) [data valueForKey:@"data"];

        [SNLog Log:@"%s: is Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
        [SNLog Log:@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason];

        if (!obj.isSuccessful) {
            self.logMessageLabel.text = obj.reason;
        }
    }
}

- (void)doneHandler {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutAllButtonHandler:(id)sender {
    self.logMessageLabel.text = @"";

    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }

    [[SecurifiToolkit sharedInstance] asyncSendLogoutAllWithEmail:self.emailID.text password:self.password.text];
}

@end
