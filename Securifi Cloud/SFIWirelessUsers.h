//
//  SFIWirelessUsers.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 03/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIWirelessUsers : NSObject
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* deviceIP;
@property (nonatomic, retain) NSString* deviceMAC;
@property (nonatomic, retain) NSString* manufacturer;
@property BOOL isBlocked;
@property BOOL isSelected;
@end
