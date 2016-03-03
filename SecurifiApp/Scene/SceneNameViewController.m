//
//  SceneNameViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 29/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SceneNameViewController.h"
#import "UIFont+Securifi.h"
#import "MBProgressHUD.h"

@interface SceneNameViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *suggestionTable;
@property (weak, nonatomic) IBOutlet UITextField *sceneNameField;
@property(nonatomic)NSArray *nameList;
@property(nonatomic)NSMutableArray *filteredList;
@property(nonatomic)NSArray *commonSceneNames;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation SceneNameViewController
int randomMobileInternalIndex;
static const int sceneNameFont = 13;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    [self initializeNotifications];
    _filteredList = [NSMutableArray new];
    _commonSceneNames = @[@"Good Morning",
                                  @"Bedroom Lights Off",
                                  @"All Lights On",
                                  @"Going away",
                                  @"Coming Home",
                                  @"lights on garage open",
                                  @"backyard lights on",
                                  @"cooling the house",
                                  @"Basement lights off",
                                  @"Decorations On"];
    [self readSceneNameFileContents];
    [self.sceneNameField addTarget:self
                  action:@selector(editingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    self.sceneNameField.delegate = self;
    self.suggestionTable.tableFooterView = [UIView new]; //to hide extra line seperators
}

-(void)viewWillAppear:(BOOL)animated{
    randomMobileInternalIndex = arc4random() % 10000;
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark initial setups
- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(sceneMobileCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
}

-(void)setUpNavigationBar{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"scene.button.Save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"scene.button.Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
}

-(void)readSceneNameFileContents{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scene_names" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.nameList = [content componentsSeparatedByString:@","];
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.filteredList.count > 0 || _sceneNameField.text.length != 0)
        return self.filteredList.count;
    
    return self.commonSceneNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.font = [UIFont securifiFont:sceneNameFont];
    if (self.filteredList.count > 0 || _sceneNameField.text.length != 0) {
        cell.textLabel.text = [self.filteredList objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = [self.commonSceneNames objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_filteredList.count > 0)
        self.sceneNameField.text = [self.filteredList objectAtIndex:indexPath.row];
    else
        self.sceneNameField.text = [self.commonSceneNames objectAtIndex:indexPath.row];
    [self.filteredList removeAllObjects];
    [self.filteredList addObject:self.sceneNameField.text];
    [self.suggestionTable reloadData];
}

#pragma mark button tap
-(void)btnSaveTap:(id)sender{
    [_sceneNameField resignFirstResponder];
    if (_sceneNameField.text.length == 0) {
        [self showMessageBox:@"Please select Scene Name"];
        return;
    }
    if(![self isSceneNameCompatibleWithAlexa]){
        [self showMessageBox:@"Please select one of the names from the provided list to have compatibility with Alexa"];
        return;
    }
    [self setAlexaCompatibleSceneName];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_REQUEST;
    command.command = [self.scenePayload JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    if (_isNewScene) {
        _HUD.labelText = NSLocalizedString(@"scenes.hud.creatingScene", @"Creating Scene...");
    }else{
        _HUD.labelText = NSLocalizedString(@"scenes.hud.updatingScene", @"Updating Scene...");
    }
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:command];
}

-(void)btnCancelTap:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isSceneNameCompatibleWithAlexa{
    NSString *lowerCaseSceneName = _sceneNameField.text.lowercaseString;
    BOOL isCompatible = NO;
    for(NSString *name in _nameList){
        if([name.lowercaseString isEqualToString:lowerCaseSceneName]){
            isCompatible = YES;
            break;
        }
    }
    return isCompatible;
}

-(void)setAlexaCompatibleSceneName{
    [self.scenePayload[@"Scenes"] setValue:self.sceneNameField.text forKey:@"Name"];
    [self.scenePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
}

#pragma mark text field delegates

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}

- (void)showMessageBox:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Scenes" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"scene.cancel-title.OK", @"OK") otherButtonTitles:nil];
        [alert show];
        alert = nil;
    });
}
-(void)editingChanged:(id)sender{
    [self.filteredList removeAllObjects];
    UITextField *textfield = sender;
    NSString *newString = textfield.text;
    for(NSString *sceneName in self.nameList){
        if ([sceneName rangeOfString:newString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.filteredList addObject:sceneName];
        }
    }
    [self.suggestionTable reloadData];
}


#pragma mark - HUD mgt
- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

#pragma mark commands
-(void)sceneMobileCommandResponse:(id)sender{
    NSLog(@"sceneMobileCommandResponse");
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
    
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        NSLog(@"mii not equal");
        return;
    }
    
    [self.HUD hide:YES];
    NSString * success = [mainDict valueForKey:@"Success"];
    if (![success isEqualToString:@"true"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scene.alert-title.Oops", @"Oops") message:NSLocalizedString(@"scene.alert-msg.Sorry, There was some problem with this request, try later!", @"Sorry, There was some problem with this request, try again or later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    
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

@end
