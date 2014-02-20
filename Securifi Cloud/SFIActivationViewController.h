//
//  SFIActivationViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIActivationViewController : UIViewController
//@property (weak, nonatomic) IBOutlet UIButton *loginButton;
//@property (weak, nonatomic) IBOutlet UIButton *activationResendButton;
//@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *subHeadingLabel;

- (IBAction)loginButtonHandler:(id)sender;
- (IBAction)activationResendButtonHandler:(id)sender;
- (IBAction)backButtonHandler:(id)sender;
@end
