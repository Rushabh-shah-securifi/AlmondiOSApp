//  NewAddSceneViewController.m
//  SecurifiApp
//
//  Created by Masood on 19/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "NewAddSceneViewController.h"
#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "Colours.h"
#import "SFIDeviceIndex.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "ValueFormatter.h"
#import "SFIButtonSubProperties.h"
#import "GenericCommand.h"
#import "SFIColors.h"
#import "SFISubPropertyBuilder.h"
//for wifi clients
#import "GenericCommand.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SFIRouterClientsTableViewController.h"
#import "AddTriggerAndAddAction.h"
#import "SFISubPropertyBuilder.h"
#import "MBProgressHUD.h"
#import "ScenePayload.h"
#import "AddRuleSceneClass.h"
#import "SceneNameViewController.h"
#import "Analytics.h"

#define kAlertViewSave 1
#define kAlertViewDelete 2

@interface NewAddSceneViewController()<UITextFieldDelegate, UIAlertViewDelegate>{
    NSInteger randomMobileInternalIndex;
}
@property (nonatomic,strong)AddRuleSceneClass *addRuleScene;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property UIButton *buttonDelete;
@property (nonatomic) CGRect ViewFrame;
@property (nonatomic) BOOL isDone;
@end

@implementation NewAddSceneViewController
UITextField *textField;
UIAlertView *alert;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.isInitialized){
        self.scene = [[Rule alloc]init];
    }
    [self initializeNotifications];
    [self setUpNavigationBar];
    
    self.addRuleScene = [[AddRuleSceneClass alloc]initWithParentView:self.view
                                               deviceIndexScrollView:self.deviceIndexButtonScrollView
                                                deviceListScrollView:self.deviceListScrollView
                                                       topScrollView:self.triggersActionsScrollView
                                                    informationLabel:self.informationLabel
                                                            triggers:self.scene.triggers
                                                             actions:self.scene.actions
                                                             isScene:YES
                                                           ];
    
    [self.addRuleScene updateInfoLabel];
    [self.addRuleScene buildTriggersAndActions];
    [self.addRuleScene getTriggersDeviceList:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ViewFrame = self.view.frame;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    if(self.isInitialized){
        [self addDeleteSceneButton];
    }
    [[Analytics sharedInstance] markNewSceneScreen];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(gotResponseFor1064:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onTabBarDidChange:)
                   name:@"TAB_BAR_CHANGED"
                 object:nil];
    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeDeleteSceneButton];
}

-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done",@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back",@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.title = self.isInitialized? [NSString stringWithFormat:@"%@", self.scene.name]: NSLocalizedString(@"newScene",@"New Scene");
}

#pragma mark button clicks
-(void)btnSaveTap:(id)sender{
    self.isDone = YES;
    if(self.scene.triggers.count > 0){
        NSString *msg;
        msg = NSLocalizedString(@"alexa_complatible_text",@"");
        if(self.isInitialized && [self isSceneNameCompatibleWithAlexa]){
            msg = NSLocalizedString(@"sceneNameCompatible",@"");
            
        }
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scene_name",@"Scene Name")
                                           message:msg
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"next",@"Next")
                                 otherButtonTitles:NSLocalizedString(@"done",@"Done"),nil];
        [alert setDelegate:self];
        alert.tag = kAlertViewSave;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        textField = [alert textFieldAtIndex:0];
        textField.delegate = self;
        
        if(self.isInitialized){
            textField.text = self.scene.name;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
        
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops",@"Oops") message:NSLocalizedString(@"AddRulesView Select atleast one Action",@"Select atleast one Action.")
                                          delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles: nil];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
        
    }
}


-(void)btnCancelTap:(id)sender{
    self.scene = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)btnDeleteSceneTap:(id)sender {
    alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"NewAddScene Are you sure, you want to delete this Scene?",@"Are you sure, you want to delete this Scene?")]
                                       message:@""
                                      delegate:self
                             cancelButtonTitle:NSLocalizedString(@"cancel",@"Cancel")
                             otherButtonTitles:NSLocalizedString(@"delete",@"Delete"), nil];
    [alert setDelegate:self];
    alert.tag = kAlertViewDelete;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

