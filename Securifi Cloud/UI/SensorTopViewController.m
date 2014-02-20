//
//  NavigationTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 2/13/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "SensorTopViewController.h"
#import "SensorsViewController.h"

@implementation SensorTopViewController

@synthesize currentMAC;

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (![self.slidingViewController.underLeftViewController isKindOfClass:[DrawerViewController class]]) {
    self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
  }
  
    
//  if (![self.slidingViewController.underRightViewController isKindOfClass:[UnderRightViewController class]]) {
//    self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UnderRight"];
//  }
  

     //Problem with detecting swipe gesture for Delete
   //[self.view addGestureRecognizer:self.slidingViewController.panGesture];

   
    SensorsViewController *viewController =[[SensorsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    self.currentMAC = [standardUserDefaults objectForKey:@"CurrentMAC"];
//     //// NSLog(@"Current MAC: %@", self.currentMAC);
//    if([self.currentMAC isEqualToString:@"Taipei Office"]){
//        [standardUserDefaults setObject:@"0" forKey:@"ColorCode"];
//        viewController.currentColorIndex = 0;
//        [self.navigationController pushViewController:viewController animated:YES];
//    }else  if([self.currentMAC isEqualToString:@"Taichung Home"]){
//        [standardUserDefaults setObject:@"1" forKey:@"ColorCode"];
//        viewController.currentColorIndex = 1;
//        [self.navigationController pushViewController:viewController animated:YES];
//    }else  if([self.currentMAC isEqualToString:@"Tyrol Cabin"]){
//        viewController.currentColorIndex = 2;
//        [standardUserDefaults setObject:@"2" forKey:@"ColorCode"];
//        [self.navigationController pushViewController:viewController animated:YES];
//    }else  if([self.currentMAC isEqualToString:@"4"]){
//        viewController.currentColorIndex = 3;
//        [standardUserDefaults setObject:@"3" forKey:@"ColorCode"];
//        [self.navigationController pushViewController:viewController animated:YES];
//    }else  if([self.currentMAC isEqualToString:@"5"]){
//        viewController.currentColorIndex = 4;
//        [standardUserDefaults setObject:@"4" forKey:@"ColorCode"];
//        [self.navigationController pushViewController:viewController animated:YES];
//    }else  if([self.currentMAC isEqualToString:@"6"]){
//        viewController.currentColorIndex = 5;
//        [standardUserDefaults setObject:@"5" forKey:@"ColorCode"];
//        [self.navigationController pushViewController:viewController animated:YES];
//    }else  if([self.currentMAC isEqualToString:@"7"]){
//        viewController.currentColorIndex = 6;
//        [standardUserDefaults setObject:@"6" forKey:@"ColorCode"];
//        [self.navigationController pushViewController:viewController animated:YES];
//    }
//
//
//    [standardUserDefaults synchronize];
    
    
}

@end
