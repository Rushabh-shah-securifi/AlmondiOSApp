//
//  IoTWebViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "IoTWebViewController.h"

@interface IoTWebViewController ()
@property (weak, nonatomic) IBOutlet UILabel *helpTitle;

@end

@implementation IoTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showIoTHelp];
    // Do any additional setup after loading the view.
}

- (void)showIoTHelp{
    switch (self.row) {
        case 0:
            [self displayWebView:NSLocalizedString(@"what_is_port_desc", @"")];
            break;
        case 1:
            [self displayWebView:NSLocalizedString(@"what_is_telnet_desc", @"")];
            break;
        case 2:
            [self displayWebView:NSLocalizedString(@"what_is_port_forwarding_desc", @"")];
            break;
        case 3:
            [self displayWebView:NSLocalizedString(@"what_is_upnp_desc", @"")];
            break;
        case 4:
            [self displayWebView:NSLocalizedString(@"what_is_botnet_desc", @"")];
            break;
        case 5:
            [self displayWebView:NSLocalizedString(@"what_is_local_ws_desc", @"")];
            break;
            
        case 6:
            [self displayWebView:NSLocalizedString(@"what_is_dns_desc", @"")];
            break;
        case 7:
            [self displayWebView:NSLocalizedString(@"what_is_an_open_port_desc", @"")];
            break;
        case 8:
            [self displayWebView:NSLocalizedString(@"what_to_do_desc", @"")];
            break;
        case 9:
            [self displayWebView:NSLocalizedString(@"what_if_your_desc", @"")];
            break;
        case 10:
            [self displayWebView:NSLocalizedString(@"best_practices_desc", @"")];
            break;
        default:
            break;
    }
}

- (void)displayWebView:(NSString *)strForWebView{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-60)];
        webView.backgroundColor = [UIColor clearColor];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSLog(@"base url: %@", baseURL);
        [webView loadHTMLString:strForWebView baseURL:baseURL];
        [self.view addSubview:webView];
    });
}

#pragma mark button tap
- (IBAction)onBackBtnTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
