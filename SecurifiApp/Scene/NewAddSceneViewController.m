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

@interface NewAddSceneViewController()<AddTriggerAndAddActionDelegate,SFISubPropertyBuilderDelegate>{
    NSInteger randomMobileInternalIndex;
}
@property (nonatomic,strong)AddTriggerAndAddAction *triggerAction;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end


@implementation NewAddSceneViewController
SFISubPropertyBuilder *subPropertyBuilder;

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.wifiClientsArray = [[NSMutableArray alloc]init];
    self.triggerAction = [[AddTriggerAndAddAction alloc]init];
    
    [self getWificlientsList];
    if(!self.isInitialized){
        self.scene = [[Rule alloc]init];
    }
//    [self initializeNotifications];
    [self setUpNavigationBar];
//    [self callRulesView];
    [self getActionsDeviceList:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    randomMobileInternalIndex = arc4random() % 10000;
    [super viewWillAppear:animated];
}

-(void)getWificlientsList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.wifiClientsArray = toolkit.wifiClientParser;
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


- (void)getActionsDeviceList:(BOOL)isTrigger{
    self.triggerAction.delegate = self;
    self.triggerAction.deviceListScrollView = self.deviceListScrollView;
    self.triggerAction.deviceIndexButtonScrollView = self.deviceIndexButtonScrollView;
    self.triggerAction.parentView = self.view;
    
    self.triggerAction.selectedButtonsPropertiesArrayAction = self.scene.actions;
    [self.triggerAction addDeviceNameList:isTrigger];
}

-(void) addSceneToTopView{
    subPropertyBuilder = [SFISubPropertyBuilder new];
    subPropertyBuilder.delegate = self;
    [subPropertyBuilder createEntryForView:self.triggersActionsScrollView indexScrollView:self.deviceIndexButtonScrollView parentView:self.view triggers:self.scene.triggers actions:self.scene.actions isCrossButtonHidden:NO isRuleActive:YES];
}

#pragma mark button clicks
-(void)btnSaveTap:(id)sender{
    
}

-(void)btnCancelTap:(id)sender{
    
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
    if(self.scene.actions.count == 0){
        self.informationLabel.text = @"To get started, please select an Action";
    }
    else if (self.scene.actions.count > 0){
        self.informationLabel.text = @"Add another action or press SAVE to finalize the Scene";
    }
    
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
