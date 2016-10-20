//
//  MeshView.m
//  SecurifiApp
//
//  Created by Masood on 7/27/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshView.h"
#import "MeshPayload.h"
#import "AlmondJsonCommandKeyConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonMethods.h"
#import "SFIColors.h"
#import "Analytics.h"
#import "RouterPayload.h"

#define ADD_FAIL -2
#define NETWORK_OFFLINE -1
#define HELP_INFO 0

#define INTERFACE_SCR 1
#define ALMONDS_LIST 2
#define BLINK_CHECK 3
#define NAMING 4
#define FINISH 5

#define PAIRING_ALMOND_1 6
#define PAIRING_ALMOND_2 7

@interface MeshView()<UIAlertViewDelegate>
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *blinkTimer;
@property (nonatomic) NSTimer *nonRepeatingTimer;

@property (nonatomic) CFTimeInterval startTime;

@property (strong, nonatomic) IBOutlet UIView *interfaceView;
@property (strong, nonatomic) IBOutlet UIView *almondsView;
@property (strong, nonatomic) IBOutlet UIView *addingAlmondView;
@property (strong, nonatomic) IBOutlet UIView *namingView;
@property (strong, nonatomic) IBOutlet UIView *setupCompleteView;
@property (strong, nonatomic) IBOutlet UIView *pairingAlmondView;
@property (strong, nonatomic) IBOutlet UIView *pairingAlmondRestView;
@property (strong, nonatomic) IBOutlet UIView *addAnotherAlmondView;
@property (strong, nonatomic) IBOutlet UIView *enjoyLastView;

@property (weak, nonatomic) IBOutlet UIButton *wiredBtn;
@property (weak, nonatomic) IBOutlet UIButton *wirelessBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *almondPicker;
@property (weak, nonatomic) IBOutlet UIButton *noLedBtn;
@property (weak, nonatomic) IBOutlet UIButton *notRtNowBtn;
@property (weak, nonatomic) IBOutlet UIButton *namingBtn;
@property (weak, nonatomic) IBOutlet UILabel *namingTitle;


@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *troublePairingBtn;
@property (weak, nonatomic) IBOutlet UIView *lineBtm;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndic1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndic2;
@property (weak, nonatomic) IBOutlet UIImageView *tickImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *tickImgView2;
@property (weak, nonatomic) IBOutlet UILabel *pairingAlmondRstInfo;

/* Mesh-help Start*/
@property NSDictionary *item;

@property (strong, nonatomic) IBOutlet UIView *infoScreen;
@property (weak, nonatomic) IBOutlet UILabel *helpTitle;
@property (weak, nonatomic) IBOutlet UITextView *helpDescription;
@property (weak, nonatomic) IBOutlet UITextView *helpDescBtm;

@property (weak, nonatomic) IBOutlet UIImageView *helpImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBtmConstraint;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
/* Mesh-help End*/

@property (nonatomic) UIView *currentView;
@property (nonatomic) NSArray *slavesDictArray;
@property (nonatomic) NSArray *currentSlaves;

@property (nonatomic) NSString *almondTitle;
@property (nonatomic) NSArray *almondNames;
@property (nonatomic) NSString *selectedName;
@property (nonatomic) BOOL isYesBlinkTapped;

@property (nonatomic)int mii;
@end

@implementation MeshView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSLog(@"frame initialized");
        [[NSBundle mainBundle] loadNibNamed:@"mesh" owner:self options:nil];
        self.slavesDictArray = nil;
        self.nameField.text = @"";
        self.almondNames = @[@"Bed Room",@"Den",@"Dining Room",@"Down Stairs",@"Entryway",@"Family Room",@"Hallway",@"Kids Room",@"Kitchen",@"Living Room",@"Master Bedroom",@"Office",@"Upstairs"];
        self.selectedName = self.almondNames[0];
        
        self.troublePairingBtn.hidden = YES;
        self.lineBtm.hidden = YES;
        
        [self setCornerRadiusToBtn:self.noLedBtn color:[SFIColors clientGreenColor]];
        [self setCornerRadiusToBtn:self.notRtNowBtn color:[SFIColors clientGreenColor]];
        [self initializeNotification];
    }
    return self;
}

