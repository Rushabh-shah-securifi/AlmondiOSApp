//
//  TextInput.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "TextInput.h"
#import "UIFont+Securifi.h"
#import "UIViewController+Securifi.h"
#import "Colours.h"
#import "UICommonMethods.h"


@interface TextInput ()<UITextFieldDelegate>
@property (nonatomic)UITextField *deviceNameField;
@end

@implementation TextInput
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue isSensor:(BOOL)isSensor
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        self.isSensor = isSensor;
        [self drawTextField];
    }
    return self;
}

-(void)drawTextField{
    NSLog(@"self.genericIndexValue.index %@",self.genericIndexValue.genericIndex.ID);
    self.deviceNameField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 5)];
    
    if(self.isSensor){
        int type = [Device getTypeForID:self.genericIndexValue.deviceID];
        BOOL isNameLocationField = [self.genericIndexValue.genericIndex.ID isEqualToString:@"-1"] || [self.genericIndexValue.genericIndex.ID isEqualToString:@"-2"];
        
        if(isNameLocationField && (type == SFIDeviceType_NestThermostat_57 || type == SFIDeviceType_NestSmokeDetector_58 || type == SFIDeviceType_AlmondBlink_64 || type == SFIDeviceType_AlmondSiren_63)){
            [self.deviceNameField setEnabled:NO];
            self.deviceNameField.alpha = 0.7;
        }
    }
    
    self.deviceNameField.text = self.genericIndexValue.genericValue.value;
    self.deviceNameField.delegate = self;
    self.deviceNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    //    self.deviceNameField.backgroundColor = self.color;
    self.deviceNameField.textColor = [UIColor blackColor];
    self.deviceNameField.font = [UIFont securifiFont:15];
    [self.deviceNameField becomeFirstResponder];
    UIView *OnelineView = [[UIView alloc]initWithFrame:CGRectMake(self.deviceNameField.frame.origin.x, self.deviceNameField.frame.size.height , self.frame.size.width, 1)];
    OnelineView.backgroundColor = [UIColor lightGrayColor];
    OnelineView.alpha = 0.5;
    
    [self addSubview:OnelineView];
    [self addSubview:self.deviceNameField];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIImageView *textCheckMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height , 0, self.frame.size.height -10, self.frame.size.height -10)];
    NSLog(@"frame width: %f, frame height: %f", self.frame.size.width, self.frame.size.height);
    
    textCheckMarkView.image = [UICommonMethods imageNamed:@"iconSceneChekmark" withColor:[UIColor blackColor]];
    
    UIButton *btnCloseNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseNotification.frame = CGRectMake(self.frame.size.width - self.frame.size.height - 20, 0, 60, 35);
    btnCloseNotification.backgroundColor = [UIColor clearColor];
    [btnCloseNotification addTarget:self action:@selector(tapCheckMark) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnCloseNotification];
    [self addSubview:textCheckMarkView];
}

