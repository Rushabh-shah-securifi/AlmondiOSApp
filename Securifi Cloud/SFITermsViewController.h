//
//  SFITermsViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 24/02/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFITermsViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextView *tvTermsConditions;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
- (IBAction)backButtonHandler:(id)sender;
@end
