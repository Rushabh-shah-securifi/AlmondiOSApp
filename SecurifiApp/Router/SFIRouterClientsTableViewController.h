//
//  SFIRouterClientsTableViewController.h
//  Securifi Cloud
//
//  Created by Matthew Sinclair-Day on 2015/08/12
//  Copyright (c) 2015 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIRouterClientsTableViewController : UITableViewController

@property(nonatomic, copy) NSString *almondMac;
@property(nonatomic, copy) NSArray *wirelessSettings;
@property(nonatomic) BOOL enableRouterWirelessControl;

@end
