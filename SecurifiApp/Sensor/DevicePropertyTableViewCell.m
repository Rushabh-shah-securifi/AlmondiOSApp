//
//  DevicePropertyTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DevicePropertyTableViewCell.h"
#import "SFIColors.h"
#import "UICommonMethods.h"

#define NAVIGATE @"navigate"
#define LINK @"link"
#define SWITCHBUTTON @"switchButton"
#define DISPLAYHERE @"displayHere"
#define EDITTEXT @"EditText"
#define BUTTON @"button"


typedef NS_ENUM(NSUInteger, PropertyType) {
    navigate_,
    link_,
    switchButton_,
    displayHere_,
    EditText_,
    button_
    
};
@interface DevicePropertyTableViewCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *leftLabelView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (weak, nonatomic) IBOutlet UISwitch *onOFFSwitch;
@property (nonatomic)PropertyType propertyType;
@property (nonatomic )GenericIndexValue *genericIndexValue;
@property (weak, nonatomic) IBOutlet UIView *editTextUdView;

@end

@implementation DevicePropertyTableViewCell

- (void)awakeFromNib {
    self.textField.delegate = self;
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellProperty:(NSString *)property{
    if([property isEqualToString:EDITTEXT])
        self.propertyType = EditText_;
    else if([property isEqualToString:DISPLAYHERE])
        self.propertyType = displayHere_;
    else if([property isEqualToString:NAVIGATE])
        self.propertyType = navigate_;
    else if([property isEqualToString:SWITCHBUTTON])
        self.propertyType = switchButton_;
    else if([property isEqualToString:LINK])
        self.propertyType = link_;
}
- (void)setUpCell:(NSDictionary *)cellDict property:(NSString *)property genericValue:(GenericIndexValue *)genericIndexValue{
    self.genericIndexValue = genericIndexValue;
    [self resetViews];
    [self setCellProperty:property];
    NSLog(@"genericIndexValue.genericIndex.icon %@",genericIndexValue.genericIndex.icon);
    switch (self.propertyType) {
        case EditText_:{
            [self setEditText:cellDict icon:genericIndexValue.genericIndex.icon];
            break;
        }
        case displayHere_:{
            [self setLeftlabelAndRightLabel:cellDict];
            if(genericIndexValue.genericIndex.readOnly)
                [self setRightLabelColor:[UIColor darkGrayColor]];
            else
                 [self setRightLabelColor:[SFIColors ruleBlueColor]];
            
        }
            break;
        case navigate_:{
            [self setNavigate:cellDict];
           
        }
             break;
        case switchButton_:{
            [self setSwitchPropertyItem:cellDict];
        }
            break;
        case link_:{
            [self setButtonitem:cellDict];
        }
            break;
        default:
            break;
    }
   
}
-(void)setNavigate:(NSDictionary *)cellDict{
    [self setLeftlabelAndRightLabel:cellDict];
//    self.rightLabel.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
-(void)setLeftlabelAndRightLabel:(NSDictionary *)cellDict{
    [self setLeftValue:[NSString stringWithFormat:@"%@",cellDict[@"leftLabel"]].capitalizedString];
    [self setRightValue:[NSString stringWithFormat:@"%@",cellDict[@"rightLabel"]].capitalizedString];

}
-(void)setEditText:(NSDictionary *)cellDict icon:(NSString *)icon{
    self.imgView.image = [UICommonMethods imageNamed:icon withColor:[UIColor darkGrayColor]];
    self.editTextUdView.hidden = NO;
    self.textField.hidden = NO;
    self.textField.text = cellDict[@"rightLabel"];
}

- (void)setLeftValue:(NSString *)value{
    self.leftLabelView.hidden = NO;
    self.leftLabelView.text = value;
}

- (void)setRightValue:(NSString *)value{
    self.rightLabel.hidden = NO;
    self.rightLabel.text = value;
}
-(void)setRightLabelColor:(UIColor *)color{
    self.rightLabel.textColor = color;
}
-(void)setSwitchPropertyItem:(NSDictionary *)dict{
    [self setLeftValue:dict[@"leftLabel"]];
    self.onOFFSwitch.hidden = NO;
}
-(void)setButtonitem:(NSDictionary *)dict{
    self.button.hidden = NO;
    [self.button setTitleColor:[SFIColors ruleBlueColor] forState:UIControlStateNormal];
    self.button.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.button setTitle:dict[@"leftLabel"] forState:UIControlStateNormal];
}
- (IBAction)buttonClicked:(id)sender {
    [self.delegate linkToNextScreen:self.genericIndexValue];
}
- (void)resetViews{
    self.editTextUdView.hidden = YES;
    self.imgView.hidden = YES;
    self.textField.hidden = YES;
    self.leftLabelView.hidden = YES;
    self.onOFFSwitch.hidden = YES;
    self.button.hidden = YES;
    self.rightLabel.hidden = YES;
    self.rightLabel.textColor = [UIColor blackColor];
    
    self.accessoryType = UITableViewCellAccessoryNone;
}
#pragma mark - TextField Delegates

// This method is called once we click inside the textField
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"Text field did begin editing");
}

// This method is called once we complete editing
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.delegate deviceNameUpdate:textField.text genericIndexValue:self.genericIndexValue];
    NSLog(@"Text field ended editing ,%@",textField.text);
}

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)onOFFChanged:(id)sender {
    if(self.onOFFSwitch.on){
        [self.delegate deviceOnOffSwitchUpdate:@"ON" genericIndexValue:self.genericIndexValue];
    }
    else{
         [self.delegate deviceOnOffSwitchUpdate:@"OFF" genericIndexValue:self.genericIndexValue];
    }
}

@end
