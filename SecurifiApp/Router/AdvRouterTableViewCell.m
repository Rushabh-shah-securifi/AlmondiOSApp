//
//  AdvRouterTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvRouterTableViewCell.h"
#import "SFIColors.h"
#import "AlmondProperties.h"

#define MAX_LENGTH 32
#define Hide_All -1

@interface AdvRouterTableViewCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;//0
@property (weak, nonatomic) IBOutlet UIView *textFieldView;//1
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIView *secureFieldView;//2
@property (weak, nonatomic) IBOutlet UITextField *secureField;
@property (weak, nonatomic) IBOutlet UILabel *valueLbl;//3

@property (weak, nonatomic) IBOutlet UIView *lineView;//4
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic) AdvCellType type;
@property (nonatomic) NSString *value;
@property (nonatomic) NSInteger row; //to differentiate same fields
@end

@implementation AdvRouterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.switchBtn.transform = CGAffineTransformMakeScale(0.80, 0.80);
    [self addEventsToBtn:self.eyeBtn];
    
    self.textField.delegate = self;
    self.secureField.delegate = self;
    
    self.textField.returnKeyType = UIReturnKeyDone;
    self.secureField.returnKeyType = UIReturnKeyDone;
}

- (void)setupNumberPad{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.textField.inputAccessoryView = numberToolbar;
    self.secureField.inputAccessoryView = numberToolbar;
}

-(void)cancelNumberPad{
    [self.textField resignFirstResponder];
    [self.secureField resignFirstResponder];
}

-(void)doneWithNumberPad{
    if(self.type == Adv_AlmondScreenLock){
        if(self.row == 1){
            [self textFieldShouldReturn:self.secureField];
        }
        else if(self.row == 2)
            [self textFieldShouldReturn:self.textField];
    }
}

