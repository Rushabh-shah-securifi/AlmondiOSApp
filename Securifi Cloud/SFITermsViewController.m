//
//  SFITermsViewController.m
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 24/02/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import "SFITermsViewController.h"

@interface SFITermsViewController ()

@end

@implementation SFITermsViewController
@synthesize tvTermsConditions, navBar;

#pragma mark - View Methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navBar.titleTextAttributes = titleAttributes;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [tvTermsConditions setScrollEnabled:YES];
    [tvTermsConditions setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods
- (IBAction)backButtonHandler:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