- (void)setCornerRadiusToBtn:(UIButton *)btn color:(UIColor *)color{
    btn.layer.borderWidth = 1.0f;
    btn.layer.borderColor = color.CGColor;
}

- (void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [center addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [center addObserver:self selector:@selector(onCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onMeshCommandResponse:) name:NOTIFICATION_COMMAND_TYPE_MESH_RESPONSE object:nil];
    
    [center addObserver:self selector:@selector(onNetworkDownNotifier:) name:NETWORK_DOWN_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onNetworkUpNotifier:) name:NETWORK_UP_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onLoginResponse:) name:kSFIDidCompleteLoginNotification object:nil];
    
    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
}

- (void)removeNotificationObserver{
    NSLog(@"mesh view remove observer");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addInterfaceView:(CGRect)frame{
    [self addView:self.interfaceView frame:frame];
}

//interface view
- (IBAction)onWiredBtnTap:(UIButton*)btn {
    if(!btn.selected)
        [self toggleImage:@"wired_active" image:@"wireless_icon"];
    [[Analytics sharedInstance] markWired];
}
- (IBAction)onWirelessBtnTap:(UIButton*)btn {
    if(!btn.selected)
        [self toggleImage:@"wired_icon" image:@"wireless_active"];
    [[Analytics sharedInstance] markWireless];
}

-(void)toggleImage:(NSString *)selectedImg image:(NSString *)unSelectedImg{
    [self.wiredBtn setImage:[UIImage imageNamed:selectedImg] forState:UIControlStateNormal];
    self.wiredBtn.selected = !self.wiredBtn.selected;
    
    [self.wirelessBtn setImage:[UIImage imageNamed:unSelectedImg] forState:UIControlStateNormal];
    self.wirelessBtn.selected = !self.wirelessBtn.selected;
}


#pragma mark UIPickerViewDelegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSLog(@"number of rows");
    UIView *view = [pickerView superview];
    if(view.tag == 2) //variable, almond count
        return self.slavesDictArray.count;
    else
        return self.almondNames.count; //fixed first few names
    return 4;
}

// Set the width of the component inside the picker
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.frame.size.width;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    UIView *view = [pickerView superview];
    if(view.tag == 2){//almond
        NSDictionary *slave = self.slavesDictArray[row];
        return slave[SLAVE_NAME]; //need to display actual name
    }else{//names
        return [self.almondNames objectAtIndex:row];
    }
        
    return @"";
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"did select picker row");
    UIView *view = [thePickerView superview];
    if(view.tag == 2){ //unique slave name
        NSDictionary *slave = self.slavesDictArray[row];
        self.almondTitle = slave[SLAVE_UNIQUE_NAME]; //this will have unique name
    }else{
        self.selectedName = self.almondNames[row];
        self.nameField.text = @"";
        [self toggleTick1:NO tick2:YES];
    }
}

- (void)toggleTick1:(BOOL)tick1Hidden tick2:(BOOL)tick2Hidden{
    NSLog(@"Tick 1");
    if(_tickImgView1.isHidden == tick1Hidden && _tickImgView2.isHidden == tick2Hidden)
        return;
    NSLog(@"Tick 2");
    self.tickImgView1.hidden = tick1Hidden;
    self.tickImgView2.hidden = tick2Hidden;
}
#pragma mark text field delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.text.length == 0)
        [self toggleTick1:NO tick2:YES];
    [textField resignFirstResponder];
    return  YES;
}

- (void)onKeyboardDidShow:(id)notification {
    NSLog(@"on keyboard did show");
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.frame;
        CGFloat y = -keyboardSize.height ;
        f.origin.y =  y ;
        self.frame = f;
    }];
    [self toggleTick1:YES tick2:NO];
}

-(void)onKeyboardDidHide:(id)notice{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.frame;
        f.origin.y = 20;
        self.frame = f;
    }];
}

//adding almond view / blinkled view
- (IBAction)onNoLEDBlinking:(UIButton *)noButton {
    _mii = arc4random() % 10000;
    [self addView:self.almondsView frame:self.currentView.frame];
    [self requestStopLED];
    [[Analytics sharedInstance] markLedNotBlinking];
}

