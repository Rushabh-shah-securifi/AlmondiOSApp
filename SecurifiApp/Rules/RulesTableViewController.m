//
//  RulesTableViewController.m
//  RulesUI
//
//  Created by Securifi-Mac2 on 03/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "RulesTableViewController.h"
#import "CustomCellTableViewCell.h"
#import "Rule.h"
#import "SecurifiToolkit/GenericCommand.h"
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit/ClientParser.h"
#import "AlmondPlusConstants.h"
#import "SFISubPropertyBuilder.h"
#import "MBProgressHUD.h"
#import "RulePayload.h"
#import "Colours.h"
#import "Analytics.h"
#import "UIViewController+Securifi.h"
#import "SFIColors.h"
#import "CommonMethods.h"
#import "UIFont+Securifi.h"
#import "MessageView.h"
#import "SFICloudLinkViewController.h"
#import "LocalNetworkManagement.h"
#import "ConnectionStatus.h"

#define AVENIR_ROMAN @"Avenir-Roman"

@interface RulesTableViewController ()<CustomCellTableViewCellDelegate,MBProgressHUDDelegate, HelpScreensDelegate,MessageViewDelegate, RouterNetworkSettingsEditorDelegate>{
    NSInteger randomMobileInternalIndex;
}

@property UIButton *buttonAdd;
@property(nonatomic) SecurifiToolkit *toolkit;
@property(nonatomic) MBProgressHUD *HUD;
@property(nonatomic) HelpScreens *helpScreensObj;
@property(nonatomic) UIView *maskView;
@end

@implementation RulesTableViewController
CGPoint tablePoint;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolkit = [SecurifiToolkit sharedInstance];
    if([[SecurifiToolkit sharedInstance] isScreenShown:@"rules"] == NO)
        [self initializeHelpScreens];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tablePoint = self.tableView.contentOffset;
    [self setUpHUD];
    [self setUpNavBar];
}

-(void)viewWillAppear:(BOOL)animated{
    //    [self.rules removeAllObjects];
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    
    self.tableView.contentOffset = tablePoint;
    
    [self markAlmondTitle];
    [self initializeNotifications];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
    [[Analytics sharedInstance] markRuleScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onRuleUpdateCommandResponse:)
                   name:SAVED_TABLEVIEW_RULE_COMMAND
                 object:nil];
    
    [center addObserver:self selector:@selector(onRuleCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
    
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onConnectionStatusChanged:)
                   name:CONNECTION_STATUS_CHANGE_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onAlmondNameDidChange:)
                   name:kSFIDidChangeAlmondName
                 object:nil];
}

-(void)markAlmondTitle{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *currentAlmond = [toolkit currentAlmond];
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
                                 NSFontAttributeName : [UIFont standardNavigationTitleFont]
                                 };
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    if (currentAlmond == nil) {
        self.navigationItem.title = NSLocalizedString(@"scene.title.Get Started", @"Get Started");
    }
    else {
        
        self.navigationItem.title = [CommonMethods getTitleShortName:currentAlmond.almondplusName];
    }
}

