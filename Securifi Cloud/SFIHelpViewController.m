//
//  SFIHelpViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import "SFIHelpViewController.h"
#import "DrawerViewController.h"
#import "AlmondPlusConstants.h"

@interface SFIHelpViewController ()
@property(nonatomic, strong, readonly) MBProgressHUD *HUD;
@end

@implementation SFIHelpViewController

#pragma mark - View Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.dimBackground = YES;
    _HUD.labelText = @"Loading...";

    // Do any additional setup after loading the view.
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HELP_URL]]];

    //Display Drawer Gesture
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealMenu:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:showMenuSwipe];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![self.slidingViewController.underLeftViewController isKindOfClass:[DrawerViewController class]]) {
        self.slidingViewController.underLeftViewController = [DrawerViewController new];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation Handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    [webView reload];
//    [webView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e);"];
}

#pragma mark - UIWebView delegate


- (void)webViewDidStartLoad:(UIWebView *)aWebView {
    [self.HUD hide:YES afterDelay:10];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    NSLog(@"Loaded");
    [self.HUD hide:YES];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error Loading");
    [self.HUD hide:YES];
}


#pragma mark - Class Methods

- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)backButtonHandler:(id)sender {
    [self.webView goBack];
}


@end
