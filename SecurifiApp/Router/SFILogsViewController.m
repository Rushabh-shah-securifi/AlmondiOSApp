//
//  SFILogsViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 12/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFILogsViewController.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"

@interface SFILogsViewController ()

@end

@implementation SFILogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNavigationBar];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5, 70, self.view.frame.size.width - 10 , 250)];
    view.backgroundColor = [[SFIColors yellowColor] color];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, view.frame.size.width -10, 20)];
    titleLabel.text = @"Repoart a problem";
    titleLabel.font = [UIFont securifiFont:16];
    titleLabel.textColor = [UIColor whiteColor];
    [view addSubview:titleLabel];
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 35, view.frame.size.width -10, 100)];
    textView.text = @"Aloong with your message,this will send Almond debug infiormation and logs to our cloud.This information will help us to resolve your problem faster.Please note that we do not send any sensitive information like your passwords.";
    
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textView.font = [UIFont securifiLightFont:13];
    textView.backgroundColor = [[SFIColors yellowColor] color];
    textView.textColor = [UIColor whiteColor];
    [view addSubview:textView];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(5, 145, view.frame.size.width -10, 20)];
    textField.placeholder = @"Describe your problem here";
    textField.font = [UIFont securifiFont:14];
    textField.textColor = [UIColor whiteColor];
    [textField becomeFirstResponder];
    textField.backgroundColor = [UIColor clearColor];
    [view addSubview:textField];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(5, 166, view.frame.size.width -10, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [view addSubview:lineView];
    
    
    UIButton *doneButton = [[UIButton alloc]initWithFrame:CGRectMake(view.frame.size.width - 110 , 176,100, 40)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.backgroundColor = [UIColor whiteColor];
    [doneButton setTitleColor:[[SFIColors yellowColor] color] forState:UIControlStateNormal];
    [view addSubview:doneButton];
    
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
}

-(void)btnCancelTap:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