- (IBAction)onYesLEDBlinking:(UIButton *)yesButton {
    self.isYesBlinkTapped = YES;
    _mii = arc4random() % 10000;
    int blinkTimeout = 120;
    self.blinkTimer = [NSTimer scheduledTimerWithTimeInterval:blinkTimeout target:self selector:@selector(onBlinkTimeout:) userInfo:nil repeats:NO];
    [self.delegate showHudWithTimeoutMsgDelegate:@"Please wait..." time:blinkTimeout];
    [self requestAddSlave:YES];
    [[Analytics sharedInstance] markLedBlinking];
}

-(void)onBlinkTimeout:(id)sender{
    NSLog(@"blink time out");
    [RouterPayload routerSummary:self.mii mac:[SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC];
    [self.blinkTimer invalidate];
    self.blinkTimer = nil;
}

//naming almond view

//setup complete view

- (IBAction)onNextButtonTap:(UIButton*)nextButton {
    _mii = arc4random() % 10000;
    if(self.isMeshEditView){
        NSString *name = self.nameField.text.length == 0? self.selectedName: self.nameField.text;
        [self.delegate requestSetSlaveNameDelegate:name];
        return;
    }
    [self sendCommand:self.currentView];
}

- (IBAction)onCannotFindAlmondTap:(id)sender {
    self.currentSlaves = self.slavesDictArray;
    [self requestAddableSlave:ALMONDS_LIST];
    [self.activityIndic2 startAnimating];
    [self addView:self.pairingAlmondRestView frame:self.currentView.frame];
    [[Analytics sharedInstance] markCanNotFindAlmond];
}

- (IBAction)onTroublePairingTap:(id)sender {
    //time is already invalidated at this point (think of any other cases where time is no invalidated).
    [self requestAddableSlave:PAIRING_ALMOND_1];
    [self loadNextView];
    [[Analytics sharedInstance] markTroublePairingAlmond];
}
- (IBAction)onNotRightNowTap:(id)sender {
    [self addView:self.enjoyLastView frame:self.currentView.frame];
    [[Analytics sharedInstance] markAddAlmondLater];
}

- (IBAction)onAddAnotherAlmondTap:(id)sender {
    [self addView:self.interfaceView frame:self.currentView.frame];
    [[Analytics sharedInstance] markAddAnotherAlmond];
}

- (IBAction)onSweetTap:(id)sender {
    [self dismissView];
}

- (void)sendCommand:(UIView*)view{
    //tags to views are assigned in xib files
    int tag = (int)view.tag;
    switch (tag) {
        case 1:{
            [self requestAddableSlave:INTERFACE_SCR];
            [self loadNextView];
            break;
        }
        case 2:{
            [self.delegate showHudWithTimeoutMsgDelegate:@"Loading..." time:60];
            [self requestblinkLED];
            break;
        }
        case 3:{
            //seperate methods for blink buttons press, that sends commands
            break;
        }
        case 4:{
            [self requestSetSlaveName];
            break;
        }
        case 5:{
            [self loadNextView];
            break;
        }
        default:
            break;
    }
}

-(void)loadNextView{
    int tag = (int)self.currentView.tag;
    NSLog(@"Load next view \n\n Current View Tag: %ld", (long)self.currentView.tag);
    CGRect frame = self.currentView.frame;
//    [self.currentView removeFromSuperview];
    
    switch (tag) {
        case 0:{//for info screen
            if([self.item[S_NAME] isEqualToString:@"Interface"])
                [self addView:self.interfaceView frame:frame];
            else if([self.item[S_NAME] isEqualToString:@"Wiring"] || [self.item[S_NAME] isEqualToString:@"Wireless"]){
                
                if(self.slavesDictArray)
                    [self addView:self.almondsView frame:frame];
                else{
                    [self addPairingAlmondView:frame];
                }
                
            }
            
            break;
        }
        case 1:{
            if(self.wiredBtn.selected)
                [self initializeFirstScreen:[CommonMethods getMeshDict:@"Wiring"]];
            else
                [self initializeFirstScreen:[CommonMethods getMeshDict:@"Wireless"]];
            [self addInfoScreen:frame];
            break;
        }
        case 2:{
            [self addView:self.addingAlmondView frame:frame];
            break;
        }
        case 3:{
            [self addView:self.namingView frame:frame];
            [self showAlert:@"Almond Added" msg:@"You have successfuly added an Almond. You may now continue naming the Almond." cancel:@"Ok" other:nil tag:NAMING];
            break;
        }
        case 4:{
            [self addView:self.setupCompleteView frame:frame];
            break;
        }
        case 5:{
            [self addView:self.addAnotherAlmondView frame:frame];
            break;
        }
        case 6:{
            [self.activityIndic2 startAnimating];
            [self addView:self.pairingAlmondRestView frame:frame];
            break;
        }
        case 7:{
            [self addView:self.almondsView frame:frame];
            break;
        }

        default:
            break;
    }
}

- (IBAction)onBackBtnTap:(UIButton *)backBtn {
    NSLog(@"on back button tap");
    if(self.isMeshEditView){
        [self.delegate dismissControllerDelegate];
        return;
    }
    
    [self loadPrevView:[backBtn superview]];
}

-(void)loadPrevView:(UIView*)view{
    //tags to views are assigned in xib files
    int tag = (int)view.tag;
    NSLog(@"view tag: %d", tag);
    CGRect frame = view.frame;
//    [view removeFromSuperview];
    switch (tag) {
        case 0:{
            if([self.item[S_NAME] isEqualToString:@"Interface"]){
                [self dismissView];
            }
            
            else if([self.item[S_NAME] isEqualToString:@"Wiring"] || [self.item[S_NAME] isEqualToString:@"Wireless"])
                [self addView:self.interfaceView frame:frame];
            break;
        }
        case 1:{
            [self initializeFirstScreen:[CommonMethods getMeshDict:@"Interface"]];
            [self addInfoScreen:frame];
            break;
        }
        case 2:{
            [self requestAddableSlave:ALMONDS_LIST];
            [self addPairingAlmondView:frame];
            break;
        }
        case 3:{
            [self requestStopLED];
            [self addView:self.almondsView frame:frame];
            break;
        }
        case 4:{
            [self addView:self.almondsView frame:frame];
            break;
        }
        case 5:{
            
            break;
        }
        case 6:{
            [self addView:self.interfaceView frame:frame];
            break;
        }
        case 7:{
            [self addPairingAlmondView:frame];
            break;
        }
        default:
            break;
    }
}

-(void)addPairingAlmondView:(CGRect)frame{
    self.troublePairingBtn.hidden = YES;
    self.lineBtm.hidden = YES;
    [self.activityIndic1 startAnimating];
    [self addView:self.pairingAlmondView frame:frame];
}

-(void)dismissView{
    [self removeFromSuperview];
    [self.delegate dismissControllerDelegate];
}

-(void)addView:(UIView*)view frame:(CGRect)frame{
    if(view.tag == 1){//view here will now be added
        [self.timer invalidate];
        self.slavesDictArray = nil;
        self.currentSlaves = nil;
    }
    else if(view.tag == 2){//almond list
        [self.almondPicker reloadAllComponents];
    }
    else if(view.tag == 3){
        self.isYesBlinkTapped = NO;
    }
    else if(view.tag == 4){ //almond name
        self.nameField.text = @"";
    }
    else if(view.tag == PAIRING_ALMOND_2){
        [self setPairingAlmondsScreen2];
    }
    
    NSLog(@"current view: %@", self.currentView);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentView removeFromSuperview];
        self.currentView = view;
        view.frame = frame;
        [self addSubview:view];
    });
}