-(void)setUpNavBar{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.navigationController.navigationBar.translucent = NO;
    
    if(toolkit.currentAlmond){
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_almond_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onAddBtnTap:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self isNoAlmondMAC] || [self isRuleArrayEmpty]){
        return 1;
    }
    NSLog(@"row count: %lu", (unsigned long)self.toolkit.ruleList.count);
    return self.toolkit.ruleList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isNoAlmondMAC] || [self isRuleArrayEmpty]){
        return 400;
    }
    return 146; //height of the cell from story board
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return [self createNoAlmondCell:tableView];
    }
    
    if([self isRuleArrayEmpty]){
        return [self createEmptyCell:tableView];
    }
    
    CustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCellTableViewCell"];
    if(cell==nil){//check out if this will ever get executed
        cell = [[CustomCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCellTableViewCell"];
    }
    
    
    if(indexPath.row  > (int)self.toolkit.ruleList.count - 1){
        NSLog(@"rule list empty");
        return cell;
    }
    
    Rule *rule = self.toolkit.ruleList[indexPath.row];
    cell.delegate = self;
    cell.ruleNameLabel.text = rule.name;
    [cell.activeDeactiveSwitch setSelected:rule.isActive];
    [cell.activeDeactiveSwitch setOn:rule.isActive animated:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [SFISubPropertyBuilder createEntryForView:cell.scrollView indexScrollView:nil parentView:nil parentClass:nil triggers:rule.triggers actions:rule.actions isCrossButtonHidden:YES isRuleActive:rule.isActive isScene:NO];
    
    // Configure the cell...
    [cell.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}


#pragma mark button taps
- (void)btnAddNewRuleTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
    AddRulesViewController * addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
    addRuleController.rule = [[Rule alloc]init];
    [self.navigationController pushViewController:addRuleController animated:YES];
}


#pragma mark helper methods
- (BOOL)isNoAlmondMAC {
    return [SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC == nil;
}

- (BOOL)isRuleArrayEmpty {
    return self.toolkit.ruleList.count == 0;
}

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    static NSString *empty_cell_id = @"EmptyCell";
    
    UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    const CGFloat table_width = CGRectGetWidth(self.tableView.frame);
    
    UILabel *lblNewScene = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, table_width-20, 130)];
    lblNewScene.textAlignment = NSTextAlignmentCenter;
    [lblNewScene setFont:[UIFont fontWithName:AVENIR_ROMAN size:18]];
    lblNewScene.text = NSLocalizedString(@"newRule",@"New Rule");
    lblNewScene.textColor = [UIColor grayColor];
    [cell addSubview:lblNewScene];
    
    UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, table_width-20, 130)];
    lblNoSensor.textAlignment = NSTextAlignmentCenter;
    [lblNoSensor setFont:[UIFont fontWithName:AVENIR_ROMAN size:15]];
    lblNoSensor.numberOfLines = 10;
    lblNoSensor.text = NSLocalizedString(@"RulesViewController Tap on add button to create your rule",@"Tap on add button to create your rule");
    lblNoSensor.textColor = [UIColor grayColor];
    [cell addSubview:lblNoSensor];
    
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
#pragma mark custom cell Delegate methods
- (void)deleteRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if(self.toolkit.ruleList==nil || self.toolkit.ruleList.count==0 || indexPath.row >= self.toolkit.ruleList.count)
        return;
    [self showHudWithTimeoutMsg:[NSString stringWithFormat:NSLocalizedString(@"RulesViewController Deleting rule %@...",@"Deleting rule %@..."),cell.ruleNameLabel.text]];
    NSDictionary *payload = [self getDeleteRulePayload:indexPath.row];
    if(payload!=nil){
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payload JSONString];
        [self.toolkit asyncSendToNetwork:cloudCommand];
    }
    [[Analytics sharedInstance] markDeleteRule];
}

-(NSDictionary *)getdeleteAllPayload{
    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
    [rulePayload setValue:@"RemoveAllRules" forKey:@"CommandType"];
    return rulePayload;
}

-(NSDictionary *)getDeleteRulePayload:(NSInteger)row{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    if (!plus.almondplusMAC) {
        return nil;
    }
    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
    Rule *currentRule = self.toolkit.ruleList[row];
    if(currentRule==nil ||currentRule.ID==nil)
        return nil;
    
    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
    [rulePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    
    [rulePayload setValue:@"RemoveRule" forKey:@"CommandType"];
    [rulePayload setValue:[self getRuleID:currentRule.ID] forKey:@"Rules"]; //Get From Rule instance
    
    return rulePayload;
    
}
-(NSDictionary *)getRuleID:(NSString *)ruleid{
    NSDictionary *dict = @{
                           @"ID" : ruleid
                           };
    return dict;
}
- (void)editRule:(CustomCellTableViewCell *)cell{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    AddRulesViewController *addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
    if(indexPath.row < self.toolkit.ruleList.count){
        Rule *rule = [self.toolkit.ruleList[indexPath.row] createNew];
        addRuleController.rule = rule;
    }
    addRuleController.isInitialized = YES;
    [[Analytics sharedInstance] markUpdateRule];
    [self.navigationController pushViewController:addRuleController animated:YES];
}

- (void)activateRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if(self.toolkit.ruleList==nil || self.toolkit.ruleList.count==0 || indexPath.row >= self.toolkit.ruleList.count)
        return;
    //
    NSString *msg = cell.activeDeactiveSwitch.selected? [NSString stringWithFormat: NSLocalizedString(@"RulesViewController Activating rule - %@...",@"Activating rule - %@..."),cell.ruleNameLabel.text]: [NSString stringWithFormat:NSLocalizedString(@"RulesViewController Deactivating rule - %@...",@"Deactivating rule - %@..."),cell.ruleNameLabel.text];
    [self showHudWithTimeoutMsg:msg];
    Rule *rule = self.toolkit.ruleList[indexPath.row];
    RulePayload *rulePayload = [RulePayload new];
    rulePayload.rule = rule;
    NSDictionary *payload = [rulePayload validateRule:randomMobileInternalIndex valid:cell.activeDeactiveSwitch.selected?@"true":@"false"];
    
    if(payload!=nil){
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payload JSONString];
        [self.toolkit asyncSendToNetwork:cloudCommand];
    }
    [[Analytics sharedInstance] markActivateRule];
}

