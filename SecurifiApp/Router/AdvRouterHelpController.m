//
//  AdvRouterHelpController.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvRouterHelpController.h"
#import "CommonMethods.h"
#import "SFIColors.h"

@interface AdvRouterHelpController ()

@end

@implementation AdvRouterHelpController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHelp];
//    [self testWebView];
}

- (void)testWebView{
    NSString *htmlString = NSLocalizedString(@"AddingDev_alScreen_desc", @"");
    [self displayWebView:htmlString];
}



- (void)showHelp{
    switch (self.row) {
//        case Feature_Vpn:
//            [self showVpnHelp];
//            break;
        case 0:
            [self showPortForwardingHelp];
            break;
        case 1:
            [self showDnsHelp];
            break;
        case 2:
            [self showStaticIPHelp];
            break;
        case 3:
            [self showUpnpHelp];
            break;
        default:
            break;
    }
}

- (void)showVpnHelp{
    NSString *strForWebView = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
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
    
    [self displayWebView:strForWebView];
}

- (void)showPortForwardingHelp{
    NSString *strForWebView = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
                               "body {font-family: \"%@\"; font-size: %@; height: auto; }</style></head>"
                               "<body>"
                               "<h3>%@</h3>"
                               "<p>%@</p>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\">"
                                   "<li>%@</li>"
                                   "<li>%@ <ol type=\"a\"><li>%@</li><li>%@</li><li>%@</li><li>%@</li><li>%@</li></ol></li>"
                                   "<li>%@</li>"
                               "</ol>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\">"
                               "<li>%@</li>"
                               "<li>%@ <ol type=\"a\"><li>%@</li><li>%@</li><li>%@</li><li>%@</li><li>%@</li></ol></li>"
                               "</ol>"
                               "</body>"
                               "</html>", @"Avenir-Roman", [NSNumber numberWithInt:16], NSLocalizedString(@"port_title",@""),
                               NSLocalizedString(@"port_description",@""),
                               NSLocalizedString(@"port_title_2",@""),
                               NSLocalizedString(@"port_sub_description_1",@""),
                               NSLocalizedString(@"port_sub_description_2",@""),
                               NSLocalizedString(@"port_sub_step_1",@""),
                               NSLocalizedString(@"port_sub_step_2",@""),
                               NSLocalizedString(@"port_sub_step_3",@""),
                               NSLocalizedString(@"port_sub_step_4",@""),
                               NSLocalizedString(@"port_sub_step_5",@""),
                               NSLocalizedString(@"port_sub_description_3",@""),
                               NSLocalizedString(@"port_plus_title",@""),
                               NSLocalizedString(@"port_plus_sub_description_1",@""),
                               NSLocalizedString(@"port_plus_sub_description_2",@""),
                               NSLocalizedString(@"port_plus_sub_step_1",@""),
                               NSLocalizedString(@"port_plus_sub_step_2",@""),
                               NSLocalizedString(@"port_plus_sub_step_3",@""),
                               NSLocalizedString(@"port_plus_sub_step_4",@""),
                               NSLocalizedString(@"port_plus_sub_step_5",@"")];
    
    [self displayWebView:strForWebView];
}

- (void)showDnsHelp{
    NSString *strForWebView = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
                               "body {font-family: \"%@\"; font-size: %@; height: auto; }</style></head>"
                               "<body>"
                               "<h3>%@</h3>"
                               "<p>%@</p>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\"><li>%@</li><li>%@</li><li>%@</li></ol>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\"><li>%@</li><li>%@</li><li>%@</li><li>%@</li></ol>"
                               "</body>"
                               "</html>", @"Avenir-Roman", [NSNumber numberWithInt:16], NSLocalizedString(@"dns_title",@""),
                               NSLocalizedString(@"dns_description",@""),
                               NSLocalizedString(@"dns_title_2",@""),
                               NSLocalizedString(@"dns_sub_descr_1",@""),
                               NSLocalizedString(@"dns_sub_descr_2",@""),
                               NSLocalizedString(@"dns_sub_descr_3",@""),
                               NSLocalizedString(@"dns_title_3",@""),
                               NSLocalizedString(@"dns_plus_sub_descr_1",@""),
                               NSLocalizedString(@"dns_plus_sub_descr_2",@""),
                               NSLocalizedString(@"dns_plus_sub_descr_3",@""),
                               NSLocalizedString(@"dns_plus_sub_descr_4",@"")];
    
    [self displayWebView:strForWebView];
}

- (void)showStaticIPHelp{
    NSString *strForWebView = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
                               "body {font-family: \"%@\"; font-size: %@; height: auto; }</style></head>"
                               "<body>"
                               "<h3>%@</h3>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\"><li>%@</li><li>%@</li><li>%@</li></ol>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\"><li>%@</li><li>%@</li><li>%@</li><li>%@</li></ol>"
                               "</body>"
                               "</html>", @"Avenir-Roman", [NSNumber numberWithInt:16], NSLocalizedString(@"static_title",@""),
                               NSLocalizedString(@"static_title_2",@""),
                               NSLocalizedString(@"static_sub_descr_1",@""),
                               NSLocalizedString(@"static_sub_descr_2",@""),
                               NSLocalizedString(@"static_sub_descr_3",@""),
                               NSLocalizedString(@"static_title_plus",@""),
                               NSLocalizedString(@"static_sub_descr_plus_1",@""),
                               NSLocalizedString(@"static_sub_descr_plus_2",@""),
                               NSLocalizedString(@"static_sub_descr_plus_3",@""),
                               NSLocalizedString(@"static_sub_descr_plus_4",@"")];
    
    [self displayWebView:strForWebView];
}

- (void)showUpnpHelp{
    NSString *strForWebView = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
                               "body {font-family: \"%@\"; font-size: %@; height: auto; }</style></head>"
                               "<body>"
                               "<h3>%@</h3>"
                               "<p>%@</p>"
                               "<h4>%@</h4>"
                               "<p>%@</p>"
                               "<h4>%@</h4>"
                               "<ol type=\"1\"><li>%@</li><li>%@</li><li>%@</li></ol>"
                               "</body>"
                               "</html>", @"Avenir-Roman", [NSNumber numberWithInt:16], NSLocalizedString(@"upnp_title",@""),
                               NSLocalizedString(@"upnp_descr",@""),
                               NSLocalizedString(@"upnp_title_2",@""),
                               NSLocalizedString(@"upnp_descr_2",@""),
                               NSLocalizedString(@"upnp_title_3",@""),
                               NSLocalizedString(@"upnp_sub_descr_1",@""),
                               NSLocalizedString(@"upnp_sub_descr_2",@""),
                               NSLocalizedString(@"upnp_sub_descr_3",@"")];
    
    [self displayWebView:strForWebView];
}

- (void)displayWebView:(NSString *)strForWebView{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        webView.backgroundColor = [UIColor clearColor];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSLog(@"base url: %@", baseURL);
        [webView loadHTMLString:strForWebView baseURL:baseURL];
        [self.view addSubview:webView];
    });
}

- (void)helpCode{
    /*
     NSString *strForWebView = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">"
     "body {font-family: \"%@\"; font-size: %@; height: auto; }</style></head>"
     "<body>  <h3>My First Heading</h3>  %@ </body> \n"
     "<a href=\"http://www.w3schools.com\">This is a link</a> \n"
     "</html>", @"Avenir-Roman", [NSNumber numberWithInt:16], @"Hello here is my new html content."];
     
     
     <ol type="1">
     <li>Coffee</li>
     <li>Tea</li>
     <li>Milk</li>
     </ol>
     
     
     */
}
@end
