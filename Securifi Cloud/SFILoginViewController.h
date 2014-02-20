//
//  SFILoginViewController.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
//#import "SFISingleton.h"
//#import "XMLDictionary.h"

@interface SFILoginViewController : UIViewController 
{
    //UIActivityIndicatorView *ai;
    //SFISingleton            *singletonObj;
   // NSTimer                 *timeout;
    MBProgressHUD               *HUD;
}
//@property (weak, nonatomic) IBOutlet UILabel *logMessage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UILabel *headingLabel;
@property (strong, nonatomic) IBOutlet UILabel *subHeadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *forgotPwdButton;
@property NSInteger state;

//@property (weak, nonatomic) IBOutlet UITextField *deviceID;
//@property (nonatomic, retain) UIToolbar *keyboardToolbar;
//@property (strong, nonatomic) UIWindow *window;
//@property (weak, nonatomic) IBOutlet UIButton *loginButton;
//@property (weak, nonatomic) IBOutlet UIButton *signupButton;
//@property (nonatomic, retain) NSMutableArray *deviceList;

- (void) resignKeyboard:(id)sender;
//- (void) previousField:(id)sender;
//- (void) nextField:(id)sender;
//- (IBAction)loginButton:(id)sender;
- (IBAction)backClick:(id)sender;
- (IBAction)loginClick:(id)sender;
- (void)networkHandlerUP:(id)sender;
- (void)networkHandlerDOWN:(id)sender;
- (IBAction)signupButton:(id)sender;
- (IBAction)forgotPwdButtonHandler:(id)sender;
@end

