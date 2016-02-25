//
//  RulesTableViewController.m
//  RulesUI
//
//  Created by Securifi-Mac2 on 03/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "RulesTableViewController.h"
#import "CustomCellTableViewCell.h"
#import "SecurifiToolkit/Rule.h"
#import "SecurifiToolkit/GenericCommand.h"
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit/Parser.h"
#import "AlmondPlusConstants.h"
#import "SFISubPropertyBuilder.h"
#import "MBProgressHUD.h"
#import "RulePayload.h"
#import "Colours.h"

#define AVENIR_ROMAN @"Avenir-Roman"

@interface RulesTableViewController ()<AddRulesViewControllerDelegate, CustomCellTableViewCellDelegate,MBProgressHUDDelegate>{
    NSInteger randomMobileInternalIndex;
}

@property (nonatomic, strong)NSMutableArray *rules;
@property SFIAlmondPlus *currentAlmond;
@property UIButton *buttonAdd;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation RulesTableViewController
CGPoint tablePoint;
- (void)viewDidLoad {
    [super viewDidLoad];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [self initializeNotifications];
    [self initializeTableViewAttributes];
    tablePoint = self.tableView.contentOffset;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated{
    //    [self.rules removeAllObjects];
    [super viewWillAppear:animated];
    self.enableDrawer = YES;
    [self getRuleList];
    if([self isLocal]){
        [self addAddRuleButton];
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    if (self.currentAlmond == nil) {
        [self markTitle: @"Get Started"];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle: self.currentAlmond.almondplusName];
    }
    randomMobileInternalIndex = arc4random() % 10000;
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
    [center addObserver:self selector:@selector(onRuleUpdateCommandResponse:) name:SAVED_TABLEVIEW_RULE_COMMAND object:nil];
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self getRuleList];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}
-(void)initializeTableViewAttributes{
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)onRuleUpdateCommandResponse:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        self.rules =[NSMutableArray arrayWithArray:toolkit.ruleList];
        [self.tableView reloadData];
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
    
    
    [self.tableView reloadData];
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

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
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
    return self.rules.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isRuleArrayEmpty]){
        return 400;
    }
    return 154; //height of the cell from story board
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isRuleArrayEmpty] || ![self isLocal]){
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
    [SFISubPropertyBuilder createEntriesView:cell.scrollView triggers:rule.triggers actions:rule.actions isCrossButtonHidden:YES parentController:nil isRuleActive:rule.isActive];
    
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
    addRuleController.delegate = self;
    addRuleController.indexPathRow = (int)[self.rules count]; //index path, when you are creating a new entry
    [self.navigationController pushViewController:addRuleController animated:YES];
}


#pragma mark helper methods
- (BOOL)isRuleArrayEmpty {
    return self.rules.count == 0;
}

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    static NSString *empty_cell_id = @"EmptyCell";
    
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:empty_cell_id];
    
    //if (cell == nil || ![self isLocal]) {
        UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        const CGFloat table_width = CGRectGetWidth(self.tableView.frame);
        
        UILabel *lblNewScene = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, table_width-20, 130)];
        lblNewScene.textAlignment = NSTextAlignmentCenter;
        [lblNewScene setFont:[UIFont fontWithName:AVENIR_ROMAN size:18]];
        lblNewScene.text = ![self isLocal]?@"":@"New Rule";
        lblNewScene.textColor = [UIColor grayColor];
        [cell addSubview:lblNewScene];
        
        UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, table_width-20, 130)];
        lblNoSensor.textAlignment = NSTextAlignmentCenter;
        [lblNoSensor setFont:[UIFont fontWithName:AVENIR_ROMAN size:15]];
        lblNoSensor.numberOfLines = 10;
        lblNoSensor.text = ![self isLocal]?@"At this time, you can view, create and edit rules only in Local Connection":@"Tap on add button to create your rule";
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];
    //}
    if(![self isLocal]){
        [self removeAddSceneButton];
    }
    else
        [self addAddRuleButton];
    return cell;
}

