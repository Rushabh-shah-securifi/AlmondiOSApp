//
//  SFIOfflineDataManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIOfflineDataManager : NSObject
+(BOOL) writeAlmondList:(NSMutableArray*)arrayAlmondList;
+(NSMutableArray*) readAlmondList;

+(BOOL) writeHashList:(NSString*)strHashValue currentMAC:(NSString*)strCurrentMAC;
+(NSString*) readHashList:(NSString*)strCurrentMAC;

+(BOOL) writeDeviceList:(NSMutableArray *)deviceList currentMAC:(NSString*)strCurrentMAC;
+(NSMutableArray*) readDeviceList:(NSString*)strCurrentMAC;

+(BOOL) writeDeviceValueList:(NSMutableArray *)deviceValueList currentMAC:(NSString*)strCurrentMAC;
+(NSMutableArray*) readDeviceValueList:(NSString*)strCurrentMAC;
+(BOOL)deleteFile:(NSString*)fileName;

+(void) deleteHashForAlmond:(NSString*)strCurrentMAC;
+(void) deleteDeviceDataForAlmond:(NSString*)strCurrentMAC;
+(void) deleteDeviceValueForAlmond:(NSString*)strCurrentMAC;
@end
