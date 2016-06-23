//
//  DashboardViewController.h
//  Dashbord
//
//  Created by Securifi Support on 03/05/16.
//  Copyright © 2016 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFITabBarController.h"

@interface DashboardViewController : UIViewController<UITableViewDataSource , UITableViewDelegate>{
    IBOutlet UIScrollView *Scroller;
}
//@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImage;
//@property (strong, nonatomic) IBOutlet UIButton *notificationImage;

//- (IBAction)cloudAction:(id)sender;
//- (IBAction)notificationAction:(id)sender;
//- (IBAction)settingsAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *labelAlmond;
@property (strong, nonatomic) IBOutlet UILabel *labelAlmondStatus;

- (IBAction)homeMode:(id)sender;
- (IBAction)homeawayMode:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *buttonHome;
@property (strong, nonatomic) IBOutlet UIButton *buttonHomeAway;
@property (strong, nonatomic) IBOutlet UITableView *dashboardTable;

@property (strong, nonatomic) IBOutlet UILabel *labelHome;
@property (strong, nonatomic) IBOutlet UILabel *labelHomeAway;

@property (strong, nonatomic) IBOutlet UILabel *totalConnectedDevices;
@property (strong, nonatomic) IBOutlet UILabel *smartHomeConnectedDevices;
@property (strong, nonatomic) IBOutlet UILabel *networkConnectedDevices;

- (IBAction)AlmondSelection:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *AddAlmond;

@property(nonatomic, readonly) BOOL enableNotificationsView;
@property(nonatomic, readonly) BOOL enableNotificationsHomeAwayMode;

@end
