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
    self.navigationItem.title = @"Firmware Update";
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_cross_gray"] style:UIBarButtonItemStylePlain target:self action:@selector(onCrossBtnTap:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
//    [self showAlmondUpdateAvailableScreen];
}

-(void)onCrossBtnTap:(id)sender{
    NSLog(@"onCrossBtnTap");
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFIDidTapUpdateAvailCrossBtn object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addAlmondUpdateAvailableScreen:(UITableViewCell *)cell{
    UIView *almondUpdateView = [UIView new];
    
    int viewWidth = self.view.frame.size.width;
    
    almondUpdateView.frame = CGRectMake(0, 0, viewWidth, self.navigationController.view.frame.size.height);
    almondUpdateView.backgroundColor = [UIColor whiteColor];

    [UICommonMethods setupUpdateAvailableScreen:almondUpdateView viewWidth:viewWidth];
    [cell addSubview:almondUpdateView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 420;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createUpdateAvailableCell:tableView];
}

- (UITableViewCell *)createUpdateAvailableCell:(UITableView *)tableView {
    static NSString *no_almond_cell_id = @"updateAvailableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addAlmondUpdateAvailableScreen:cell];
    }
    
    return cell;
}


//-(void)checkToShowUpdateScreen{
//    SFIAlmondPlus *currentAlmond = [[SecurifiToolkit sharedInstance] currentAlmond];
//    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:currentAlmond.almondplusMAC];
//    NSLog(@"current almond dash: %@", currentAlmond);
//    if(currentAlmond.firmware == nil || local){
//        return;
//    }
//    NSLog(@"passed");
//    BOOL isNewVersion = [currentAlmond supportsGenericIndexes:currentAlmond.firmware];
//    if(!isNewVersion){
//        [self showAlmondUpdateAvailableScreen];
//        [self.tabBarController.tabBar setHidden:YES];
//    }
//}


//called places oncurrentalmondchange, onalmondlistdidchange and viewwillappear
@end
