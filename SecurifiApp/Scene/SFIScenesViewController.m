//
//  SFIScenesViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIScenesViewController.h"
#import "SFIAddSceneViewController.h"
#import "SFIScenesTableViewCell.h"
#import <SWRevealViewController/SWRevealViewController.h>
#import "MBProgressHUD.h"
#import "SFIParser.h"
#import "MDJSON.h"

@interface SFIScenesViewController ()<UITableViewDataSource,UITableViewDelegate,SFIScenesTableViewCellDelegate> {
    
    __weak IBOutlet UIView *viewGridNewScene;
    __weak IBOutlet UITableView *tblScenes;
    __weak IBOutlet UIButton *btnAdd;
    NSMutableArray * scenesArray;
}

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
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconNotification"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    // Do any additional setup after loading the view.
    
    [self sendGetAllScenesRequest];
    [self initializeNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
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
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:cloudCommand];
}

#pragma mark responses

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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)rightButtonTap:(id)sender {
    
}

- (IBAction)btnAddNewSceneTap:(id)sender {
    SFIAddSceneViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIAddSceneViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
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
    
    NSInteger randomNumber = arc4random() % 10000;
    [activateScenePayload setValue:@(randomNumber) forKey:@"MobileInternalIndex"];
    [activateScenePayload setValue:plus.almondplusMAC forKey:@"AlmondplusMAC"];
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [activateScenePayload JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"scenes.hud.activatingScene", @"Activating scene...");
    _HUD.dimBackground = YES;
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
- (void)gotResponseFor1064:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    NSLog(@"%@",mainDict);
    
    [self.HUD hide:YES];
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
