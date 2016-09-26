//
//  SFIScenesTableViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 08.08.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIScenesTableViewController.h"
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
#import "NewAddSceneViewController.h"
#import "SFIButtonSubProperties.h"
#import "AlertView.h"

#define AVENIR_ROMAN @"Avenir-Roman"

@interface SFIScenesTableViewController ()<UITableViewDataSource,UITableViewDelegate,SFIScenesTableViewCellDelegate,MBProgressHUDDelegate> {
    
    UIButton *btnAdd;
    NSInteger randomMobileInternalIndex;
}
@property SFIAlmondPlus *currentAlmond;
@property(nonatomic) SecurifiToolkit *toolkit;
@end

@implementation SFIScenesTableViewController

- (void)viewDidLoad {
    self.needAddButton = YES;
    [super viewDidLoad];
    self.toolkit = [SecurifiToolkit sharedInstance];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"scenes table viewwillappear");
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    
    [self markAlmondTitleAndMac];
    [self initializeNotifications];
    
    if([[SecurifiToolkit sharedInstance] isScreenShown:@"scenes"] == NO)
        [self initializeHelpScreensfirst:@"Scenes"];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

-(void)markAlmondTitleAndMac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    if (self.currentAlmond == nil) {
        [self markNewTitle: NSLocalizedString(@"scene.title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markNewTitle: self.currentAlmond.almondplusName];
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
    }
}

- (void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
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
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}
-(void)updateSceneTableView:(id)sender{
    NSLog(@"updateSceneTableView : %@",self.toolkit.scenesArray);
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        [self.HUD hide:YES];
    });
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
    if ([self isNoAlmondMAC] || [self isSceneListEmpty] || ![self isFirmwareCompatible]) {
        return 400;
    }
    return 90.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isNoAlmondMAC] || ![self isFirmwareCompatible]) {
        return 1;
    }
    
    if ([self isSceneListEmpty]) {
        return 1;
    }
    return self.toolkit.scenesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isFirmwareCompatible] == NO){
        tableView.scrollEnabled = NO;
        return [self createAlmondUpdateAvailableCell:tableView];
    }
    
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
    if(indexPath.row  > (int)self.toolkit.scenesArray.count - 1){
        NSLog(@"scene reload");
        return cell;
    }
    
    [cell createScenesCell:self.toolkit.scenesArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC] || [self isSceneListEmpty]) {
        return;
    }
    
    NewAddSceneViewController *newAddSceneViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewAddSceneViewController"];
    newAddSceneViewController.isInitialized = YES;
    newAddSceneViewController.scene = [self getScene:self.toolkit.scenesArray[indexPath.row]];
    [self.navigationController pushViewController:newAddSceneViewController animated:YES];
}

-(Rule *)getScene:(NSDictionary*)dict{
    Rule *scene = [[Rule alloc]init];
    scene.ID = [dict valueForKey:@"ID"];
    scene.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    scene.isActive = [[dict valueForKey:@"Active"] boolValue];
    scene.triggers= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"SceneEntryList"] list:scene.triggers];
    return scene;
}

-(void)getEntriesList:(NSArray*)sceneEntryList list:(NSMutableArray *)triggers{
    for(NSDictionary *triggersDict in sceneEntryList){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        NSLog(@"triggersDict %@",triggersDict);
        subProperties.deviceId = [[triggersDict valueForKey:@"ID"] intValue];
        subProperties.index = [[triggersDict valueForKey:@"Index"] intValue];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.valid = [[triggersDict valueForKey:@"Valid"] boolValue];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        //        subProperties.type = subProperties.deviceId==0?@"EventTrigger":@"DeviceTrigger";
        //        subProperties.delay=[triggersDict valueForKey:@"PreDelay"];
        //        [self addTime:triggersDict timeProperty:subProperties];
        [triggers addObject:subProperties];
    }
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
        lblNewScene.text = NSLocalizedString(@"newScene",@"New Scene");
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
        
        MessageView *view = [self addMessagegView];
        
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
    
    [self showHudWithTimeoutMsg:NSLocalizedString(@"scenes.hud.activatingScene", @"Activating scene...")];
    [self asyncSendCommand:cloudCommand];
    
    [[Analytics sharedInstance] markActivateScene];
}

#pragma mark
- (void)btnAddNewSceneTap:(id)sender {
    [self removeAlert];
    NewAddSceneViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewAddSceneViewController"];
    viewController.scene = [[Rule alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - HUD mgt
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
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

#pragma mark Notifications
- (void)onCurrentAlmondChanged:(id)sender {
    [self.toolkit.scenesArray removeAllObjects];
    
    [self markAlmondTitleAndMac];
    [self showHudWithTimeoutMsg:NSLocalizedString(@"scenes.hud.loadingScenes", @"Loading Scenes...")];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)onAlmondListDidChange:(id)notice {
    [self markAlmondTitleAndMac];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)gotResponseFor1064:(id)sender {
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
    [self hideHude];
}

#pragma mark - State

- (BOOL)isSceneListEmpty {
    return self.toolkit.scenesArray.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.almondMac isEqualToString:NO_ALMOND];
}

- (void)hideHude{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD hide:YES];
    });
}
#pragma mark event
- (void)onAddBtnTap:(id)sender{
    NSLog(@"scene on add btn tap");
    [self btnAddNewSceneTap:sender];
}
@end
