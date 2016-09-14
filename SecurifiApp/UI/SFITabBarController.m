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
#import "DashboardViewController.h"
#import "HelpCenter.h"
#import "MoreViewController.h"
#import "AlmondUpdateViewController.h"

#define TAB_BAR_DEVICES @"Devices"
#define TAB_BAR_ROUTER @"WiFi"
#define TAB_BAR_SCENES @"Scenes"
#define TAB_BAR_RULES @"Rules"
#define TAB_BAR_DASHBOARD @"Dashboard"
#define TAB_BAR_HELPCENTER @"HelpCenter"
#define TAB_BAR_MORE @"More"
#define TAB_BAR_UPDATE @"Update"

typedef NS_ENUM(int, TabBarMode) {
    TabBarMode_cloud = 1,
    TabBarMode_local,
    TabBarMode_noAlmond,
    TabBarMode_updateAvailable
};

@interface SFITabBarController () <MessageViewDelegate>
@property(nonatomic) TabBarMode currentTabs;
@property(nonatomic) UIViewController *messageTab;
@property(nonatomic) UIViewController *sensorTab;
@property(nonatomic) UIViewController *routerTab;
@property(nonatomic) UIViewController *scenesTab;
@property(nonatomic) UIViewController *rulesTab;
@property(nonatomic) UIViewController *dashboardTab;
@property(nonatomic) UIViewController *helpTab;
@property(nonatomic) UIViewController *moreTab;
@property(nonatomic) UIViewController *updateTab;

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
    [center addObserver:self selector:@selector(onUpdateAvailableCrossTap:) name:kSFIDidTapUpdateAvailCrossBtn object:nil];
    
    [center addObserver:self selector:@selector(onLoginPage:) name:LOGIN_PAGE_NOTIFIER object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"tabbar view will appear");
//    self.selectedIndex = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isBeingDismissed || self.isMovingFromParentViewController) {
        self.isDismissed = YES;
    }
}

- (void)onLoginPage:(id)sender{
    //to set dashboard as default tab after login.
    self.selectedIndex = 0;
}

//have a look at it.
- (void)onUpdateAvailableCrossTap:(NSNotification *)sender{
    [self setTabBar:TabBarMode_cloud];//because local will never show update screen.
}

- (void)onTryChangeTabs:(NSNotification *)sender {
    enum TabBarMode mode = [self pickTabMode];
    [self setTabBar:mode];
}


- (void)setTabBar:(TabBarMode)mode{
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
    
    //for non compatible older firmwares.
    BOOL isFirmwareCompatible = [self checkIfFirmwareIsCompatible];
    if(isFirmwareCompatible == NO){
        return TabBarMode_updateAvailable;
    }
    
    NSArray *list = [toolkit almondList];
    if (list.count == 0) {
        list = [toolkit localLinkedAlmondList];
    }
    
    if (list.count == 0) {
//        return TabBarMode_noAlmond;
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


-(BOOL)checkIfFirmwareIsCompatible{
    SFIAlmondPlus *currentAlmond = [[SecurifiToolkit sharedInstance] currentAlmond];
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:currentAlmond.almondplusMAC];
    NSLog(@"current almond tab bar: %@", currentAlmond);
    //Ignoring the screen in local connection and when firmware is nil
    if(currentAlmond.firmware == nil || local){
        return YES;
    }
    return [currentAlmond supportsGenericIndexes:currentAlmond.firmware];
}

- (NSArray *)pickTabList:(TabBarMode)mode {
    switch (mode) {
        case TabBarMode_cloud:
            return [self tryAddScoreboardTab:[self cloudTabs]];
        case TabBarMode_local:
            return [self tryAddScoreboardTab:[self localTabs]];
        case TabBarMode_noAlmond:
            return [self tryAddScoreboardTab:[self noAlmondsTab]];
        case TabBarMode_updateAvailable:
            return [self tryAddScoreboardTab:[self updateFirmwareTab]];
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
                 self.routerTab,
                 self.moreTab
//                 self.rulesTab,
//                 self.helpTab
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
             self.routerTab,
             self.moreTab
//             self.rulesTab,
//             self.helpTab
             ];
}

// tabs to be show when no Almonds are affiliated with the account
- (NSArray *)noAlmondsTab {
    return @[
             self.messageTab
             ];
}

// tab to show when your almond firmware is old (not json compatible).
-(NSArray *)updateFirmwareTab{
    return @[self.updateTab];
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
        NSLog(@"sensortab");
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
        DashboardViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
        
        UIImage *icon = [UIImage imageNamed:@"icon_dashboard"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_DASHBOARD image:icon selectedImage:icon];
        self.dashboardTab = nav;
    }
    return _dashboardTab;
}

- (UIViewController *)helpTab {
    if (!_helpTab) {
        NSLog(@"helpTab");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
        HelpCenter *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"HelpCenter"];
        UIImage *icon = [UIImage imageNamed:@"help-icon"];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        ctrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_HELPCENTER image:icon selectedImage:icon];
        self.helpTab = ctrl;
    }
    return _helpTab;
}

- (UIViewController *)moreTab{
    if (!_moreTab) {
        NSLog(@"more Tab");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"More" bundle:nil];
        MoreViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"MoreViewController"];
        UIImage *icon = [UIImage imageNamed:@"more_horizontal_icon"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_MORE image:icon selectedImage:icon];
        self.moreTab = nav;
    }
    return _moreTab;
}

- (UIViewController *)messageTab {
    if (!_messageTab) {
        SFIMessageViewController *ctrl = [SFIMessageViewController new];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil selectedImage:nil];
        
        self.messageTab = nav;
    }
    return _messageTab;
}

- (UIViewController *)updateTab {
    if (!_updateTab) {
        AlmondUpdateViewController *ctrl = [AlmondUpdateViewController new];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil selectedImage:nil];
        
        self.updateTab = nav;
    }
    return _updateTab;
}


#pragma mark - MessageViewDelegate methods

- (void)messageViewDidPressButton:(MessageView *)msgView {
    
}

@end