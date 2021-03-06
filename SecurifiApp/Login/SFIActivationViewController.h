//
//  SFIActivationViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIActivationViewController : UIViewController
@property(weak, nonatomic) IBOutlet UILabel *headingLabel;
@property(weak, nonatomic) IBOutlet UILabel *subHeadingLabel;

// Required property; set this before presenting the view; the email address for the user and to where activation emails will be sent
@property(nonatomic, strong) NSString *emailID;

- (IBAction)loginButtonHandler:(id)sender;

- (IBAction)activationResendButtonHandler:(id)sender;

- (IBAction)backButtonHandler:(id)sender;
@end
