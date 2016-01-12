//
//  SavedRulesTableViewController.m
//  RulesUI
//
//  Created by Securifi-Mac2 on 03/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "SavedRulesTableViewController.h"
#import "CustomCellTableViewCell.h"
#import "RulesView.h"
#import "SecurifiToolkit/Rule.h"
#import "SecurifiToolkit/GenericCommand.h"
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit/RuleParser.h"
#import "SecurifiToolkit/Parser.h"
#import "SFITriggersActionsSwitchButton.h"

#define AVENIR_ROMAN @"Avenir-Roman"

@interface SavedRulesTableViewController ()<AddRulesViewControllerDelegate, CustomCellTableViewCellDelegate,RuleViewDelegate>{
    NSInteger randomMobileInternalIndex;
}

//@property (nonatomic, strong) NSMutableArray *triggers;
//@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong)NSMutableArray *rules;
@property (nonatomic,strong)RuleParser *ruleParser;
@property (nonatomic,strong)Parser *wiFiClientParser;//for getting wifi client parm
@property UIButton *buttonAdd;

@end

@implementation SavedRulesTableViewController

- (void)viewDidLoad {
    NSLog(@"savedRuleViewDidLoad");
    self.wiFiClientParser = [[Parser alloc]init];
    self.ruleParser = [[RuleParser alloc]init];
        [super viewDidLoad];
    self.rules = [[NSMutableArray alloc]init];
    
    [self getRuleList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self initializeNotifications];
    [self setUpNavigationBar];
}

-(void)requestForRuleList{
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    GenericCommand *cmd = [GenericCommand websocketRequestAlmondRules];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cmd almondMac:plus.almondplusMAC];
}
- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"savedRuleviewWillAppear");
//    [self.rules removeAllObjects];
    [self.tableView reloadData];
    [self getRuleList];
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
     [self initializeNotifications];
    [self addAddRuleButton];

}
-(void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onDynamicRuleUpdateParser:) name:SAVED_TABLEVIEW_DYNAMIC_RULE_UPDATED object:nil];
    [center addObserver:self selector:@selector(onDynamicRuleAdded1:) name:DYNAMIC_RULE_LISTCHANGED object:nil];
    [center addObserver:self selector:@selector(onRuleUpdateCommandResponse:) name:SAVED_TABLEVIEW_RULE_COMMAND object:nil];
}
- (void)onRuleUpdateCommandResponse:(id)sender{
    NSLog(@"onRuleUpdateCommandResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSArray *updatedRuleList = [data valueForKey:@"data"];
    self.rules =[NSMutableArray arrayWithArray:updatedRuleList];
    [self.tableView reloadData];
    NSLog(@"dynamaic updated : %@",updatedRuleList);
}
- (void)onDynamicRuleAdded1:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic added savedcontroller: %@",mainDict);
    [self requestForRuleList];
    return;
    
}

-(void)onDynamicRuleUpdateParser:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    Rule *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic updated : %@",mainDict);
    [self.rules addObject:mainDict];
    [self.tableView reloadData];
}

#pragma mark wificlientDelegate

//-(NSMutableArray*)getwificlientDelegate{
//    return self.wifiClientsArray;
//}


-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DeleteALL" style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteALL)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    //UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    //self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.navigationItem.title = @"Rules Builder";
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [self removeAddSceneButton];
}

