//
//  SFISwitchViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 5/21/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFISwitchViewController.h"
#import "CustomAlertView.h"

@interface SFISwitchViewController ()

@end

@implementation SFISwitchViewController

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
    ai =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    //MIGRATING TO SDK
    //singleton = [SFISingleton createSingletonObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchHnadler:(id)sender {
    NSLog(@"In Enable Hue");
    UISwitch *PowerSwitch =  (UISwitch *)sender;
    //printf("In switch event\n");
    if (PowerSwitch.on)
    {
        //Set send command in streamer to start sending hue commands
        NSLog(@"Switch On");
        ai.center = self.view.center;
        [self.view addSubview:ai];
        [ai startAnimating];
        
        //SET_DIMMER in node_ssl_client is 11
        // NSURL Get request is different than POST
        
        //NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=50000001&command=12&value=254"];
          //PY080813 - to remove SFISingleton
//        NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=%d&command=12&value=254",(unsigned int)singleton.deviceid];
//        
//        NSLog(@"Switch Command : %@",urlString);
//        
//        NSURL *url = [[NSURL alloc] initWithString:urlString];
//        
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setURL:url];
//        
//        [request setTimeoutInterval:10]; //Slow 3G connection
        
        //SFIWebService *request_obj = [[SFIWebService alloc] init];
        //[request_obj initWithURL:request andDelegate:self];
        
        //Commented to disable warning
        //Json *myJsonParser = [[Json alloc] init];
        //[myJsonParser startLoadingObjectWithMutableUrl:request andDelegate:self];
    }
    else
    {
        NSLog(@"Switch Off");
        //Set send command in streamer to start sending hue commands
        ai.center = self.view.center;
        [self.view addSubview:ai];
        [ai startAnimating];
        
        //SET_DIMMER in node_ssl_client is 11
        // NSURL Get request is different than POST
        
        //NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=50000001&command=12&value=0"];
          //PY080813 - to remove SFISingleton
//        NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=%d&command=12&value=0",(unsigned int)singleton.deviceid];
//        NSLog(@"Switch Command : %@",urlString);
//        
//        NSURL *url = [[NSURL alloc] initWithString:urlString];
//        
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setURL:url];
//        
//        [request setTimeoutInterval:10]; //Slow 3G connection
        
        //SFIWebService *request_obj = [[SFIWebService alloc] init];
        //[request_obj initWithURL:request andDelegate:self];
        
        //commented to disable warning
        //Json *myJsonParser = [[Json alloc] init];
        //[myJsonParser startLoadingObjectWithMutableUrl:request andDelegate:self];
    }
}


-(void)didFailWithError:(id)error
{
    [ai stopAnimating];
    
    NSString *errorCode = [NSString stringWithFormat:@"%@:%d",@"Error Code" ,[error code]];
    NSLog(@"%@",errorCode);
    [self alertStatus:[error localizedDescription]:errorCode];
}

-(void)dataRequestCompletedWithJsonObject:(id)jsonObject
{
    //Hide Hud and show error message
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [ai stopAnimating];
    NSLog(@"Delegate Data : %@",jsonObject);
    NSDictionary *jsonData = (NSDictionary*)jsonObject;
    NSString *loginRes = (NSString *) [jsonData objectForKey:@"login"];
    
    NSLog(@"Login Response: %@",loginRes);
    if ([loginRes isEqualToString:@"fail"])
    {
        // [self alertStatus:@"Please check your Username and/or Password" :@"Login Failed"];
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    
    CustomAlertView *alertView = [[CustomAlertView alloc]initWithTitle:title
                                                               message:msg
                                                              delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil,nil];
    [alertView show];
}


@end
