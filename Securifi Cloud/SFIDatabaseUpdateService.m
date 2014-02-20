//
//  SFIDatabaseUpdateService.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 23/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDatabaseUpdateService.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SFIOfflineDataManager.h"
#import "SNLog.h"

@implementation SFIDatabaseUpdateService
+(void)startDatabaseUpdateService{
    //    SNFileLogger *logger = [[SNFileLogger alloc] init];
    //    [// [SNLog logManager] addLogStrategy:logger];
    
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    //    //TODO: Remove Later - to test
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(AlmondListResponseCallback:)
    //                                                 name:@"AlmondListResponseNotifier"
    //                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DeviceDataCloudResponseCallback:)
                                                    name:DEVICE_DATA_CLOUD_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DeviceValueListResponseCallback:)
                                                    name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListAddCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListDeleteCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];
}

+(void)stopDatabaseUpdateService{
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DEVICE_DATA_CLOUD_NOTIFIER
                                                     object:nil];
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                     object:nil];
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                     object:nil];
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                     object:nil];
}

//-(void)AlmondListResponseCallback:(id)sender
//{
//    // NSLog(@"In SERVICE: AlmondListResponseCallback");
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = (NSDictionary *)[notifier userInfo];
//
//    if(data !=nil){
//        // NSLog(@"Received Almond List response");
//
//        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
//        obj = (AlmondListResponse *)[data valueForKey:@"data"];
//
//        // NSLog(@"List size : %d",[obj.almondPlusMACList count]);
//    }
//
//}

+(void)DeviceDataCloudResponseCallback:(id)sender
{
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        // [SNLog Log:@"Method Name: %s Received DeviceDataCloudResponse", __PRETTY_FUNCTION__];
        
        DeviceListResponse *obj = [[DeviceListResponse alloc] init];
        obj = (DeviceListResponse *)[data valueForKey:@"data"];
        
        
        BOOL isSuccessful = obj.isSuccessful;
        if(isSuccessful){
            NSMutableArray *deviceList = obj.deviceList;
            NSString *currentMAC = obj.almondMAC;
            // [SNLog Log:@"Method Name: %s Update Offline Storage - Service", __PRETTY_FUNCTION__];
            //Update offline storage
            [SFIOfflineDataManager writeDeviceList:deviceList currentMAC:currentMAC];
            
            //Compare the list with device value list size and correct the list accordingly if any device was deleted
            //Read device value list from storage
            NSMutableArray *offlineDeviceValueList = [SFIOfflineDataManager readDeviceValueList:currentMAC];
            //Compare the size
            if([deviceList count] < [offlineDeviceValueList count]){
                // NSLog(@"Some device was deleted!");
                for(SFIDevice *currentDevice in deviceList){
                    //// [SNLog Log:@"Method Name: %s Cloud DeviceID: %d" , __PRETTY_FUNCTION__,currentDevice.deviceID];
                    for(SFIDeviceValue *offlineDeviceValue in offlineDeviceValueList){
                        //// [SNLog Log:@"Method Name: %s Mobile DeviceID: %d" , __PRETTY_FUNCTION__,offlineDeviceValue.deviceID];
                        if(currentDevice.deviceID == offlineDeviceValue.deviceID){
                            // [SNLog Log:@"Method Name: %s Device ID Match - Device Exists!" , __PRETTY_FUNCTION__];
                            offlineDeviceValue.isPresent = TRUE;
                            break;
                        }
                    }
                }
                
                //Delete from the device value list
                NSMutableArray *tempDeviceValueList = [[NSMutableArray alloc]init];
                for(SFIDeviceValue *offlineDeviceValue in offlineDeviceValueList){
                    if(offlineDeviceValue.isPresent){
                        //Add to new list
                        [tempDeviceValueList addObject:offlineDeviceValue];
                    }
                    
                }
                
                // [SNLog Log:@"Method Name: %s Size of new device value list: %d" , __PRETTY_FUNCTION__, [tempDeviceValueList count]];
                [SFIOfflineDataManager writeDeviceValueList:tempDeviceValueList currentMAC:currentMAC];
            }
            
        }
    }
}

