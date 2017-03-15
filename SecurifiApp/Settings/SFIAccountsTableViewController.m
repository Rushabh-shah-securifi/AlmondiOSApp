//
//  SFIAccountsTableViewController.m
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//


#import "SFIAccountsTableViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"
#import "SFIAccountMacros.h"
#import "SFIAccountCellView.h"
#import "SFIAlmondCell.h"
#import "AlmondManagement.h"
#import "SFISecondaryUser.h"
#import "UIViewController+Securifi.h"

static NSString *simpleTableIdentifier = @"AccountCell";

@interface SFIAccountsTableViewController ()

@property(nonatomic) NSMutableArray *ownedAlmondList;
@property(nonatomic) NSMutableArray *sharedAlmondList;
@property(nonatomic) NSString *changedAlmondName;
@property(nonatomic) NSString *currentAlmondMAC;
@property(nonatomic) NSString *changedEmailID;
@property(nonatomic) NSDictionary *failureReasonForAccountsPageResponse;
@property(nonatomic) SFIAccountCellView* accountCell;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property(nonatomic) int nameChangedForAlmond;
@property NSTimer *almondNameChangeTimer;
@property BOOL isAlmondNameChangeSuccessful;
@property NSMutableDictionary* textFieldValues;
@property float baseYCordinate;
@property UIView* backgroundLabel;
@end

@implementation SFIAccountsTableViewController

@synthesize ownedAlmondList, sharedAlmondList;
@synthesize changedAlmondName;
@synthesize currentAlmondMAC, changedEmailID, nameChangedForAlmond;
@synthesize baseYCordinate;
@synthesize backgroundLabel;
@synthesize failureReasonForAccountsPageResponse;
@synthesize accountCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
                                                                    NSFontAttributeName : [UIFont standardNavigationTitleFont]
                                                                    };

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = NSLocalizedString(ACCOUNTS_NAVBAR_TITLE_SETTINGS, ACCOUNTS_SETTINGS);
    
    failureReasonForAccountsPageResponse = @{
                                             @5 :THIS_USER_DOES_NOT_HAVE_A_SECURIFI_ACCOUNT,
                                             @6 :THIS_USER_NEEDS_TO_VERIFY_ACCOUNT,
                                             @7 :THIS_IS_NOT_YOUR_ALMOND,
                                             @8 :ALREADY_INVITED,
                                             @9 :YOU_ARE_OWNER_OF_THIS_ALMOND,
                                             @10:PLEASE_TRY_AGAIN_LATER,
                                             @20:THE_EMAIL_ID_IS_INVALID,
                                             @21:COULD_NOT_DELETE_YOUR_ACCOUNT,
                                             @22:COULD_NOT_DELETE_YOUR_ACCOUNT,
                                             @23:COULD_NOT_DELETE_YOUR_ACCOUNT,
                                             @24:INCORRECT_PASSWORD,
                                             @25:INCORRECT_PASSWORD,
                                             @26:PLEASE_TRY_AGAIN_LATER,
                                             @27:USER_WAS_ALREADY_REMOVED
                                             };
    
    accountCell = [[SFIAccountCellView alloc] initWithFrame:self.tableView.frame];
    [accountCell initWith:self.tableView.frame];
    accountCell.delegate = self;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(loadAlmondList)
                   name:RELOAD_ACCOUNTS_PAGE
                 object:nil];
    
    [center addObserver:self
               selector:@selector(loadAlmondList)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
    
    [center addObserver:self
               selector:@selector(accountResponseCallback:)
                   name:ACCOUNTS_RELATED
                 object:nil];
    
    [center addObserver:self
               selector:@selector(loadAlmondList)
                   name:kSFIDidChangeAlmondName
                 object:nil];
    
    [center addObserver:self
               selector:@selector(mobileCommandResponseCallback:)
                   name:MOBILE_COMMAND_NOTIFIER
                 object:nil];

    NSMutableDictionary *data = [NSMutableDictionary new];
    NSArray *localizedStrings = @[ACCOUNTS_HUD_LOADINGDETAILS, LOADING_ACCOUNT_DETAILS];
    
    [self sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:@"UserProfileRequest" withDictionaryData:data withLocalizedStrings:localizedStrings];
    
    [[Analytics sharedInstance] markAccountsScreen];
}


