//
//  AlmondUpdateViewController.m
//  SecurifiApp
//
//  Created by Masood on 8/25/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondUpdateViewController.h"
#import "CommonMethods.h"
#import "UICommonMethods.h"

@interface AlmondUpdateViewController ()

@end

@implementation AlmondUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkToShowUpdateScreen{
    SFIAlmondPlus *currentAlmond = [[SecurifiToolkit sharedInstance] currentAlmond];
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:currentAlmond.almondplusMAC];
    NSLog(@"current almond dash: %@", currentAlmond);
    if(currentAlmond.firmware == nil || local){
        return;
    }
    NSLog(@"passed");
    BOOL isNewVersion = [currentAlmond supportsGenericIndexes:currentAlmond.firmware];
    if(!isNewVersion){
        [self showAlmondUpdateAvailableScreen];
        [self.tabBarController.tabBar setHidden:YES];
    }
}



-(void)showAlmondUpdateAvailableScreen{
    UIView *almondUpdateView = [UIView new];
    
    int viewWidth = self.view.frame.size.width;
    
    almondUpdateView.frame = CGRectMake(0, 0, viewWidth, self.navigationController.view.frame.size.height);
    almondUpdateView.backgroundColor = [UIColor whiteColor];

    [UICommonMethods setupUpdateAvailableScreen:almondUpdateView viewWidth:viewWidth];
}


//called places oncurrentalmondchange, onalmondlistdidchange and viewwillappear
@end