-(void) removeRuleAtIndexPathRow:(NSInteger)indexPathRow{
    [self.rules removeObjectAtIndex:indexPathRow];
}


#pragma mark custom cell Delegate methods


- (void)deleteRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if(self.rules==nil || self.rules.count==0 || self.rules.count<=indexPath.row)
        return;
    [self setUpHUD];
    self.HUD.labelText = [NSString stringWithFormat:@"Deleting rule %@...",cell.ruleNameLabel.text];
    [self showHudWithTimeout];
    NSDictionary *payload = [self getDeleteRulePayload:indexPath.row];
    if(payload!=nil){
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payload JSONString];
        [self asyncSendCommand:cloudCommand];
    }
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
    //    AddRulesViewController *addRuleController = [[AddRulesViewController alloc]init];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    AddRulesViewController *addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
    addRuleController.delegate = self;
    Rule *rule = [self.rules[indexPath.row] createNew];
    [self removeInvalidActionsOrTriggers:rule];
    addRuleController.rule = rule;
    addRuleController.isInitialized = YES;
    //need to create textfield param as well.
    addRuleController.indexPathRow = (int)indexPath.row; //current index path
    
    [self.navigationController pushViewController:addRuleController animated:YES];
}

-(void)removeInvalidActionsOrTriggers:(Rule *)rule{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSArray *devices =[toolkit deviceValuesList:plus.almondplusMAC];
    
    [self removeInvalidEntries:rule.triggers devices:devices ];
    [self removeInvalidEntries:rule.actions devices:devices ];
}

-(BOOL)findDevice:(int *)deviceId devices:(NSArray *)devices{
    for(SFIDeviceValue *deviceValue in devices){
        if(deviceValue.deviceID == deviceId)
            return YES;
    }
    return NO;
}

-(void)removeInvalidEntries:(NSMutableArray *)entries devices:(NSArray *)devices{
    NSMutableArray *invalidEntries=[NSMutableArray new];
    for(SFIButtonSubProperties *properties in entries){
        if([properties.type containsString:@"Device"] && ![self findDevice:properties.deviceId devices:devices])
            [invalidEntries addObject:properties];
    }
    if(invalidEntries.count>0)
        [entries removeObjectsInArray:invalidEntries ];
}

- (void)activateRule:(CustomCellTableViewCell *)cell{
    [self setUpHUD];
    self.HUD.labelText = cell.activeDeactiveSwitch.selected? [NSString stringWithFormat:@"Activating rule - %@...",cell.ruleNameLabel.text]: [NSString stringWithFormat:@"Deactivating rule - %@...",cell.ruleNameLabel.text];
    [self showHudWithTimeout];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
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
}

-(void)setUpHUD{
    self.HUD.removeFromSuperViewOnHide = NO;
    self.HUD.dimBackground = YES;
    self.HUD.delegate = self;
    [self.navigationController.view addSubview:self.HUD];
}

///*
// {
// "CommandType":"ValidateRule",
// "AlmondMAC":"25110100101010",
// "ID":""1",
// "Value":"1",
// "MobileInternalIndex":"111"
// }
// */
//-(NSDictionary *)getactivateRulePayload:(NSInteger)row activate:(NSString*)value{
//    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
//    SFIAlmondPlus *plus = [toolkit currentAlmond];
//    if (!plus.almondplusMAC) {
//        return nil;
//    }
//    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
//    Rule *currentRule = self.rules[row];
//    if(currentRule==nil ||currentRule.ID==nil)
//        return nil;
//
//    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
//    [rulePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
//    [rulePayload setValue:@"ValidateRule" forKey:@"CommandType"];
//    [rulePayload setValue:value forKey:@"Value"];
//    [rulePayload setValue:[self getRuleID:currentRule.ID] forKey:@"ID"]; //Get From Rule instance
//
//    return rulePayload;
//
//}
//
#pragma mark asyncRequest methods
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cloudCommand almondMac:plus.almondplusMAC];
}

@end
