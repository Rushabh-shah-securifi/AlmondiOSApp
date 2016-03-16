//
//  CommonCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 10/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
typedef NS_ENUM(NSUInteger, CellType) {
    SensorTable_Cell,
    ClientTable_Cell,
    SensorEdit_Cell,
    ClientEdit_Cell,
    ClientEditProperties_cell
    
};
@protocol CommonCellDelegate <NSObject>
@optional
-(void)delegateSensorTable;
-(void)delegateClientEditTable;
-(void)delegateSensorTable:(Device*)device withGenericIndexValues:(NSArray *)genericIndexValues;

@end
@interface CommonCell : UIView
@property (weak, nonatomic) IBOutlet UIButton *deviceButton;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *deviceValue;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (nonatomic)CellType cellType;
@property (weak,nonatomic)id<CommonCellDelegate> delegate;
@property (nonatomic)Device *device;
@property (nonatomic)UIColor *color;
-(void)setUpClientCell;
-(void)setUPSensorCell;

@end
