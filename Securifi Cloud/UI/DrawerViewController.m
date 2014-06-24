//
//  DrawerViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "DrawerViewController.h"
#import "SNLog.h"
#import "AlmondPlusConstants.h"

@interface DrawerViewController ()
@property(nonatomic, strong, readonly) NSDictionary *dataDictionary;
@property(nonatomic, strong) NSString *currentMAC;
@end

@implementation DrawerViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.slidingViewController setAnchorRightRevealAmount:250.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    self.drawTable.backgroundColor = [UIColor colorWithRed:(CGFloat) (34 / 255.0) green:(CGFloat) (34 / 255.0) blue:(CGFloat) (34 / 255.0) alpha:1.0];

    UISwipeGestureRecognizer *showTabSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealTab:)];
    showTabSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:showTabSwipe];

    self.drawTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetAlmondList];
    [self.drawTable reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)resetAlmondList {
    NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
    NSArray *settingsList = @[@"Logout", @"Logout All"];

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
    //Number of rows it should expect should be based on the section
    NSArray *array;
    switch (sectionIndex) {
        case 0:
            array = self.dataDictionary[ALMONDLIST];
            NSLog(@"Almond List count %d", [array count]);
            return [array count] + 1;
        case 1:
            array = self.dataDictionary[SETTINGS_LIST];
            return [array count];
        case 2:
            return 0;
        default:
            break;
    }
    return 0;

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
    return 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];

    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
    [label setTextColor:[UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0]];

    NSString *string;
    if (section == 0) {
        string = @"LOCATION";
    }
    else if (section == 1) {
        string = @"SETTINGS";
    }
    else {
        string = @"";
    }

    /* Section header is in 0th index... */
    [label setText:string];

    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:(CGFloat) (34 / 255.0) green:(CGFloat) (34 / 255.0) blue:(CGFloat) (34 / 255.0) alpha:1.0]];

    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            NSArray *array = self.dataDictionary[ALMONDLIST];
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
        NSArray *array = self.dataDictionary[ALMONDLIST];
        if (indexPath.row == [array count]) {
            //Add almond - Affiliation process
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
            [self presentViewController:mainView animated:YES completion:nil];
        }
        else {
            int codeIndex = 0;
            //Display the corresponding Sensor List
            UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabTop"];
//            UITabBarController *ctrl = (UITabBarController *) newTopViewController;
//            ctrl.tabBar.tintColor = [UIColor blackColor];

            SFIAlmondPlus *currentAlmond = array[(NSUInteger) indexPath.row];
            self.currentMAC = currentAlmond.almondplusMAC;

            //[SNLog Log:@"Method Name: %s Selected MAC is @%@", __PRETTY_FUNCTION__,self.currentMAC];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = paths[0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
            NSArray *listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

            //PY 111013 - Integration with new UI
            codeIndex = (int) indexPath.row;
            if (indexPath.row >= [listAvailableColors count]) {
                codeIndex = codeIndex % [listAvailableColors count];
            }

            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
            [prefs setObject:currentAlmond.almondplusName forKey:CURRENT_ALMOND_MAC_NAME];
            [prefs setInteger:codeIndex forKey:COLORCODE];
            [prefs synchronize];

            [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
                CGRect frame = self.slidingViewController.topViewController.view.frame;
                self.slidingViewController.topViewController = newTopViewController;
                self.slidingViewController.topViewController.view.frame = frame;
                [self.slidingViewController resetTopView];
            }];
        }
    }
    else if (indexPath.section == 1) {
        //Settings
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (indexPath.row == 0) {
            //Logout Action
            [[SecurifiToolkit sharedInstance] asyncSendLogout];
        }
        else if (indexPath.row == 1) {
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
    [lblName setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];

    lblName.text = @"Add";

    [cell addSubview:lblName];

    [cell setBackgroundColor:[UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0]];
    return cell;
}

- (UITableViewCell *)tableViewCreateAlmondListCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *id = @"AlmondListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];

    UIImageView *imgLocation;
    imgLocation = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, 24, 21.5)];
    imgLocation.userInteractionEnabled = YES;
    imgLocation.image = [UIImage imageNamed:@"almondHome.png"];
    [cell addSubview:imgLocation];

    UILabel *lblName;
    lblName = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 180, 30)];
    lblName.backgroundColor = [UIColor clearColor];
    lblName.textColor = [UIColor whiteColor];
    [lblName setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];

    NSArray *array = self.dataDictionary[ALMONDLIST];
    SFIAlmondPlus *currentAlmond = array[(NSUInteger) indexPath.row];
    lblName.text = currentAlmond.almondplusName;

    [cell addSubview:lblName];

    [cell setBackgroundColor:[UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0]];

    return cell;

}


- (UITableViewCell *)tableViewCreateSettingsCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *id = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];

    NSArray *array = self.dataDictionary[SETTINGS_LIST];
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
    [lblName setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];

    lblName.text = cellValue;

    [cell addSubview:lblName];

    [cell setBackgroundColor:[UIColor colorWithRed:(CGFloat) (51 / 255.0) green:(CGFloat) (51 / 255.0) blue:(CGFloat) (51 / 255.0) alpha:1.0]];
    return cell;
}


#pragma mark - Class Methods

- (IBAction)revealTab:(id)sender {
    NSLog(@"Reveal Tab: Drawer View");
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        [self.slidingViewController resetTopView];
    }];
}

#pragma mark - SFILogoutAllDelegate methods

- (void)presentLogoutAllView {
    // Delegate to the main view, which will manage presenting the logout all controller
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_LOGOUT_ALL object:nil]];
}

@end
