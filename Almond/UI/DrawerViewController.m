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

@interface DrawerViewController ()
@property(nonatomic, strong, readonly) NSDictionary *dataDictionary;
@property(nonatomic, strong) NSString *currentMAC;
@end

@implementation DrawerViewController

#pragma mark - View Cycle

//- (id)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:UITableViewStylePlain];
//    if (self) {
//
//    }
//
//    return self;
//}


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
    NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
    NSArray *settingsList = @[@"Account", @"Logout", @"Logout All"];

    _dataDictionary = @{
            ALMONDLIST : almondList,
            SETTINGS_LIST : settingsList
    };
}

#pragma mark - Table Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataDictionary count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case 0: {
            NSArray *array = [self getAlmondList];
            DLog(@"Almond List count %ld", (long) [array count]);
            return [array count] + 1;
        }
        case 1: {
            NSArray *array = [self getSettingsList];
            return [array count];
        }
        case 2:
            return 0;
        default:
            return 0;
    }
}

- (NSArray *)getSettingsList {
    return self.dataDictionary[SETTINGS_LIST];
}

- (NSArray *)getAlmondList {
    return self.dataDictionary[ALMONDLIST];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"LOCATION";
    }
    else if (section == 1) {
        return @"SETTINGS";
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0) ? 65 : 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (section == 0) ?
            CGRectMake(10, 25, tableView.frame.size.width, 18) :
            CGRectMake(10, 25, tableView.frame.size.width, 18);

    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont securifiBoldFontLarge];
    label.textColor = [UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0];

    if (section == 0) {
        label.text = @"LOCATION";
    }
    else if (section == 1) {
        label.text = @"SETTINGS";
    }
    else {
        label.text = @"";
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

        default: {
            return [self tableViewCreateSettingsCell:tableView indexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {

        NSArray *almondList = [self getAlmondList];
        if (indexPath.row == [almondList count]) {
            //Add almond - Affiliation process
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
            [self presentViewController:mainView animated:YES completion:nil];
        }
        else {
            //Display the corresponding Sensor List

            SFIAlmondPlus *currentAlmond = almondList[(NSUInteger) indexPath.row];
            self.currentMAC = currentAlmond.almondplusMAC;

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = paths[0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
            NSArray *listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

            int codeIndex = (int) indexPath.row;
            if (indexPath.row >= [listAvailableColors count]) {
                codeIndex = codeIndex % [listAvailableColors count];
            }
            currentAlmond.colorCodeIndex = codeIndex;

            [[SecurifiToolkit sharedInstance] setCurrentAlmond:currentAlmond];

            SWRevealViewController *revealController = [self revealViewController];
            [revealController revealToggleAnimated:YES];
        }
    }
    else if (indexPath.section == 1) {
        //Settings
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        //PY 150914 - Account Settings
        if (indexPath.row == 0) {
            //Account
            [self presentAccountsView];
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountsStoryboard_iPhone" bundle:nil];
//            UITableViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AccountNavigationTop"];
//            [self presentViewController:mainView animated:YES completion:nil];
        }
        else if (indexPath.row == 1) {
            //Logout Action
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
    NSString *id = @"AddSymbolCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:id];

    UIImageView *imgAddDevice = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 24)];
    imgAddDevice.userInteractionEnabled = YES;
    imgAddDevice.image = [UIImage imageNamed:@"addAlmond.png"];

    [cell addSubview:imgAddDevice];

    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
    lblName.backgroundColor = [UIColor clearColor];
    lblName.textColor = [UIColor whiteColor];
    [lblName setFont:[UIFont standardHeadingFont]];
    lblName.text = @"Add";

    [cell addSubview:lblName];

    [cell setBackgroundColor:[UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0]];
    return cell;
}

- (UITableViewCell *)tableViewCreateAlmondListCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *id = @"AlmondListCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];

        UIImageView *imgLocation = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 21.5)];
        imgLocation.userInteractionEnabled = YES;
        imgLocation.image = [UIImage imageNamed:@"almondHome.png"];
        [cell.contentView addSubview:imgLocation];

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
        nameLabel.tag = 101;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [nameLabel setFont:[UIFont standardHeadingFont]];
        [cell.contentView addSubview:nameLabel];
    }

    cell.backgroundColor = [UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0];

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
    NSString *id = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];

    NSArray *array = [self getSettingsList];
    NSString *cellValue = array[(NSUInteger) indexPath.row];

    UIImageView *imgSettings;
    switch (indexPath.row) {
        case 0:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 24)];
            imgSettings.image = [UIImage imageNamed:@"account.png"];
            break;
        case 1:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24.5, 19)];
            imgSettings.image = [UIImage imageNamed:@"logout.png"];
            break;
        case 2:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 25, 17.5)];
            imgSettings.image = [UIImage imageNamed:@"logout.png"];
            break;
        case 3:
            imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 24)];
            imgSettings.image = [UIImage imageNamed:@"account.png"];
            break;
        default:
            break;
    }
    imgSettings.userInteractionEnabled = YES;

    [cell addSubview:imgSettings];

    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
    lblName.backgroundColor = [UIColor clearColor];
    lblName.textColor = [UIColor whiteColor];
    [lblName setFont:[UIFont standardHeadingFont]];

    lblName.text = cellValue;

    [cell addSubview:lblName];

    [cell setBackgroundColor:[UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0]];
    return cell;
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

@end
