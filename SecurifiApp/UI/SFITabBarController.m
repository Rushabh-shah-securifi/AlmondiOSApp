//
// Created by Matthew Sinclair-Day on 8/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFITabBarController.h"
#import "SFIRouterTableViewController.h"
#import "SFIScenesTableViewController.h"
#import "ScoreboardViewController.h"
#import "MessageView.h"
#import "SFIMessageViewController.h"
#import "RulesTableViewController.h"
#import "DeviceListController.h"
#import "MainViewController.h"

#define TAB_BAR_DEVICES @"Devices"
#define TAB_BAR_ROUTER @"Router"
#define TAB_BAR_SCENES @"Scenes"
#define TAB_BAR_RULES @"Rules"
#define TAB_BAR_DASHBOARD @"Dashboard"

typedef NS_ENUM(int, TabBarMode) {
    TabBarMode_cloud = 1,
    TabBarMode_local,
    TabBarMode_noAlmond
};

@interface SFITabBarController () <MessageViewDelegate>
@property(nonatomic) TabBarMode currentTabs;
@property(nonatomic) UIViewController *messageTab;
@property(nonatomic) UIViewController *sensorTab;
@property(nonatomic) UIViewController *routerTab;
@property(nonatomic) UIViewController *scenesTab;
@property(nonatomic) UIViewController *rulesTab;
@property(nonatomic) UIViewController *dashboardTab;

@property(nonatomic) UIViewController *scoreboardTab;
@property(nonatomic) BOOL isDismissed;
@end

@implementation SFITabBarController

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // set up the tabs
    [self onTryChangeTabs:nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onTryChangeTabs:) name:kSFIDidChangeAlmondConnectionMode object:nil];
    [center addObserver:self selector:@selector(onTryChangeTabs:) name:kSFIDidChangeCurrentAlmond object:nil];
    [center addObserver:self selector:@selector(onTryChangeTabs:) name:kSFIDidUpdateAlmondList object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isBeingDismissed || self.isMovingFromParentViewController) {
        self.isDismissed = YES;
    }
}

- (void)onTryChangeTabs:(NSNotification *)sender {
    enum TabBarMode mode = [self pickTabMode];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.isDismissed) {
            return;
        }
        if (self.currentTabs == mode) {
            return;
        }
        
        NSArray *list = [self pickTabList:mode];
        self.currentTabs = mode;
        
        UIViewController *selected = self.selectedViewController;
        self.viewControllers = list;
        
        if (selected && [list containsObject:selected]) {
            self.selectedViewController = selected;
        }
    });
}

- (enum TabBarMode)pickTabMode {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSArray *list = [toolkit almondList];
    if (list.count == 0) {
        list = [toolkit localLinkedAlmondList];
    }
    
    if (list.count == 0) {
        return TabBarMode_noAlmond;
    }
    
    SFIAlmondPlus *plus = toolkit.currentAlmond;
    
    enum SFIAlmondConnectionMode mode = [toolkit connectionModeForAlmond:plus.almondplusMAC];
    switch (mode) {
        case SFIAlmondConnectionMode_cloud:
            return TabBarMode_cloud;
        case SFIAlmondConnectionMode_local:
            return TabBarMode_local;
        default:
            return TabBarMode_cloud;
    }
}

- (NSArray *)pickTabList:(TabBarMode)mode {
    switch (mode) {
        case TabBarMode_cloud:
            return [self tryAddScoreboardTab:[self cloudTabs]];
        case TabBarMode_local:
            return [self tryAddScoreboardTab:[self localTabs]];
        case TabBarMode_noAlmond:
            return [self tryAddScoreboardTab:[self noAlmondsTab]];
        default:
            return @[];
    }
}

- (NSArray *)tryAddScoreboardTab:(NSArray *)tabs {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    if (configurator.enableScoreboard) {
        UIViewController *scoreNav = [self scoreboardTab];
        return [tabs arrayByAddingObject:scoreNav];
    }
    else {
        return tabs;
    }
}

// tabs to be shown when an Almond is on cloud connection
- (NSArray *)cloudTabs {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    
    if (configurator.enableScenes) {
        return @[
                 self.dashboardTab,
                 self.sensorTab,
                 self.scenesTab,
                 self.rulesTab,
                 self.routerTab,
                 
                 ];
    }
    else {
        return @[
                 self.dashboardTab,
                 self.sensorTab,
                 self.routerTab,
                 self.rulesTab,
                 ];
    }
}

// tabs to be show when an Almond is using local connection
- (NSArray *)localTabs {
    return @[
             self.dashboardTab,
             self.sensorTab,
             self.scenesTab,
             self.rulesTab,
             self.routerTab,
             
             ];
}

// tabs to be show when no Almonds are affiliated with the account
- (NSArray *)noAlmondsTab {
    return @[
             self.messageTab
             ];
}

- (UIViewController *)scoreboardTab {
    if (!_scoreboardTab) {
        ScoreboardViewController *ctrl = [ScoreboardViewController new];
        UIImage *icon = [UIImage imageNamed:@"878-binoculars"];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Debug" image:icon selectedImage:icon];
        
        self.scoreboardTab = nav;
    }
    return _scoreboardTab;
}

- (UIViewController *)scenesTab {
    if (!_scenesTab) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
        SFIScenesTableViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"SFIScenesTableViewController"];
        UIImage *icon = [UIImage imageNamed:@"icon_scenes"];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_SCENES image:icon selectedImage:icon];
        
        self.scenesTab = nav;
    }
    return _scenesTab;
}

- (UIViewController *)rulesTab {
    if (!_rulesTab) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
        RulesTableViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"RulesTableViewController"];
        UIImage *icon = [UIImage imageNamed:@"icon_rules"];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_RULES image:icon selectedImage:icon];
        
        self.rulesTab = nav;
    }
    return _rulesTab;
}

- (UIViewController *)routerTab {
    if (!_routerTab) {
        SFIRouterTableViewController *ctrl = [SFIRouterTableViewController new];
        UIImage *icon = [UIImage imageNamed:@"icon_router"];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_ROUTER image:icon selectedImage:icon];
        
        self.routerTab = nav;
    }
    return _routerTab;
}

- (UIViewController *)sensorTab {
    if (!_sensorTab) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
        DeviceListController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"DeviceListController"];
        UIImage *icon = [UIImage imageNamed:@"icon_sensor"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_DEVICES image:icon selectedImage:icon];
        
        self.sensorTab = nav;
    }
    return _sensorTab;
}

- (UIViewController *)dashboardTab {
    if (!_dashboardTab) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainDashboard" bundle:nil];
        MainViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        UIImage *icon = [UIImage imageNamed:@"icon_dashboard"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_DASHBOARD image:icon selectedImage:icon];
        self.dashboardTab = nav;
    }
    return _dashboardTab;
}


- (UIViewController *)messageTab {
    if (!_messageTab) {
        SFIMessageViewController *ctrl = [SFIMessageViewController new];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:nil selectedImage:nil];
        
        self.messageTab = nav;
    }
    return _messageTab;
}


#pragma mark - MessageViewDelegate methods

- (void)messageViewDidPressButton:(MessageView *)msgView {
    
}

@end