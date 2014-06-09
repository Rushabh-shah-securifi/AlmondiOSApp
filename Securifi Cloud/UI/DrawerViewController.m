//
//  DrawerViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "DrawerViewController.h"
#import "AlmondPlusConstants.h"
#import "SFIOfflineDataManager.h"
#import "SNLog.h"

@interface DrawerViewController ()
//@property(nonatomic, strong) NSArray *locationItems;
@property(nonatomic, strong) NSArray *settingsItems;
@property(nonatomic, strong) NSDictionary *dataDictionary;
@end

@implementation DrawerViewController
//@synthesize locationItems;
@synthesize settingsItems;
@synthesize dataDictionary;
@synthesize drawTable;
//PY 111013 - Integration with new UI
@synthesize almondList;
@synthesize currentMAC;

#pragma mark - View Cycle

- (void)awakeFromNib {
//    self.locationItems = @[@"Taipei Office", @"Taichung Home", @"Tyrol Cabin", @"4", @"5", @"6", @"7"];
    //PY 300114 - Account to be removed for Beta Testers
    // self.settingsItems = [NSArray arrayWithObjects:@"Account", @"Logout",@"Logout All" , nil];
    self.settingsItems = @[@"Logout", @"Logout All"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Read Almond list from file
    //Upload old list and start refreshing

    self.almondList = [SFIOfflineDataManager readAlmondList];
    //[self loadAlmondList];
    dataDictionary = [[NSMutableDictionary alloc] init];
    [dataDictionary setValue:self.almondList forKey:ALMONDLIST];
    [dataDictionary setValue:settingsItems forKey:SETTINGS_LIST];
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

    self.almondList = [SFIOfflineDataManager readAlmondList];
    [dataDictionary setValue:self.almondList forKey:ALMONDLIST];
    [self.drawTable reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LogoutResponseCallback:)
                                                 name:LOGOUT_NOTIFIER
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGOUT_NOTIFIER
                                                  object:nil];
}

#pragma mark - Table Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataDictionary count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    //Number of rows it should expect should be based on the section
    NSArray *array;
    switch (sectionIndex) {
        case 0:
            array = dataDictionary[ALMONDLIST];
            NSLog(@"Almond List count %d", [array count]);
            return [array count] + 1;
        case 1:
            array = dataDictionary[SETTINGS_LIST];
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
            NSArray *array = dataDictionary[ALMONDLIST];
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
    //NSString *identifier = [NSString stringWithFormat:@"%@Top", [self.menuItems objectAtIndex:indexPath.row]];

    //  UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    //
    //  [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
    //    CGRect frame = self.slidingViewController.topViewController.view.frame;
    //    self.slidingViewController.topViewController = newTopViewController;
    //    self.slidingViewController.topViewController.view.frame = frame;
    //    [self.slidingViewController resetTopView];
    //  }];
    if (indexPath.section == 0) {
        NSArray *array = dataDictionary[ALMONDLIST];
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
        //PY 300114 - Account to be removed for Beta Testers
//        if(indexPath.row == 1)
        if (indexPath.row == 0) {
            //Logout Action
            GenericCommand *cloudCommand = [[GenericCommand alloc] init];
            cloudCommand.commandType = LOGOUT_COMMAND;
            cloudCommand.command = nil;
            [SNLog Log:@"Method Name: %s Before Writing to socket -- LogoutCommand", __PRETTY_FUNCTION__];

            NSError *error = nil;
            [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

            //PY 250214 - Wait for callback from cloud
//            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//            [prefs removeObjectForKey:EMAIL];
//            [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
//            [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
//            [prefs removeObjectForKey:COLORCODE];
//            [prefs synchronize];
//            
//            //Delete files
//            [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
//            [SFIOfflineDataManager deleteFile:HASH_FILENAME];
//            [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
//            [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
//            
//            //[self dismissViewControllerAnimated:NO completion:nil];
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
//            //[self presentViewController:mainView animated:YES completion:nil];
//            [self presentViewController:mainView animated:YES completion:nil];


        }
            //PY 300114 - Account to be removed for Beta Testers
//        else  if(indexPath.row == 2)
        else if (indexPath.row == 1) {
            //Logout All Action
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"LogoutAllTop"];
            [self presentViewController:mainView animated:YES completion:nil];
        }
    }
}

#pragma mark - Table cell creation

- (UITableViewCell *)tableViewTableViewCreateAddSymbolCell:(UITableView*)tableView {
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

    NSArray *array = dataDictionary[ALMONDLIST];
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

    NSArray *array = dataDictionary[SETTINGS_LIST];
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


#pragma mark - Cloud Command : Sender and Receivers

/*
- (void)loadAlmondList {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];

    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = almondListCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}
*/


/*
- (void)AlmondListResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received Almond List response", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *) [data valueForKey:@"data"];

        self.almondList = [[NSMutableArray alloc] init];
        [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];

        self.almondList = obj.almondPlusMACList;
        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:self.almondList];
        [dataDictionary setValue:self.almondList forKey:ALMONDLIST];
        [self.drawTable reloadData];

    }


}
*/

- (void)LogoutResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received Logout response", __PRETTY_FUNCTION__];

        LogoutResponse *obj = (LogoutResponse *) [data valueForKey:@"data"];
        if (obj.isSuccessful) {
            //Logout Successful
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs removeObjectForKey:EMAIL];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
            [prefs removeObjectForKey:COLORCODE];
            [prefs synchronize];

            //Delete files
            [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
            [SFIOfflineDataManager deleteFile:HASH_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];

            //[self dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
            //[self presentViewController:mainView animated:YES completion:nil];
            [self presentViewController:mainView animated:YES completion:nil];
        }
        else {
            NSLog(@"Could not logout - Reason %@", obj.reason);
            NSString *alertMsg = @"Sorry. Logout was unsuccessful. Please try again.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Unsuccessful"
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - Class Methods

- (IBAction)revealTab:(id)sender {
    NSLog(@"Reveal Tab: Drawer View");
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
//        CGRect frame = self.slidingViewController.topViewController.view.frame;
//        self.slidingViewController.topViewController = newTopViewController;
//        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}


@end
