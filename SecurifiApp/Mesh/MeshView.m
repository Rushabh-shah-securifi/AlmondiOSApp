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

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *troublePairingBtn;
@property (weak, nonatomic) IBOutlet UIView *lineBtm;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndic1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndic2;

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
@property (nonatomic) NSArray *almondTitles;
@property (nonatomic) NSString *almondTitle;
@property (nonatomic) NSArray *almondNames;
@property (nonatomic) NSString *selectedName;

@property (nonatomic)int mii;
@end

@implementation MeshView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSLog(@"frame initialized");
        [[NSBundle mainBundle] loadNibNamed:@"mesh" owner:self options:nil];
        self.almondTitles = nil;
        self.almondNames = @[@"Bed Room",@"Den",@"Dining Room",@"Down Stairs",@"Entryway",@"Family Room",@"Hallway",@"Kids Room",@"Kitchen",@"Living Room",@"Master Bedroom",@"Office",@"Upstairs"];
        self.selectedName = self.almondNames[0];
        
        self.troublePairingBtn.hidden = YES;
        self.lineBtm.hidden = YES;
        [self initializeNotification];
    }
    return self;
}

- (void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [center addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [center addObserver:self selector:@selector(onMeshCommandResponse:) name:NOTIFICATION_CommandType_MESH_RESPONSE object:nil];
}

- (void)removeNotificationObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addInterfaceView:(CGRect)frame{
    [self addView:self.interfaceView frame:frame];
}

//interface view
- (IBAction)onWiredBtnTap:(UIButton*)btn {
    if(!btn.selected)
        [self toggleImage:@"wired_active" image:@"wireless_icon"];
    
}
- (IBAction)onWirelessBtnTap:(UIButton*)btn {
    if(!btn.selected)
        [self toggleImage:@"wired_icon" image:@"wireless_active"];
    
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
    UIView *view = [pickerView superview];
    if(view.tag == 2) //variable, almond count
        return self.almondTitles.count;
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
        NSArray *almTitles = self.almondTitles;
        return [almTitles objectAtIndex:row];
    }else{//names
        return [self.almondNames objectAtIndex:row];
    }
        
    return @"";
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"did select picker row");
    UIView *view = [thePickerView superview];
    if(view.tag == 2){ //unique slave name
        self.almondTitle = self.almondTitles[row];
    }else{
        self.selectedName = self.almondNames[row];
        self.nameField.text = @"";
    }
}

#pragma mark text field delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}

- (void)onKeyboardDidShow:(id)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.frame;
        CGFloat y = -keyboardSize.height ;
        f.origin.y =  y ;
        self.frame = f;
    }];
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
}

- (IBAction)onYesLEDBlinking:(UIButton *)yesButton {
    _mii = arc4random() % 10000;
    self.blinkTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(onBlinkTimeout:) userInfo:nil repeats:NO];
    [self.delegate showHudWithTimeoutMsgDelegate:@"Please wait!" time:120];
    [self requestAddSlave:YES];
}

-(void)onBlinkTimeout:(id)sender{
    [self.blinkTimer invalidate];
    self.blinkTimer = nil;
    if(self.currentView.tag == BLINK_CHECK)
        [self showAlert:self.almondTitle msg:@"Adding to network failed." cancel:@"Ok" other:nil tag:BLINK_CHECK];
}

//naming almond view

//setup complete view

- (IBAction)onNextButtonTap:(UIButton*)nextButton {
    _mii = arc4random() % 10000;
    [self sendCommand:self.currentView];
}

- (IBAction)onCannotFindAlmondTap:(id)sender {
    [self requestAddableSlave:ALMONDS_LIST];
    [self.activityIndic2 startAnimating];
    [self addView:self.pairingAlmondRestView frame:self.currentView.frame];
}

- (IBAction)onTroublePairingTap:(id)sender {
    //time is already invalidated at this point (think of any other cases where time is no invalidated).
    [self requestAddableSlave:PAIRING_ALMOND_1];
    [self loadNextView];
}
- (IBAction)onNotRightNowTap:(id)sender {
    [self addView:self.enjoyLastView frame:self.currentView.frame];
}

- (IBAction)onAddAnotherAlmondTap:(id)sender {
    [self addView:self.interfaceView frame:self.currentView.frame];
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
                
                if(self.almondTitles)
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
    [self requestRai2DownMobile];
    [self.delegate dismissControllerDelegate];
}

