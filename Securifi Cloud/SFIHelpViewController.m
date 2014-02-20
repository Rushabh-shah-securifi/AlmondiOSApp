//
//  SFIHelpViewController.m
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 30/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import "SFIHelpViewController.h"
#import "DrawerViewController.h"
#import "AlmondPlusConstants.h"

@interface SFIHelpViewController ()

@end

@implementation SFIHelpViewController
@synthesize webView;

#pragma mark - View Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView.delegate = self;
     [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HELP_URL]]];
    
    //Display Drawer Gesture
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealMenu:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:showMenuSwipe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[DrawerViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation Handling
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
//    [webView reload];
//    [webView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e);"];
}

#pragma mark - UIWebView delegate


- (void)webViewDidStartLoad:(UIWebView *)webView {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading...";
    [HUD hide:YES afterDelay:10];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Loaded");
    [HUD hide:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error Loading");
    [HUD hide:YES];
}


#pragma mark - Class Methods

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)backButtonHandler:(id)sender
{
    [webView goBack];
}



@end
