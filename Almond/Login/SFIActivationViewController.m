//
//  SFIActivationViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIActivationViewController.h"


@implementation SFIActivationViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateResponseCallback:)
                                                 name:VALIDATE_RESPONSE_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VALIDATE_RESPONSE_NOTIFIER
                                                  object:nil];
}

#pragma mark - Button Handlers

- (IBAction)loginButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)activationResendButtonHandler:(id)sender {
    [self sendReactivationRequest];
}

- (IBAction)backButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cloud command and handlers

- (void)sendReactivationRequest {
    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = self.emailID;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

- (void)validateResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];

    dispatch_async(dispatch_get_main_queue(), ^() {
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
    });
}

@end