-(void)addView:(UIView*)view frame:(CGRect)frame{
    if(view.tag == 1){//view here will now be added
        [self.timer invalidate];
        self.almondTitles = nil;
    }
    NSLog(@"almond titles: %@, tag: %d", self.almondTitles, view.tag);
    [self.currentView removeFromSuperview];
    
    self.currentView = view;
    view.frame = frame;
    [self addSubview:view];
}

#pragma mark command requests
-(void)requestAddableSlave:(int)tag{
    [self.timer invalidate];
    self.almondTitles = nil;
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
    if(elapsedTime >= timeout){
        [self.timer invalidate];
        [self showPairingTroubleButton];
        
        if(tag == PAIRING_ALMOND_1){
            [self showAlert:@"No Almonds found" msg:@"Please bring the Almond closer or reboot and try again." cancel:@"Ok" other:nil tag:PAIRING_ALMOND_1];
        }
        else if(tag == ALMONDS_LIST){
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
    if(tag == ALMONDS_LIST)
        return 20;
    else if(tag == PAIRING_ALMOND_1)
        return 120;
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

-(void)requestRai2DownMobile{
    //I am not sure what is to be done on response of this command, what does fail mean ?
    [MeshPayload requestRai2DownMobile:self.mii];
}

-(void)onMeshCommandResponse:(id)sender{
    NSLog(@"onmeshcommandresponse");
    //load next view
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    BOOL local = [toolkit useLocalNetwork:toolkit.currentAlmond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"meshview mesh payload: %@", payload);
    NSString *commandType = payload[COMMAND_TYPE];
    
    //special case
    if([commandType isEqualToString:@"DynamicAddWiredSlaveMobile"] || [commandType isEqualToString:@"DynamicAddWirelessSlaveMobile"]){
        [self.delegate hideHUDDelegate];
        [self.blinkTimer invalidate];
        self.blinkTimer = nil;
        if([payload[SUCCESS] boolValue]){
            [self loadNextView];
        }
        else{//failed
            [self showAlert:self.almondTitle msg:@"Adding to network failed." cancel:@"Ok" other:nil tag:BLINK_CHECK];
        }
        
        return;
    }
    
    if([payload[MOBILE_INTERNAL_INDEX] intValue]!=  self.mii|| ![payload[COMMAND_MODE] isEqualToString:@"Reply"])
        return;
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    
    if(isSuccessful){
        //ignore it, we are looking for dynamic command.
        if([commandType isEqualToString:@"AddWiredSlaveMobile"] || [commandType isEqualToString:@"AddWirelessSlaveMobile"]){
            return;
        }

        if([commandType isEqualToString:@"CheckForAddableWiredSlaveMobile"] || [commandType isEqualToString:@"CheckForAddableWirelessSlaveMobile"]){

            if(self.currentView.tag == 6 || self.currentView.tag == 7){
                //need to directly load almonds view
                if(self.currentView.tag == 6){
                    [self parseSlaves:payload[SLAVES]];
                    [self addView:self.almondsView frame:self.currentView.frame];
                }else{
                    //this condition was written when you come back from almonds list screen, but still will work when you come form screen 6
                    if([(NSArray*)payload[SLAVES] count] > self.almondTitles.count){
                        [self parseSlaves:payload[SLAVES]];
                        [self addView:self.almondsView frame:self.currentView.frame];
                        [self.delegate showToastDelegate:@"New Almond found!"];
                    }
                }
            }else{
                [self parseSlaves:payload[SLAVES]];
            }
            //not loading next view, as the user might still be on helpscreen.
        }
        
        else if([commandType isEqualToString:@"BlinkLedMobile"]){
            [self.delegate hideHUDDelegate];
            [self loadNextView];
        }
  
        else if([commandType isEqualToString:@"SetSlaveNameMobile"]){
            [self.delegate hideHUDDelegate];
            [self loadNextView];
        }
    }
    else{
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
    self.almondTitles = Slaves;
    self.almondTitle = self.almondTitles[0]==nil? @"": self.almondTitles[0];
    [self.timer invalidate];
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
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:nil];
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
            [self addView:self.almondsView frame:self.currentView.frame];
        }
    }else{
        
    }
}

/* Meshhelp -End */
@end
