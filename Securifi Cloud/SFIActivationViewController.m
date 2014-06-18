//
//  SFIActivationViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIActivationViewController.h"
#import "AlmondPlusConstants.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SNLog.h"

@interface SFIActivationViewController ()

@end

@implementation SFIActivationViewController
@synthesize headingLabel, subHeadingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateResponseCallback:)
                                                 name:VALIDATE_RESPONSE_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SNLog Log:@"Method Name: %s", __PRETTY_FUNCTION__];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VALIDATE_RESPONSE_NOTIFIER
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Handlers


- (IBAction)loginButtonHandler:(id)sender{
      NSLog(@"Login");
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)activationResendButtonHandler:(id)sender{
    NSLog(@"Activation Resend");
    [self sendReactivationRequest];
    //[self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)backButtonHandler:(id)sender{
    NSLog(@"Back Button");
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Cloud command and handlers

- (void)sendReactivationRequest {
    NSString *email = [[SecurifiToolkit sharedInstance] loginEmail];
    NSLog(@"Email : %@", email);

    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = email;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

-(void)validateResponseCallback:(id)sender{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    
    ValidateAccountResponse *obj = [[ValidateAccountResponse alloc] init];
    obj = (ValidateAccountResponse *)[data valueForKey:@"data"];
    
    [SNLog Log:@"Method Name: %s Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.reason];
    
    
    if (obj.isSuccessful == 0)
    {
        NSLog(@"Reason Code %d", obj.reasonCode);
        //PY 181013: Reason Code
        NSString *failureReason;
        switch(obj.reasonCode){
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
        }
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }else{
         self.subHeadingLabel.text = @"Reactivation link has been sent to your account.";
    }
}

@end
