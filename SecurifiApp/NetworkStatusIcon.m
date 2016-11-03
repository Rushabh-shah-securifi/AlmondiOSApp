//
//  NetworkStatusIcon.m
//  SecurifiApp
//
//  Created by Masood on 11/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "NetworkStatusIcon.h"
#import "ConnectionStatus.h"
#import "DashboardViewController.h"

@implementation NetworkStatusIcon

id<NetworkStatusIconDelegate> delegate;

+(void) setDelegate :(id<NetworkStatusIconDelegate>) dashboard{
    delegate = dashboard;
}

+ (void)markNetworkStatusIcon: (SFICloudStatusBarButtonItem*)statusButton isDashBoard:(BOOL)value{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    enum SFIAlmondConnectionMode connectionMode = [toolkit currentConnectionMode];
    enum SFIAlmondConnectionStatus status = [toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]];
    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [statusButton markState:state];
            [delegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [statusButton markState:SFICloudStatusStateConnecting];
            [delegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [statusButton markState:state];
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            [delegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            [delegate changeColorOfNavigationItam];
            [statusButton markState:state];
            break;
        }
    }
}

@end
