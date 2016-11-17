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
#import "LocalNetworkManagement.h"

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
                [networkStatusIconDelegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [statusButton markState:SFICloudStatusStateConnecting];
            if(isDashBoard)
                [networkStatusIconDelegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [statusButton markState:state];
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            if(isDashBoard)
                [networkStatusIconDelegate changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            if(isDashBoard)
                [networkStatusIconDelegate changeColorOfNavigationItam];
            [statusButton markState:state];
            break;
        }
    }
}

-(void) onConnectionStatusButtonPressed {
    NSString *Title;
    NSString *subTitle1, *subTitle2;
    SFIAlmondConnectionMode mode1, mode2;
    BOOL presentLocalNetworkSettings;
    SecurifiToolkit* toolKit = [SecurifiToolkit sharedInstance];
    
    if([ConnectionStatus getConnectionStatus]==AUTHENTICATED){
        if([toolKit currentConnectionMode] == SFIAlmondConnectionMode_cloud){
            SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:toolKit.currentAlmond.almondplusMAC];
            if (settings){
                Title = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
                mode1 = SFIAlmondConnectionMode_local;
            }else{
                Title = NSLocalizedString(@"alert msg offline Local connection not supported.", @"Local connection settings are missing.");
                subTitle1 = NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings");
                presentLocalNetworkSettings = YES;
                mode1 = SFIAlmondConnectionMode_local;
            }
        }else{
            Title = NSLocalizedString(@"alert.message-Connected to your Almond via local.", @"Connected to your Almond via local.");
            subTitle1 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            mode1 = SFIAlmondConnectionMode_cloud;
        }
    }else if([ConnectionStatus getConnectionStatus]==NO_NETWORK_CONNECTION || [ConnectionStatus getConnectionStatus] == IS_CONNECTING_TO_NETWORK){
        if([toolKit currentConnectionMode] == SFIAlmondConnectionMode_cloud){
            Title = NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection.");
            subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
            subTitle2 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            mode1 = SFIAlmondConnectionMode_local;
            mode2 = SFIAlmondConnectionMode_cloud;
        }else{
            Title = NSLocalizedString(@"local_conn_failed_retry", "Local connection to your Almond failed. Tap retry or switch to cloud connection.");
            subTitle1 = NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection");
            subTitle2 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            mode1 = SFIAlmondConnectionMode_local;
            mode2 = SFIAlmondConnectionMode_cloud;
        }
    }
    
    [networkStatusIconDelegate showNetworkTogglePopUp:Title withSubTitle1:subTitle1 withSubTitle2:subTitle2 withMode1:mode1 withMode2:mode2 presentLocalNetworkSettingsEditor:presentLocalNetworkSettings];
}

@end
