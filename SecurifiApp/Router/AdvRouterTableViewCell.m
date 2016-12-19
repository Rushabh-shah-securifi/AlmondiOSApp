//
//  AdvRouterTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvRouterTableViewCell.h"

#define Hide_All -1

@interface AdvRouterTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;//0
@property (weak, nonatomic) IBOutlet UIView *textFieldView;//1
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIView *secureFieldView;//2
@property (weak, nonatomic) IBOutlet UITextField *secureField;
@property (weak, nonatomic) IBOutlet UIView *lineView;//4

@end

@implementation AdvRouterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.switchBtn.transform = CGAffineTransformMakeScale(0.80, 0.80);
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setUpSection:(NSDictionary *)sectionDict indexPath:(NSIndexPath *)indexPath{
    AdvCellType type = [sectionDict[CELL_TYPE] integerValue];
    NSArray *cells = sectionDict[CELLS];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *cell = cells[row];
    if(section == Adv_Help)
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        self.accessoryType = UITableViewCellAccessoryNone;
    
    self.label.text = cell[LABEL];
    //instead of setting in each method setting for every thng right here
    self.textField.text = cell[VALUE];
    self.switchBtn.on = [cell[VALUE] boolValue];
    self.secureField.text = cell[VALUE];
    
    switch (type) {
        case Adv_LocalWebInterface:{
            NSLog(@"local web interface switch");
            if(row == 0){
                [self setConcernedView:self.switchBtn.tag];
                
            }else if(row == 1){
                [self setConcernedView:self.textFieldView.tag];
                
            }else{
                [self setConcernedView:self.secureFieldView.tag];
            }
        }
            break;
        case Adv_UPnP:{
            if(row == 0){
                [self setConcernedView:self.switchBtn.tag];
            }
        }
            break;
        case Adv_AlmondScreenLock:{
            if(row == 0){
                [self setConcernedView:self.switchBtn.tag];
            }else if(row == 1){
                [self setConcernedView:self.secureFieldView.tag];
            }else{
                [self setConcernedView:self.textFieldView.tag];
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
                [self setConcernedView:self.textFieldView.tag];
            }
        }
            break;
        case Adv_Help:{
            [self setConcernedView:Hide_All];
        }
            break;
            
        default:
            break;
    }

}

- (void)setConcernedView:(NSInteger)viewTag{
    _switchBtn.hidden = (viewTag != _switchBtn.tag);
    _textFieldView.hidden = (viewTag != _textFieldView.tag);
    NSLog(@"secure hidden : %zd", (viewTag != _secureFieldView.tag));
    _secureFieldView.hidden = (viewTag != _secureFieldView.tag);
}

@end
