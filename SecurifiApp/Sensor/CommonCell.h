//
//  CommonCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 10/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, CellType) {
    SensorTable_Cell,
    ClientTable_Cell,
    SensorEdit_Cell,
    ClientEdit_Cell,
    ClientEditProperties_cell
    
};
@protocol CommonCellDelegate <NSObject>
-(void)delegateSensorTable;
-(void)delegateClientEditTable;

@end
@interface CommonCell : UIView
@property (weak, nonatomic) IBOutlet UIButton *deviceButton;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *deviceValue;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (nonatomic)CellType cellType;
@property (nonatomic)id<CommonCellDelegate> delegate;
-(void)setUpClientCell;

@end
