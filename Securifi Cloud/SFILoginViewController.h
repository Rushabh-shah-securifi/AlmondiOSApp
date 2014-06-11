//
//  SFILoginViewController.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFILoginViewController : UIViewController

@property(weak, nonatomic) IBOutlet UITextField *userName;
@property(weak, nonatomic) IBOutlet UITextField *password;
@property(strong, nonatomic) IBOutlet UILabel *headingLabel;
@property(strong, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property(weak, nonatomic) IBOutlet UIButton *forgotPwdButton;

//- (void)resignKeyboard:(id)sender;

- (IBAction)backClick:(id)sender;

- (IBAction)loginClick:(id)sender;

//- (void)networkHandlerUP:(id)sender;
//
//- (void)networkHandlerDOWN:(id)sender;

- (IBAction)signupButton:(id)sender;

- (IBAction)forgotPwdButtonHandler:(id)sender;

@end

