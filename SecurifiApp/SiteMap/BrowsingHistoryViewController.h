//
//  BrowsingHistoryViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowsingHistory.h"
@interface BrowsingHistoryViewController : UIViewController
@property (nonatomic) NSArray *browsingHistoryDayWise;
@property (nonatomic) BrowsingHistory *browsingHistoryObj;
@property (nonatomic) Client *client;
@property (nonatomic) BOOL is_IotType;
@end
