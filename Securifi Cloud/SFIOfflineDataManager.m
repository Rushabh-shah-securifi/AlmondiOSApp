//
//  SFIOfflineDataManager.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIOfflineDataManager.h"
#import "AlmondPlusConstants.h"
#import "SNLog.h"

@implementation SFIOfflineDataManager
//Write AlmondList for the current user to offline storage
+(BOOL) writeAlmondList:(NSMutableArray*)arrayAlmondList{
//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [// [SNLog logManager] addLogStrategy:logger];
    // [SNLog Log:@"Method Name: %s Write to file! Almond List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:ALMONDLIST_FILENAME];
    
    NSArray *arAlmondList = [arrayAlmondList copy];
    BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:arAlmondList toFile:filePath];
   // BOOL didWriteSuccessful = [arAlmondList writeToFile:filePath atomically:YES];
    return didWriteSuccessful;
}

//Read AlmondList for the current user from offline storage
+(NSMutableArray*) readAlmondList{
//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [// [SNLog logManager] addLogStrategy:logger];
    // [SNLog Log:@"Method Name: %s Read from file! Almond List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:ALMONDLIST_FILENAME];
    
    //NSArray * arAlmondList = [NSArray arrayWithContentsOfFile:filePath];
    NSArray * arAlmondList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    // [SNLog Log:@"Method Name: %s Almond List: Size: %d", __PRETTY_FUNCTION__,[arAlmondList count]];
    return [NSMutableArray arrayWithArray:arAlmondList];
}

//Write HashList for the current user to offline storage
+(BOOL) writeHashList:(NSString*)strHashValue currentMAC:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Write to file! Hash List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:HASH_FILENAME];
    
    NSDictionary *dictHashList = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if(dictHashList == nil){
        // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
        dictHashList = [[NSDictionary alloc]init];
    }
    NSMutableDictionary *mutableDictHashList = [NSMutableDictionary dictionary];
    [mutableDictHashList setValue:strHashValue forKey:strCurrentMAC];
    dictHashList = [mutableDictHashList copy];
    //Write
    BOOL didWriteSuccessful = [dictHashList writeToFile:filePath atomically:YES];
    return didWriteSuccessful;
}

//Read HashList for the current user from offline storage
+(NSString*) readHashList:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Read from file! Hash List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:HASH_FILENAME];
    
    NSDictionary *dictHashList = [NSDictionary dictionaryWithContentsOfFile:filePath];
    //Read the current almond's device list from the hashmap
    NSString *strHashValue = [dictHashList valueForKey:strCurrentMAC];
    return strHashValue;
}

//Delete HashList for the deleted almond from offline storage
+(void) deleteHashForAlmond:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Read from file! Delete Almond Hash", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:HASH_FILENAME];
    
    //Remove current hash from the dictionary
     NSMutableDictionary *mutableDictHashList = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
    [mutableDictHashList removeObjectForKey:strCurrentMAC];
    NSDictionary *dictHashList = [mutableDictHashList copy];
    [dictHashList writeToFile:filePath atomically:YES];
}

//Write Device List for the current MAC to offline storage
+(BOOL) writeDeviceList:(NSMutableArray *)deviceList currentMAC:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Write to file! Device List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICELIST_FILENAME];
    
    //Read the entire dictionary from the list
    NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if(dictDeviceList == nil){
        // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
        dictDeviceList = [[NSMutableDictionary alloc]init];
    }
    [dictDeviceList setObject:deviceList forKey:strCurrentMAC];
    //Create NSDictionary for List and AlmondPlusMAC
    BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictDeviceList toFile:filePath];
    return didWriteSuccessful;
}

//Read DeviceList for the current MAC from offline storage
+(NSMutableArray*) readDeviceList:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Read from file! Device List", __PRETTY_FUNCTION__];
    NSMutableArray *deviceList = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICELIST_FILENAME];
    
    NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    //Read the current almond's device list from the hashmap
    if(dictDeviceList!=nil){
        deviceList = [dictDeviceList valueForKey:strCurrentMAC];
    }
    return deviceList;
}

//Delete DeviceList for the deleted almond from offline storage
+(void) deleteDeviceDataForAlmond:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Read from file! Delete Almond Device List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICELIST_FILENAME];
    
    NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    //Remove the current almond's device list from the hashmap
    [dictDeviceList removeObjectForKey:strCurrentMAC];
   [NSKeyedArchiver archiveRootObject:dictDeviceList toFile:filePath];
}


//Write DeviceValueList for the current MAC to offline storage
+(BOOL) writeDeviceValueList:(NSMutableArray *)deviceValueList currentMAC:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Write to file! Device Value List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICEVALUE_FILENAME];
    
    //Read the entire dictionary from the list
    NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if(dictDeviceValueList == nil){
        // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
        dictDeviceValueList = [[NSMutableDictionary alloc]init];
    }
    [dictDeviceValueList setObject:deviceValueList forKey:strCurrentMAC];
    //Create NSDictionary for List and AlmondPlusMAC
    BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictDeviceValueList toFile:filePath];
    return didWriteSuccessful;
}

//Read DeviceValueList for the current MAC from offline storage
+(NSMutableArray*) readDeviceValueList:(NSString*)strCurrentMAC{
   // [SNLog Log:@"Method Name: %s Read from file! Device Value List", __PRETTY_FUNCTION__];
    NSMutableArray *deviceValueList = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICEVALUE_FILENAME];
    
    NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    //Read the current almond's device list from the hashmap
    if(dictDeviceValueList!=nil){
        deviceValueList = [dictDeviceValueList valueForKey:strCurrentMAC];
    }
    return deviceValueList;
}

//Delete DeviceValueList for the deleted almond from offline storage
+(void) deleteDeviceValueForAlmond:(NSString*)strCurrentMAC{
    // [SNLog Log:@"Method Name: %s Read from file! Delete Almond Device Value List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICEVALUE_FILENAME];
    
    NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    //Remove the current almond's device list from the hashmap
    [dictDeviceValueList removeObjectForKey:strCurrentMAC];
    [NSKeyedArchiver archiveRootObject:dictDeviceValueList toFile:filePath];
}

+(BOOL)deleteFile:(NSString*)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    return success;
}
@end
