//
//  SelectedPlanViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SelectedPlanViewController.h"
#import "PaymentCompleteViewController.h"
#import "PaymentTypesViewController.h"

@interface SelectedPlanViewController ()

@end

@implementation SelectedPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBackArrowTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (IBAction)onProceedToPaymentTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PaymentTypesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PaymentTypesViewController"];
        //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        //self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        //[self presentViewController:nav animated:YES completion:nil];
    });
    
    /*
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    PaymentCompleteViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PaymentCompleteViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
     */
}


@end
