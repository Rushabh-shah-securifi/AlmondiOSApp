//
//  SFIHelpViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MBProgressHUD.h"

@interface SFIHelpViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic, strong) IBOutlet UIWebView *webView;

- (IBAction)revealMenu:(id)sender;

- (IBAction)backButtonHandler:(id)sender;

@end