- (void)setPairingAlmondsScreen2{
    if(self.wiredBtn.selected){
        self.pairingAlmondRstInfo.text = @"Having trouble pairing your Almond 3 ?\n\n1. Check for loose wired connection between your Almonds.\n2. Press and hold the factory reset button on it for 5 secs.";
    }
    else{
        self.pairingAlmondRstInfo.text = @"Having trouble pairing your Almond 3 ?\n\n1. Bring it closer to primary Almond.\n2. Press and hold the factory reset button on it for 5 secs.";
    }
}

#pragma mark command requests
-(void)requestAddableSlave:(int)tag{
    [self.timer invalidate];
    self.slavesDictArray = nil;
    [self sendAddableSlaveCmd];
    
    self.startTime = CACurrentMediaTime();
    //timer repeats itself for every 2 seconds until it is invalidated
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                   target:self
                                                 selector:@selector(onTimeout:)
                                                userInfo:@(tag).stringValue
                                                  repeats:YES];
}

-(void)sendAddableSlaveCmd{
    if(self.wiredBtn.selected)
        [MeshPayload requestCheckForAddableWiredSlave:self.mii];//mii
    else
        [MeshPayload requestCheckForAddableWirelessSlave:self.mii];
}

-(void)onTimeout:(id)sender{
    //on cmd success timer will be invalidated
    CFTimeInterval elapsedTime = CACurrentMediaTime() - self.startTime;
    int tag = [(NSString *)self.timer.userInfo intValue];
    NSLog(@"elapsed time: %f, tag: %d", elapsedTime, tag);
    int timeout = [self getTimeOut:tag];
    if(elapsedTime > 150 && elapsedTime < 151)
        [self showPairingTroubleButton];
    if(elapsedTime >= timeout){
        [self.timer invalidate];
        
        if(tag == PAIRING_ALMOND_1){
            [self showAlert:@"No Almonds found" msg:@"Please bring the Almond closer or reboot and try again." cancel:@"Ok" other:nil tag:PAIRING_ALMOND_1];
        }
        else if(tag == ALMONDS_LIST){
            self.slavesDictArray = self.currentSlaves;
            [self addView:self.almondsView frame:self.currentView.frame];
            [self showAlert:@"Unable to find an Almond." msg:@"Make sure your Almond is plugged in. Reset it and try again." cancel:@"Ok" other:nil tag:ALMONDS_LIST];
        }
        [self.activityIndic1 stopAnimating];
        [self.activityIndic2 stopAnimating];
        return;
    }
        
    [self sendAddableSlaveCmd];
}