-(void) addButtonToPostNotification {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"postDynamicNotification" forState:UIControlStateNormal];
    button.frame = CGRectMake(100.0, 400.0, 160.0, 40.0);
    [button setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:button];
}

-(void) aMethod:(id)sender {
    NSString* payload = @"{ \"CommandType\" :\"DynamicAlmondDelete\",\"Success\":\"true\",\"AlmondMAC\":\"251176217114456\" }";
    NSData* data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [[SecurifiToolkit sharedInstance] postNotification:ACCOUNTS_RELATED data:data];
}


- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self
                      name:RELOAD_ACCOUNTS_PAGE
                    object:nil];
    
    [center removeObserver:self
                      name:ACCOUNTS_RELATED
                    object:nil];
    
    [center removeObserver:self
                      name:ALMOND_NAME_CHANGE_NOTIFIER
                    object:nil];
    
    [center removeObserver:self
                      name:MOBILE_COMMAND_NOTIFIER
                    object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - HUD mgt
- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}


#pragma mark - Button Handlers
- (IBAction)doneButtonHandler:(id)sender {
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate userAccountDidDone:self];
}


#pragma mark - Data access
- (SFIAlmondPlus *)ownedAlmondAtIndexPathRow:(NSInteger)row {
    NSUInteger index = (NSUInteger) (row - 1);
    if (index >= ownedAlmondList.count) {
        return nil;
    }
    return ownedAlmondList[index];
}

- (SFIAlmondPlus *)sharedAlmondAtIndexPathRow:(NSInteger)row {
    NSLog(@"%ld is the row value",(long)row);
    NSUInteger index = (NSUInteger) (row - 1 - ownedAlmondList.count);
    if (index >= sharedAlmondList.count) {
        return nil;
    }
    return sharedAlmondList[index];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return accountCell.isExpanded?EXPANDED_PROFILE_ROW_HEIGHT:120;
    if(indexPath.row<=[ownedAlmondList count]){
        SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:indexPath.row];
        if (currentAlmond.isExpanded) {
            if ([currentAlmond.accessEmailIDs count] > 0) {
                return EXPANDED_OWNED_ALMOND_ROW_HEIGHT + 30 + ([currentAlmond.accessEmailIDs count] * 30);
            }
            return EXPANDED_OWNED_ALMOND_ROW_HEIGHT;
        }
        return 120;
    }
    if(indexPath.row<=[sharedAlmondList count]) {
        SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:indexPath.row];
        if (currentAlmond.isExpanded)
            return EXPANDED_SHARED_ALMOND_ROW_HEIGHT;
        return 120;
    }
    return 120;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1 + [ownedAlmondList count] + [sharedAlmondList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (indexPath.row == 0) {
        cell = [self createUserProfileCell:cell listRow:(int) indexPath.row];
    }
    
    if ([ownedAlmondList count] > 0) {
        if (indexPath.row > 0 && indexPath.row <= [ownedAlmondList count]) {
            cell = [self createAlmondCell:cell listRow:(int)indexPath.row withOwnedAlmond:YES];
        }
    }
    
    if ([sharedAlmondList count] > 0) {
        if (indexPath.row > [ownedAlmondList count] && indexPath.row <= ([ownedAlmondList count] + [sharedAlmondList count])) {
            cell = [self createAlmondCell:cell listRow:(int) indexPath.row withOwnedAlmond:NO];
        }
    }
    
    return cell;
}


#pragma mark - deletegatesFromAccountCell
- (void) stopHUD {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.HUD hide:YES];
    });
}

- (void) onProfileButtonClicked:(id)sender {
    [self onProfileClicked:sender];
}

-(void) onChangePasswordButtonClicked:(id)sender{
    [self onChangePasswordClicked:sender];
}

-(void) onDeleteAccountButtonClicked:(id)sender {
    [self onDeleteAccountClicked:sender];
}

-(void) onChangeAlmondNameClicked:(NSString*)newAlmondName almondMac:(NSString*)mac{
    changedAlmondName = newAlmondName;
    NSString *reqname = @"AlmondNameChange";
    if((newAlmondName.length == 0) || (newAlmondName.length > 32)){
        [self showToast:@"almond name should be less than 32 character"];
        return;
    }
    [self sendAlmondNameChangeRequest:mac];
    
}
- (void)sendAlmondNameChangeRequest:(NSString *)almondplusMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.changeAlmondName", @"Change almond name...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestChangeAlmondName:changedAlmondName almondMAC:almondplusMAC];
}

