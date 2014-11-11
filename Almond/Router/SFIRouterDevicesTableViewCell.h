//
//  SFIRouterDevicesTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"

@interface SFIRouterDevicesTableViewCell : SFICardTableViewCell

@property(nonatomic) BOOL blockedDevice;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *deviceIP;
@property(nonatomic) NSString *deviceMAC;

@end
