//
//  SFIDimmerViewController.m
//  Securifi Cloud
//
//  Created by Securifi on 13/01/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDimmerViewController.h"
#import "CustomAlertView.h"

@interface SFIDimmerViewController ()

@end

@implementation SFIDimmerViewController

@synthesize dimmerLabelValue, dimmerSlider;


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
    //Only when user done with changing value
    self.dimmerSlider.continuous=NO;
    
    ai =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    //MIGRATING TO SDK
    //singleton = [SFISingleton createSingletonObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendCommand:(unsigned int)value
{
    ai.center = self.view.center;
    [self.view addSubview:ai];
    [ai startAnimating];
    
    //SET_DIMMER in node_ssl_client is 11
    // NSURL Get request is different than POST
    
    // Populate deviceID from singleton object
    
    
    //NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=50000001&command=11&value=%d",(int)value];
    
    //PY080813 - to remove SFISingleton
//    NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=%d&command=11&value=%d",(unsigned int)singleton.deviceid,(int)value];
//    NSLog(@"DIMMER COMMAND STRING %@",urlString);
//    
//    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:url];
//    
//    [request setTimeoutInterval:10]; //Slow 3G connection
    
    //SFIWebService *request_obj = [[SFIWebService alloc] init];
    //[request_obj initWithURL:request andDelegate:self];
    
    //Commented two lines to disable warning
    //Json *myJsonParser = [[Json alloc] init];
    //[myJsonParser startLoadingObjectWithMutableUrl:request andDelegate:self];
}

- (IBAction)dimmerON:(id)sender {
    [self sendCommand:99];
}

- (IBAction)dimmerOFF:(id)sender {
    [self sendCommand:0];
}


- (IBAction)dimmerValueChanged:(UISlider *)sender {
    dimmerLabelValue.text=[NSString stringWithFormat:@"%d", (int)[sender value]];
    //send command to cloud
    
    [self sendCommand:(int)[sender value]];
    
    /* ai.center = self.view.center;
    [self.view addSubview:ai];
    [ai startAnimating];

    //SET_DIMMER in node_ssl_client is 11
    // NSURL Get request is different than POST
    
    NSString *urlString=[[NSString alloc] initWithFormat:@"https://ec2-54-242-107-108.compute-1.amazonaws.com/command?devid=50000001&command=11&value=%d",(int)[sender value]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    [request setTimeoutInterval:10]; //Slow 3G connection
    
    //SFIWebService *request_obj = [[SFIWebService alloc] init];
    //[request_obj initWithURL:request andDelegate:self];
    
    Json *myJsonParser = [[Json alloc] init];
    [myJsonParser startLoadingObjectWithMutableUrl:request andDelegate:self];
     */
     
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
