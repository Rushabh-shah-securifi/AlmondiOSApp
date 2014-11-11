//
//  SFIWirelessUsers.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 03/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIWirelessUsers : NSObject
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *deviceIP;
@property(nonatomic) NSString *deviceMAC;
@property(nonatomic) NSString *manufacturer;
@property(nonatomic) BOOL isBlocked;
@property(nonatomic) BOOL isSelected;
@end
