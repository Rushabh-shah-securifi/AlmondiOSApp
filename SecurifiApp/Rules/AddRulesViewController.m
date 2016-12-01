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
#import "ValueFormatter.h"
#import "RulesConstants.h"
#import "SFIButtonSubProperties.h"
#import "RulesDeviceNameButton.h"
#import "GenericCommand.h"
#import "SFIColors.h"
#import "RulesTableViewController.h"
#import "SFISubPropertyBuilder.h"
//for wifi clients
#import "GenericCommand.h"
#import "SecurifiToolkit/SFIDevice.h"
#import "SFIRouterClientsTableViewController.h"
#import "RulePayload.h"
#import "AddTriggerAndAddAction.h"
#import "SFISubPropertyBuilder.h"
#import "MBProgressHUD.h"
#import "AddRuleSceneClass.h"
#import "Analytics.h"
#import "CommonMethods.h"

@interface AddRulesViewController()<UIAlertViewDelegate, UITextFieldDelegate>{
    sfi_id dc_id;
    NSInteger randomMobileInternalIndex;
}

@property (weak, nonatomic) IBOutlet UIButton *IfButton;
@property (weak, nonatomic) IBOutlet UIButton *thenButton;
@property (weak, nonatomic) IBOutlet UIImageView *ifThenTabSeperator;
@property (nonatomic,strong)AddRuleSceneClass *addRuleScene;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property (nonatomic) CGRect ViewFrame;
@property (nonatomic) BOOL isDone;

@end

@implementation AddRulesViewController
UITextField *textField;
UIAlertView *alert;

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
    [self ifThenClick:YES infoText:NSLocalizedString(@"selectTriggerInitial", @"To get started, please select a trigger") infoText2:NSLocalizedString(@"add_trigger_or_add_action", @"Add another trigger or press THEN to define action")];
    self.ViewFrame = self.view.frame;
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
    [CommonMethods clearTopScroll:self.triggersActionsScrollView middleScroll:self.deviceListScrollView bottomScroll:self.deviceIndexButtonScrollView];
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
    
    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];

}

-(void)getWificlientsList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.wifiClientsArray = toolkit.clients;
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
    
    BOOL success = [mainDict[@"Success"] boolValue];
    if (!success)  {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Oops") message:NSLocalizedString(@"try_later", @"Sorry, There was some problem with this request, try later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles: nil];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
    }else{
        //        self.originalSceneInfo = [self.sceneInfo copy];
        //to do copy rules array
        //        if(self.rule.ID != NULL){
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.HUD hide:YES];
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
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"Done") style:UIBarButtonItemStylePlain target:self action:@selector(btnSaveTap:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", @"Back") style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x02a8f3),
                                                                                                       NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Roman" size:17.5f]} forState:UIControlStateNormal];
    self.title = self.isInitialized? [NSString stringWithFormat:@"%@", self.rule.name]: NSLocalizedString(@"New Rule", @"New Rule");
}



#pragma mark buttonclickedMetghods
- (IBAction)ifButtonClicked:(id)sender {
    [self ifThenClick:YES infoText:NSLocalizedString(@"selectTriggerInitial", @"To get started, please select a trigger") infoText2:NSLocalizedString(@"AddRulesView Add another trigger or press THEN to define action", @"Add another trigger or press THEN to define action")];
    
}

-(void)clearAndToggleViews{
    [self clearDeviceListScrollView];
    [self clearDeviceIndexButtonScrollView];
}

- (IBAction)thenButtonClicked:(id)sender {
    [self ifThenClick:NO infoText:NSLocalizedString(@"AddRulesView Select Triggers First", @"Select Triggers First") infoText2:NSLocalizedString(@"selectActionInitial", @"Select action for your trigger")];
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
    self.isDone = YES;
    textField = [[UITextField alloc]init];
    if(self.isInitialized){
        textField.text = self.rule.name;
    }//
    if(self.rule.triggers.count > 0 && self.rule.actions.count > 0){
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"rule_name", @"Rule Name")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"done", @"Done"), nil];
        [alert setDelegate:self];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        textField = [alert textFieldAtIndex:0];
        textField.delegate = self;
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
            msg = NSLocalizedString(@"AddRulesView Select atleast one Trigger", @"Select atleast one Trigger");
        else if(self.rule.actions.count == 0)
            msg = NSLocalizedString(@"AddRulesView Select atleast one Action", @"Select atleast one Action");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Oops") message:msg
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles: nil];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [alert show];
        });
        
    }
}

#pragma mark alert view delegeate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
        self.isDone = NO;
    }else{
        self.rule.name = textField.text;
        [self sendCreateRuleCommand];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return ([[[alertView textFieldAtIndex:0] text] length]>0)?YES:NO;
}

#pragma mark textfield delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    self.isDone = NO;
    [textField resignFirstResponder];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(range.location == 0 && [string isEqualToString:@" "]){
        // Returning no here to restrict whitespace as first char
        return NO;
    }
    
    if (textField.text.length >= 32 && range.length == 0){
        return NO; // return NO to not change text
    }
    else{
        return YES;
    }
}

#pragma mark commands
-(void)sendCreateRuleCommand{
    RulePayload *rulePayload = [RulePayload new];
    rulePayload.rule = self.rule;
    
    //HUd methods.....
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"AddRulesView Saving Rule...", @"Saving Rule...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    NSDictionary *payload = [rulePayload createRulePayload:randomMobileInternalIndex with:self.isInitialized valid:@"true"];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [payload JSONString];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cloudCommand];
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