+(void)DeviceValueListResponseCallback:(id)sender
{
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        // [SNLog Log:@"Method Name: %s Received DeviceValueListResponse", __PRETTY_FUNCTION__];
        
        DeviceValueResponse *obj = [[DeviceValueResponse alloc] init];
        obj = (DeviceValueResponse *)[data valueForKey:@"data"];
        
        
        //NSMutableArray *deviceValueList = obj.deviceValueList;
        NSString *currentMAC = obj.almondMAC;
        // [SNLog Log:@"Method Name: %s Update Offline Storage - Service", __PRETTY_FUNCTION__];
        //Match values and update the exact known value for the device
        
        NSMutableArray *cloudDeviceValueList;
        NSMutableArray *mobileDeviceValueList;
        NSMutableArray *mobileDeviceKnownValues;
        NSMutableArray *cloudDeviceKnownValues;
        
        cloudDeviceValueList = obj.deviceValueList;
        mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:currentMAC];
        
        if(mobileDeviceValueList!=nil)
        {
            BOOL isDeviceFound = FALSE;
            for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList){
                // [SNLog Log:@"Method Name: %s Mobile DeviceID: %d ", __PRETTY_FUNCTION__, currentMobileValue.deviceID];
                for(SFIDeviceValue *currentCloudValue in cloudDeviceValueList){
                    // [SNLog Log:@"Method Name: %s Cloud DeviceID:  %d ", __PRETTY_FUNCTION__, currentCloudValue.deviceID];
                    if(currentMobileValue.deviceID == currentCloudValue.deviceID){
                        isDeviceFound = TRUE;
                        currentCloudValue.isPresent = TRUE;
                        mobileDeviceKnownValues = currentMobileValue.knownValues;
                        cloudDeviceKnownValues = currentCloudValue.knownValues;
                        for(SFIDeviceKnownValues *currentMobileKnownValue in mobileDeviceKnownValues){
                            // [SNLog Log:@"Method Name: %s Mobile Device Known Value Index: %d " , __PRETTY_FUNCTION__, currentMobileKnownValue.index];
                            for(SFIDeviceKnownValues *currentCloudKnownValue in cloudDeviceKnownValues){
                                // [SNLog Log:@"Method Name: %s Cloud Device Known Value Index: %d " , __PRETTY_FUNCTION__, currentCloudKnownValue.index];
                                if(currentMobileKnownValue.index == currentCloudKnownValue.index){
                                    //Update Value
                                    // [SNLog Log:@"Method Name: %s BEFORE update => Cloud: %@  Mobile: %@", __PRETTY_FUNCTION__ , currentCloudKnownValue.value , currentMobileKnownValue.value];
                                    [currentMobileKnownValue setValue:currentCloudKnownValue.value];
                                    // [SNLog Log:@"Method Name: %s AFTER update => Cloud: %@  Mobile: %@" , __PRETTY_FUNCTION__, currentCloudKnownValue.value , currentMobileKnownValue.value];
                                    break;
                                }
                            }
                        }
                        [currentMobileValue setKnownValues:mobileDeviceKnownValues];
                    }
                }
            }
            
                if(!isDeviceFound){
                    // NSLog(@"SERVICE - New Value Added!");
                    //Traverse the list and add the new value to offline list
                     for(SFIDeviceValue *currentCloudValue in cloudDeviceValueList){
                         if(!currentCloudValue.isPresent){
                             [mobileDeviceValueList addObject:currentCloudValue];
                         }
                     }
                }
        }else{
            mobileDeviceValueList = cloudDeviceValueList;
        }
        
        //deviceValueList = mobileDeviceValueList;
        //Update offline storage
        [SFIOfflineDataManager writeDeviceValueList:mobileDeviceValueList currentMAC:currentMAC];
        
    }
}

+(void)DynamicAlmondListAddCallback:(id)sender
{
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        // [SNLog Log:@"Method Name: %s Received DynamicAlmondListAddCallback", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *)[data valueForKey:@"data"];
        
        if(obj.isSuccessful){
            // [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
            //Write Almond List offline - New list with added almond
            [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
        }
    }
}
    
    
    +(void)DynamicAlmondListDeleteCallback:(id)sender
    {
        // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *data = (NSDictionary *)[notifier userInfo];
        
        if(data !=nil){
            // [SNLog Log:@"Method Name: %s Received DynamicAlmondListDeleteCallback", __PRETTY_FUNCTION__];
            
            AlmondListResponse *obj = [[AlmondListResponse alloc] init];
            obj = (AlmondListResponse *)[data valueForKey:@"data"];
    
            if(obj.isSuccessful){
                
                // [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
                NSMutableArray *offlineAlmondList = [SFIOfflineDataManager readAlmondList];
                NSMutableArray *deletedAlmondList = obj.almondPlusMACList;
                NSMutableArray *newAlmondList = [[NSMutableArray alloc]init];
                SFIAlmondPlus *deletedAlmond = [deletedAlmondList objectAtIndex:0];
                //Update Almond List
                for(SFIAlmondPlus *currentOfflineAlmond in offlineAlmondList){
                    if(![currentOfflineAlmond.almondplusMAC isEqualToString:deletedAlmond.almondplusMAC]){
                        //Add the current Almond from list except the deleted one
                        [newAlmondList addObject:currentOfflineAlmond];
                    }
                }
                // [SNLog Log:@"Method Name: %s Offline List size : %d New List size : %d", __PRETTY_FUNCTION__,[offlineAlmondList count], [newAlmondList count]];
                [SFIOfflineDataManager writeAlmondList:newAlmondList];
                
                //Update Hash List
                [SFIOfflineDataManager deleteHashForAlmond:deletedAlmond.almondplusMAC];
                
                //Update Device List
                [SFIOfflineDataManager deleteDeviceDataForAlmond:deletedAlmond.almondplusMAC];
                
                //Update Device Value List
                [SFIOfflineDataManager deleteDeviceValueForAlmond:deletedAlmond.almondplusMAC];
            }
            
        }
    }
    @end
