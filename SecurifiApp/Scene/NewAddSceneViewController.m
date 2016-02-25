//
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
#import "SFIDimmerButton.h"
#import "ValueFormatter.h"
#import "SFIButtonSubProperties.h"
#import "GenericCommand.h"
#import "SFIColors.h"
#import "SFISubPropertyBuilder.h"
//for wifi clients
#import "SFIWiFiClientsListViewController.h"
#import "GenericCommand.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SFIRouterClientsTableViewController.h"
#import "AddTriggerAndAddAction.h"
#import "SFISubPropertyBuilder.h"
#import "MBProgressHUD.h"
#import "ScenePayload.h"
#import "AddRuleSceneClass.h"

#define kAlertViewSave 1
#define kAlertViewDelete 2

@interface NewAddSceneViewController()<UIAlertViewDelegate>{
    NSInteger randomMobileInternalIndex;
}
@property (nonatomic,strong)AddRuleSceneClass *addRuleScene;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property UIButton *buttonDelete;
@end

@implementation NewAddSceneViewController
UITextField *textField;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.isInitialized){
        self.scene = [[Rule alloc]init];
    }else{
        [self addDeleteSceneButton];
    }
    [self initializeNotifications];
    [self setUpNavigationBar];
    
    self.addRuleScene = [[AddRuleSceneClass alloc]initWithParentView:self.view deviceIndexScrollView:self.deviceIndexButtonScrollView deviceListScrollView:self.deviceListScrollView topScrollView:self.triggersActionsScrollView informationLabel:self.informationLabel triggers:self.scene.triggers actions:self.scene.actions isScene:YES];
    [self.addRuleScene updateInfoLabel];
    [self.addRuleScene buildTriggersAndActions];
    [self.addRuleScene getTriggersDeviceList:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    randomMobileInternalIndex = arc4random() % 10000;
    [super viewWillAppear:animated];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(gotResponseFor1064:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeDeleteSceneButton];
}

-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.title = self.isInitialized? [NSString stringWithFormat:@"Edit Scene - %@", self.scene.name]: @"New Scene";
}

#pragma mark button clicks
-(void)btnSaveTap:(id)sender{
    textField = [[UITextField alloc]init];
    if(self.isInitialized){
        textField.text = self.scene.name;
    }
    if(self.scene.triggers.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scene Name"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save", nil];
        [alert setDelegate:self];
        alert.tag = kAlertViewSave;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        textField = [alert textFieldAtIndex:0];
        textField.frame = CGRectMake(alert.frame.origin.x, 25.0, alert.frame.size.width, 15.0);
        [textField setBackgroundColor:[UIColor whiteColor]];
        if(self.isInitialized){
            textField.text = self.scene.name;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"You cannot save Scene without selecting actions"
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure, you want to delete this Scene?"]
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
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
        self.buttonDelete.frame = CGRectMake((self.navigationController.view.frame.size.width - 65)/2, self.navigationController.view.frame.size.height-130, 65, 65);
        [self.buttonDelete setImage:[UIImage imageNamed:@"btnDel"] forState:UIControlStateNormal];
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
    NSLog(@"gotResponseFor1064 - addscene");
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
    
    [self.HUD hide:YES];
    NSString * success = [mainDict valueForKey:@"Success"];
    if (![success isEqualToString:@"true"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scene.alert-title.Oops", @"Oops") message:NSLocalizedString(@"scene.alert-msg.Sorry, There was some problem with this request, try later!", @"Sorry, There was some problem with this request, try later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

#pragma mark alert view delegeate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        if(alertView.tag == kAlertViewSave){
            self.scene.name = textField.text;
            [self sendAddSceneCommand];
        }else if(alertView.tag == kAlertViewDelete){
            [self sendDeleteSceneCommand];
        }
    }
}

-(void)sendAddSceneCommand{
    //HUd methods.....
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Saving Scene...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    NSDictionary* payloadDict = [ScenePayload getScenePayload:self.scene mobileInternalIndex:(int)randomMobileInternalIndex isEdit:self.isInitialized];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_REQUEST;
    command.command = [payloadDict JSONString];

    [self asyncSendCommand:command];
    NSLog(@"new scenes payload %@",[payloadDict JSONString]);
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




@end
