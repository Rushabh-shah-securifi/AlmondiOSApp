//
//  HelpViewController.m
//  SecurifiApp
//
//  Created by Masood on 8/23/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpViewController.h"
#import "SWRevealViewController.h"
#import "HelpScreens.h"
#import "Analytics.h"
#import "AlmondJsonCommandKeyConstants.h"

@interface HelpViewController ()<HelpScreensDelegate>
@property(nonatomic) HelpScreens *helpScreens;

@property (weak, nonatomic) IBOutlet UILabel *helpTitle;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    NSLog(@"viewdidload");
    [super viewDidLoad];
    [self initializeHelpScreens];
    [[Analytics sharedInstance] markHelpDescriptionScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark help screens

-(void)initializeHelpScreens{
    if(self.isHelpTopic){
        NSArray *screens = self.startScreen[SCREENS];
        NSDictionary *screen = screens.firstObject;
        self.helpTitle.text = NSLocalizedString(screen[TITLE], @"");
        [self displayWebView:NSLocalizedString(screen[DESCRIPTION], @"")];
    }
    else{
        self.helpScreens = [HelpScreens initializeHelpScreen:self.view isOnMainScreen:NO startScreen:self.startScreen];
        self.helpScreens.delegate = self;
        [self.view addSubview:self.helpScreens];
    }
}

- (void)displayWebView:(NSString *)htmlString{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-60)];
        webView.backgroundColor = [UIColor clearColor];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSLog(@"help base url: %@", baseURL);
        [webView loadHTMLString:htmlString baseURL:baseURL];
        [self.view addSubview:webView];
    });
}

#pragma mark helpscreen delegate methods
- (void)resetViewDelegate{
//    [self.helpScreens removeFromSuperview];
//    self.helpScreens = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)onSkipTapDelegate{
    
}

#pragma mark button press event
- (IBAction)onBackButtonTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


@end
