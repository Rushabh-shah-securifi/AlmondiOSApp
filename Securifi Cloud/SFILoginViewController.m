//
//  SFILoginViewController.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFILoginViewController.h"
#import "SNLog.h"
#import "SFIOfflineDataManager.h"
#import "SFIDatabaseUpdateService.h"
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

    self.loginButton.enabled = YES;

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    //PY 170913 - To stop the view from going below tab bar
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.userName.delegate = self;
    self.password.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];

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
                                                 name:kSFIReachabilityChangedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetPasswordResponseCallback:)
                                                 name:RESET_PWD_RESPONSE_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_UP_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_DOWN_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSFIReachabilityChangedNotification
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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // do nothing
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return textField.text.length > 0;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // do nothing
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userName) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        NSLog(@"Login Action!!");
        [textField resignFirstResponder];
        [self loginClick:nil];
    }
    return YES;
}

#pragma mark - Event handlers


- (void)signupButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFISignupViewController"];
    [self presentViewController:mainView animated:YES completion:nil];
}

- (IBAction)forgotPwdButtonHandler:(id)sender {
    [self sendResetPasswordRequest];
}

- (IBAction)loginClick:(id)sender {
    if ([self.userName isFirstResponder]) {
        [self.userName resignFirstResponder];

    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }

    if ([[self.userName text] isEqualToString:@""] || [[self.password text] isEqualToString:@""]) {
        self.headingLabel.text = @"Oops";
        self.subHeadingLabel.text = @"Please enter Username and Password";
    }
    else {
        Login *loginCommand = [[Login alloc] init];
        loginCommand.UserID = [NSString stringWithString:self.userName.text];
        loginCommand.Password = [NSString stringWithString:self.password.text];

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:loginCommand.UserID forKey:EMAIL];
        [prefs synchronize];

        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = LOGIN_COMMAND;
        cloudCommand.command = loginCommand;

        [self asyncSendCommand:cloudCommand];
    }
}

- (void)loginResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Login failed
    if ([notifier userInfo] == nil) {
        [SNLog Log:@"In Method Name: %s TEMP Pass failed", __PRETTY_FUNCTION__];
        return;
    }

    LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"In Method Name: %s UserID %@", __PRETTY_FUNCTION__, obj.userID];
    [SNLog Log:@"In Method Name: %s TempPass %@", __PRETTY_FUNCTION__, obj.tempPass];
    [SNLog Log:@"In Method Name: %s isSuccessful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"In Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.reason];
    [SNLog Log:@"In Method Name: %s Reason Code : %d", __PRETTY_FUNCTION__, obj.reasonCode];

    if (!obj.isSuccessful) {
        NSLog(@"Login failure reason Code: %d", obj.reasonCode);
        self.headingLabel.text = @"Oops";

        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1: {
                failureReason = @"The email was not found.";
                break;
            }
            case 2: {
                failureReason = @"The password is incorrect.";
                break;
            }
            case 3: {
                //Display Activation Screen
                self.headingLabel.text = @"Almost there.";
                failureReason = @"You need to activate your account.";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

                UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                [self presentViewController:mainView animated:YES completion:nil];
                break;
            }
            case 4:
                failureReason = @"The email or password is incorrect";
                break;
            default:
                failureReason = @"Sorry! Login was unsuccessful.";
        }

        self.subHeadingLabel.text = failureReason;

        return;
    }

    self.HUD.labelText = @"Loading your personal data.";

    //Retrieve Almond List, Device List and Device Value - Before displaying the screen
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(almondListResponseCallback:)
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];

    //todo sinclair - why are we doing this?
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SFIDatabaseUpdateService stopDatabaseUpdateService];
        [SFIDatabaseUpdateService startDatabaseUpdateService];
    });

    [self loadAlmondList];
}

- (IBAction)backClick:(id)sender {
    if ([self.userName isFirstResponder]) {
        [self.userName resignFirstResponder];

    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }
}


#pragma mark - Reconnection

- (void)networkUpNotifier:(id)sender {
    [SNLog Log:@"Method Name: %s Login controller :In networkUP notifier", __PRETTY_FUNCTION__];
    [self.HUD hide:YES];
}

- (void)networkDownNotifier:(id)sender {
    BOOL online = [[SecurifiToolkit sharedInstance] isCloudOnline];
    if (!online) {
        self.HUD.labelText = @"Reconnecting...";
        [self.HUD hide:YES afterDelay:1];
    }
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    BOOL reachable = [[SFIReachabilityManager sharedManager] isReachable];
    if (!reachable) {
        NSLog(@"Unreachable");
    }

    BOOL online = [[SecurifiToolkit sharedInstance] isCloudOnline];
    if (!online) {
        self.HUD.labelText = @"Reconnecting...";
        [self.HUD hide:YES afterDelay:1];
    }
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)sendResetPasswordRequest {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email = [prefs objectForKey:EMAIL];
    NSLog(@"Email : %@", email);

    ResetPasswordRequest *resetCommand = [[ResetPasswordRequest alloc] init];
    resetCommand.email = self.userName.text;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = RESET_PASSWORD_REQUEST;
    cloudCommand.command = resetCommand;

    [self asyncSendCommand:cloudCommand];
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
        UIStoryboard *storyboard;
        UIViewController *mainView;

        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The username was not found";
                break;
            case 2:
                //Display Activation Screen
                self.headingLabel.text = @"Almost there.";
                failureReason = @"You need to activate your account.";
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                [self presentViewController:mainView animated:YES completion:nil];
                break;
            case 3:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            case 4:
                failureReason = @"The email ID is invalid.";
                break;
            case 5:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            default:
                break;
        }

        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }
    else {
        self.headingLabel.text = @"Almost there.";
        self.subHeadingLabel.text = @"Password reset link has been sent to your account.";
    }
}


- (void)loadAlmondList {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = almondListCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)almondListResponseCallback:(id)sender {
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

    [self.delegate controllerDidCompleteLogin:self];
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