-(void)tapCheckMark{
    NSLog(@"tapCheckMark %@",self.deviceNameField.text);
    
    if(!self.isSensor){
        if(self.genericIndexValue.genericIndex.ID.intValue == -18){
            if(self.deviceNameField.text.length == 0){
                NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 1 - 60 min");
                [self showAlert:[NSString stringWithFormat:@"%@ 1 - 60",locStr]];
            }else if([self isAllDigits:self.deviceNameField.text]){
                if([self.deviceNameField.text integerValue] >= 61 || [self.deviceNameField.text integerValue] < 1 ){
                    NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 1 - 60 min");
                    [self showAlert:[NSString stringWithFormat:@"%@ 1 - 60",locStr]];
                }else{
                    [self.delegate save:self.deviceNameField.text forGenericIndexValue:_genericIndexValue currentView:self];
                    [self.deviceNameField resignFirstResponder];
                }
            }else{
                NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 1 - 60 min");
                [self showAlert:[NSString stringWithFormat:@"%@ 1 - 60",locStr]];
            }
            
        }
        
        else if(self.genericIndexValue.genericIndex.ID.intValue == -11){
            if(self.deviceNameField.text.length == 0){
                [self showAlert:[NSString stringWithFormat:NSLocalizedString(@"TextInput Please Enter %@", @"Please Enter %@"), self.genericIndexValue.genericIndex.groupLabel]];
            }else{
                [self.delegate save:self.deviceNameField.text forGenericIndexValue:_genericIndexValue currentView:self];
                [self.deviceNameField resignFirstResponder];
            }
        }
        
        return;
    }
    
    
    DeviceCommandType deviceCmdType = self.genericIndexValue.genericIndex.commandType;
    if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
        if(self.deviceNameField.text.length == 0){
            [self showAlert:[NSString stringWithFormat:NSLocalizedString(@"TextInput Please Enter %@", @"Please Enter %@"), self.genericIndexValue.genericIndex.groupLabel]];
        }
        else{
            [self.delegate save:self.deviceNameField.text forGenericIndexValue:_genericIndexValue currentView:self];
            [self.deviceNameField resignFirstResponder];
        }
        return;
    }
    
    if(self.deviceNameField.text.length == 0)
        [self showAlert:NSLocalizedString(@"TextInput Please Enter Number", @"Please Enter Number")];
    
    else if ([self isAllDigits:self.deviceNameField.text])
    {
        BOOL isNameLocationField = [self.genericIndexValue.genericIndex.ID isEqualToString:@"-1"] || [self.genericIndexValue.genericIndex.ID isEqualToString:@"-2"];
        int type =  [Device getTypeForID:self.genericIndexValue.deviceID];
        
        if( !isNameLocationField && (type == SFIDeviceType_StandardWarningDevice_21)  && ([self.deviceNameField.text integerValue] >= 65536 || [self.deviceNameField.text integerValue] < 0 ))
        {   NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 65535");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 65535",locStr]];
            
        }
        else if( !isNameLocationField && (type == SFIDeviceType_AlmondBlink_64 || type == SFIDeviceType_AlmondSiren_63)  && ([self.deviceNameField.text integerValue] >= 99999 || [self.deviceNameField.text integerValue] < 0 ))
        {   NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 99999");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 99999",locStr]];
            
        }
        else if(!isNameLocationField &&  type == SFIDeviceType_ZWtoACIRExtender_54 && ([self.deviceNameField.text integerValue] > 999 || [self.deviceNameField.text integerValue] < 0 ))
        {   NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 999");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 999",locStr]];
            
        }else if(!isNameLocationField &&  type == SFIDeviceType_Weather && ([self.deviceNameField.text integerValue] > 9999 || [self.deviceNameField.text integerValue] < 0 ))
        {   NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 0 - 9999");
            [self showAlert:[NSString stringWithFormat:@"%@ 0 - 9999",locStr]];
            
        }
        else if(!isNameLocationField &&  type == SFIDeviceType_ColorDimmableLight_32 && ([self.deviceNameField.text integerValue] > 9000 || [self.deviceNameField.text integerValue] < 1000 ))
        {    NSString *locStr =NSLocalizedString(@"please_enter_value_between", @"Please Enter Value between 1000 - 9000");
            [self showAlert:[NSString stringWithFormat:@"%@ 1000 - 9000",locStr]];
        }
        else{
            [self.delegate save:self.deviceNameField.text forGenericIndexValue:_genericIndexValue currentView:self];
            [self.deviceNameField resignFirstResponder];
        }
        
    }
    else
        [self showAlert:NSLocalizedString(@"TextInput Please enter numbers only", @"Please enter numbers only")];
}

-(void)setTextFieldValue:(NSString*)value{
    self.deviceNameField.text = value;
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

-(void)showAlert:(NSString *)string{
    NSLog(@"self.deviceNameField.placeholder %@",string);
    self.deviceNameField.text = @"";
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor colorFromHexString:@"C7C7CD"] };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    
    [self.deviceNameField setAttributedPlaceholder:attrStr];
    self.deviceNameField.placeholder = string;
}

- (BOOL) isAllDigits:(NSString *)string{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && string.length > 0;
}

@end