#pragma mark events
- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"on current almond change: %@", [SecurifiToolkit sharedInstance].currentAlmond);
    [self.toolkit.ruleList removeAllObjects];
    [self markAlmondTitle];
    [self showHudWithTimeoutMsg:NSLocalizedString(@"RulesViewController Loading Rules...",@"Loading Rules...")];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)onAlmondListDidChange:(id)notice {
    [self markAlmondTitle];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)onAlmondNameDidChange:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        SFIAlmondPlus *obj = (SFIAlmondPlus *) [data valueForKey:@"data"];
        if ([self isSameAsCurrentMAC:obj.almondplusMAC]) {
            [self markAlmondTitle];
        }
    });
}

- (BOOL)isSameAsCurrentMAC:(NSString *)aMac {
    if (aMac == nil) {
        return NO;
    }
    
    NSString *current = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    if (current == nil) {
        return NO;
    }
    
    return [current isEqualToString:aMac];
}


-(void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
    if(statusIntValue == IS_CONNECTING_TO_NETWORK){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            [self showHudWithTimeoutMsg:@"Loading..."];
        });
    }
}

#pragma mark command response
- (void)onRuleUpdateCommandResponse:(id)sender{
    NSLog(@"onRuleUpdateCommandResponse ");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        [self.HUD hide:YES];
        self.tableView.contentOffset = tablePoint;
    });
}

-(void)onRuleCommandResponse:(id)sender{ //mobile command
    NSLog(@"onUpdateDeviceIndexResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    SFIAlmondPlus *almond = [self.toolkit currentAlmond];
    BOOL local = [self.toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"devicelistcontroller - mobile - payload: %@", payload);
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD hide:YES];
        if(isSuccessful == NO){
            [self showToast:NSLocalizedString(@"DeviceList Sorry, Could not update!",@"Sorry, Could not update!")];
        }else{
            [self showToast:NSLocalizedString(@"RulesViewController Successfully updated!",@"Successfully updated!")];
        }
    });
}
#pragma mark - MessageViewDelegate methods

- (void)messageViewDidPressButton:(MessageView *)msgView {
    enum SFIAlmondConnectionMode mode = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    switch (mode) {
        case SFIAlmondConnectionMode_cloud: {
            UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
            [self presentViewController:ctrl animated:YES completion:nil];
            break;
        }
        case SFIAlmondConnectionMode_local: {
            RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
            editor.delegate = self;
            editor.makeLinkedAlmondCurrentOne = YES;
            
            UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
            
            [self presentViewController:ctrl animated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - HUD and Toast mgt
-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}

- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:20];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

#pragma mark tap events
- (void)onAddBtnTap:(id)sender{
    NSLog(@"on add btn tap");
    [self btnAddNewRuleTap:sender];
}

#pragma mark help screens
-(void)initializeHelpScreens{
    NSLog(@"nav view heigt: %f, view ht: %f", self.navigationController.view.frame.size.height, self.view.frame.size.height);
    [self.toolkit setScreenDefault:@"rules"];
    
    NSDictionary *startScreen = [CommonMethods getDict:@"Quick_Tips" itemName:@"rules"];
    
    self.helpScreensObj = [HelpScreens initializeHelpScreen:self.navigationController.view isOnMainScreen:YES startScreen:startScreen];
    self.helpScreensObj.delegate = self;
    
    [self.tabBarController.view addSubview:self.helpScreensObj];
    //    [self.tabBarController.tabBar setHidden:YES];
}

#pragma mark helpscreen delegate methods
- (void)resetViewDelegate{
    NSLog(@"dashboard reset view");
    [self.helpScreensObj removeFromSuperview];
    [self.maskView removeFromSuperview];
    //    [self.tabBarController.tabBar setHidden:NO];
    
}

- (void)onSkipTapDelegate{
    NSLog(@"dashboard skip delegate");
    //    [self.tabBarController.tabBar setHidden:YES];
    [self showOkGotItView];
}


- (void)showOkGotItView{
    NSLog(@"showokgotit");
    self.maskView = [[UIView alloc]init];
    self.maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height);
    [self.maskView setBackgroundColor:[SFIColors maskColor]];
    [self.tabBarController.view addSubview:self.maskView];
    
    [HelpScreens initializeGotItView:self.helpScreensObj navView:self.navigationController.view];
    
    [self.maskView addSubview:self.helpScreensObj];
}

#pragma mark - RouterNetworkSettingsEditorDelegate methods

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    
    [LocalNetworkManagement storeLocalNetworkSettings:newSettings];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {
    
}

@end
