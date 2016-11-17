//
//  DrawerViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "DrawerViewController.h"
#import "AlmondPlusConstants.h"
#import "SWRevealViewController.h"
#import "UIFont+Securifi.h"
#import "SFICloudLinkViewController.h"
#import "RouterNetworkSettingsEditor.h"

#define SEC_ALMOND_LIST     @"AlmondList"
#define SEC_SETTINGS_LIST   @"Settings"
#define SEC_VERSION         @"Version"

@interface DrawerViewController () <RouterNetworkSettingsEditorDelegate>
@property(nonatomic, strong, readonly) NSDictionary *dataDictionary;
@end

@implementation DrawerViewController

#pragma mark - View Cycle

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView.backgroundColor = [self headerBackgroundColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidUpdateAlmondList object:nil];
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidChangeAlmondName object:nil];
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidLogoutNotification object:nil];
//    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidLogoutAllNotification object:nil];
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidChangeAlmondConnectionMode object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetAlmondList];
    [self.tableView reloadData];
}

- (void)onAlmondListDidChange:(id)notice {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self resetAlmondList];
        [self.tableView reloadData];
    });
}

- (void)resetAlmondList {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSLog(@"i am called");
    enum SFIAlmondConnectionMode mode = [toolkit currentConnectionMode];

    NSArray *almondList = [self buildAlmondList:mode];

    NSArray *settingsList = @[
            NSLocalizedString(@"Drawviewcontroller.account",@"Account"),
            NSLocalizedString(@"Drawviewcontroller.Logout","uitloggen"),
            NSLocalizedString(@"Drawviewcontroller.Logout All","logout alle";)
    ];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *shortVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [bundle objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
    NSString *version = [NSString stringWithFormat:NSLocalizedString(@"read-almond-version %@ (%@)",@"version %@ (%@)"), shortVersion, buildNumber];

    if (mode == SFIAlmondConnectionMode_cloud) {
        _dataDictionary = @{
                SEC_ALMOND_LIST : almondList,
                SEC_SETTINGS_LIST : settingsList,
                SEC_VERSION : @[version],
        };
    }
    else {
        _dataDictionary = @{
                SEC_ALMOND_LIST : almondList,
                SEC_VERSION : @[version],
        };
    }
}

- (NSArray *)buildAlmondList:(enum SFIAlmondConnectionMode)mode {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    switch (mode) {
        case SFIAlmondConnectionMode_cloud: {
            NSArray *cloud = [toolkit almondList];
            if (!cloud) {
                cloud = @[];
            }
            return cloud;
        }
        case SFIAlmondConnectionMode_local: {
            NSArray *local = [toolkit localLinkedAlmondList];
            if (!local) {
                local = @[];
            }
            return local;
        }
        default:
            return @[];
    }
}

#pragma mark - Table Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataDictionary count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSUInteger sectionCount = [self.dataDictionary count];

    if (sectionCount == 2) {
        switch (sectionIndex) {
            case 0: {
                NSArray *array = [self getAlmondList];
                return [array count] + 1;
            }
            case 1: {
                NSArray *array = [self getVersionList];
                return [array count];
            }
            default:
                return 0;
        }
    }
    else {
        switch (sectionIndex) {
            case 0: {
                NSArray *array = [self getAlmondList];
                return [array count] + 1;
            }
            case 1: {
                NSArray *array = [self getSettingsList];
                return [array count];
            }
            case 2: {
                NSArray *array = [self getVersionList];
                return [array count];
            }
            default:
                return 0;
        }
    }
}

- (NSArray *)getSettingsList {
    return self.dataDictionary[SEC_SETTINGS_LIST];
}

- (NSArray *)getAlmondList {
    return self.dataDictionary[SEC_ALMOND_LIST];
}

- (NSArray *)getVersionList {
    return self.dataDictionary[SEC_VERSION];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = CGRectMake(10, 25, tableView.frame.size.width, 18);

    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont securifiBoldFontLarge];
    label.textColor = [UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0];

    NSUInteger sectionCount = [self.dataDictionary count];
    if (sectionCount == 2) {
        switch (section) {
            case 0:
                label.text = NSLocalizedString(@"Draw viecontroller.label LOCATION", @"LOCATION");
                break;
            case 1:
                label.text = NSLocalizedString(@"Draw viecontroller.label SETTINGS", @"SETTINGS");
                break;
            default:
                label.text = @"";
                break;
        }
    }
    else {
        switch (section) {
            case 0:
                label.text = NSLocalizedString(@"Draw viecontroller.label LOCATION", @"LOCATION");
                break;
            case 1:
                label.text = NSLocalizedString(@"Draw viecontroller.label SETTINGS", @"SETTINGS");
                break;
            case 2:
                label.text = NSLocalizedString(@"Draw viecontroller.label INFO", @"INFO");
                break;
            default:
                label.text = @"";
                break;
        }
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 65)];
    view.backgroundColor = [self headerBackgroundColor];
    [view addSubview:label];

    return view;
}

