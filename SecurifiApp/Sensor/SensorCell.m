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
#import "GenericIndexUtil.h"

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

-(void) setCellInfo{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSString *genericIndex = [GenericIndexUtil getHeaderGenericIndexForDevice:self.device];
    NSLog(@"cell genericindex: %@", genericIndex);
    NSDictionary *genericIndexDict = toolkit.genericIndexesJson[genericIndex];
//    NSLog(@"cell generic index dict: %@", genericIndexDict);
    NSString *value = [Device getValueForGenericIndex:genericIndex forDevice:self.device];
    NSLog(@"value: %@", value);
    self.deviceImage.image = [UIImage imageNamed:[GenericIndexUtil getIconImageFromGenericIndexDic:genericIndexDict forValue:value]];
    self.deviceNameLable.text = self.device.name;
    self.deviceStatusLabel.text = [GenericIndexUtil getLabelValueFromGenericIndexDict:genericIndexDict forValue:value];
    NSLog(@"imagen name: %@, label: %@", [GenericIndexUtil getIconImageFromGenericIndexDic:genericIndexDict forValue:value],[GenericIndexUtil getLabelValueFromGenericIndexDict:genericIndexDict forValue:value] );
    
}

-(NSDictionary*)getDeviceStatus:(SFIDeviceKnownValues *)values{
    NSDictionary *deviceInfo = [NSDictionary new];
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    //for(NSDictionary *dict in toolKit.dataBaseManager ge)
    
    
    return deviceInfo;
}
- (IBAction)onSettingClicked:(id)sender {
    NSMutableArray *genericIndexes = [GenericIndexUtil getGenericIndexesForDevice:self.device];
    [self.delegate onSettingButtonClicked:self.device genericIndex:genericIndexes];
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
                                   @"Values" : @{@"true" :@{
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
