//
//  PerformanceTest.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "PerformanceTest.h"
#import "Device.h"

@implementation PerformanceTest

+(void)startTest{
    [self dictTest];
    [self objTest];
}
+ (void)dictTest{
    NSDictionary *dynamicDeviceAdded =@{     @"Name":@"ContactSwitch #1",
                                             @"FriendlyDeviceType":@"ContactSwitch",
                                             @"Type":@"12",
                                             @"Location":@"Default",
                                             @"DeviceValues":@"Vlues",
                                             @"Name1":@"ContactSwitch #1",
                                             @"FriendlyDeviceType1":@"ContactSwitch",
                                             @"Type1":@"12",
                                             @"Location1":@"Default",
                                             @"DeviceVa1lues":@"Vlues",
                                             @"Device":@{
                                                     @"3":@{
                                                             @"Name":@"ContactSwitch #1",
                                                             @"FriendlyDeviceType":@"ContactSwitch",
                                                             @"Type":@"12",
                                                             @"Location":@"Default",
                                                             @"DeviceValues":@{
                                                                     @"1":@{
                                                                             @"Name":@"STATE",
                                                                             @"Value":@"true"
                                                                             },
                                                                     @"2":@{
                                                                             @"Name":@"LOW BATTERY",
                                                                             @"Value":@"0"
                                                                             },
                                                                     @"3":@{
                                                                             @"Name":@"TAMPER",
                                                                             @"Value":@"true"
                                                                             }
                                                                     }
                                                             },
                                                     @"4":@{
                                                             @"Name":@"BinarySwitch #2",
                                                             @"FriendlyDeviceType":@"BinarySwitch",
                                                             @"Type":@"1",
                                                             @"Location":@"Default",
                                                             @"DeviceValues":@{
                                                                     @"1":@{
                                                                             @"Name":@"SWITCH BINARY",
                                                                             @"Value":@"true"
                                                                             }
                                                                     }
                                                             }
                                                     
                                                         }
                                             };
    
    
    [self timeDictTest:dynamicDeviceAdded];
}

+ (void)objTest{
    Device *device = [[Device alloc]init];
    device.name = @"ContactSwitch #1";
    device.type = 7;
    device.ID = 2;
    [self timeObjectTest:device];
}
+ (void)timeDictTest:(NSDictionary*)deviceDict{
    CFTimeInterval start = CACurrentMediaTime();
    deviceDict[@"Name"];
    deviceDict[@"DeviceVa1lues"];
    deviceDict[@"Location1"];
    deviceDict[@"Location"];
    deviceDict[@"Name"];
    deviceDict[@"Type"];
    deviceDict[@"FriendlyDeviceType"];
    deviceDict[@"DeviceVa1lues"];
    deviceDict[@"Type"];
    deviceDict[@"Type"];
    [[deviceDict[@"Device"]valueForKey:@"3"] valueForKey:@"Name"];
    
    float endTime = CACurrentMediaTime() - start;
    NSLog(@" dict time diff %.8f ",endTime);
    //1 access - dict time diff 0.00000292 ~5times
    // 4 access - dict time diff 0.00000375 ~3 times
    //10 access - dict time diff 0.00000495 ~3 times
    //10 name - 0.00000352 ~3times
    //10 name - 0.00000270
}
+(void)timeObjectTest:(Device *)device{
    CFTimeInterval start = CACurrentMediaTime();
    device.name;
    device.name;
    device.name;
    device.name;
    device.name;
    device.type;
    device.type;
    device.type;
    device.type;
    device.type;
    
    float endTime = CACurrentMediaTime() - start;
    NSLog(@" object time diff %.8f ",endTime);
    //1name, 1 access - dict time diff 0.00000080
    //1name 3 type, 4 access - object time diff 0.00000136
    //7type, 3 name - 10 access - dict time diff 0.00000164
    //10 name - 0.00000126
    //10 name - 0.00000153
}

//5name, 5type
//dict time diff 0.00000171
//2016-04-07 12:18:39.100 Almond[5007:19532]  object time diff 0.00001863

//dict time diff 0.00000118
//2016-04-07 12:19:48.830 Almond[5414:20984]  object time diff 0.00000166

//dict time diff 0.00000208
//2016-04-07 12:20:57.363 Almond[5812:22153]  object time diff 0.00000179

//2016-04-07 12:21:40.941 Almond[6220:23369]  dict time diff 0.00000121
//2016-04-07 12:21:40.941 Almond[6220:23369]  object time diff 0.00002270

//2016-04-07 12:22:44.218 Almond[6621:24495]  dict time diff 0.00000198
//2016-04-07 12:22:44.218 Almond[6621:24495]  object time diff 0.00000175
@end