- (UIColor *)headerBackgroundColor {
    return [UIColor colorWithRed:(CGFloat) (34 / 255.0) green:(CGFloat) (34 / 255.0) blue:(CGFloat) (34 / 255.0) alpha:1.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger sectionCount = [self.dataDictionary count];

    switch (indexPath.section) {
        case 0: {
            NSArray *array = [self getAlmondList];
            if (indexPath.row == [array count]) {
                //Create Add symbol
                return [self tableViewTableViewCreateAddSymbolCell:tableView];
            }
            else {
                //Add almond list
                return [self tableViewCreateAlmondListCell:tableView indexPath:indexPath];
            }
        }
        case 1:
            if (sectionCount == 2) {
                return [self tableViewCreateVersionCell:tableView indexPath:indexPath];
            }
            else {
                return [self tableViewCreateSettingsCell:tableView indexPath:indexPath];
            }

        case 2:
            return [self tableViewCreateVersionCell:tableView indexPath:indexPath];

        default: {
            return [self tableViewCreateSettingsCell:tableView indexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger sectionCount = [self.dataDictionary count];

    if (indexPath.section == 0) {
        NSArray *almondList = [self getAlmondList];
        if (indexPath.row == [almondList count]) {
            //Add almond - Affiliation process
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSLog(@"i am called");
            switch ([[SecurifiToolkit sharedInstance] currentConnectionMode]) {
                case SFIAlmondConnectionMode_cloud: {
                    UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
                    [self presentViewController:ctrl animated:YES completion:nil];
                    break;
                }
                case SFIAlmondConnectionMode_local: {
                    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
                    editor.delegate = self;
                    editor.makeLinkedAlmondCurrentOne = YES;

                    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
                    [self presentViewController:ctrl animated:YES completion:nil];
                    break;
                }
            }
        }
        else {
            //Display the corresponding Sensor List

            SFIAlmondPlus *currentAlmond = almondList[(NSUInteger) indexPath.row];
            currentAlmond.colorCodeIndex = (int) indexPath.row;
            NSLog(@"i am called");
            [[SecurifiToolkit sharedInstance] setCurrentAlmond:currentAlmond];

            SWRevealViewController *revealController = [self revealViewController];
            [revealController revealToggleAnimated:YES];
        }
    }
    else if (indexPath.section == 1 && sectionCount != 2) {
        //Settings
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (indexPath.row == 0) {
            //Account
            [self presentAccountsView];
        }
        else if (indexPath.row == 1) {
            [[SecurifiToolkit sharedInstance] asyncSendLogout];
        }
        else if (indexPath.row == 2) {
            //Logout All Action
            [self presentLogoutAllView];
        }
    }
}

#pragma mark - Table cell creation

- (UITableViewCell *)tableViewTableViewCreateAddSymbolCell:(UITableView *)tableView {
    NSString * id = @"AddSymbolCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:id];
    cell.backgroundColor = [self cellBackgroundColor];

    UIImageView *imgAddDevice = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 24)];
    imgAddDevice.userInteractionEnabled = YES;
    imgAddDevice.image = [UIImage imageNamed:@"addAlmond"];

    [cell addSubview:imgAddDevice];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont standardHeadingFont];
    label.text = NSLocalizedString(@"Draqviewcontroller.add","toevoegen");

    [cell addSubview:label];

    return cell;
}

- (UITableViewCell *)tableViewCreateAlmondListCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString * id = @"AlmondListCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
        cell.backgroundColor = [self cellBackgroundColor];

        UIImageView *imgLocation = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 21.5)];
        imgLocation.userInteractionEnabled = YES;
        imgLocation.image = [UIImage imageNamed:@"almondHome"];
        [cell.contentView addSubview:imgLocation];

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
        nameLabel.tag = 101;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [nameLabel setFont:[UIFont standardHeadingFont]];
        [cell.contentView addSubview:nameLabel];
    }

    for (UIView *view in [cell.contentView subviews]) {
        if (view.tag == 101) {
            UILabel *nameLabel = (UILabel *) view;

            NSArray *array = [self getAlmondList];
            SFIAlmondPlus *almond = array[(NSUInteger) indexPath.row];
            nameLabel.text = almond.almondplusName;
            break;
        }
    }

    return cell;
}


- (UITableViewCell *)tableViewCreateSettingsCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString * id = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    cell.backgroundColor = [self cellBackgroundColor];

    UIImageView *imgSettings;
    switch (indexPath.row) {
        case 0:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 24)];
            imgSettings.image = [UIImage imageNamed:@"account"];
            break;
        case 1:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24.5, 19)];
            imgSettings.image = [UIImage imageNamed:@"logout"];
            break;
        case 2:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 25, 17.5)];
            imgSettings.image = [UIImage imageNamed:@"logout"];
            break;
        case 3:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 24)];
            imgSettings.image = [UIImage imageNamed:@"account"];
            break;
        default:
            break;
    }
    imgSettings.userInteractionEnabled = YES;

    [cell addSubview:imgSettings];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont standardHeadingFont];

    NSArray *array = [self getSettingsList];
    NSString * cellValue = array[(NSUInteger) indexPath.row];
    label.text = cellValue;

    [cell addSubview:label];

    return cell;
}

- (UITableViewCell *)tableViewCreateVersionCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString * id = @"VersionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [self cellBackgroundColor];

    NSArray *array = [self getVersionList];
    NSString * cellValue = array[(NSUInteger) indexPath.row];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont standardHeadingFont];
    label.text = cellValue;

    [cell addSubview:label];

    return cell;
}

- (UIColor *)cellBackgroundColor {
    return [UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0];
}

#pragma mark - SFILogoutAllDelegate methods

- (void)presentLogoutAllView {
    // Delegate to the main view, which will manage presenting the logout all controller
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_LOGOUT_ALL object:nil]];
}

- (void)presentAccountsView {
    // Delegate to the main view, which will manage presenting the account controller
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_ACCOUNTS object:nil]];
}

#pragma mark - RouterNetworkSettingsEditorDelegate methods

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

@end
