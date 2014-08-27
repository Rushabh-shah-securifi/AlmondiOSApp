//
//  SFIDeviceDetailViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "MBProgressHUD.h"

@interface SFIDeviceDetailViewController : UIViewController
{
     MBProgressHUD               *HUD;
}
@property BOOL doRefreshView;
@property SFIDeviceValue *deviceValue;
//@property SFIDeviceKnownValues *deviceKnownValues;
@property unsigned int  currentDeviceType;
@property NSString *currentDeviceName;
@property (nonatomic, strong) UILabel *lblDeviceName;
@property NSMutableArray *deviceKnownValues;

@property (nonatomic,retain) NSString *currentMAC;
@property NSString *currentDeviceID;
@property unsigned int currentIndexID;
@property NSString *currentValue;
@property unsigned int currentInternalIndex;
@end
