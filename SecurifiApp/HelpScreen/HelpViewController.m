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
        //        self.helpScreens = [HelpScreens addHelpTopic:self.view HelpTopicType:self.helpTopic];
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
    htmlString = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
                               "body {font-family: \"%@\"; font-size: %@; height: auto; }</style></head>"
                               "<body>"
                               "<h3>%@</h3>"
                               "<p>%@</p>"
                               "<h4>%@</h4>"
                               "<p>%@</p>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\"><li>%@</li><li>%@</li><li>%@</li></ol>"
                               "</body>"
                               "</html>", @"Avenir-Roman", [NSNumber numberWithInt:16], NSLocalizedString(@"vpn_title",@""),
                               NSLocalizedString(@"vpn_description",@""),
                               NSLocalizedString(@"vpn_title_2",@""),
                               NSLocalizedString(@"vpn_description_2",@""),
                               NSLocalizedString(@"vpn_title_3",@""),
                               NSLocalizedString(@"vpn_sub_description_1",@""),
                               NSLocalizedString(@"vpn_sub_description_2",@""),
                               NSLocalizedString(@"vpn_sub_description_3",@"")];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-60)];
    webView.backgroundColor = [UIColor clearColor];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSLog(@"help base url: %@", baseURL);
    [webView loadHTMLString:htmlString baseURL:baseURL];
    dispatch_async(dispatch_get_main_queue(), ^{
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
