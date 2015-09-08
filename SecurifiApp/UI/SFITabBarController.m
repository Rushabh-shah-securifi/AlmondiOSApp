//
// Created by Matthew Sinclair-Day on 8/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFITabBarController.h"
#import "SFISensorsViewController.h"
#import "SFIRouterTableViewController.h"
#import "SFIScenesTableViewController.h"
#import "ScoreboardViewController.h"

#define TAB_BAR_SENSORS @"Sensors"
#define TAB_BAR_ROUTER @"Router"
#define TAB_BAR_SCENES @"Scenes"

typedef NS_ENUM(int, TabBarMode) {
    TabBarMode_cloud = 1,
    TabBarMode_local,
    TabBarMode_noAlmond
};

@interface SFITabBarController ()
@property(nonatomic) TabBarMode currentTabs;
@property(nonatomic) UIViewController *sensorTab;
@property(nonatomic) UIViewController *routerTab;
@property(nonatomic) UIViewController *scenesTab;
@property(nonatomic) UIViewController *scoreboardTab;
@end

@implementation SFITabBarController

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

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)onTryChangeTabs:(NSNotification *)sender {
    enum TabBarMode mode = [self pickTabMode];
    dispatch_async(dispatch_get_main_queue(), ^() {
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
                [self sensorTab],
                [self scenesTab],
                [self routerTab],
        ];
    }
    else {
        return @[
                [self sensorTab],
                [self routerTab],
        ];
    }
}

// tabs to be show when an Almond is using local connection
- (NSArray *)localTabs {
    return @[
            [self sensorTab],
            [self routerTab],
    ];
}

// tabs to be show when no Almonds are affiliated with the account
- (NSArray *)noAlmondsTab {
    return @[
            [self sensorTab],
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
        SFISensorsViewController *ctrl = [SFISensorsViewController new];
        UIImage *icon = [UIImage imageNamed:@"icon_sensor"];

        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctrl];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_SENSORS image:icon selectedImage:icon];

        self.sensorTab = nav;
    }
    return _sensorTab;
}


@end