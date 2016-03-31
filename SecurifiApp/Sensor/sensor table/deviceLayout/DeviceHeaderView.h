//
//  DeviceHeaderView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 10/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "GenericIndexValue.h"
#import "GenericParams.h"

typedef NS_ENUM(NSUInteger, CellType) {
    SensorTable_Cell,
    ClientTable_Cell,
    SensorEdit_Cell,
    ClientEdit_Cell,
    ClientEditProperties_cell
    
};
@protocol DeviceHeaderViewDelegate <NSObject>
@optional
-(void)delegateClientSettingButtonClick:(GenericParams*)genericParams;
-(void)delegateClientEditTable;
-(void)delegateDeviceSettingButtonClick:(GenericParams*)genericParams;
-(void)delegateDeviceButtonClickWithGenericProperies:(GenericIndexValue*)genericIndexValue;
@end

@interface DeviceHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *deviceButton;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *deviceValue;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (nonatomic)CellType cellType;
@property (weak,nonatomic)id<DeviceHeaderViewDelegate> delegate;
@property (nonatomic)GenericParams *genericParams;

-(void)setUpDeviceCell;
-(void)initializeSensorCellWithGenericParams:(GenericParams*)genericParams cellType:(CellType)cellType;

@end
