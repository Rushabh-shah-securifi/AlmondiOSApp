//
//  ClientPropertiesViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericParams.h"

@interface ClientPropertiesViewController : UIViewController
@property(nonatomic)NSDictionary *connectedDevice;
@property(nonatomic)NSMutableArray *indexArray;
@property(nonatomic)NSDictionary *clientProperties;

@property (nonatomic)GenericParams *genericParams;

@end
