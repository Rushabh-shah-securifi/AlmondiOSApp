//
//  SFITermsViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 24/02/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import "SFITermsViewController.h"

@implementation SFITermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.toolbarHidden = NO;
    self.navigationItem.title = @"Terms and Conditions";

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Decline" style:UIBarButtonItemStylePlain target:self action:@selector(didNotAcceptTermsAction:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStylePlain target:self action:@selector(acceptTermsAction:)];
    self.toolbarItems = @[cancelButton, spacer, acceptButton];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"termsofuse" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:nil];

    [self.view addSubview:webView];
}

- (void)didNotAcceptTermsAction:(id)sender {
    [self.delegate termsViewControllerDidDismiss:self userAcceptedLicense:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)acceptTermsAction:(id)sender {
    [self.delegate termsViewControllerDidDismiss:self userAcceptedLicense:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
