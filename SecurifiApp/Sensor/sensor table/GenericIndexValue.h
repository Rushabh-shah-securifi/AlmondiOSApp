//
//  GenericIndexValue.h
//  SecurifiToolkit
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexClass.h"
#import "GenericValue.h"

@interface GenericIndexValue : UIViewController
@property (nonatomic)GenericIndexClass *genericIndex;
@property (nonatomic)GenericValue *genericValue;
@property (nonatomic)int index;
@property (nonatomic)int deviceID;
@property (nonatomic)NSString* eventType;

-(id)initWithGenericIndex:(GenericIndexClass*)genericIndex genericValue:(GenericValue*)genericValue index:(int)index deviceID:(int)deviceID;
@end
