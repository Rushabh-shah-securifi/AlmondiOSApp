//
//  SFISensor.h
//  TestApp
//
//  Created by Priya Yerunkar on 16/08/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFISensor : NSObject
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) int sensorId;
@property(nonatomic, assign) int status;
@property(nonatomic, assign) int deviceType;
@property(nonatomic, assign) unsigned int valueCount;
@property(nonatomic, retain) NSMutableArray *knownValues;
@property(nonatomic, assign) BOOL isExpanded;
@property(nonatomic, retain) NSString *imageName;
@property(nonatomic, retain) NSString *mostImpValueName;
@property(nonatomic, assign) int mostImpValueIndex;
@property(nonatomic, assign) int stateIndex;
@end
