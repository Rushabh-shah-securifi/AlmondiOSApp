//
//  SFILogoutAllViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFILogoutAllViewController : UIViewController

@property(weak, nonatomic) IBOutlet UITextField *password;
@property(weak, nonatomic) IBOutlet UITextField *emailID;
@property(weak, nonatomic) IBOutlet UILabel *logMessageLabel;


- (IBAction)logoutAllButtonHandler:(id)sender;

@end

