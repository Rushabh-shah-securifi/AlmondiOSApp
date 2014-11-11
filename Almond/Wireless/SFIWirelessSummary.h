//
//  SFIWirelessSummary.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIWirelessSummary : NSObject

@property(nonatomic) int wirelessIndex;
@property(nonatomic) BOOL enabled;
@property(nonatomic) NSString *ssid;

@end
