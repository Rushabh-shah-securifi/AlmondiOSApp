//
//  RulesViewController.m
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "AddRulesViewController.h"
#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "Colours.h"
#import "SFIDeviceIndex.h"
#import "RuleSensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "SFIDimmerButton.h"
#import "SFIRulesSwitchButton.h"
#import "ValueFormatter.h"
#import "RulesConstants.h"
#import "SFIButtonSubProperties.h"
#import "RulesDeviceNameButton.h"
#import "RulesView.h"
#import "AddTriggers.h"
#import "AddActions.h"
#import "GenericCommand.h"
#import "Colours.h"
#import "SavedRulesTableViewController.h"
//for wifi clients
#import "SFIWiFiClientsListViewController.h"
#import "GenericCommand.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SFIRouterClientsTableViewController.h"
#import "RulePayload.h"
//for wifi clients

@interface AddRulesViewController()<AddTriggersDelegate, AddActionsDelegate, RuleViewDelegate,UIAlertViewDelegate>{
    sfi_id dc_id;
    NSInteger randomMobileInternalIndex;
}


@property (nonatomic, strong)AddTriggers *addTriggersView;
@property (nonatomic ,strong)AddActions *addActionsView;
@property (nonatomic, strong)RulesView *rulesView;
@property (weak, nonatomic) IBOutlet UIButton *IfButton;
@property (weak, nonatomic) IBOutlet UIButton *thenButton;

@property (weak, nonatomic) SFIWiFiClientsListViewController *wifiClientsList;//response
@property (weak, nonatomic) SFIRouterClientsTableViewController *routerClientstableView;//request
@property (weak, nonatomic) IBOutlet UIImageView *ifThenTabSeperator;


@end

@implementation AddRulesViewController
UITextField *textField;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.actuatorDeviceArray = [NSMutableArray new];
    self.addActionsView = [[AddActions alloc]init];
    
    self.wifiClientsArray = [[NSMutableArray alloc]init];
    self.deviceArray = [NSMutableArray new];
    //self.ruleNameField.text = self.rule.name;
    [self getWificlientsList];
    if(!self.isInitialized){
        self.rule = [[Rule alloc]init];//[buttonObj sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
    [self initializeNotifications];
    [self setUpNavigationBar];
   
    [self callRulesView]; //to handle edit
//    [self.IfButton sendActionsForControlEvents: UIControlEventTouchUpInside];//programatically clicking if
    
    [self getTriggerAndActionDeviceList];
    [self getTriggerDeviceListView:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    randomMobileInternalIndex = arc4random() % 10000;
    [super viewWillAppear:animated];
}

#pragma mark notificationMethods

-(void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //add, update, remove etc.
    [center addObserver:self selector:@selector(onDynamicRuleAdded:) name:DYNAMIC_RULE_LISTCHANGED object:nil];
    [center addObserver:self selector:@selector(onRuleCommandResponse:) name:RULE_COMMAND_RESPONSE_NOTIFIER object:nil];
    

}

-(void)getWificlientsList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.wifiClientsArray = toolkit.wifiClientParser;
}



-(void)onRuleCommandResponse:(id)sender{ //for add, update
    NSLog(@"onRuleCommandResponse - add,update");
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
//        self.originalSceneInfo = [self.sceneInfo copy];
        //to do copy rules array
//        if(self.rule.ID != NULL){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.navigationController popViewControllerAnimated:YES];
        });
//        }
    }

}
-(void)onDynamicRuleAdded:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic added : %@",mainDict);
    self.rule.ID = [mainDict valueForKey:@"ruleid"];
    return;
    
}


-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.title = @"Rules Builder";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark buttonclickedMetghods

- (IBAction)ifButtonClicked:(id)sender {
    [self getTriggerDeviceListView:NO];
 
}

- (IBAction)thenButtonClicked:(id)sender {
    [self changeIFThenColors:NO clickedBtn:self.thenButton otherBtn:self.IfButton];
    
    [self manageViews];
    //clear views
    [self clearDeviceListScrollView];
    [self clearDeviceIndexButtonScrollView];
    
    [self getActionDeviceList];
    if(self.rule.triggers.count == 0 && self.rule.time != NULL){
        self.informationLabel.text = @"First you have to select trigger";
    }
    else {
        self.informationLabel.text = @"Select action for your trigger";
    }
}


-(void)getTriggerDeviceListView:(BOOL)isFirstTime{
    if(self.rule.triggers.count == 0)
    self.informationLabel.text = @"To get started, please select a trigger";
    else{
        self.informationLabel.text = @"Add another trigger or press THEN to define action";
    }
    [self changeIFThenColors:YES clickedBtn:self.IfButton otherBtn:self.thenButton];
    [self manageViews];
    //clear viewsFF9500
    [self clearDeviceListScrollView];
    [self clearDeviceIndexButtonScrollView];
    [self getTriggersDeviceList];
}

