//
//  SFIScenesViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIScenesViewController.h"
#import "SFIAddSceneViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "SFINotificationsViewController.h"
#import "SFINotificationStatusBarButtonItem.h"
#import "SFIScenesTableViewCell.h"
#import "UIApplication+SecurifiNotifications.h"
#import <SWRevealViewController/SWRevealViewController.h>
#import "MBProgressHUD.h"
#import "SFIParser.h"
#import "MDJSON.h"

@interface SFIScenesViewController ()<UITableViewDataSource,UITableViewDelegate,SFIScenesTableViewCellDelegate,MBProgressHUDDelegate> {
    
    __weak IBOutlet UIView *viewGridNewScene;
    __weak IBOutlet UITableView *tblScenes;
    __weak IBOutlet UIButton *btnAdd;
    NSMutableArray * scenesArray;
    NSInteger randomMobileInternalIndex;
}

@property(nonatomic, readonly) SFINotificationStatusBarButtonItem *notificationsStatusButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@end



@implementation SFIScenesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self createLeftButton];
    
    self.title = @"Scenes";
    SWRevealViewController *revealController = [self revealViewController];
    UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"drawer.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    self.navigationController.navigationBar.translucent = NO;
    
    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onCloudStatusButtonPressed:)];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    
    if (configurator.enableNotifications) {
        _notificationsStatusButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(onShowNotifications:)];
        
        NSInteger count = [[SecurifiToolkit sharedInstance] countUnviewedNotifications];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) count];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spacer.width = 25;
        
        self.navigationItem.rightBarButtonItems = @[self.statusBarButton, spacer, self.notificationsStatusButton];
    }
    else {
        self.navigationItem.rightBarButtonItem = _statusBarButton;
    };
    //
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
    
    [self sendGetAllScenesRequest];
    [self initializeNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // make sure status icon is up-to-date
    [self markCloudStatusIcon];
    [self markNotificationStatusIcon];
    
    
    randomMobileInternalIndex = arc4random() % 10000;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [tblScenes reloadData];
    });
}

- (void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(getAllScenesCallback:)
                   name:NOTIFICATION_GET_ALL_SCENES_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onScenesListChange:)
                   name:NOTIFICATION_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    [center addObserver:self
               selector:@selector(gotResponseFor1064:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onShowNotifications:)
                   name:kApplicationDidBecomeActiveOnNotificationTap
                 object:nil];
    [center addObserver:self
               selector:@selector(onAlmondModeChangeDidComplete:)
                   name:kSFIDidCompleteAlmondModeChangeRequest
                 object:nil];
    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationDidStore
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationBadgeCountDidChange
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationDidMarkViewed
                 object:nil];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}



- (void)sendGetAllScenesRequest {
    
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_GET_ALL_SCENES;
    NSDictionary * testDict =@{@"MobileCommand":@"LIST_SCENE_REQUEST",
                               @"AlmondplusMAC":plus.almondplusMAC};
    
    NSLog(@"%@",testDict);
    
    cloudCommand.command = [testDict JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"scenes.hud.loadingScenes", @"Loading Scenes...");
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
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
    
    
    return 90.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return scenesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    [cell createScenesCell:scenesArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark cell delegates
- (void)activateScene:(SFIScenesTableViewCell*)cell Info:(NSDictionary*)cellInfo{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *activateScenePayload = [NSMutableDictionary new];
    
    [activateScenePayload setValue:@"ActivateScene" forKey:@"CommandType"];
    [activateScenePayload setValue:[cellInfo valueForKey:@"SceneID"] forKey:@"SceneID"];
    [activateScenePayload setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    [activateScenePayload setValue:plus.almondplusMAC forKey:@"AlmondplusMAC"];
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [activateScenePayload JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"scenes.hud.activatingScene", @"Activating scene...");
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [self asyncSendCommand:cloudCommand];
    
}
- (void)showEmptySceneTitle{
    if (scenesArray.count==0) {
        viewGridNewScene.hidden = NO;
        btnAdd.hidden = YES;
    }else{
        viewGridNewScene.hidden = YES;
        btnAdd.hidden = NO;
    }
}
#pragma mark

- (IBAction)btnAddNewSceneTap:(id)sender {
    SFIAddSceneViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIAddSceneViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    _isHudHidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}
#pragma Event handling

- (void)onCloudStatusButtonPressed:(id)sender {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    
    if (!configurator.enableNotifications) {
        return;
    }
    
    SFICloudStatusBarButtonItem *button = self.statusBarButton;
    SFICloudStatusState state = button.state;
    
    enum SFIAlmondMode newMode;
    NSString *msg;
    
    if (state == SFICloudStatusStateAtHome) {
        newMode = SFIAlmondMode_away;
        msg = @"Setting Almond to Away Mode";
    }
    else if (state == SFICloudStatusStateAway) {
        newMode = SFIAlmondMode_home;
        msg = @"Setting Almond to Home Mode";
    }
    else {
        return;
    }
    
    // if the hud is already being shown then ignore the button press
    if (!self.isHudHidden) {
        return;
    }
    
    [self showHUD:msg];
    [self.HUD hide:YES afterDelay:10]; // in case the request times out
    
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [toolkit asyncRequestAlmondModeChange:plus.almondplusMAC mode:newMode];
}
- (void)markNotificationStatusIcon {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    if (configurator.enableNotifications) {
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        NSInteger badgeCount = [toolkit notificationsBadgeCount];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) badgeCount];
    }
}

- (void)markCloudStatusIcon {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    if ([toolkit isCloudConnecting]) {
        [self.statusBarButton markState:SFICloudStatusStateConnecting];
    }
    else if ([toolkit isCloudOnline]) {
        if (configurator.enableNotifications) {
            SFIAlmondMode mode = [toolkit modeForAlmond:plus.almondplusMAC];
            enum SFICloudStatusState state = [self stateForAlmondMode:mode];
            [self.statusBarButton markState:state];
        }
        else {
            [self.statusBarButton markState:SFICloudStatusStateConnected];
        }
    }
    else {
        [self.statusBarButton markState:SFICloudStatusStateAlmondOffline];
    }
}
- (enum SFICloudStatusState)stateForAlmondMode:(SFIAlmondMode)mode {
    switch (mode) {
        case SFIAlmondMode_home:
            return SFICloudStatusStateAtHome;
        case SFIAlmondMode_away:
            return SFICloudStatusStateAway;
            
        case SFIAlmondMode_unknown:
        default:
            // can happen when the cloud connection comes up but before almond mode has been determined
            return SFICloudStatusStateConnected;
    }
}

- (void)showHUD:(NSString *)text {
    _isHudHidden = NO;
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

#pragma mark HUD management

- (void)hudWasHidden:(MBProgressHUD *)hud {
    _isHudHidden = YES;
}
#pragma mark Notifications
- (void)onAlmondModeChangeDidComplete:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.HUD hide:YES];
    });
}

