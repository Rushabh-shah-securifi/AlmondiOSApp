//
//  SFIActivationViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIActivationViewController.h"
#import "SNLog.h"


@implementation SFIActivationViewController
@synthesize headingLabel;
@synthesize subHeadingLabel;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateResponseCallback:)
                                                 name:VALIDATE_RESPONSE_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SNLog Log:@"Method Name: %s", __PRETTY_FUNCTION__];


    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VALIDATE_RESPONSE_NOTIFIER
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Handlers


- (IBAction)loginButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)activationResendButtonHandler:(id)sender {
    [self sendReactivationRequest];
    //[self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)backButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Cloud command and handlers

- (void)sendReactivationRequest {
    NSString *email = [[SecurifiToolkit sharedInstance] loginEmail];
    [SNLog Log:@"%s: sending reactivation link to email: %@", __PRETTY_FUNCTION__, email];

    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = email;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

- (void)validateResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];

    [SNLog Log:@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason];

    if (obj.isSuccessful) {
        self.subHeadingLabel.text = @"Reactivation link has been sent to your account.";
    }
    else {
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

@end
