//
//  SFIScenesTableViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 08.08.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIScenesTableViewController.h"
#import "SFIAddSceneViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "SFINotificationsViewController.h"
#import "SFINotificationStatusBarButtonItem.h"
#import "SFIScenesTableViewCell.h"
#import "UIApplication+SecurifiNotifications.h"
#import <SWRevealViewController/SWRevealViewController.h>
#import "MBProgressHUD.h"
#import "AlmondPlusConstants.h"
#import "UIFont+Securifi.h"
#import "MessageView.h"
#import "UIImage+Securifi.h"
#import "SFICloudLinkViewController.h"
#import "MDJSON.h"
#import "Analytics.h"

#define AVENIR_ROMAN @"Avenir-Roman"

@interface SFIScenesTableViewController ()<UITableViewDataSource,UITableViewDelegate,SFIScenesTableViewCellDelegate,MBProgressHUDDelegate,MessageViewDelegate> {
    
    IBOutlet UIButton *btnAdd;
    NSMutableArray * scenesArray;
    NSInteger randomMobileInternalIndex;
}
@property SFIAlmondPlus *currentAlmond;

@end

@implementation SFIScenesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [self initializeNotifications];
    
    self.currentAlmond = [toolkit currentAlmond];
    if (self.currentAlmond == nil) {
        [self markTitle: NSLocalizedString(@"scene.title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle: self.currentAlmond.almondplusName];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.enableDrawer = YES;
    randomMobileInternalIndex = arc4random() % 10000;
    [self getAllScenes];
    [self addAddSceneButton];
}


- (void)addAddSceneButton{
    if (!btnAdd) {
        btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdd.frame = CGRectMake((self.navigationController.view.frame.size.width - 65)/2, self.navigationController.view.frame.size.height-130, 65, 65);
        [btnAdd setImage:[UIImage imageNamed:@"btnAdd"] forState:UIControlStateNormal];
        btnAdd.backgroundColor = [UIColor clearColor];
        [btnAdd addTarget:self action:@selector(btnAddNewSceneTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:btnAdd];
}

- (void)removeAddSceneButton{
    [btnAdd removeFromSuperview];
}

- (void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    [center addObserver:self
               selector:@selector(gotResponseFor1064:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
    
    [center addObserver:self
               selector:@selector(updateSceneTableView:)
                   name:NOTIFICATION_UPDATE_SCENE_TABLEVIEW
                 object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeAddSceneButton];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}
-(void)updateSceneTableView:(id)sender{
    [self getAllScenes];
    
}


- (void)sendGetAllScenesRequest {
    NSLog(@"scenetableview - sendGetAllScenesRequest");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    if (!plus.almondplusMAC) {
        return;
    }
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand = [GenericCommand cloudSceneListCommand:plus.almondplusMAC];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    //    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.HUD.removeFromSuperViewOnHide = NO;
    self.HUD.labelText = NSLocalizedString(@"scenes.hud.loadingScenes", @"Loading Scenes...");
    self.HUD.dimBackground = YES;
    self.HUD.delegate = self;
    [self.navigationController.view addSubview:self.HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:cloudCommand];
}

#pragma mark

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return 400;
    }
    
    if ([self isSceneListEmpty]) {
        return 400;
    }
    return 90.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isNoAlmondMAC]) {
        return 1;
    }
    
    if ([self isSceneListEmpty]) {
        return 1;
    }
    return scenesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }
    
    if ([self isSceneListEmpty]) {
        tableView.scrollEnabled = NO;
        return [self createEmptyCell:tableView];
    }
    
    tableView.scrollEnabled = YES;
    
    SFIScenesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIScenesTableViewCell"];
    
    int colorIndex = indexPath.row%3;
    
    switch (colorIndex) {
        case 0:
            cell.cellColor = [UIColor colorWithRed:76.0/255.0f green:175.0f/255.0 blue:80.0/255.0f alpha:1];
            break;
        case 1:
            cell.cellColor = [UIColor colorWithRed:255.0/255.0f green:152.0/255.0f blue:0/255.0 alpha:1];
            break;
        case 2:
            cell.cellColor = [UIColor colorWithRed:244.0/255.0f green:67.0/255.0f blue:54.0/255.0f alpha:1];
            
            break;
            
        default:
            break;
    }
    
    cell.delegate = self;
    if(indexPath.row < scenesArray.count)
        [cell createScenesCell:scenesArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC] || [self isSceneListEmpty]) {
        return;
    }
    
    SFIAddSceneViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIAddSceneViewController"];
    viewController.originalSceneInfo = [scenesArray[indexPath.row] mutableCopy];
    viewController.index = (int)indexPath.row;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0000001;
}
#pragma mark - Table View Cell Helpers

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    static NSString *empty_cell_id = @"EmptyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:empty_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        const CGFloat table_width = CGRectGetWidth(self.tableView.frame);
        
        UILabel *lblNewScene = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, table_width-20, 130)];
        lblNewScene.textAlignment = NSTextAlignmentCenter;
        [lblNewScene setFont:[UIFont fontWithName:AVENIR_ROMAN size:18]];
        lblNewScene.text = @"New Scene";
        lblNewScene.textColor = [UIColor grayColor];
        [cell addSubview:lblNewScene];
        
        UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, table_width-20, 130)];
        lblNoSensor.textAlignment = NSTextAlignmentCenter;
        [lblNoSensor setFont:[UIFont fontWithName:AVENIR_ROMAN size:15]];
        lblNoSensor.numberOfLines = 10;
        lblNoSensor.text = NSLocalizedString(@"scenes.no-scenes.label.Scenes allow you to control multiple devices at the same time. For example you can turn all your lights off with a single click.", @"Scenes allow you to control multiple devices at the same time. For example you can turn all your lights off with a single click.");
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];
        
    }
    
    return cell;
}

- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    static NSString *no_almond_cell_id = @"NoAlmondCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        MessageView *view = [MessageView linkRouterMessage];
        view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 400);
        view.delegate = self;
        
        [cell addSubview:view];
    }
    
    return cell;
}

#pragma mark cell delegates
- (void)activateScene:(SFIScenesTableViewCell*)cell Info:(NSDictionary*)cellInfo{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *activateScenePayload = [NSMutableDictionary new];
    
    [activateScenePayload setValue:@"ActivateScene" forKey:@"CommandType"];
    [activateScenePayload setValue:@{@"ID":[cellInfo valueForKey:@"ID"]} forKey:@"Scenes"];
    [activateScenePayload setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    [activateScenePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [activateScenePayload JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    //    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.HUD.removeFromSuperViewOnHide = NO;
    self.HUD.labelText = NSLocalizedString(@"scenes.hud.activatingScene", @"Activating scene...");
    self.HUD.dimBackground = YES;
    self.HUD.delegate = self;
    [self.navigationController.view addSubview:self.HUD];
    [self showHudWithTimeout];
    [self asyncSendCommand:cloudCommand];
    
    [[Analytics sharedInstance] markActivateScene];
}

#pragma mark

- (IBAction)btnAddNewSceneTap:(id)sender {
    SFIAddSceneViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIAddSceneViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

-(BOOL)isLocal{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    return local;
}

- (void)asyncSendCommand:(GenericCommand *)command {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    if(local){
        [[SecurifiToolkit sharedInstance] asyncSendToLocal:command almondMac:almond.almondplusMAC];
    }else{
        [[SecurifiToolkit sharedInstance] asyncSendToCloud:command];
    }
}

#pragma Event handling

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

#pragma mark Notifications
- (void)onCurrentAlmondChanged:(id)sender {
    if (scenesArray!=nil && scenesArray.count>0)
        [scenesArray removeAllObjects];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    
    
    if (self.currentAlmond == nil) {
        [self markTitle: NSLocalizedString(@"scene.title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle: self.currentAlmond.almondplusName];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        [self sendGetAllScenesRequest];
    });
}

- (void)getAllScenes {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    scenesArray = [NSMutableArray arrayWithArray:toolkit.scenesArray];
    [self.tableView reloadData];
    NSLog(@"scenes array: %@", scenesArray);
}

- (void)gotResponseFor1064:(id)sender {
    NSLog(@"gotResponseFor1064 - activatescene");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary * mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }

    if (randomMobileInternalIndex != [[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }
    NSLog(@"%@",mainDict);
    
    [self hideHude];
}

#pragma mark - State

- (BOOL)isSceneListEmpty {
    return scenesArray.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.almondMac isEqualToString:NO_ALMOND];
}

#pragma mark - MessageViewDelegate methods

- (void)messageViewDidPressButton:(MessageView *)msgView {
    UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)hideHude{
    [self.HUD hide:YES];
    if ([[self.navigationController topViewController] isKindOfClass:[SFIScenesTableViewController class]]) {
        [self addAddSceneButton];
    }
}
@end
