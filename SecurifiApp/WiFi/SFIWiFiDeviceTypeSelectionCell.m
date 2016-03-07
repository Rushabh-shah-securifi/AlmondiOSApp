//
//  SFIWiFiDeviceTypeSelectionCell.m
//  Scenes
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "MDJSON.h"

@interface SFIWiFiDeviceTypeSelectionCell() {
    IBOutlet UIButton *btnSelect;
}
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end

@implementation SFIWiFiDeviceTypeSelectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    btnSelect.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSelect.layer.borderWidth = 2.0f;
    btnSelect.layer.cornerRadius = btnSelect.frame.size.height/2;
    btnSelect.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    NSLog(@"layoutSubviews");
    [super layoutSubviews];
    btnSelect.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSelect.layer.borderWidth = 2.0f;
    btnSelect.layer.cornerRadius = btnSelect.frame.size.height/2;
    btnSelect.backgroundColor = [UIColor clearColor];
    
//    if ([[self.cellInfo valueForKey:@"selected"] boolValue]) {
//        btnSelect.backgroundColor = [UIColor whiteColor];
//    }
    
}

- (void)createPropertyCell:(id)info {
    NSLog(@"createPropertyCell");
    self.cellInfo = info;
    
    
}
-(void)setTypeLabe:(NSString *)typeLabel{
    NSLog(@"typeLabel %@",typeLabel);
    self.typeLabel.text = typeLabel;
    
}
- (IBAction)btnSelectTap:(id)sender {
    btnSelect.backgroundColor = [UIColor whiteColor];
    [self.delegate btnSelectTypeTapped:self Info:self.cellInfo];
}

@end
