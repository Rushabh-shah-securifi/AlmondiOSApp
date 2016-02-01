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
//#import "SFITriggersActionsSwitchButton.h"
#import "AlmondPlusConstants.h"
#import "SFISubPropertyBuilder.h"

#define AVENIR_ROMAN @"Avenir-Roman"

@interface RulesTableViewController ()<AddRulesViewControllerDelegate, CustomCellTableViewCellDelegate>{
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
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSLog(@"viewDidLoad rules count is %@",toolkit.ruleList);
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
    
    [self getRuleList];
    [self addAddRuleButton];
    randomMobileInternalIndex = arc4random() % 10000;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeAddSceneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DeleteALL" style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteALL)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    //UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    //self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.navigationItem.title = @"Rules Builder";
}


-(void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onRuleUpdateCommandResponse:) name:SAVED_TABLEVIEW_RULE_COMMAND object:nil];
}

-(void)initializeTableViewAttributes{
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)onRuleUpdateCommandResponse:(id)sender{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.rules =[NSMutableArray arrayWithArray:toolkit.ruleList];
    NSLog(@"onRuleUpdateCommandResponse Rule is %@",self.rules);
    [self.tableView reloadData];
    self.tableView.contentOffset = tablePoint;
}

- (void)removeAddSceneButton{
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
    return 142; //height of the cell from story board
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    if([self isRuleArrayEmpty]){
        NSLog(@"rulearrayempty");
        return [self createEmptyCell:tableView];
    }
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    Rule *rule = self.rules[indexPath.row];
    CustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCellTableViewCell"];
    if(cell==nil){//check out if this will ever get executed
        NSLog(@"nil");
        cell = [[CustomCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCellTableViewCell"];
    }
    
    cell.delegate = self;
    cell.ruleNameLabel.text = rule.name;
    NSLog(@" rulename label %@",cell.ruleNameLabel.text);
    NSLog(@"cellforrow - self.triggers: %d, self.actions: %d", rule.triggers.count, rule.actions.count);
    [SFISubPropertyBuilder createEntriesView:cell.scrollView triggers:rule.triggers actions:rule.actions showCrossBtn:YES parentController:nil];
    
    // Configure the cell...
    [cell.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    return cell;
}

#pragma mark button taps
- (void)btnAddNewRuleTap:(id)sender {
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:empty_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
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
    }
    return cell;
}

-(void) removeRuleAtIndexPathRow:(NSInteger)indexPathRow{
    [self.rules removeObjectAtIndex:indexPathRow];
}


#pragma mark addrulesviewcontroller delegate methods
- (void)updateRule:(Rule*)rule atIndexPath:(int)indexPathRow{
    if (indexPathRow < (int)[self.rules count]){
        [self.rules replaceObjectAtIndex:indexPathRow withObject:rule];
    }
    else{
        [self.rules addObject:rule];
    }
    [self.tableView reloadData];
    self.tableView.contentOffset = tablePoint;
}

#pragma mark custom cell Delegate methods


- (void)deleteRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *payload = [self getDeleteRulePayload:indexPath.row];
    if(payload!=nil){
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
        cloudCommand.command = [payload JSONString];
        [self asyncSendCommand:cloudCommand];
        [self removeRuleAtIndexPathRow:indexPath.row];
        [self.tableView reloadData];
    }
}

-(void)onRuleCommandResponse:(id)sender{ //for delete//need to be work
    NSLog(@"onRuleCommandResponse - delete");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [data valueForKey:@"data"];
    
    NSLog(@"%@",mainDict);
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }

    NSString * success = [mainDict valueForKey:@"Success"];
    if (![success isEqualToString:@"true"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scene.alert-title.Oops", @"Oops") message:NSLocalizedString(@"scene.alert-msg.Sorry, There was some problem with this request, try later!", @"Sorry, There was some problem with this request, try later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        //self.originalSceneInfo = [self.sceneInfo copy];
        //to do copy rules array and reload here
    }
}

-(void)onDeleteALL{
    NSDictionary *payload = [self getdeleteAllPayload];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_RULE_COMMAND_DELETEALL;
    cloudCommand.command = [payload JSONString];
    [self asyncSendCommand:cloudCommand];
    [self.rules removeAllObjects];
    [self.tableView reloadData];
    
}

-(NSDictionary *)getdeleteAllPayload{
    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
    [rulePayload setValue:@"RemoveAllRules" forKey:@"CommandType"];
    NSLog(@"rule payload : %@ ",rulePayload);
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
    if(currentRule.ID==nil)
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
   
    NSLog(@" edit rule rul ID %@",rule.ID);
    addRuleController.rule = rule;
    addRuleController.isInitialized = YES;
    //need to create textfield param as well.
    addRuleController.indexPathRow = (int)indexPath.row; //current index path
    
    [self.navigationController pushViewController:addRuleController animated:YES];
}
- (void)activateRule:(CustomCellTableViewCell *)cell{
    if(cell.activeDeactiveSwitch.selected){
        NSLog(@" deactivateRule");

        [cell.activeDeactiveSwitch setOn:YES animated:YES];
    }else{
        NSLog(@"activateRule");

        //send activate command
        
        [cell.activeDeactiveSwitch setOn:NO animated:YES];
    }
}
/*
 {
 "CommandType":"ValidateRule",
 "AlmondMAC":"25110100101010",
 "ID":""1",
 "Value":"1",
 "MobileInternalIndex":"111"
 }
 */
#pragma mark asyncRequest methods
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cloudCommand almondMac:plus.almondplusMAC];
}

@end
