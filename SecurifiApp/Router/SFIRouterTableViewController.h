//
//  SFIRouterTopTableViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFITableViewController.h"

typedef NS_ENUM(NSInteger, RouterCmdType){
    RouterCmdType_RouterSummaryReq = 1,
    RouterCmdType_GetWirelessSettingReq,
    RouterCmdType_SetWireLessSettingReq,
    RouterCmdType_UpdateFirmware,
    RouterCmdType_RebootReq,
    RouterCmdType_SendLogsReq,
};

@interface SFIRouterTableViewController : SFITableViewController

@end
