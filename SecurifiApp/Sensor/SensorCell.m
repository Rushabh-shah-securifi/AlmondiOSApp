//
//  SensorCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorCell.h"
#import "Device.h"
#import "DeviceKnownValues.h"
#import "SensorEditViewController.h"

@implementation SensorCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSLog(@"reuseIdentifier");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}
- (void)awakeFromNib {
    // Initialization code
    NSLog(@"awake nib %@",self.device.deviceName);
    
    self.deviceNameLable.text = @"locked";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(NSMutableArray *)buildDeviceList{
    Device *device=[Device new];
    device.name=@"Test1";
    device.ID=1;
    device.type=1;
    device.location=@"location";
    
    DeviceKnownValues *value1= [DeviceKnownValues new];
    value1.index=1;
    value1.genericIndex=1;
    value1.value=@"true";
    
    device.knownValues=[NSMutableArray new];
    [device.knownValues addObject:value1];
    
    DeviceKnownValues *value2= [DeviceKnownValues new];
    value1.index=2;
    value1.genericIndex=2;
    value1.value=@"off";
    [device.knownValues addObject:value2];
    
    Device *device1=[Device new];
    device1.name=@"Test1";
    device1.ID=2;
    device1.type=2;
    device1.location=@"location";
    
    value1= [DeviceKnownValues new];
    value1.index=1;
    value1.genericIndex=3;
    value1.value=@"1";
    
    device1.knownValues=[NSMutableArray new];
    [device1.knownValues addObject:value1];
    
    
    NSMutableArray *deviceList=[NSMutableArray new];
    [deviceList addObject:device];
    [deviceList addObject:device1];
    
    return deviceList;
}

-(void) getCellInfo{
    NSArray *devices=[self buildDeviceList];
    NSArray *deviceIndex = [self deviceInfo];
    NSDictionary *indexDict = [deviceIndex objectAtIndex:0];
    NSDictionary *deviceDict = [deviceIndex objectAtIndex:1];
    
    NSDictionary *cellInfo = [NSMutableDictionary new];
    
    for(Device *device in devices ){
        NSDictionary *deviceMetaData= [deviceDict valueForKey: @(device.type).stringValue];
        NSArray *indexes=  [deviceMetaData valueForKey: @"indexes"];
        for(int i =0;i < indexes.count ; i++){
            NSString *genericIndex=[indexes objectAtIndex:i];
            
            
      
            
            NSDictionary *indexMetaData= [indexDict valueForKey: genericIndex];
            NSDictionary *indexValues=[indexMetaData valueForKey:@"Values"];
            
            
        }
    }
    
}
- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceState {
    return [self.deviceValue knownValuesForProperty:self.device.statePropertyType];
}
-(NSDictionary*)getDeviceStatus:(SFIDeviceKnownValues *)values{
    NSDictionary *deviceInfo = [NSDictionary new];
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    //for(NSDictionary *dict in toolKit.dataBaseManager ge)
    
    
    return deviceInfo;
}
- (IBAction)onSettingClicked:(id)sender {
    NSLog(@" setting");
    Device *device=[Device new];
    device.name=@"Test1";
    device.ID=1;
    device.type=1;
    device.location=@"location";
    DeviceKnownValues *value1= [DeviceKnownValues new];
    value1.index=1;
    value1.genericIndex=1;
    value1.value=@"true";
    
    device.knownValues=[NSMutableArray new];
    [device.knownValues addObject:value1];
    
    DeviceKnownValues *value2= [DeviceKnownValues new];
    value1.index=2;
    value1.genericIndex=2;
    value1.value=@"off";
    [device.knownValues addObject:value2];
    
    NSArray *genericIndexArray = [[NSArray alloc]initWithObjects:@"1",@"2",nil];
    
    [self.delegate onSettingButtonClicked:device genericIndex:genericIndexArray];

}
-(NSArray*)deviceInfo{
   
    NSDictionary *deviceIndex1 = @{
                                   @"IndexName": @"SWITCH BINARY",
                                   @"Values" : @{@"true" :@{
                                                         @"ToggleValue":      @"false",
                                                         @"Icon": @"switchon",
                                                         @"Label": @"ON"
                                                             },
                                                 @"false" :@{
                                                         @"ToggleValue":      @"true",
                                                         @"Icon": @"switchoff",
                                                         @"Label": @"OFF"
                                                         }
                                                    },
                                   
                                   };
    NSDictionary *deviceIndex2 = @{
                                   @"IndexName": @"SWITCH BINARY",
                                   @"Values" : @{@"on" :@{
                                                         @"ToggleValue":      @"false",
                                                         @"Icon": @"switchon",
                                                         @"Label": @"ON"
                                                         },
                                                 @"off" :@{
                                                         @"ToggleValue":      @"true",
                                                         @"Icon": @"switchoff",
                                                         @"Label": @"OFF"
                                                         }
                                                 },
                                   
                                   };
    NSDictionary *deviceIndex3 = @{
                                   @"IndexName": @"LOCK_STATE_ZB",
                                   @"Values" : @{@"1" :@{
                                                         @"ToggleValue":      @"2",
                                                         @"Icon": @"doorunlocked",
                                                         @"Label": @"UNLOCKED"
                                                         },
                                                 @"2" :@{
                                                         @"ToggleValue":      @"1",
                                                         @"Icon": @"doorlocked",
                                                         @"Label": @"LOCKED"
                                                         },
                                                 },
                                   
                                   };

    NSMutableDictionary *indexDict = [[NSMutableDictionary alloc]init];
    [indexDict setObject:deviceIndex1 forKey:@"1"];
    [indexDict setObject:deviceIndex2 forKey:@"2"];
    [indexDict setObject:deviceIndex3 forKey:@"3"];
    
    NSDictionary *device1 = @{@"deviceName" : @"binarySwitch",
                              @"indexes":@[@"1",@"2"],
                              
                              };
    NSDictionary *device2 = @{@"deviceName" : @"DoorLock",
                              @"indexes":@[@"3"],
                              
                              };
    NSMutableDictionary *deviceDict = [[NSMutableDictionary alloc]init];
    [deviceDict setObject:device1 forKey:@"1"];
    [deviceDict setObject:device2 forKey:@"2"];

    return @[indexDict,deviceDict];
}

@end