-(int)getTimeOut:(int)tag{
    //read it as, timeout when you are coming/visitig from screen ->"tag".
    if(tag == ALMONDS_LIST) //for cant find my almond
        return 120;
    else if(tag == PAIRING_ALMOND_1) //for trouble pairing almond
        return 300;
    else if(tag == INTERFACE_SCR) //for paring almond 1st screen
        return 300;
    else
        return 60;
}

-(void)requestAddSlave:(BOOL)isBlinking{
    if(self.wiredBtn.selected)
        [MeshPayload requestAddWiredSlave:self.mii slaveName:self.almondTitle];//mii
    else
        [MeshPayload requestAddWireLessSlave:self.mii slaveName:self.almondTitle];
}

-(void)requestblinkLED{
    [MeshPayload requestBlinkLed:self.mii slaveName:self.almondTitle];
}

-(void)requestStopLED{
    [MeshPayload stopBlinkLed:self.mii];
}

-(void)requestSetSlaveName{
    if(self.nameField.text.length == 0){
        [MeshPayload requestSetSlaveName:self.mii uniqueSlaveName:self.almondTitle newName:self.selectedName];
    }else{
        if(self.nameField.text.length <= 2){
            //show toast
            [self.nameField resignFirstResponder];
            [self.delegate showToastDelegate:@"Please Enter a name of atleast 3 characters."];
            return;
        }
        [MeshPayload requestSetSlaveName:self.mii uniqueSlaveName:self.almondTitle newName:self.nameField.text];
    }

    [self.delegate showHudWithTimeoutMsgDelegate:@"Loading..." time:10];
}

