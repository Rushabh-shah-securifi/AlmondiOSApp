//
//  SFIDeviceListViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIDeviceListViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UITableView *tvDeviceList;

@property (nonatomic,retain) NSString *currentMAC;
@property (nonatomic, retain) NSMutableArray *deviceList;
@property (nonatomic, retain) NSMutableArray *deviceValueList;
@end
