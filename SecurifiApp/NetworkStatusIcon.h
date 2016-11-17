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

-(void) showNetworkTogglePopUp:(NSString*)title withSubTitle1:(NSString*)subTitle1 withSubTitle2:(NSString*)subTitle2 withMode1:(SFIAlmondConnectionMode)mode1 withMode2:(SFIAlmondConnectionMode)mode2 presentLocalNetworkSettingsEditor:(BOOL)present;
@end

@interface NetworkStatusIcon : NSObject

@property id<NetworkStatusIconDelegate> networkStatusIconDelegate;

- (void) onConnectionStatusButtonPressed;

- (void)markNetworkStatusIcon: (SFICloudStatusBarButtonItem*)button isDashBoard:(BOOL)value;

@end
