//
//  SFIAlmondListViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SFIAlmondListViewController : UITableViewController
{
 MBProgressHUD               *HUD;
}

@property (nonatomic, strong) IBOutlet UITableView *tvAlmondList;
@property (nonatomic, retain) NSMutableArray *almondList;


@property (nonatomic,retain) NSString *currentMAC;
@property (nonatomic,retain) NSString *offlineHash;
@property (nonatomic, retain) NSMutableArray *deviceList;
@property (nonatomic, retain) NSMutableArray *deviceValueList;
@end