- (void)removeAddSceneButton{
    [self.buttonAdd removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getRuleList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.rules = toolkit.ruleList;
    //Rule *rl =[self.rules objectAtIndex:0];
    //NSLog(@" self.rullist object %@",rl.triggers);
    NSLog(@" self rullist %ld",self.rules.count);
    
    [self.tableView reloadData];
//    GenericCommand *localCommand = [GenericCommand websocketRequestAlmondRules];
//    [self asyncSendCommand:localCommand];
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
     CellIdentifier = [NSString stringWithFormat:@"Cell%ld",indexPath.row];
    Rule *rule = self.rules[indexPath.row];
    CustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCellTableViewCell"];
    if(cell==nil){//check out if this will ever get executed
        NSLog(@"nil");
        cell = [[CustomCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCellTableViewCell"];
    }
    NSLog(@" rules wifi clients %@",rule.wifiClients);
//    NSLog(@" rules wificlient array %@",rule.wificlientArray);
    
    cell.delegate = self;
    cell.ruleNameLabel.text = rule.name;
    NSLog(@" rulename label %@",cell.ruleNameLabel.text);
    NSLog(@"cellforrow - self.triggers: %@, self.actions: %@", rule.triggers, rule.actions);
    RulesView *rulesviews = [[RulesView alloc]init];
    rulesviews.delegate = self;
    rulesviews.rule = rule;
    rulesviews.toHideCrossButton = YES;
    NSLog(@"rules wifi clients at index %ld  %lu",(long)indexPath.row,(unsigned long)rule.wifiClients.count);
    [rulesviews createTriggersActionsView:cell.scrollView];
    // Configure the cell...
    [cell.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    return cell;
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


#pragma mark delegate methods
//coming from addrulesviewcontroller - store in rules
- (void)updateRule:(Rule*)rule atIndexPath:(int)indexPathRow{
    if (indexPathRow < (int)[self.rules count]){
        [self.rules replaceObjectAtIndex:indexPathRow withObject:rule];
    }
    else{
        [self.rules addObject:rule];
    }
    //reload table view
    [self.tableView reloadData];
}

-(Rule*)getRuleCopy:(Rule*)originalRule{
    Rule *ruleCopy = [[Rule alloc]init];
    ruleCopy.triggers = [originalRule.triggers copy];
    ruleCopy.actions = [originalRule.actions copy];
    ruleCopy.wifiClients = [originalRule.wifiClients copy];
//    ruleCopy.time = [originalRule.time copy];
    ruleCopy.isActive = originalRule.isActive;
    ruleCopy.name = [originalRule.name copy];
    ruleCopy.lastActivated = originalRule.lastActivated;
    ruleCopy.ID = [originalRule.ID copy];
//    ruleCopy.wificlientArray = [originalRule.wificlientArray copy];
    return ruleCopy;
}

#pragma mark custom cell Delegate methods
//delegate coming from customCellTableView - to edit
- (void)editRule:(CustomCellTableViewCell *)cell{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    AddRulesViewController *addRuleController = [[AddRulesViewController alloc]init];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    AddRulesViewController *addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
    addRuleController.delegate = self;
    Rule *rule = self.rules[indexPath.row];
    
    NSLog(@" edit rule rul ID %@",rule.ID);
    addRuleController.rule = rule;
    addRuleController.isInitialized = YES;
    //need to create textfield param as well.
    addRuleController.indexPathRow = (int)indexPath.row; //current index path
    
    [self.navigationController pushViewController:addRuleController animated:YES];
}

- (void)deleteRule:(CustomCellTableViewCell *)cell{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *payload = [self getDeleteRulePayload:indexPath.row];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [payload JSONString];
    [self asyncSendCommand:cloudCommand];
    [self removeRuleAtIndexPathRow:indexPath.row];
    [self.tableView reloadData];
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

- (void)activateRule:(CustomCellTableViewCell *)cell{
    if(cell.activeDeactiveSwitch.selected){
        NSLog(@"activateRule");
        [cell.activeDeactiveSwitch setOn:YES animated:YES];
    }else{
        [cell.activeDeactiveSwitch setOn:NO animated:YES];
        //change bg color to gray
    }
    
}

#pragma mark notification handler
//-(void)onRuleListResponse:(id)sender{
//   self.rules = ;
//    NSLog(@" rule %@",self.rules);
//    [self.tableView reloadData];
//}

//-(void)onDynamicRuleUpdate:(id)sender{
//    self.rules = [self.ruleParser onDynamicRuleUpdateParser:sender];
//    [self.tableView reloadData];
//}
//
//-(void)onDynamicRuleRemoved:(id)sender{
//    self.rules = [self.ruleParser onDynamicRuleRemovedParser:sender];
//    [self.tableView reloadData];
//}
//
//-(void)onDynamicRuleRemoveAll:(id)sender{
//    self.rules = [self.ruleParser onDynamicRuleRemovedParser:sender];
//    [self.tableView reloadData];
//    }

#pragma mark asyncRequest methods

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cloudCommand almondMac:plus.almondplusMAC];
}

@end