#pragma mark - FromAlmondCell
-(void) reloadTable :(int) index {
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationFade];
}


-(void) showToastForMoreThan32Chars {
    [[[iToast makeText:NSLocalizedString(ACCOUNTS_ITOAST_ALMONDNAMEMAX32CHARACTERS, ALMOND_NAME_CANNOT_BE_MORE_THAN_32_CHARACTERS)] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    return;
}


#pragma mark - Custom cell creation
- (UITableViewCell *)createUserProfileCell:(UITableViewCell *)cell listRow:(int)indexPathRow {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [accountCell drawAccountCell:self.tableView.frame];
    [cell addSubview: accountCell];
    return cell;
}


- (UITableViewCell *)createAlmondCell:(UITableViewCell *)cell listRow:(int)indexPathRow withOwnedAlmond:(BOOL)isOwnedAlmond {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SFIAlmondCell *almondCell = [[SFIAlmondCell alloc] initWithFrame:self.tableView.frame];
    [almondCell initWith:self.tableView.frame withBound:self.tableView.bounds isOwnedAlmond:isOwnedAlmond listRow:indexPathRow ownedAlmondList:ownedAlmondList sharedAlmondList:sharedAlmondList];
    
    almondCell.delegate =self;
    [cell addSubview:almondCell];
    return cell;
}


#pragma mark - Class methods

- (void)onProfileClicked:(id)sender {
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *rowsToReload = @[rowToReload];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onChangePasswordClicked:(id)sender {
    //Display option to change password
    DLog(@"Change Password Clicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountsStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}


- (void)onDeleteAccountClicked:(id)sender {
    //Confirmation Box
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(ACCOUNTS_ALERT_ONDELETEACCOUNT_TITLE, DELETE_ACCOUNT) message:NSLocalizedString(ACCOUNTS_ALERT_ONDELETEACCOUNT_MESSAGE, DELETING_THE_ACCOUNT_WILL_UNLINK_YOUR_ALMONDS_AND_DELETE_USER_PREFERENCES_TO_CONFIRM_ACCOUNT_DELETION_ENTER_YOUR_PASSWORD_BELOW) delegate:self cancelButtonTitle:NSLocalizedString(ACCOUNTS_ALERT_ONDELETEACCOUNT_CANCEL, CANCEL) otherButtonTitles:NSLocalizedString(ACCOUNTS_ALERT_ONDELETE_DELETE, DELETE), nil];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = DELETE_ACCOUNT_CONFIRMATION;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
}


- (void)onUnlinkAlmondClicked:(id)sender {
    
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;
    
    SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    currentAlmondMAC = currentAlmond.almondplusMAC;
    
    //Confirmation Box
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(ACCOUNTS_ALERT_ONUNLINKALMOND_TITLE, UNLINK_ALMOND) message:NSLocalizedString(ACCOUNTS_ALERT_ONUNLINKALMOND_MESSAGE, TO_CONFIRM_UNLNKING_ALMOND_ENTER_YOUR_PASSWORD_BELOW ) delegate:self cancelButtonTitle:NSLocalizedString(ACCOUNTS_ALERT_ONUNLINKALMOND_CANCEL, CANCEL) otherButtonTitles:NSLocalizedString(ACCOUNTS_ALERT_ONUNLINKALMOND_UNLINK, UNLINK), nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = UNLINK_ALMOND_CONFIRMATION;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
    
}

- (void)onInviteClicked:(id)sender {
    DLog(@"onInviteClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;
    
    SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    
    currentAlmondMAC = currentAlmond.almondplusMAC;
    
    //Invitation Email Input Box
    NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(ACCOUNTS_ALERT_ONINVITETOSHAREDALMOND_MESSAGE, @"By inviting someone they can access %@"), currentAlmond.almondplusName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(ACCOUNTS_ALERT_ONINVITETOSHAREDALMOND_TITLE, INVITE_BY_EMAIL) message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(ACCOUNTS_ALERT_ONINVITETOSHAREALMOND_CANCEL, CANCEL) otherButtonTitles:NSLocalizedString(ACCOUNTS_ALERT_ONINVITETOSHAREALMOND_INVITE,INVITE), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = USER_INVITE_ALERT;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
}


- (void)onEmailRemoveClicked:(id)sender {
    DLog(@"onEmailRemoveClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;
    
    CGPoint buttonOrigin = btn.frame.origin;
    CGPoint pointInTableView = [self.tableView convertPoint:buttonOrigin fromView:btn.superview];
    
    SFIAlmondPlus *currentAlmond;
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInTableView];
    if (indexPath) {
        currentAlmond = [self ownedAlmondAtIndexPathRow:indexPath.row];
    }
    
    currentAlmondMAC = currentAlmond.almondplusMAC;
    SFISecondaryUser* user = (SFISecondaryUser*)currentAlmond.accessEmailIDs[index];
    NSString* emailID = user.emailId;
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    DLog(@"Selected Email %@", emailID);
    
    NSArray * localizedStrings = @[ACCOUNTS_HUD_REMOVEUSERFROMSHAREDLIST, REMOVE_USER_FROM_SHARED_LIST];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    [dictionary setObject:currentAlmondMAC forKey:ALMOND_MAC];
    
    NSString* userId = [AlmondManagement getUserIDfromEmail: emailID andAlmondMAC: currentAlmond.almondplusMAC];
    [dictionary setObject:userId forKey:USER_ID];
    [self sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:DELETE_SECONDARY_USER_REQUEST withDictionaryData:dictionary withLocalizedStrings:localizedStrings];
}


- (void)onRemoveSharedAlmondClicked:(id)sender {
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;
    SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:index];
    currentAlmondMAC = currentAlmond.almondplusMAC;
    NSArray *localizedStrings = @[ACCOUNTS_HUD_REMOVESHAREDALMOND, REMOVE_SHARED_ALMOND];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:currentAlmond.almondplusMAC forKey:ALMOND_MAC];
    [self sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:DELETE_ME_AS_SECONDARY_USER_REQUEST withDictionaryData:dictionary withLocalizedStrings:localizedStrings];
}


#pragma  mark - Alertview delgate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *password = [alertView textFieldAtIndex:0];
    BOOL flag = TRUE;
    if (password.text.length == 0){
        flag = FALSE;
    }
    return flag;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    DLog(@"Button Index =%ld", (long) buttonIndex);
    if (alertView.tag == DELETE_ACCOUNT_CONFIRMATION) {
        if (buttonIndex == 1) {  //Delete Account
            UITextField *password = [alertView textFieldAtIndex:0];
            DLog(@"password: %@", password.text);
            //Send request to delete
            NSArray *localizedStrings = @[ACCOUNTS_HUD_DELETINGACCOUNT, DELETING_ACCOUNT];
            NSMutableDictionary* dictionary = [NSMutableDictionary new];
            [dictionary setObject:[[SecurifiToolkit sharedInstance] loginEmail] forKey:EMAIL_ID];
            [dictionary setObject:password.text forKey:Password];
            [self sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:DELETE_ACCOUNT_REQUEST withDictionaryData:dictionary withLocalizedStrings:localizedStrings];
        }
    }
    else if (alertView.tag == UNLINK_ALMOND_CONFIRMATION) {
        if (buttonIndex == 1) {  //Unlink Almond
            UITextField *password = [alertView textFieldAtIndex:0];
            DLog(@"password: %@", password.text);
            //Send request to delete
            NSArray *localizedStrings = @[ACCOUNTS_HUD_UNLINKINGALMOND, UNLINKING_ALMOND];
            NSMutableDictionary *dictionary = [NSMutableDictionary new];
            [dictionary setObject:currentAlmondMAC forKey:ALMOND_MAC];
            [dictionary setObject:[[SecurifiToolkit sharedInstance] loginEmail] forKey:EMAIL_ID];
            [dictionary setObject:password.text forKey:Password];
            [self sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:UNLINK_ALMOND_REQUEST withDictionaryData:dictionary withLocalizedStrings:localizedStrings];
        }
    }
    else if (alertView.tag == USER_INVITE_ALERT) {
        if (buttonIndex == 1) {  //Invite user to share Almond
            UITextField *emailID = [alertView textFieldAtIndex:0];
            DLog(@"emailID: %@", emailID.text);
            changedEmailID = emailID.text;
            //Send request to delete
            NSArray * localizedStrings = @[ACCOUNT_HUD_INVITEUSERTOSHAREALMOND, INVITING_USER_TO_SHARE_ALMOND];
            NSMutableDictionary *dictionary = [NSMutableDictionary new];
            [dictionary setObject:currentAlmondMAC forKey:ALMOND_MAC];
            [dictionary setObject:changedEmailID forKey:EMAIL_ID];
            [self sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:USER_INVITE_REQUEST withDictionaryData:dictionary withLocalizedStrings:localizedStrings];
        }
    }
}


#pragma - delegates from AccountCell
-(void) loadAlmondList {
    ownedAlmondList = [AlmondManagement getOwnedAlmondList];
    sharedAlmondList = [AlmondManagement getSharedAlmondList];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
        [self.tableView reloadData];
    });
}


