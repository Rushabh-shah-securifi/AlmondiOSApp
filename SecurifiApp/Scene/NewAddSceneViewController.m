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

@interface NewAddSceneViewController()<AddTriggerAndAddActionDelegate,SFISubPropertyBuilderDelegate,UIAlertViewDelegate>{
    NSInteger randomMobileInternalIndex;
}
@property (nonatomic,strong)AddTriggerAndAddAction *triggerAction;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property UIButton *buttonDelete;
@end


@implementation NewAddSceneViewController
UITextField *textField;
SFISubPropertyBuilder *subPropertyBuilder;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.triggerAction = [[AddTriggerAndAddAction alloc]init];
    
    if(!self.isInitialized){
        self.scene = [[Rule alloc]init];
    }
    [self initializeNotifications];
    [self setUpNavigationBar];
    
    [self updateInfoLabel];
    [self addSceneToTopView];
    
    [self getTriggersDeviceList:YES];
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


- (void)getTriggersDeviceList:(BOOL)isTrigger{
    self.triggerAction.delegate = self;
    self.triggerAction.deviceListScrollView = self.deviceListScrollView;
    self.triggerAction.deviceIndexButtonScrollView = self.deviceIndexButtonScrollView;
    self.triggerAction.parentView = self.view;
    self.triggerAction.isScene = YES;
    
    self.triggerAction.selectedButtonsPropertiesArrayTrigger = self.scene.triggers;
    [self.triggerAction addDeviceNameList:isTrigger];
}

-(void) addSceneToTopView{
    subPropertyBuilder = [SFISubPropertyBuilder new];
    subPropertyBuilder.delegate = self;
    [subPropertyBuilder createEntryForView:self.triggersActionsScrollView indexScrollView:self.deviceIndexButtonScrollView parentView:self.view triggers:self.scene.triggers actions:self.scene.actions isCrossButtonHidden:NO isRuleActive:YES];
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

#pragma mark helper methods
-(void)clearDeviceListScrollView{
    NSArray *viewsToRemove = [self.deviceListScrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]])
            [v removeFromSuperview];
    }
    
}

-(void)clearDeviceIndexButtonScrollView{
    NSArray *viewsToRemove = [self.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]])
            [v removeFromSuperview];
    }
}

-(void)updateInfoLabel{
    if(self.scene.triggers.count == 0){
        self.informationLabel.text = @"To get started, please select an Action";
    }
    else if (self.scene.triggers.count > 0){
        self.informationLabel.text = @"Add another action or press SAVE to finalize the Scene";
    }
    
}

- (void)addAddRuleButton{
    if (!self.buttonDelete) {
        self.buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonDelete.frame = CGRectMake((self.navigationController.view.frame.size.width - 65)/2, self.navigationController.view.frame.size.height-130, 65, 65);
        [self.buttonDelete setImage:[UIImage imageNamed:@"btnAdd"] forState:UIControlStateNormal];
        self.buttonDelete.backgroundColor = [UIColor clearColor];
        [self.buttonDelete addTarget:self action:@selector(btnAddNewRuleTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:self.buttonDelete];
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
        self.scene.name = textField.text;
        [self sendRuleCommand];
    }
}

-(void)sendRuleCommand{
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

#pragma mark delegate methods
-(void)updateTriggerAndActionDelegatePropertie:(BOOL)isTrigger{
    [self updateInfoLabel];
    [self addSceneToTopView];
}

-(RulesDeviceNameButton*)getSelectedButton:(int)deviceId eventType:(NSString*)eventType{
    
    UIScrollView *scrollView = self.deviceListScrollView;
    for(RulesDeviceNameButton *button in [scrollView subviews]){
        if([button isKindOfClass:[UIImageView class]]){ //to handle mysterious error
            continue;
        }
        else if(button.deviceId == deviceId && button.selected){
            return button;
        }
        
    }
    return nil;
}


-(void)redrawDeviceIndexView:(sfi_id)deviceId clientEvent:(NSString*)eventType{
    NSLog(@"redrawDeviceIndexView");
    [self addSceneToTopView]; //top view
    
    RulesDeviceNameButton *deviceButton = [self getSelectedButton:deviceId eventType:eventType];
    if(deviceButton.deviceType == SFIDeviceType_WIFIClient && deviceButton.isTrigger){// wifi clients
        [self.triggerAction wifiClientsClicked:deviceButton];
        return;
    }
    
    if(deviceButton.deviceId != deviceId)
        return;
    
    if(deviceButton.isTrigger){
        if(deviceId == 0){ //time mode clients
            if([deviceButton.deviceName isEqualToString:@"Mode"]){
                [self.triggerAction onDeviceButtonClick:deviceButton];
            }else if([deviceButton.deviceName isEqualToString:@"Time"]){
                [self.triggerAction TimeEventClicked:deviceButton];
            }
        }else{
            [self.triggerAction onDeviceButtonClick:deviceButton];
        }
    }
    else{
        [self.triggerAction onDeviceButtonClick:deviceButton];
    }
    
    
}


@end
