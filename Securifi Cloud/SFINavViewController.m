//
//  SFINavViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import "SFINavViewController.h"
#import "SFILoginViewController.h"

@interface SFINavViewController ()

@end

@implementation SFINavViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)supportedInterfaceOrientations {
    if ([self.topViewController isMemberOfClass:[SFILoginViewController class]]){
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

@end