-(void)onMeshCommandResponse:(id)sender{
    NSLog(@"mesh cloud onmeshcommandresponse");
    //load next view
    NSDictionary *payload = [self getPayload:sender];
    if(payload == nil) return;
    
    NSLog(@"meshview mesh command payload: %@", payload);
    NSString *commandType = payload[COMMAND_TYPE];
    BOOL isSuccessful = [payload[SUCCESS] boolValue];
    
    NSLog(@"check point 1");
    if(![commandType isEqualToString:@"AddWiredSlaveMobile"] && ![commandType isEqualToString:@"AddWirelessSlaveMobile"]){
        return;
    }
    NSLog(@"check point 2");
    if(isSuccessful){
        //do nothing, wait for dynamic response
    }
    else{
        NSLog(@"check point 3");
        [self.delegate hideHUDDelegate];
        NSString *reason = payload[REASON];
        if([reason.lowercaseString hasPrefix:@"unplug all"]){
            NSString *msg = @"Adding to network failed. On the other Almond please Unplug all the cables connected to LAN and WAN Ports. Do not unplug the power cable.";
//            [self.blinkTimer invalidate]; //you don't have to invalidate, on unplugging it slave will auto reboot, and we may expect true response
            if(self.currentView.tag == BLINK_CHECK)
                [self showAlert:self.almondTitle msg:msg cancel:@"Ok" other:nil tag:ADD_FAIL];
        }
        else{
            [self.blinkTimer invalidate];
            if(self.currentView.tag == BLINK_CHECK)//on ok tap this will take to interface page
                [self showAlert:self.almondTitle msg:@"Adding to network failed." cancel:@"Ok" other:nil tag:BLINK_CHECK];
        }
    }
    
}
-(NSDictionary *)getPayload:(id)sender{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return nil;
    }
    BOOL local = [toolkit useLocalNetwork:toolkit.currentAlmond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    return payload;
}

-(void)onCommandResponse:(id)sender{
    NSLog(@"mesh view onCommandResponse");
    //load next view
    NSDictionary *payload = [self getPayload:sender];
    if(payload == nil) return;
    
    NSLog(@"meshview mesh payload: %@", payload);
    NSString *commandType = payload[COMMAND_TYPE];
    
    //special case
    if([commandType isEqualToString:@"DynamicAddWiredSlaveMobile"] || [commandType isEqualToString:@"DynamicAddWirelessSlaveMobile"]){
        [self.delegate hideHUDDelegate];
        [self.blinkTimer invalidate];
        self.blinkTimer = nil;
        if([payload[SUCCESS] boolValue]){
            if(self.currentView.tag == BLINK_CHECK)
                [self loadNextView];
        }
        else{//failed
            [self showAlert:self.almondTitle msg:@"Adding to network failed." cancel:@"Ok" other:nil tag:BLINK_CHECK];
        }
        return;
    }
    
    if(![payload[COMMAND_MODE] isEqualToString:@"Reply"]) //need to check for mii as well
        return;
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    
    if(isSuccessful){
        //ignore it, we are looking for dynamic command.
        

        if([commandType isEqualToString:@"CheckForAddableWiredSlaveMobile"] || [commandType isEqualToString:@"CheckForAddableWirelessSlaveMobile"]){

            if(self.currentView.tag == 6 || self.currentView.tag == 7){
                //need to directly load almonds view
                if(self.currentView.tag == 6){
                    [self parseSlaves:payload[SLAVES]];
                    [self addView:self.almondsView frame:self.currentView.frame];
                }
                else{
                    //this condition was written when you come back from almonds list screen, but still will work when you come form screen 6
                    if([(NSArray*)payload[SLAVES] count] > self.currentSlaves.count){
                        [self parseSlaves:payload[SLAVES]];
                        [self addView:self.almondsView frame:self.currentView.frame];
                        [self.delegate showToastDelegate:@"New Almond found!"];
                    }
                }
            }
            else{
                [self parseSlaves:payload[SLAVES]];
                //not loading next view, as the user might still be on helpscreen.
            }
            
        }
        
        else if([commandType isEqualToString:@"BlinkLedMobile"]){
            [self.delegate hideHUDDelegate];
            if(self.currentView.tag == ALMONDS_LIST)
                [self loadNextView];
        }
  
        else if([commandType isEqualToString:@"SetSlaveNameMobile"]){
            [self.delegate hideHUDDelegate];
            [self loadNextView];
        }
    }
    else{//failed
        if([commandType isEqualToString:@"CheckForAddableWiredSlaveMobile"] || [commandType isEqualToString:@"CheckForAddableWirelessSlaveMobile"]){
            // do not do any thing.
        }
        else{
            NSLog(@"for any other command on false hide hud");
            [self.delegate hideHUDDelegate];
        }
    }
}

