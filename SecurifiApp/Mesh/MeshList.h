//
//  MeshList.h
//  SecurifiApp
//
//  Created by Masood on 8/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondStatus : NSObject
@property (nonatomic)BOOL isConnected;
@property (nonatomic)BOOL isMaster;

@property (nonatomic)NSString *name;
@property (nonatomic)NSString *location;
@property (nonatomic)NSString *connecteVia;
@property (nonatomic)NSString *interface;
@property (nonatomic)NSString *signalStrength;
@property (nonatomic)NSString *ssid1;
@property (nonatomic)NSString *ssid2;

@property (nonatomic)NSArray *keyVals;
@end

@interface MeshList : NSObject
@property (nonatomic)NSArray *statusArray;
@property (nonatomic)NSString *commandMode;
@property (nonatomic)NSString *commandType;
@property (nonatomic)NSString *masterName;
@property (nonatomic)int mii;
@property (nonatomic)BOOL isSuccessful;
@property (nonatomic)int reason;

-(id)initWithMeshList:(NSDictionary *)meshList;
@end
