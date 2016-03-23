//
//  DeviceTableViewCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 17/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceHeaderView.h"

@interface DeviceTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet DeviceHeaderView *commonView;
@end