-(void)parseSlaves:(NSArray *)Slaves{
    NSDictionary *slave = Slaves[0];
    self.slavesDictArray = Slaves;
    self.almondTitle = slave[SLAVE_UNIQUE_NAME]==nil? @"": slave[SLAVE_UNIQUE_NAME];
    [self.timer invalidate];
}

- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SFIGenericRouterCommand *genericRouterCommand = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    if(genericRouterCommand.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
        SFIRouterSummary *routerSummary = genericRouterCommand.command;
        NSLog(@"mesh view: %@", routerSummary);
        for(NSDictionary *almond in routerSummary.almondsList){
            if([almond[SLAVE_UNIQUE_NAME] isEqualToString:self.almondTitle]){
                [self.delegate hideHUDDelegate];
                [self.blinkTimer invalidate];
                self.blinkTimer = nil;
                if(self.currentView.tag == BLINK_CHECK)
                    [self loadNextView];
                return;
            }
        }
        
        if([self.blinkTimer isValid] == NO && self.currentView.tag == BLINK_CHECK && self.isYesBlinkTapped)
            [self showAlert:self.almondTitle msg:@"Adding to network failed." cancel:@"Ok" other:nil tag:BLINK_CHECK];
        
        //almond not yet added, its in adding state show hud (alerady there)
//        else if(self.isYesBlinkTapped)
//            [self.delegate showHudWithTimeoutMsgDelegate:@"Please wait..." time:60];
        
    }
}

-(void)showPairingTroubleButton{
    [UIView transitionWithView:self.troublePairingBtn
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.troublePairingBtn.hidden = NO;
                    }
                    completion:NULL];
    [UIView transitionWithView:self.lineBtm
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.lineBtm.hidden = NO;
                    }
                    completion:NULL];
}

/* Meshhelp -Start */
#pragma mark meshhelp screen
-(void)addInfoScreen:(CGRect)frame{
    NSLog(@"add info screeen");
    self.infoScreen.tag = 0;
    [self addView:self.infoScreen frame:frame];
}

-(void)addNamingScreen:(CGRect)frame{
    [self.namingBtn setTitle:@"Done" forState:UIControlStateNormal];
    self.namingTitle.text  = @"Location";
    [self addView:self.namingView frame:frame];
}

-(void)initializeFirstScreen:(NSDictionary *)item{
    NSLog(@"Initialize first screen");
    self.item = item;
    NSArray *screens = item[SCREENS];
    NSDictionary *screen = screens.firstObject;
    
    self.helpTitle.text = NSLocalizedString(screen[TITLE], @"");
    self.helpDescription.text = NSLocalizedString(screen[DESCRIPTION], @"");
    if(screen[DESCRIPTION_BELOW])
        self.helpDescBtm.text = NSLocalizedString(screen[DESCRIPTION_BELOW], @"");
    else
        self.helpDescBtm.text = @"";
    
    self.helpImg.image = [UIImage imageNamed:screen[IMAGE]];
    self.pageControl.numberOfPages = [item[SCREENCOUNT] intValue];
    [self.pageControl setCurrentPage:0];
    [self.backBtn setHidden:YES];
    [self.backBtn setEnabled:NO];
    [self.nextBtn setEnabled:NO];
}

- (IBAction)onPageControlValueChange:(UIPageControl* )pageControl {
    int currntPg = (int)pageControl.currentPage;
    NSLog(@"on page control value change: %d", currntPg);
    NSArray *screens = self.item[SCREENS];
    NSDictionary *screen = [screens objectAtIndex:currntPg];
    self.helpTitle.text = NSLocalizedString(screen[TITLE], @"");
    self.helpDescription.text = NSLocalizedString(screen[DESCRIPTION], @"");
    if(screen[DESCRIPTION_BELOW])
        self.helpDescBtm.text = NSLocalizedString(screen[DESCRIPTION_BELOW], @"");
    else
        self.helpDescBtm.text = @"";
    
    self.helpImg.image = [UIImage imageNamed:screen[IMAGE]];
    
    if(pageControl.currentPage == 0)
        self.backBtn.hidden = YES;
    else
        self.backBtn.hidden = NO;
    
    if(pageControl.currentPage == screens.count-1){
        [self.nextBtn setEnabled:YES];
    }else{
        [self.nextBtn setEnabled:NO];
    }
}