#pragma mark helper methods
- (void)addDeleteSceneButton{
    if (!self.buttonDelete) {
        self.buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonDelete.frame = CGRectMake(self.navigationController.view.frame.size.width - 50 - 10, self.navigationController.view.frame.size.height-60, 50, 50);
        [self.buttonDelete setImage:[UIImage imageNamed: @"btnDel"] forState:UIControlStateNormal];
        self.buttonDelete.backgroundColor = [UIColor clearColor];
        [self.buttonDelete addTarget:self action:@selector(btnDeleteSceneTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:self.buttonDelete];
}

- (void)removeDeleteSceneButton{
    if(self.buttonDelete)
        [self.buttonDelete removeFromSuperview];
}

#pragma mark command response
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
    
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }
    
    BOOL success = [mainDict[@"Success"] boolValue];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
        if (success == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Oops") message:NSLocalizedString(@"try_later", @"Sorry, There was some problem with this request, try later!")
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles: nil];
            [alert show];
        }else{
                [self.navigationController popViewControllerAnimated:YES];
        }
    });
}
#pragma mark alert view delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        self.isDone = NO;
        if(alertView.tag == kAlertViewSave){
            SceneNameViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SceneNameViewController"];
            viewController.scene = self.scene;
            viewController.isInitialized = self.isInitialized;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }else{
        if(alertView.tag == kAlertViewSave){
            self.scene.name = textField.text;
            [self sendAddSceneCommand];
        }else if(alertView.tag == kAlertViewDelete){
            [self sendDeleteSceneCommand];
        }
    }
}

- (void)onTabBarDidChange:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (![[data valueForKey:@"title"] isEqualToString:@"Scenes"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}


- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    self.isDone = NO;
    [textField resignFirstResponder];
    [alert dismissWithClickedButtonIndex:nil animated:YES];
    return YES;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{//other button  -> save
    if(alertView.tag == kAlertViewSave)
        return ([[[alertView textFieldAtIndex:0] text] length]>0)?YES:NO;
    return YES;
}

-(void)sendAddSceneCommand{
    //HUd methods.....
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"NewAddScene Saving Scene...", @"Saving Scene...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    BOOL isCompatible = [self isSceneNameCompatibleWithAlexa];
    NSDictionary* payloadDict = [ScenePayload getScenePayload:self.scene mobileInternalIndex:(int)randomMobileInternalIndex isEdit:self.isInitialized isSceneNameCompatibleWithAlexa:isCompatible];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_REQUEST;
    command.command = [payloadDict JSONString];
    
    [self asyncSendCommand:command];
}

- (BOOL)isSceneNameCompatibleWithAlexa{
    NSArray *sceneNameList;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scene_names" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    sceneNameList = [content componentsSeparatedByString:@","];
    NSString *lowerCaseSceneName = self.scene.name.lowercaseString;
    BOOL isCompatible = NO;
    for(NSString *name in sceneNameList){
        if([name.lowercaseString isEqualToString:lowerCaseSceneName]){
            isCompatible = YES;
            break;
        }
    }
    return isCompatible;
}


-(void)sendDeleteSceneCommand{
    NSMutableDictionary *payloadDict = [ScenePayload getDeleteScenePayload:self.scene mobileInternalIndex:(int)randomMobileInternalIndex];
    NSLog(@"delete payload: %@", payloadDict);
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_REQUEST;
    command.command = [payloadDict JSONString];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"scenes.hud.deletingScene", @"Deleting Scene...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:command];
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

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

#pragma  mark uiwindow delegate methods
- (void)onKeyboardDidShow:(id)notification {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(_isDone)
        return;
    else{
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect f = self.view.frame;
            CGFloat y = -keyboardSize.height ;
            f.origin.y =  y + 80;
            self.view.frame = f;
            //        NSLog(@"keyboard frame %@",NSStringFromCGRect(self.parentView.frame));
        }];
    }
}

-(void)onKeyboardDidHide:(id)notice {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = self.ViewFrame.origin.y;
        self.view.frame = f;
    }];
}
@end
