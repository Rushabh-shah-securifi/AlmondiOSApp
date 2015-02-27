//
//  SFIPasswordChangeViewController.h
//  Almond
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SFIPasswordChangeViewController : UIViewController

@property(weak, nonatomic) IBOutlet UILabel *headingLabel;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) IBOutlet UIProgressView *passwordStrengthIndicator;
@property(strong, nonatomic) IBOutlet UILabel *lblPasswordStrength;

@property(weak, nonatomic) IBOutlet UITextField *currentpassword;
@property(weak, nonatomic) IBOutlet UITextField *changedPassword;
@property(weak, nonatomic) IBOutlet UITextField *confirmPassword;


- (IBAction)doneButtonHandler:(id)sender;
- (IBAction)cancelButtonHandler:(id)sender;

@end
