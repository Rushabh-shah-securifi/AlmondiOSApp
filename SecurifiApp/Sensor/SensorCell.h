//
//  SensorCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *View;

@property (weak, nonatomic) IBOutlet UIImageView *settting;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (weak, nonatomic) IBOutlet UIButton *deviceImageButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLable;
@property (weak, nonatomic) IBOutlet UILabel *deviceStatusLabel;
@property (nonatomic,strong) SFIDevice *device;
@property (nonatomic,strong) SFIDeviceValue *deviceValue;
-(void)cellInfo;
@end
