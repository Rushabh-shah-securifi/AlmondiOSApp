//
//  SFIHelpViewController.h
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 30/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MBProgressHUD.h"

@interface SFIHelpViewController : UIViewController <UIWebViewDelegate>{
      MBProgressHUD               *HUD;
}
@property (nonatomic, strong) IBOutlet UIWebView *webView;

- (IBAction)revealMenu:(id)sender;
- (IBAction)backButtonHandler:(id)sender;
@end
