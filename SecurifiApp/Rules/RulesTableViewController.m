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

#define AVENIR_ROMAN @"Avenir-Roman"

@interface RulesTableViewController ()<CustomCellTableViewCellDelegate,MBProgressHUDDelegate>{
    NSInteger randomMobileInternalIndex;
}

@property (nonatomic, strong)NSMutableArray *rules;
@property SFIAlmondPlus *currentAlmond;
@property UIButton *buttonAdd;
@end

@implementation RulesTableViewController
CGPoint tablePoint;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeTableViewAttributes];
    tablePoint = self.tableView.contentOffset;
}

-(void)viewWillAppear:(BOOL)animated{
    //    [self.rules removeAllObjects];
    [super viewWillAppear:animated];
    self.enableDrawer = YES;
    randomMobileInternalIndex = arc4random() % 10000;
    
    [self getRuleList];
    [self addAddRuleButton];
    [self markAlmondTitleAndMac];
    [self initializeNotifications];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
    [[Analytics sharedInstance] markRuleScreen];
}
-(BOOL)isLocal{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    BOOL local=[toolkit useLocalNetwork:self.currentAlmond.almondplusMAC];
    if([super currentConnectionMode] == SFIAlmondConnectionMode_cloud)
        local = NO;
    return local;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeAddSceneButton];
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
    
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
}


-(void)markAlmondTitleAndMac{
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

}
- (void)onCurrentAlmondChanged:(id)sender {
    [self.rules removeAllObjects];
    [self markAlmondTitleAndMac];
    [self showHudWithTimeoutMsg:@"Loading Rules..."];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

-(void)initializeTableViewAttributes{
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)onRuleUpdateCommandResponse:(id)sender{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSLog(@"onRuleUpdateCommandResponse ");
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.rules =[NSMutableArray arrayWithArray:toolkit.ruleList];
        
        [self.tableView reloadData];
        [self.HUD hide:YES];
        self.tableView.contentOffset = tablePoint;
    });
    
}

- (void)removeAddSceneButton{
    if(self.buttonAdd)
        [self.buttonAdd removeFromSuperview];
}

-(void)getRuleList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.rules = toolkit.ruleList;
    self.tableView.contentOffset = tablePoint;
}

- (void)addAddRuleButton{
    if (!self.buttonAdd) {
        self.buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonAdd.frame = CGRectMake((self.navigationController.view.frame.size.width - 65)/2, self.navigationController.view.frame.size.height-130, 65, 65);
        [self.buttonAdd setImage:[UIImage imageNamed:@"btnAdd"] forState:UIControlStateNormal];
        self.buttonAdd.backgroundColor = [UIColor clearColor];
        [self.buttonAdd addTarget:self action:@selector(btnAddNewRuleTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:self.buttonAdd];
}


#pragma mark - HUD and Toast mgt
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:20];
    });
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self isRuleArrayEmpty]){
        return 1;
    }
    NSLog(@"row count: %lu", (unsigned long)self.rules.count);
    return self.rules.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isRuleArrayEmpty]){
        return 400;
    }
    return 146; //height of the cell from story board
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isRuleArrayEmpty]){
        return [self createEmptyCell:tableView];
    }
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    Rule *rule = self.rules[indexPath.row];
    CustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCellTableViewCell"];
    if(cell==nil){//check out if this will ever get executed
        cell = [[CustomCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCellTableViewCell"];
    }
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width-20, 25)];
    lbl.alpha = 0.95;
    lbl.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:15.0f];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor whiteColor];
    lbl.numberOfLines = 0;
    //    lbl.text = @"Triggers -> Actions";
    return lbl;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}