//next of page control
- (IBAction)onNextBtnTap:(id)sender {
    NSLog(@"page control next tap");
    [self loadNextView];
}

#pragma mark alert methods

- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    NSLog(@"mesh view show alert tag: %d", tag);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

//delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
        if(alertView.tag == PAIRING_ALMOND_1){
            [self addView:self.interfaceView frame:self.currentView.frame];
        }
        else if(alertView.tag == ALMONDS_LIST){
            [self addView:self.almondsView frame:self.currentView.frame];
        }
        else if(alertView.tag == BLINK_CHECK){
            [self addView:self.interfaceView frame:self.currentView.frame];
        }
        else if(alertView.tag == NETWORK_OFFLINE){
            NSLog(@"on alert ok");
            SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
            
            [toolkit initToolkit];
            int connectionTO = 5;
            self.nonRepeatingTimer = [NSTimer scheduledTimerWithTimeInterval:connectionTO target:self selector:@selector(onNonRepeatingTimeout:) userInfo:@(NETWORK_OFFLINE).stringValue repeats:NO];
            [self.delegate showHudWithTimeoutMsgDelegate:@"Trying to reconnect..." time:connectionTO];
   
        }else if(alertView.tag == ADD_FAIL){
            if(self.currentView.tag == BLINK_CHECK){
                [self.blinkTimer invalidate];
                int blinkTimeout = 120;
                self.blinkTimer = [NSTimer scheduledTimerWithTimeInterval:blinkTimeout target:self selector:@selector(onBlinkTimeout:) userInfo:nil repeats:NO];
                [self.delegate showHudWithTimeoutMsgDelegate:@"Please wait..." time:blinkTimeout];
            }
                
        }
    }
    else{
        
    }
}

-(void)onNonRepeatingTimeout:(id)sender{
    [self.delegate hideHUDDelegate];
    NSLog(@"self.nonRepeatingTimer.userInfo: %@", self.nonRepeatingTimer.userInfo);
    int tag = [(NSString *)self.nonRepeatingTimer.userInfo intValue];
    
    
    if(tag == NETWORK_OFFLINE){
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        enum SFIAlmondConnectionStatus status = [toolkit connectionStatusForAlmond:toolkit.currentAlmond.almondplusMAC];
        if(status == SFIAlmondConnectionStatus_disconnected){
            NSLog(@"ok 1");
            [self showAlert:@"" msg:@"Make sure your almond 3 has working internet connection to continue setup." cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
        }else{
            NSLog(@"ok 2");
            if(self.currentView.tag == 6 || self.currentView.tag == 7){
                [self requestAddableSlave:INTERFACE_SCR];
            }
            else if(self.currentView.tag == BLINK_CHECK){
                [RouterPayload routerSummary:_mii mac:[SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC];
            }
        }
    }
    [self.nonRepeatingTimer invalidate];
}

#define network events
- (void)onNetworkDownNotifier:(id)sender{
    NSLog(@"on network down");
    if([self.nonRepeatingTimer isValid]){
        return;
    }
    [self.timer invalidate];
    [self.delegate hideHUDDelegate];
    
    [self showAlert:@"" msg:@"Make sure your almond 3 has working internet connection to continue setup." cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
    
}

- (void)onNetworkUpNotifier:(id)sender{
    NSLog(@"mesh view network up");
    if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local){
        [[SecurifiToolkit sharedInstance] connectMesh];
    }else{
        //we wait for login response in case of cloud
    }
    
    //don't invalidate non repeating timer I am making it run for 5 sec, for simplicity
}

- (void)onLoginResponse:(id)sender{
    NSLog(@"mesh view on login resposne");
    //since nonrepeating timeout is 5 sec, I am not waiting for login response
    if(self.currentView.tag == BLINK_CHECK){
//        [RouterPayload routerSummary:_mii mac:[SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC];
//        [self.delegate showHudWithTimeoutMsgDelegate:@"Please wait..." time:60];
    }else{
        
    }
}
/* Meshhelp -End */
@end
