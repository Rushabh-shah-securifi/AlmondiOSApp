//
//  DevicePropertyTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DevicePropertyTableViewCell.h"
#import "SFIColors.h"

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
@property (nonatomic)PropertyType propertyType;

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
    if([property isEqualToString:DISPLAYHERE])
        self.propertyType = displayHere_;
    if([property isEqualToString:NAVIGATE])
        self.propertyType = navigate_;
}
- (void)setUpCell:(NSDictionary *)cellDict property:(NSString *)property genericValue:(GenericIndexValue *)genericIndexValue{
    [self resetViews];
    [self setCellProperty:property];
    
    switch (self.propertyType) {
        case EditText_:{
            [self setEditText:cellDict];
            break;
        }
        case displayHere_:{
            [self setLeftlabelAndRightLabel:cellDict];
            if(genericIndexValue.genericIndex.readOnly)
                [self setRightLabelColor:[UIColor lightGrayColor]];
            else
                 [self setRightLabelColor:[UIColor blueColor]];
            break;
        }
        case navigate_:{
            [self setNavigate:cellDict];
            break;
        }
            
        default:
            break;
    }
   
}
-(void)setNavigate:(NSDictionary *)cellDict{
    [self setLeftlabelAndRightLabel:cellDict];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
-(void)setLeftlabelAndRightLabel:(NSDictionary *)cellDict{
    [self setLeftValue:[NSString stringWithFormat:@"%@",cellDict[@"leftLabel"]].capitalizedString];
    [self setRightValue:[NSString stringWithFormat:@"%@",cellDict[@"rightLabel"]].capitalizedString];

}
-(void)setEditText:(NSDictionary *)cellDict{
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
- (void)resetViews{
    self.imgView.hidden = YES;
    self.textField.hidden = YES;
    self.leftLabelView.hidden = YES;
    
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
    
    NSLog(@"Text field ended editing ,%@",textField.text);
}

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