-(void) showToastonTableViewController:(NSDictionary*)dictionary {
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    if (![[dictionary valueForKey:SUCCESS] isEqualToString:@"true"]) {
        NSString *failureReason;
        failureReason = [failureReasonForAccountsPageResponse valueForKey:[dictionary valueForKey:@"Reason"]];
        if(failureReason==nil){
            failureReason =  NSLocalizedString(ACCOUNTS_UPDATEACCOUNT_FAILURE_DEFAULT, SORRY_UPDATE_WAS_UNSUCCESSFUL);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
        });
    }
}


#pragma mark - Cloud Command : Sender and Receivers
-(void) sendRequest:(CommandType *)commandType withCommandString:(NSString*)commandString withDictionaryData:(NSMutableDictionary *)data withLocalizedStrings:(NSArray *)strings {
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    if(strings!=nil){
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.removeFromSuperViewOnHide = NO;
        _HUD.labelText = NSLocalizedString(strings[0], strings[1]);
        _HUD.dimBackground = YES;
        [self.navigationController.view addSubview:_HUD];
        [self showHudWithTimeout];
    }
    [[SecurifiToolkit sharedInstance] asyncSendRequest:commandType commandString:commandString payloadData:data];
}

//@TODO - Test if findAlmond return nil - will result in exception.
- (void) removeAlmond:(NSMutableArray*) almondList {
    [almondList removeObject:[self findAlmond:almondList]];
}

