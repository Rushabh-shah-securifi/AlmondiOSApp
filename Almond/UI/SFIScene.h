//
//  SFIScene.h
//  SecurifiUI
//
//  Created by Priya Yerunkar on 09/10/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIColors.h"

@interface SFIScene : NSObject
@property (nonatomic, retain) NSString   *name;
@property BOOL isExpanded;
@property BOOL isActivated;
@property (nonatomic, retain) NSString   *sensorCount;
@property (nonatomic, retain) SFIColors *sceneColor;
@end