#pragma mark button taps
- (void)btnAddNewRuleTap:(id)sender {
    [self.HUD hide:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddRulesViewController * addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
    addRuleController.rule = [[Rule alloc]init];
    [self.navigationController pushViewController:addRuleController animated:YES];
}


#pragma mark helper methods
- (BOOL)isRuleArrayEmpty {
    return self.rules.count == 0;
}

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    static NSString *empty_cell_id = @"EmptyCell";

    UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    const CGFloat table_width = CGRectGetWidth(self.tableView.frame);
    
    UILabel *lblNewScene = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, table_width-20, 130)];
    lblNewScene.textAlignment = NSTextAlignmentCenter;
    [lblNewScene setFont:[UIFont fontWithName:AVENIR_ROMAN size:18]];
    lblNewScene.text = @"New Rule";
    lblNewScene.textColor = [UIColor grayColor];
    [cell addSubview:lblNewScene];
    
    UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, table_width-20, 130)];
    lblNoSensor.textAlignment = NSTextAlignmentCenter;
    [lblNoSensor setFont:[UIFont fontWithName:AVENIR_ROMAN size:15]];
    lblNoSensor.numberOfLines = 10;
    lblNoSensor.text = @"Tap on add button to create your rule";
    lblNoSensor.textColor = [UIColor grayColor];
    [cell addSubview:lblNoSensor];

    [self addAddRuleButton];
    return cell;
}

#pragma mark custom cell Delegate methods
- (void)deleteRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if(self.rules==nil || self.rules.count==0 || self.rules.count<=indexPath.row)
        return;
    [self showHudWithTimeoutMsg:[NSString stringWithFormat:@"Deleting rule %@...",cell.ruleNameLabel.text]];
    NSDictionary *payload = [self getDeleteRulePayload:indexPath.row];
    if(payload!=nil){
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payload JSONString];
        [self asyncSendCommand:cloudCommand];
    }
    [[Analytics sharedInstance] markDeleteRule];
}

-(void)onRuleCommandResponse:(id)sender{ //for delete//need to be work
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSDictionary * mainDict = [data valueForKey:@"data"];
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }
    
    NSString * success = [mainDict valueForKey:@"Success"];
    if (![success isEqualToString:@"true"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scene.alert-title.Oops", @"Oops") message:NSLocalizedString(@"scene.alert-msg.Sorry, There was some problem with this request, try later!", @"Sorry, There was some problem with this request, try later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
        [alert show];
    }
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
    Rule *currentRule = self.rules[row];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    AddRulesViewController *addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
    if(self.rules.count > indexPath.row){
        Rule *rule = [self.rules[indexPath.row] createNew];
        addRuleController.rule = rule;
    }
    addRuleController.isInitialized = YES;
    [[Analytics sharedInstance] markUpdateRule];
    [self.navigationController pushViewController:addRuleController animated:YES];
}

- (void)activateRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if(self.rules==nil || self.rules.count==0 || self.rules.count<=indexPath.row)
        return;
    
    NSString *msg = cell.activeDeactiveSwitch.selected? [NSString stringWithFormat:@"Activating rule - %@...",cell.ruleNameLabel.text]: [NSString stringWithFormat:@"Deactivating rule - %@...",cell.ruleNameLabel.text];
    [self showHudWithTimeoutMsg:msg];
    Rule *rule = self.rules[indexPath.row];
    RulePayload *rulePayload = [RulePayload new];
    rulePayload.rule = rule;
    NSDictionary *payload = [rulePayload validateRule:randomMobileInternalIndex valid:cell.activeDeactiveSwitch.selected?@"true":@"false"];
    
    if(payload!=nil){
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payload JSONString];
        [self asyncSendCommand:cloudCommand];
    }
    [[Analytics sharedInstance] markActivateRule];
}

-(void)setUpHUD{
    self.HUD.removeFromSuperViewOnHide = NO;
    self.HUD.dimBackground = YES;
    self.HUD.delegate = self;
    [self.navigationController.view addSubview:self.HUD];
}

#pragma mark asyncRequest methods
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [[SecurifiToolkit sharedInstance] currentAlmond];
    if([self isLocal]){
        [toolkit asyncSendToLocal:cloudCommand almondMac:almond.almondplusMAC];
    }else{
        [toolkit asyncSendToCloud:cloudCommand];
    }
}

@end