- (void)onNotificationCountChanged:(id)event {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNotificationStatusIcon];
    });
}
- (void)onShowNotifications:(id)onShowNotifications {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController != nil) {
            return;
        }
        
        SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        ctrl.enableDebugMode = YES;
        
        UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        [self presentViewController:nav_ctrl animated:YES completion:nil];
    });
}

- (void)onCurrentAlmondChanged:(id)sender {
    if (scenesArray) {
        [scenesArray removeAllObjects];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self sendGetAllScenesRequest];
        //        [self initializeAlmondData];
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)getAllScenesCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSLog(@"%@",[data valueForKey:@"data"]);
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
        scenesArray = [mainDict valueForKey:@"Scenes"];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [tblScenes reloadData];
            [self.HUD hide:YES];
        });
        
    }else {
        DLog(@"Reason Code %@", [mainDict valueForKey:@"reasonCode"]);
        [self.HUD hide:YES];
    }
    [self showEmptySceneTitle];
}
- (void)onScenesListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    
    
    
    NSString * commandType = [mainDict valueForKey:@"CommandType"];
    
    if ([commandType isEqualToString:@"DynamicActivateScene"]) {
        //scenes has been activated
        for (NSMutableDictionary *sceneDict in scenesArray) {
            if ([[sceneDict valueForKey:@"SceneID"] intValue]==[[mainDict valueForKey:@"SceneID"] intValue]) {
                //                        [sceneDict setValue:[mainDict valueForKey:@"SceneEntryList"] forKey:@"SceneEntryList"];
                [sceneDict setValue:[mainDict valueForKey:@"IsActive"] forKey:@"IsActive"];
                
            }
        }
        [tblScenes reloadData];
        return;
    }
    
    if ([commandType isEqualToString:@"DynamicSetScene"]) {
        //scenes parameterers has been updated
        for (NSMutableDictionary *sceneDict in [scenesArray copy]) {
            if ([[sceneDict valueForKey:@"SceneID"] intValue]==[[mainDict valueForKey:@"SceneID"] intValue]) {
                [sceneDict setValue:[mainDict valueForKey:@"SceneEntryList"] forKey:@"SceneEntryList"];
                [sceneDict setValue:[mainDict valueForKey:@"SceneName"] forKey:@"SceneName"];
                
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^() {
            [tblScenes reloadData];
        });
        return;
    }
    
    if ([commandType isEqualToString:@"DynamicCreateScene"]) {
        NSArray *scenes = [mainDict valueForKey:@"Scenes"];
        //scenes has been added
        for (NSDictionary * dict in scenes) {
            NSMutableDictionary * sceneDict = [NSMutableDictionary new];
            [sceneDict setValue:[dict valueForKey:@"SceneEntryList"] forKey:@"SceneEntryList"];
            [sceneDict setValue:[dict valueForKey:@"SceneName"] forKey:@"SceneName"];
            [sceneDict setValue:[dict valueForKey:@"SceneID"] forKey:@"SceneID"];
            [scenesArray addObject:sceneDict];
        }
        [self showEmptySceneTitle];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [tblScenes reloadData];
        });
        return;
    }
    if ([commandType isEqualToString:@"DynamicDeleteScene"]) {
        for (NSDictionary * sceneDict in [scenesArray copy]) {
            if ([[mainDict valueForKey:@"SceneID"] intValue]==[[sceneDict valueForKey:@"SceneID"] intValue])
            {
                [scenesArray removeObject:sceneDict];
            }
        }
        [self showEmptySceneTitle];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [tblScenes reloadData];
        });
        return;
    }
}

- (void)gotResponseFor1064:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }
    NSLog(@"%@",mainDict);
    
    [self.HUD hide:YES];
}

@end
