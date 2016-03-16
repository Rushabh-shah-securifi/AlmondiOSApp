//
//  SensorEditViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@interface SensorEditViewController : UIViewController
@property (nonatomic,strong)Device *device;
@property(nonatomic,strong)NSArray *genericIndexValues;

//wifi client edit properties
@property (nonatomic)NSString *indexName;
@property (nonatomic) NSDictionary *deviceDict;
@property (nonatomic) BOOL isSensor;

@end
