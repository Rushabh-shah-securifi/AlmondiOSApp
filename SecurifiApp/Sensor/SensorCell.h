//
//  SensorCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@protocol SensorCellDelegate//onSettingButtonClicked:device genericIndex:genericIndexArray
-(void)onSettingButtonClicked:(Device*)device genericIndex:(NSMutableArray*)genericIndexArray;
@end
@interface SensorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *View;

@property (weak, nonatomic) IBOutlet UIImageView *settting;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (weak, nonatomic) IBOutlet UIButton *deviceImageButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLable;
@property (weak, nonatomic) IBOutlet UILabel *deviceStatusLabel;
@property (nonatomic,strong) Device *device;
@property (nonatomic,strong) SFIDeviceValue *deviceValue;
@property (nonatomic)id<SensorCellDelegate> delegate;
-(void) setCellInfo;
@end
