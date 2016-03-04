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
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "SFIDimmerButton.h"
#import "ValueFormatter.h"
#import "RulesConstants.h"
#import "SFIButtonSubProperties.h"
#import "RulesDeviceNameButton.h"
#import "GenericCommand.h"
#import "SFIColors.h"
#import "RulesTableViewController.h"
#import "SFISubPropertyBuilder.h"
//for wifi clients
#import "SFIWiFiClientsListViewController.h"
#import "GenericCommand.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SFIRouterClientsTableViewController.h"
#import "RulePayload.h"
#import "AddTriggerAndAddAction.h"
#import "SFISubPropertyBuilder.h"
#import "MBProgressHUD.h"
#import "AddRuleSceneClass.h"
#import "Analytics.h"

@interface AddRulesViewController()<UIAlertViewDelegate>{
    sfi_id dc_id;
    NSInteger randomMobileInternalIndex;
}

@property (weak, nonatomic) IBOutlet UIButton *IfButton;
@property (weak, nonatomic) IBOutlet UIButton *thenButton;
@property (weak, nonatomic) IBOutlet UIImageView *ifThenTabSeperator;
@property (nonatomic,strong)AddRuleSceneClass *addRuleScene;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation AddRulesViewController
UITextField *textField;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wifiClientsArray = [[NSMutableArray alloc]init];
    [self getWificlientsList];
    if(!self.isInitialized){
        self.rule = [[Rule alloc]init];
    }
    [self initializeNotifications];
    [self setUpNavigationBar];
    
    self.addRuleScene = [[AddRuleSceneClass alloc]initWithParentView:self.view deviceIndexScrollView:self.deviceIndexButtonScrollView deviceListScrollView:self.deviceListScrollView topScrollView:self.triggersActionsScrollView informationLabel:self.informationLabel triggers:self.rule.triggers actions:self.rule.actions isScene:NO];
    [self.addRuleScene buildTriggersAndActions];
    [self ifThenClick:YES infoText:@"To get started, please select a trigger" infoText2:@"Add another trigger or press THEN to define action"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    [[Analytics sharedInstance] markAddOrEditRuleScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
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

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark notificationMethods
-(void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //add, update, remove etc.
    [center addObserver:self selector:@selector(onRuleCommandResponse:) name:RULE_COMMAND_RESPONSE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onRuleCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
    [center addObserver:self
               selector:@selector(onTabBarDidChange:)
                   name:@"TAB_BAR_CHANGED"
                 object:nil];
}

-(void)getWificlientsList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.wifiClientsArray = toolkit.wifiClientParser;
}

-(void)onRuleCommandResponse:(id)sender{ //for add, update
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [data valueForKey:@"data"];
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    BOOL local = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    
    if(!local)
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    if ([mainDict valueForKey:@"MobileInternalIndex"]==nil || randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue] ) {
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
        [self.HUD hide:YES];
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
    self.rule.ID = [mainDict valueForKey:@"ruleid"];
    return;
    
}

-(void) setUpNavigationBar{
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.title = self.isInitialized? [NSString stringWithFormat:@"%@", self.rule.name]: @"New Rule";
}



#pragma mark buttonclickedMetghods
- (IBAction)ifButtonClicked:(id)sender {
    [self ifThenClick:YES infoText:@"To get started, please select a trigger" infoText2:@"Add another trigger or press THEN to define action"];
    
}

-(void)clearAndToggleViews{
    [self clearDeviceListScrollView];
    [self clearDeviceIndexButtonScrollView];
}

- (IBAction)thenButtonClicked:(id)sender {
    [self ifThenClick:NO infoText:@"Select Triggers First" infoText2:@"Select action for your trigger"];
}

-(void)ifThenClick:(BOOL)isTrigger infoText:(NSString*)text1 infoText2:(NSString*)text2{
    [self clearAndToggleViews];
    if(!isTrigger){
        [self changeIFThenColors:isTrigger clickedBtn:self.thenButton otherBtn:self.IfButton];
    }
    else{
        [self changeIFThenColors:isTrigger clickedBtn:self.IfButton otherBtn:self.thenButton];
    }
    [self.addRuleScene updateInfoLabel];
    [self.addRuleScene getTriggersDeviceList:isTrigger];
    
}

-(void) changeIFThenColors:(BOOL)ifClick clickedBtn:(UIButton *)clickedButton otherBtn:(UIButton *)otherButton{
    UIColor *selectedColor=[SFIColors ruleBlueColor];
    UIColor *imageBgColor=[UIColor whiteColor];
    UIColor *imageColor=selectedColor;
    if(!ifClick){
        selectedColor=[SFIColors ruleOrangeColor];
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


-(void)btnSaveTap:(id)sender{
    textField = [[UITextField alloc]init];
    if(self.isInitialized){
        textField.text = self.rule.name;
    }
    if(self.rule.triggers.count > 0 && self.rule.actions.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rule Name"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done", nil];
        [alert setDelegate:self];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        textField = [alert textFieldAtIndex:0];
        textField.frame = CGRectMake(alert.frame.origin.x, 25.0, alert.frame.size.width, 15.0);
        [textField setBackgroundColor:[UIColor whiteColor]];
        if(self.isInitialized){
            textField.text = self.rule.name;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
        
    }
    else
    {
        NSString *msg;
        if(self.rule.triggers.count == 0)
            msg = @"Select atleast one Trigger.";
        else if(self.rule.actions.count == 0)
            msg = @"Select atleast one Action";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:msg
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"scene.alert-button.OK", @"OK") otherButtonTitles: nil];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
        
    }
}

#pragma mark alert view delegeate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        self.rule.name = textField.text;
        [self sendCreateRuleCommand];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return ([[[alertView textFieldAtIndex:0] text] length]>0)?YES:NO;
    
}

-(void)sendCreateRuleCommand{
    RulePayload *rulePayload = [RulePayload new];
    rulePayload.rule = self.rule;
    
    //HUd methods.....
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Saving Rule...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    NSDictionary *payload = [rulePayload createRulePayload:randomMobileInternalIndex with:self.isInitialized valid:@"1"];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [payload JSONString];
    [self asyncSendCommand:cloudCommand];
    [[Analytics sharedInstance] markAddRule];
}
- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

-(void)btnCancelTap:(id)sender{
    self.rule = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    BOOL local=[toolkit useLocalNetwork:plus.almondplusMAC];
    if(local){
        [toolkit asyncSendToLocal:cloudCommand almondMac:plus.almondplusMAC];
    }else{
        [toolkit asyncSendToCloud:cloudCommand];
    }
}



@end