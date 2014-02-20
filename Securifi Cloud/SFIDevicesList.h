//
//  SFIConnectedDevices.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDevicesList : NSObject
@property unsigned int deviceCount;
@property (nonatomic,retain) NSArray *deviceList;
@end
