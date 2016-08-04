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


@interface MeshView()
@property (strong, nonatomic) IBOutlet UIView *interfaceView;
@property (strong, nonatomic) IBOutlet UIView *almondsView;
@property (strong, nonatomic) IBOutlet UIView *addingAlmondView;
@property (strong, nonatomic) IBOutlet UIView *namingView;
@property (strong, nonatomic) IBOutlet UIView *setupCompleteView;

@property (weak, nonatomic) IBOutlet UIButton *wiredBtn;
@property (weak, nonatomic) IBOutlet UIButton *wirelessBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (nonatomic) UIView *currentView;
@property (nonatomic) NSArray *almondTitles;
@property (nonatomic) NSString *almondTitle;
@property (nonatomic) NSArray *almondNames;

@property (nonatomic)int mii;
@end

@implementation MeshView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSLog(@"frame initialized");
        [[NSBundle mainBundle] loadNibNamed:@"mesh" owner:self options:nil];
        self.almondTitles = @[@"title 1", @"title 2", @"title 3",@"title 4"];
        self.almondNames = @[@"Galaxy", @"Universe", @"Dark Matter", @"Black Hole", @"Supernova"];
        self.nameField.text = self.almondNames[0];
        
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

- (void)addInterfaceView:(CGRect)frame{
    self.interfaceView.frame = frame;
    [self addSubview:self.interfaceView];
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

-(void)toggleImage:selectedImg image:unSelectedImg{
    [self.wiredBtn setImage:[UIImage imageNamed:selectedImg] forState:UIControlStateNormal];
    self.wiredBtn.selected = !self.wiredBtn.selected;
    
    [self.wirelessBtn setImage:[UIImage imageNamed:unSelectedImg] forState:UIControlStateNormal];
    self.wirelessBtn.selected = !self.wirelessBtn.selected;
}

//add almond view
- (IBAction)onCannotFindAlmondTap:(id)sender {
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
    if(view.tag == 2){
        NSArray *almTitles = self.almondTitles;
        return [almTitles objectAtIndex:row];
    }else{
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
        self.nameField.text = self.almondNames[row];
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
    [self.delegate showHudWithTimeoutMsgDelegate:@"Loading..."];
    self.currentView = [noButton superview];
    [self requestAddSlave:NO];
}

- (IBAction)onYesLEDBlinking:(UIButton *)yesButton {
    _mii = arc4random() % 10000;
    [self.delegate showHudWithTimeoutMsgDelegate:@"Loading..."];
    self.currentView = [yesButton superview];
    [self requestAddSlave:YES];
}

//naming almond view

//setup complete view

- (IBAction)onNextButtonTap:(UIButton*)nextButton {
    _mii = arc4random() % 10000;
    [self.delegate showHudWithTimeoutMsgDelegate:@"Loading..."];
    [self sendCommand:[nextButton superview]];
}

- (void)sendCommand:(UIView*)view{
    //tags to views are assigned in xib files
    self.currentView = view;
    int tag = (int)view.tag;
    switch (tag) {
        case 1:{
            [self requestAddableSlave];
            break;
        }
        case 2:{
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
            [self dismissView];
            break;
        }
        default:
            break;
    }
}

-(void)loadNextView{
    NSLog(@"Load next view");
    int tag = (int)self.currentView.tag;
    CGRect frame = self.currentView.frame;
    [self.currentView removeFromSuperview];
    
    switch (tag) {
        case 1:{
            [self addView:self.almondsView frame:frame];
            break;
        }
        case 2:{
            [self addView:self.addingAlmondView frame:frame];
            break;
        }
        case 3:{
            [self addView:self.namingView frame:frame];
            break;
        }
        case 4:{
            [self addView:self.setupCompleteView frame:frame];
            break;
        }
        case 5:{
            [self dismissView];
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
    CGRect frame = view.frame;
    [view removeFromSuperview];
    switch (tag) {
        case 1:{
            [self dismissView];
            break;
        }
        case 2:{
            [self addView:self.interfaceView frame:frame];
            break;
        }
        case 3:{
            [self addView:self.almondsView frame:frame];
            break;
        }
        case 4:{
            [self addView:self.addingAlmondView frame:frame];
            break;
        }
        case 5:{
            
            break;
        }
        default:
            break;
    }
}

-(void)dismissView{
    [self removeFromSuperview];
    [self.delegate dismissControllerDelegate];
}
-(void)addView:(UIView*)view frame:(CGRect)frame{
    view.frame = frame;
    [self addSubview:view];
}

#pragma mark command requests
-(void)requestAddableSlave{
    if(self.wiredBtn.selected)
        [MeshPayload requestCheckForAddableWiredSlave:self.mii];//mii
    else
        [MeshPayload requestCheckForAddableWirelessSlave:self.mii];
}

-(void)requestAddSlave:(BOOL)isBlinking{
    if(isBlinking){
        if(self.wiredBtn.selected)
            [MeshPayload requestAddWiredSlave:self.mii slaveName:self.almondTitle];//mii
        else
            [MeshPayload requestAddWireLessSlave:self.mii slaveName:self.almondTitle];
    }else{
        
    }
}

-(void)requestblinkLED{
    [MeshPayload requestBlinkLed:self.mii slaveName:self.almondTitle];
}

-(void)requestSetSlaveName{
    [MeshPayload requestSetSlaveName:self.mii];
}

-(void)onMeshCommandResponse:(id)sender{
    NSLog(@"onmeshcommandresponse");
    //load next view
    [self.delegate hideHUDDelegate];
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
    NSLog(@"mesh payload: %@", payload);

    if([payload[MOBILE_INTERNAL_INDEX] intValue]!=  self.mii|| ![payload[COMMAND_MODE] isEqualToString:@"Reply"])
        return;
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if(YES){
        NSString *commandType = payload[COMMAND_TYPE];
        if([commandType isEqualToString:@"CheckForAddableWiredSlave"] || [commandType isEqualToString:@"CheckForAddableWirelessSlave"]){
            self.almondTitles = payload[SLAVES];
            self.almondTitle = self.almondTitles[0]==nil? @"": self.almondTitles[0];
        }
        else if([commandType isEqualToString:@"AddWiredSlave"] || [commandType isEqualToString:@"AddWirelessSlave"]){
            
        }
        else if([commandType isEqualToString:@"BlinkLed"]){
            
        }
        else if([commandType isEqualToString:@"SetSlaveName"]){
            
        }
        [self loadNextView];
    }else{
       //show toast or something
    }
    
}
@end