- (void)addEventsToBtn:(UIButton *)btn{
    [btn addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(hidePassword:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setUpSection:(NSDictionary *)sectionDict indexPath:(NSIndexPath *)indexPath{
    AlmondProperties *almondProp = [SecurifiToolkit sharedInstance].almondProperty;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    self.type = type;
    self.row = row;
    
    NSArray *cells = sectionDict[CELLS];
    NSDictionary *cell = cells[row];
    
    //leftside
    self.label.text = cell[LABEL];
    if(row == 0 && type != Adv_Help)
       [self.label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:self.label.font.pointSize]];
    else
        [self.label setFont:[UIFont fontWithName:@"Avenir-Roman" size:self.label.font.pointSize]];
    
    //right side - instead of setting in each method setting for every thng right here
    self.value = cell[VALUE];
    
    self.textField.text = cell[VALUE];
    self.switchBtn.on = [cell[VALUE] boolValue];
    self.secureField.text = cell[VALUE];
    self.valueLbl.text = cell[VALUE];
    self.textField.placeholder = @"";
    self.secureField.placeholder = @"";
    
    //color
    self.mainView.backgroundColor = [SFIColors ruleBlueColor];
    
    //enabling fields
    [self tryEnableFields:YES alpha:1.0];
    
    //keyboard type
    [self setKeyboardType:type];
    switch (type) {
        case Adv_LocalWebInterface:{
            NSLog(@"local web interface switch");
            [self setMainViewColorAndDisable:[almondProp.webAdminEnable boolValue]];
            if(row == 0){
                [self setConcernedView:self.switchBtn.tag];
                
            }else if(row == 1){
                [self setConcernedView:self.valueLbl.tag];
                
            }else{
                [self setConcernedView:self.secureFieldView.tag];
            }
        }
            break;
        case Adv_UPnP:{
            [self setMainViewColorAndDisable:[almondProp.upnp boolValue]];
            if(row == 0){
                [self setConcernedView:self.switchBtn.tag];
            }
        }
            break;
        case Adv_AlmondScreenLock:{
            [self setMainViewColorAndDisable:[almondProp.screenLock boolValue]];
            if(row == 0){
                [self setConcernedView:self.switchBtn.tag];
            }else if(row == 1){
                [self setConcernedView:self.secureFieldView.tag];
            }else{
                [self setConcernedView:self.textFieldView.tag];
                self.textField.placeholder = @"100-999999 Sec";
            }
        }
            break;

        case Adv_DiagnosticSettings:{
            if(row == 0){
                [self setConcernedView:Hide_All];
            }else if(row == 1){
                [self setConcernedView:self.textFieldView.tag];
            }else{
                [self setConcernedView:self.textFieldView.tag];
            }
        }
            break;
        case Adv_Language:{
            if(row == 0){
                [self setConcernedView:self.valueLbl.tag];
            }
        }
            break;
        case Adv_Help:{
            [self setConcernedView:self.arrowImg.tag];
        }
            break;
            
        default:
            break;
    }
}

- (void)setMainViewColorAndDisable:(BOOL)enabled{
    if(!enabled){
        self.mainView.backgroundColor = [SFIColors ruleGraycolor];
        [self tryEnableFields:NO alpha:0.7];
    }
}

- (void)tryEnableFields:(BOOL)enable alpha:(float)alpha{
    self.textField.enabled = enable;
    self.secureField.enabled = enable;
    self.eyeBtn.enabled = enable;
    
    self.eyeBtn.alpha = alpha;
    self.textField.alpha = alpha;
    self.secureField.alpha = alpha;
}

- (void)setKeyboardType:(AdvCellType)type{
    if(type == Adv_AlmondScreenLock){
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.secureField.keyboardType = UIKeyboardTypeNumberPad;
        [self setupNumberPad];
        
    }else{
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.secureField.keyboardType = UIKeyboardTypeDefault;
    }
        
}
- (void)setConcernedView:(NSInteger)viewTag{
    _valueLbl.hidden = (viewTag != _valueLbl.tag);
    _switchBtn.hidden = (viewTag != _switchBtn.tag);
    _textFieldView.hidden = (viewTag != _textFieldView.tag);
    NSLog(@"secure hidden : %zd", (viewTag != _secureFieldView.tag));
    _secureFieldView.hidden = (viewTag != _secureFieldView.tag);
    _arrowImg.hidden = (viewTag != _arrowImg.tag);
}

#pragma mark action methods
- (IBAction)onSwitchTap:(UISwitch *)switchBtn {
    [self.delegate onSwitchTapDelegate:self.type value:switchBtn.isOn];
}

- (void)showPassword:(id)sender {
    self.secureField.secureTextEntry = NO;
}

- (void)hidePassword:(id)sender {
    self.secureField.secureTextEntry = YES;
}

#pragma mark text field delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    NSString *str = textField.text;
    if([str isEqualToString:self.value]){
        [textField resignFirstResponder];
        return YES;
    }
    
    
    BOOL valid = [self validateMinLen:str] && [self validateMaxLen:str];
    if (valid) {
        [textField resignFirstResponder];
        
        
        if(textField == self.textField){
            [self.delegate onDoneTapDelegate:self.type value:self.textField.text isSecureFld:NO row:self.row];
        }else if(textField == self.secureField){
            [self.delegate onDoneTapDelegate:self.type value:self.secureField.text isSecureFld:YES row:self.row];
        }
        
        return  YES;
    }else{
        return NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    
}

/*
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return [self validateMaxLen:str];
}*/

- (BOOL)validateMinLen:(NSString *)str{
    // SSID name value must be 1 char or longer
    if(self.type == Adv_LocalWebInterface){
        if(self.row == 2){//secure
            return [self minLengthHelper:str length:4 msg:@"Min Length should be 4 Chars"];
        }
    }
    else if(self.type == Adv_AlmondScreenLock){
        if(self.row == 1){
            return [self minLengthHelper:str length:4 msg:@"Min Length should be 4 Digits"];
        }else if(self.row == 2){
            return [self minValueHelper:str value:100 msg:@"Min Value should be 100 and Max 999999"];
        }
    }
    
    //any other case
    return [self minLengthHelper:str length:1 msg:@"Min Length should be 1"];
}

- (BOOL)validateMaxLen:(NSString *)str {
    // SSID name value must be 180 chars or fewer
    if(self.type == Adv_LocalWebInterface) {
        if(self.row == 1){//screen time
            return [self maxLengthHelper:str length:32 msg:@"Max Length should be 32 Chars"];
        }
    }
    else if(self.type == Adv_AlmondScreenLock){
        if(self.row == 1){//screen time
            return [self maxLengthHelper:str length:8 msg:@"Max Length should be 8 Digits"];
        }else if(self.row == 2){//pin
            return [self maxLengthHelper:str length:999999 msg:@"Min Value should be 100 and Max 999999"];
        }
    }
    
    //for any other case
    return [self maxLengthHelper:str length:MAX_LENGTH msg:@"Max Length should be 32 Digits"];
}

//helper methods
- (BOOL)minLengthHelper:(NSString *)str length:(NSInteger)length msg:(NSString *)msg{
    if(str.length >= length)
        return YES;
    else{
        [self.delegate showMidToastDelegate:msg];
        return NO;
    }
}

- (BOOL)minValueHelper:(NSString *)str value:(NSInteger)value msg:(NSString *)msg{
    if(str.integerValue >= value)
        return YES;
    else{
        [self.delegate showMidToastDelegate:msg];
        return NO;
    }
}

- (BOOL)maxLengthHelper:(NSString *)str length:(NSInteger)length msg:(NSString *)msg{
    if(str.length <= length)
        return YES;
    else{
        [self.delegate showMidToastDelegate:msg];
        return NO;
    }
}

@end
