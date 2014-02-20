//
//  SFIDatabaseUpdateService.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 23/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDatabaseUpdateService : NSObject
+(void)startDatabaseUpdateService;
+(void)stopDatabaseUpdateService;
@end