-(void) changeIFThenColors:(BOOL)ifClick clickedBtn:(UIButton *)clickedButton otherBtn:(UIButton *)otherButton{
    UIColor *selectedColor=[UIColor colorFromHexString:@"02a8f3"];
    UIColor *imageBgColor=[UIColor whiteColor];
    UIColor *imageColor=selectedColor;
    if(!ifClick){
         selectedColor=[UIColor colorFromHexString:@"FF9500"];
         imageBgColor=selectedColor;
        imageColor=[UIColor whiteColor];
    }
    
    clickedButton.backgroundColor = selectedColor;
    [clickedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    self.ifThenTabSeperator.image = [self imageNamed:@"tab-separator" withColor:imageColor];
    otherButton.backgroundColor = [UIColor clearColor];
    self.ifThenTabSeperator.backgroundColor = imageBgColor;
}

-(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    // load the image
    
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

-(void)getTriggerAndActionDeviceList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSLog(@" divece list count %@",[toolkit deviceList:plus.almondplusMAC]);
    for(SFIDevice *device in [toolkit deviceList:plus.almondplusMAC]){
        if ((device.deviceType != SFIDeviceType_HueLamp_48) && (device.deviceType != SFIDeviceType_NestSmokeDetector_58)) {
            NSLog(@" hue device ");
            [self.deviceArray addObject:device];
        }
        if (device.isActuator ) {
            [self.actuatorDeviceArray addObject:device];
        }
    }
}

//on if button clicked
-(void)getTriggersDeviceList{
    self.addTriggersView = [[AddTriggers alloc]init]; // if rule is new then params are initialied in rule
    self.addTriggersView.parentViewController = self;
    self.addTriggersView.delegate = self;
    self.addTriggersView.selectedButtonsPropertiesArray = self.rule.triggers;
    self.addTriggersView.ruleTime = self.rule.time;
    [self.addTriggersView displayTriggerDeviceList];
    
}

// on then button clicked
-(void)getActionDeviceList{
    self.addActionsView = [[AddActions alloc]init];
    self.addActionsView.parentViewController = self;
    self.addActionsView.delegate = self;
    self.addActionsView.selectedButtonsPropertiesArray = self.rule.actions;
    [self.addActionsView displayActionDeviceList];
}

#pragma mark helper methods
-(void)clearDeviceListScrollView{
    NSArray *viewsToRemove = [self.deviceListScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
}

-(void)clearDeviceIndexButtonScrollView{
    NSArray *viewsToRemove = [self.deviceIndexButtonScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

-(void) manageViews{
    //necessary to manage it, when you click on then you need to hide timeview
    self.TimeSectionView.hidden = YES;
    self.deviceIndexButtonScrollView.hidden = NO;
}

#pragma mark delegate methods
//update from add triggers.m
-(void)updateTriggersButtonsPropertiesArray:(NSMutableArray*)triggersButtonPropertiesArray{
    self.rule.triggers = triggersButtonPropertiesArray;
    if(self.rule.triggers.count > 0){
        self.informationLabel.text = @"Add another trigger or press THEN to define action";
    }
    if(self.rule.triggers.count == 0){
        self.informationLabel.text = @"To get started, please select a trigger";
    }
    //NSLog(@"trigger dict in add rules vc: %@", triggersButtonPropertiesArray);
    [self callRulesView];
    
}


//add action delegate method
-(void) updateActionsButtonsPropertiesArray:(NSMutableArray*)actionButtonPropertiesArray{
    self.rule.actions = actionButtonPropertiesArray;
    NSLog(@"actions array in add rules vc: %@", actionButtonPropertiesArray);
    [self callRulesView];
    if(self.rule.actions.count >0){
        self.informationLabel.text = @"Add another action or press SAVE to finalize the rule";
    }
    if(self.rule.actions == 0){
        self.informationLabel.text = @"Add another trigger or press THEN to define action";
    }
}

// add time-element delegate method //rushabh
-(void)updateTimeElementsButtonsPropertiesArray:(RulesTimeElement*)ruleTimeElement{//time element is only one object
    self.rule.time = ruleTimeElement;
    //NSLog(@"rule time in add rules vc: %@", ruleTimeElement);
    [self callRulesView];
    if(self.rule.time != NULL){
        self.informationLabel.text = @"Add another trigger or press THEN to define action";
    }
}
//rushabh

//being called on each click
-(void) callRulesView{
    NSLog(@"callRulesView");
    self.rulesView = [[RulesView alloc]init]; //initialized dicts here
    self.rulesView.rule = self.rule;
    
    self.rulesView.delegate = self;
    self.rulesView.toHideCrossButton = NO;
    self.rulesView.parentViewController = self;
    [self.rulesView createTriggersActionsView:self.triggersActionsScrollView];
    
}

#pragma mark delegate from action trigger view
-(void)updateActionsArray:(NSMutableArray*)actionButtonPropertiesArray andDeviceIndexesForId:(int)deviceId{
    self.rule.actions = actionButtonPropertiesArray;
    [self callRulesView];
    SFIDevice *currentDevice;
    for(SFIDevice *device in self.deviceArray){
        if(device.deviceID == deviceId){
            currentDevice = device;
        }
    }
    RuleSensorIndexSupport *sensorSupport = [RuleSensorIndexSupport new];
    
    NSMutableArray *deviceIndexes = [NSMutableArray arrayWithArray:[sensorSupport getIndexesFor:currentDevice.deviceType]];
    if ([self.addActionsView istoggle:currentDevice.deviceType]) {
        SFIDeviceIndex *temp = [self.addActionsView getToggelDeviceIndex];
        [deviceIndexes addObject : temp];
    }
    [self clearDeviceIndexButtonScrollView];
    [self.addActionsView createDeviceIndexesLayoutForDeviceId:deviceId deviceType:currentDevice.deviceType deviceIndexes:deviceIndexes];
    if(self.rule.actions.count == 0){
        self.informationLabel.text = @"Add another trigger or press THEN to define action";
    }
}

-(void)updateTriggerArray:(NSMutableArray*)triggerButtonPropertiesArray andDeviceIndexesForId:(int)deviceId{
    self.rule.triggers = triggerButtonPropertiesArray;
    [self callRulesView];
    
    SFIDevice *currentDevice;
    for(SFIDevice *device in self.deviceArray){
        if(device.deviceID == deviceId){
            currentDevice = device;
        }
    }
   
    
    RuleSensorIndexSupport *sensorSupport = [RuleSensorIndexSupport new];
    NSMutableArray *deviceIndexes = [NSMutableArray arrayWithArray:[sensorSupport getIndexesFor:currentDevice.deviceType]];
    
    //repaint only if devicelistbutton of corresponding crossbutton is higlighted
    UIScrollView *scrollView = self.deviceListScrollView;
    for(RulesDeviceNameButton *button in [scrollView subviews]){
        if([button isKindOfClass:[UIImageView class]]){
            continue;
        }
        else if(button.deviceId == deviceId && button.selected){
            [self clearDeviceIndexButtonScrollView];
            [self.addTriggersView createDeviceIndexesLayoutForDeviceId:deviceId deviceType:currentDevice.deviceType deviceName:currentDevice.deviceName deviceIndexes:deviceIndexes];
        }
    }
    if(self.rule.triggers.count == 0){
        self.informationLabel.text = @"To get started, please select a trigger";
    }
    
}

//-(void) updateWifiClients:(NSMutableArray *)wifiClients{
//    self.rule.wifiClients = wifiClients;
//    [self callRulesView]; //for removing
//
//    [self clearDeviceIndexButtonScrollView];
//    int i =0;
//    for(SFIConnectedDevice *connectedClient in self.wifiClientsArray){
//        if(connectedClient.deviceUseAsPresence){
//            [self.addTriggersView addWiFiClient:connectedClient withY:ROW_PADDING + (ROW_PADDING+frameSize)*i];
//            i++;
//        }
//    }
//}

-(void)updateTime:(RulesTimeElement *)time{
    [self callRulesView];
    self.informationLabel.text = @"Add another trigger or press THEN to define action";
}


-(void)btnSaveTap:(id)sender{
   
    textField = [[UITextField alloc]init];
    if(self.isInitialized){
        textField.text = self.rule.name;
        NSLog(@"rule name edit %@",self.rule.name);
        NSLog(@"rule name edit %@",textField.text);
    }
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rule Name"
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
        textField.text = self.rule.name;
        NSLog(@"rule name edit %@",self.rule.name);
        NSLog(@"rule name edit %@",textField.text);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
    
     
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        self.rule.name = textField.text;
        NSLog(@" rule name %@",self.rule.name);
        [self sendRuleCommand];
    }
}
-( void)sendRuleCommand{
    NSLog(@"btn save tap");
    //self.rule.name = self.ruleNameField.text;
    //delegate to tableViewController
    [self.delegate updateRule:self.rule atIndexPath:self.indexPathRow];
    NSLog(@" rules total%@",self.rule);
    //[self.navigationController popViewControllerAnimated:YES];   // you should be doing this on response
    
    
    //create json
    RulePayload *rulePayload = [RulePayload new];
    rulePayload.rule = self.rule;
    NSDictionary *payload = [rulePayload createRulePayload:randomMobileInternalIndex with:self.isInitialized];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [payload JSONString];
    [self asyncSendCommand:cloudCommand];
    NSLog(@"rules payload %@",[payload JSONString]);
    
    
}

-(void)btnCancelTap:(id)sender{
    NSLog(@"btn cancel tap");
    self.rule = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSLog(@" my almond mac %@ %@",plus.almondplusMAC,plus.almondplusName);
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cloudCommand almondMac:plus.almondplusMAC];
}

@end