- (void) addAlmond:(SFIAlmondPlus*) almond toList:(NSArray*)almondList {
    NSArray* list = almondList;
    NSMutableArray* newOwnedList = [NSMutableArray new];
    for(SFIAlmondPlus* almond in list){
        [newOwnedList addObject:almond];
    }
    [newOwnedList addObject:almond];
    almondList = newOwnedList;
    
}


-(SFIAlmondPlus *)findAlmond:(NSMutableArray*)almondList{
    for (SFIAlmondPlus *current in almondList) {
        if ([current.almondplusMAC isEqualToString:currentAlmondMAC])
            return current;
    }
    return nil;
}


- (void)accountResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSError *error = nil;
    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:[data valueForKey:@"data"] options:kNilOptions error:&error];
    NSString *success = [dictionary valueForKey:SUCCESS];
    
    if ([success isEqualToString:@"true"]){
        if([[dictionary objectForKey:@"CommandType"] isEqualToString:@"DeleteAccountResponse"]){
            [self.delegate userAccountDidDelete:self];
        }
        return;
    }
    
    NSString *failureReason = [failureReasonForAccountsPageResponse objectForKey:[dictionary valueForKey:@"Reason"]];
                               
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    });
}


- (void)mobileCommandResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    MobileCommandResponse *obj = (MobileCommandResponse *) [data valueForKey:@"data"];
    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    [self.almondNameChangeTimer invalidate];
    self.isAlmondNameChangeSuccessful = TRUE;
    
    if (!obj.isSuccessful) {
        NSString *failureReason = obj.reason;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[[iToast makeText:[NSString stringWithFormat:NSLocalizedString(ACCOUNTS_ITOAST_UNABLETOCHANGEALMONDNAME, @"Sorry! We were unable to change Almond's name3333. %@"), failureReason]] setGravity:iToastGravityBottom] show:iToastTypeWarning];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cloudCommand];
}

#pragma mark - Keyboard methods

@end
