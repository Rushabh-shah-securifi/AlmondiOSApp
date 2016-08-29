//
//  SupportViewController.m
//  SecurifiApp
//
//  Created by Masood on 8/18/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SupportViewController.h"
#import "HelpCenterTableViewCell.h"

@interface SupportViewController ()
@property (nonatomic) NSArray *countryNumbers;
@end

@implementation SupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Support";
    self.countryNumbers= @[@[@"canada",@"CA",@"+1-855-969-7328"],
                               @[@"germany",@"DE",@"+49-800-723-7994"],
                               @[@"france",@"FR",@"+33-805-080-447"],
                               @[@"uk",@"GB",@"+44-800-078-6277"],
                               @[@"taiwan",@"TW",@"+886-800-000-152"],
                                @[@"uae",@"AE",@"+800-0357-04234"],
                               @[@"singapore",@"SG",@"+800-101-3371"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countryNumbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HelpCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"helpcentercell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[HelpCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"helpcentercell"];
    }
    
    [cell setUpSupportCell:self.countryNumbers[indexPath.row] row:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *number = [self.countryNumbers[indexPath.row] objectAtIndex:2];
    NSLog(@"number: %@", number);

    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
}

- (IBAction)onSupportMailTap:(UIButton*)supportBtn {
    NSString *mail = supportBtn.currentTitle;
    NSLog(@"email: %@", mail);
  
    //put email info here:
    NSString *toEmail= mail;
    NSString *subject=@"";
    NSString *body = @"";
    
    //opens mail app with new email started
    NSString *email = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", toEmail,subject,body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


@end
