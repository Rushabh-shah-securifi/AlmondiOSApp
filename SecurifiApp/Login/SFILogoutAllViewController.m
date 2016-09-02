//
//  SFILogoutAllViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFILogoutAllViewController.h"
#import "UIFont+Securifi.h"
#import "MBProgressHUD.h"
#import "Analytics.h"

@interface SFILogoutAllViewController () <MBProgressHUDDelegate, UITextFieldDelegate>
@property(nonatomic) MBProgressHUD *HUD;
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
    
    [self setUpHUD];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.emailID.text.length == 0) {
        [self.emailID becomeFirstResponder];
    }
    else {
        [self.password becomeFirstResponder];
    }
    
    [[Analytics sharedInstance] markLogoutAllScreen];
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

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
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
    
    [self showHudWithTimeoutMsgDelegate:@"Logging out from all devices!" time:10];
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

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    
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
        dispatch_async(dispatch_get_main_queue(), ^() {
            ELog(@"LogoutAll response no sucess");
            self.logMessageLabel.text = NSLocalizedString(@"logoutall.label.Logout from all devices was not successful.", @"Logout from all devices was not successful.");

            if (obj.reasonCode == LogoutAllResponseResonCode_wrongPassword) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logoutall.alertview.title.Error", @"Invalid Email or Password")
                                                                message:NSLocalizedString(@"logoutall.alertview.msg.The password is invalid.", @"The email address or password is invalid.")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"alert.button.OK", @"OK"), nil];

                [alert show];
            }
        });
    }
}

#pragma mark hud methods
- (void)showHudWithTimeoutMsgDelegate:(NSString*)hudMsg time:(NSTimeInterval)sec{
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:sec];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

@end
