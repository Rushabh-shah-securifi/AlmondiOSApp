//
//  SFILogoutAllViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFILogoutAllViewController.h"
#import "SNLog.h"
#import "UIFont+Securifi.h"

@interface SFILogoutAllViewController () <UITextFieldDelegate>
@end

@implementation SFILogoutAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"logoutall.navbar-title.Continue", @"Continue") style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutAll:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLogoutAllResponseCallback:)
                                                 name:kSFIDidLogoutAllNotification
                                               object:nil];

    self.emailID.text = [[SecurifiToolkit sharedInstance] loginEmail];

    self.emailID.delegate = self;
    self.password.delegate = self;

    [self enableContinueButton:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.emailID.text.length == 0) {
        [self.emailID becomeFirstResponder];
    }
    else {
        [self.password becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.emailID.delegate = nil;
    self.password.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFIDidLogoutAllNotification object:nil];
}

- (void)enableContinueButton:(BOOL)enabled {
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

#pragma mark - Actions

- (IBAction)onCancel:(id)sender {
    [self.delegate logoutAllControllerDidCancel:self];
}

- (IBAction)onLogoutAll:(id)sender {
    self.logMessageLabel.text = @"";

    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];
    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }

    [[SecurifiToolkit sharedInstance] asyncSendLogoutAllWithEmail:self.emailID.text password:self.password.text];
}

#pragma mark - UITextField delegate methods

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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOOL enabled = self.emailID.text.length > 0 && self.password.text.length > 0;
    [self enableContinueButton:enabled];
}

#pragma mark - Cloud commands

- (void)onLogoutAllResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data == nil) {
        self.logMessageLabel.text = NSLocalizedString(@"logoutall.label.Logout from all devices was not successful.", @"Logout from all devices was not successful.");
        return;
    }

    LogoutAllResponse *obj = (LogoutAllResponse *) [data valueForKey:@"data"];

    if (obj.isSuccessful) {
        NSLog(@"LogoutAll response sucess");
        [self.delegate logoutAllControllerDidLogoutAll:self];
    }
    else {
        NSLog(@"LogoutAll response no sucess");
        self.logMessageLabel.text = NSLocalizedString(@"logoutall.label.Logout from all devices was not successful.", @"Logout from all devices was not successful.");
    }
}

@end
