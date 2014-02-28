//
//  SFIRouterTopTableViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "SFIRouterSummary.h"
#import "MBProgressHUD.h"

@interface SFIRouterTableViewController : UITableViewController <UIActionSheetDelegate>
{
    //PY 301013 - Generic Command Request
    NSMutableData *genericData;
    NSString *genericString;
    MBProgressHUD               *HUD;
}

@property unsigned int mobileInternalIndex;
@property NSString *currentMAC;
@property (nonatomic, retain) NSMutableArray *listAvailableColors;
@property (nonatomic, retain) SFIRouterSummary *routerSummary;
@property BOOL isRebooting;

//PY 301013 - Generic Command Request
@property unsigned int expectedGenericDataLength,totalGenericDataReceivedLength, command;

- (IBAction)revealMenu:(id)sender;

@end
