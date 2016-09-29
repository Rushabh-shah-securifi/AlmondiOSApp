//
//  SFILogsViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 12/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFILogsViewController.h"
#import "SFITableViewController.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "RouterPayload.h"
#import "MBProgressHUD.h"
#import "UIViewController+Securifi.h"

@interface SFILogsViewController ()<MBProgressHUDDelegate, UITextFieldDelegate>
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIView *logView;
@property NSTimer *hudTimer;
@property(nonatomic) MBProgressHUD *HUD;
@end

@implementation SFILogsViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavigationBar];
    [self addLogsView];
    [self setUpHUD];
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"logs - viewWillAppear");
    [super viewWillAppear:animated];
    mii = arc4random() % 10000;
    [self initializeNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [self onHudTimeout:nil];
}
- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onLogsRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
}

-(void)addLogsView{
    self.logView = [[UIView alloc]initWithFrame:CGRectMake(5, 70, self.view.frame.size.width - 10 , 250)];
    self.logView.backgroundColor = [[SFIColors yellowColor] color];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.logView.frame.size.width -10, 20)];
    titleLabel.text = NSLocalizedString(@"router.card-title.Send Logs",@"Report a problem");
    titleLabel.font = [UIFont securifiFont:16];
    titleLabel.textColor = [UIColor whiteColor];
    [self.logView addSubview:titleLabel];
    
    UILabel *msgLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 35, self.logView.frame.size.width -10, 100)];
    msgLable.text = NSLocalizedString(@"SFILogsViewController_logs_msg_title", @"");
    msgLable.lineBreakMode = NSLineBreakByWordWrapping;
    msgLable.numberOfLines = 0;
    msgLable.font = [UIFont securifiLightFont:13];
    msgLable.backgroundColor = [[SFIColors yellowColor] color];
    msgLable.textColor = [UIColor whiteColor];
    [self.logView addSubview:msgLable];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(5, 145, self.logView.frame.size.width -10, 20)];
    self.textField.placeholder = NSLocalizedString(@"SFILogsViewController Describe your problem here",@"Describe your problem here");
    self.textField.font = [UIFont securifiFont:14];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.delegate = self;
    [self.textField becomeFirstResponder];
    [self.logView addSubview:self.textField];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(5, 166, self.logView.frame.size.width -10, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.logView addSubview:lineView];
    
    
    UIButton *doneButton = [[UIButton alloc]initWithFrame:CGRectMake(self.logView.frame.size.width - 110 , 176,100, 40)];
    [doneButton setTitle:NSLocalizedString(@"SFILogsViewController Send",@"Send") forState:UIControlStateNormal];//
    doneButton.backgroundColor = [UIColor whiteColor];
    [doneButton setTitleColor:[[SFIColors yellowColor] color] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(onSendLogsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.logView addSubview:doneButton];
    
    [self.view addSubview:self.logView];
}
-(void)addValidationLable{
    UILabel *alertLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 176, self.view.frame.size.width -120, 40)];
    alertLable.text = NSLocalizedString(@"SFILogsViewController Please write description between 10 and 180 characters.",@"Please write description between 10 and 180 characters.");
    alertLable.lineBreakMode = NSLineBreakByWordWrapping;
    alertLable.numberOfLines = 0;
    alertLable.font = [UIFont securifiLightFont:13];
    alertLable.backgroundColor = [[SFIColors yellowColor] color];
    alertLable.textColor = [UIColor whiteColor];
    [self.logView addSubview:alertLable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back",@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

-(void)btnCancelTap:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onSendLogsPressed:(id)sender{
   
    if([_textField.text length] < 10){
        [self addValidationLable];
        [self.textField becomeFirstResponder];
    }else{
        [self showHudWithTimeout:NSLocalizedString(@"sendingLogs",@"Sending logs")];
        [self.textField resignFirstResponder];
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [RouterPayload sendLogs:self.textField.text mii:mii mac:toolkit.currentAlmond.almondplusMAC];
    }
}

- (void)onLogsRouterCommandResponse:(id)sender {
    NSLog(@"onLogsRouterCommandResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    
    if (data == nil) {
        return;
    }
    SFIGenericRouterCommand *genericRouterCommand = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self || !genericRouterCommand.commandSuccess) {// || mii != genericRouterCommand.mii
            [self showToast:NSLocalizedString(@"SFILogsViewController Sorry! Unable to send logs.",@"Sorry! Unable to send logs.")];
            return;
        }
        else if(genericRouterCommand.commandType == SFIGenericRouterCommandType_SEND_LOGS_RESPONSE){
            NSLog(@"success true");
            [self showToast:NSLocalizedString(@"SFILogsViewController Logs successfully sent!",@"Logs successfully sent!")];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

#pragma mark HUD mgt

- (void)showHudWithTimeout:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        self.hudTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onHudTimeout:) userInfo:nil repeats:NO];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)onHudTimeout:(id)sender {
    [self.hudTimer invalidate];
    self.hudTimer = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

#pragma mark uitextfielddelegate
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

@end
