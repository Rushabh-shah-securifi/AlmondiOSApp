//
//  SFIDoorSensorViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 6/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDoorSensorViewController.h"

@interface SFIDoorSensorViewController ()

@end

@implementation SFIDoorSensorViewController
@synthesize sensorStatus;

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
    
    //MIGRATING TO SDK
    //singletonObj = [SFISingleton createSingletonObj];
      //PY080813 - to remove SFISingleton
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(command:) name:@"receivedCommand" object:singletonObj];
    
}

-(void) command
{
    sensorStatus.text = @"Received Command";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end  
