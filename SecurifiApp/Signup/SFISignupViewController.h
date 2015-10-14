//
//  SFISignupViewController.h
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFISignupViewController : UIViewController

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UITextField *password;
@property(weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property(weak, nonatomic) IBOutlet UITextField *emailID;
@property(weak, nonatomic) IBOutlet UILabel *headingLabel;
@property(weak, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property(weak, nonatomic) IBOutlet UILabel *footerLabel;
@property(weak, nonatomic) IBOutlet UIButton *footerButton;
@property(strong, nonatomic) IBOutlet UIProgressView *passwordStrengthIndicator;
@property(strong, nonatomic) IBOutlet UILabel *passwordStrength;

- (IBAction)onContinueAction:(id)sender;

- (IBAction)onCancelAction:(id)sender;

- (IBAction)footerButtonHandler:(id)sender;

@end
