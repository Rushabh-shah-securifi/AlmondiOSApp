//
//  NetworkStatusIcon.m
//  SecurifiApp
//
//  Created by Masood on 11/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SecurifiToolkit.h"
#import "NetworkStatusIcon.h"
#import "ConnectionStatus.h"

@implementation NetworkStatusIcon

- (void)markNetworkStatusIcon: (SFICloudStatusBarButtonItem*)statusButton isDashBoard:(BOOL)isDashBoard{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    enum SFIAlmondConnectionMode connectionMode = [toolkit currentConnectionMode];
    enum SFIAlmondConnectionStatus status = [toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]];
    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [statusButton markState:state];
            if(isDashBoard)
                [_networkStatusIconDelegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [statusButton markState:SFICloudStatusStateConnecting];
            if(isDashBoard)
                [_networkStatusIconDelegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [statusButton markState:state];
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            if(isDashBoard)
                [_networkStatusIconDelegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            if(isDashBoard)
                [_networkStatusIconDelegate changeColorOfNavigationItam];
            [statusButton markState:state];
            break;
        }
    }
}


-(void) onConnectionStatusButtonPressed {
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    struct PopUpSuggestions data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    
    [_networkStatusIconDelegate showNetworkTogglePopUp:data.title withSubTitle1:data.subTitle1 withSubTitle2:data.subTitle2 withMode1:data.mode1 withMode2:data.mode2 presentLocalNetworkSettingsEditor:data.presentLocalNetworkSettings];
}

@end
