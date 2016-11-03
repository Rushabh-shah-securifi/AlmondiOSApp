//
//  NetworkStatusIcon.h
//  SecurifiApp
//
//  Created by Masood on 11/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFICloudStatusBarButtonItem.h"

@protocol NetworkStatusIconDelegate <NSObject>

-(void) changeColorOfNavigationItam;

@end

@interface NetworkStatusIcon : NSObject

+ (void) setDelegate :(id<NetworkStatusIconDelegate>) dashboard;

+ (void)markNetworkStatusIcon: (SFICloudStatusBarButtonItem*)button isDashBoard:(BOOL)value;

@end
