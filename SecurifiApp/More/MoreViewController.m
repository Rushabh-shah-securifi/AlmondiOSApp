//
//  MoreViewController.m
//  SecurifiApp
//
//  Created by Masood on 8/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreCellTableViewCell.h"
#import "SFIColors.h"
#import "CommonMethods.h"
#import "SFICloudLinkViewController.h"
#import "HelpCenter.h"
#import "AlmondPlusConstants.h"
#import "RulesTableViewController.h"
#import "MBProgressHUD.h"
#import "UIViewController+Securifi.h"
#import "KeyChainAccess.h"
#import "NotificationDeleteRegistrationRequest.h"
#import "AlmondManagement.h"
#import "MySubscriptionsViewController.h"
#define USER_INVITE_ALERT               0

@interface MoreViewController ()<MoreCellTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RouterNetworkSettingsEditorDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSArray *moreFeatures;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString *userName;
@property (nonatomic) BOOL isLocal;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property MySubscriptionsViewController *subscriptionsPage;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"more", @"");
    self.userName = @"";
    [self loadProfileImage];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.isLocal = [[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local;
    
    self.moreFeatures= [self getFeaturesArray];
    [self.tableView reloadData];
    [self initializeNotification];
    
    if(!self.isLocal)
        [self sendUserProfileRequest];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userProfileResponseCallback:)
                   name:ACCOUNTS_RELATED
                 object:nil];
    
    [center addObserver:self
               selector:@selector(userInviteResponseCallback:)
                   name:USER_INVITE_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onLogoutResponse:)
                   name:kSFIDidLogoutNotification
                 object:nil];
    
}


- (void)sendUserProfileRequest {
    NSMutableDictionary * data = [NSMutableDictionary new];
    [[SecurifiToolkit sharedInstance] asyncSendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED commandString:@"UserProfileRequest" payloadData:data];
}


- (void)userProfileResponseCallback:(id)sender {
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[data valueForKey:@"data"] options:kNilOptions error:&error];
    
    NSString *commandType = [dictionary valueForKey:COMMAND_TYPE];
    if(![commandType isEqualToString:@"UserProfileResponse"])
        return;
    
    NSString* success = [dictionary objectForKey:@"Success"];
    
    if ([success isEqualToString:@"true"]) {
        self.userName = [[dictionary objectForKey:@"FirstName"] stringByAppendingString:[dictionary objectForKey:@"LastName"]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}


-(NSArray *)getFeaturesArray{
    NSMutableArray *moreFeatures = [NSMutableArray new];
    [moreFeatures addObject:@{@"rule_forward_icon":NSLocalizedString(@"rules", @"")}];
    if(!self.isLocal && [AlmondManagement hasAtleaseOneAL3])
        [moreFeatures addObject:@{@"subscriptions_icon":NSLocalizedString(@"my_subscriptions", @"")}];
    
    NSString *addAlmondText = self.isLocal? NSLocalizedString(@"add_almond", @""): NSLocalizedString(@"link_almond_account", @"");
    [moreFeatures addObject:@{@"link_almond_icon":addAlmondText}];
    if(!self.isLocal)
        [moreFeatures addObject:@{@"almond_sharing_icon":NSLocalizedString(@"almond_sharing", @"")}];
    [moreFeatures addObject:@{@"help_center_icon":NSLocalizedString(@"help_center", @"")}];
    return moreFeatures;
}


#pragma mark check methods
-(BOOL)isFirmwareCompatible{
    return [SFIAlmondPlus checkIfFirmwareIsCompatible:[AlmondManagement currentAlmond]];
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isLocal ?2: 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isLocal){
        return section == 0? self.moreFeatures.count: 1;
    }else{
        return section == 1? self.moreFeatures.count: 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreCellTableViewCell *cell;
    NSInteger section = indexPath.section;
    if(self.isLocal){
        if(section == 0){
            cell = [self getMorecell:tableView identifier:@"morecell2" indexPath:indexPath accessory:YES];
            [cell setUpMoreCell2:self.moreFeatures[indexPath.row]];
        }
        else if(section == 1){
            cell = [self getMorecell:tableView identifier:@"morecell3" indexPath:indexPath accessory:NO];
            [cell setUpMoreCell3];
        }
    }else{
        if(section == 0){//accounts
            cell = [self getMorecell:tableView identifier:@"morecell1" indexPath:indexPath accessory:YES];
            [cell setUpMoreCell1:self.userName];
        }
        else if(section == 1){//various paths
            cell = [self getMorecell:tableView identifier:@"morecell2" indexPath:indexPath accessory:YES];
            [cell setUpMoreCell2:self.moreFeatures[indexPath.row]];
        }
        else if(section == 2){//app rating
            cell = [self getMorecell:tableView identifier:@"morecell4" indexPath:indexPath accessory:NO];
            [cell setUpMoreCell4:[SFIColors ruleBlueColor] title:NSLocalizedString(@"rate_app", @"")];
        }
        else if(section == 3){//logout
            cell = [self getMorecell:tableView identifier:@"morecell4" indexPath:indexPath accessory:NO];
            [cell setUpMoreCell4:[UIColor redColor] title:NSLocalizedString(@"log_out", @"")];
        }
        else if(section == 4){//logout all
            cell = [self getMorecell:tableView identifier:@"morecell5" indexPath:indexPath accessory:NO];
        }
        else if(section == 5){//app version
            cell = [self getMorecell:tableView identifier:@"morecell3" indexPath:indexPath accessory:NO];
            [cell setUpMoreCell3];
            
        }
    }
    return cell;
}


- (MoreCellTableViewCell *)getMorecell:(UITableView *)tableView identifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath accessory:(BOOL)accessory{
    MoreCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MoreCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(accessory)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isLocal){
        return 40;
    }else{
        return indexPath.section == 0? 80: 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 && ![self isFirmwareCompatible])
        return 80;
    else
        return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0 && ![self isFirmwareCompatible]){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 79)];
        [CommonMethods setLableProperties:label text:NSLocalizedString(@"update_fimware", @"") textColor:[UIColor blackColor] fontName:@"Avenir-Light" fontSize:16 alignment:NSTextAlignmentCenter];
        [headerView addSubview:label];
        [CommonMethods addLineSeperator:headerView yPos:headerView.frame.size.height-1];
        return headerView;
    }else{
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
        headerView.backgroundColor = [UIColor whiteColor];
        [CommonMethods addLineSeperator:headerView yPos:headerView.frame.size.height-1];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.backgroundColor = [SFIColors lineColor];
    return lineView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(self.isLocal){
        if(section == 0)
            [self callControllersOnRowSelection:row];
    }else{
        if(section == 0){
            // Delegate to the main view, which will manage presenting the account controller
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_ACCOUNTS object:nil]];
        }
        else if(section == 1){
            [self callControllersOnRowSelection:row];
        }
        else if(section == 2){
            //app rating
            NSLog(@"app rating here");
            [self gotoReviews];
        }
        else if(section == 3){
            //main view will catch the response.
            [self addHud:NSLocalizedString(@"logout_hud", @"")];
            [self showHudWithTimeout];
            [self asyncSendLogout];
        }
    }
}


- (void)asyncSendLogout {
    SecurifiToolkit* toolkit  = [SecurifiToolkit sharedInstance];
    if (toolkit.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }
    
    if (toolkit.isNetworkOnline) {
        [self asyncRequestDeregisterForNotification];
        
        GenericCommand *cmd = [GenericCommand new];
        cmd.commandType = CommandType_LOGOUT_COMMAND;
        cmd.command = nil;
        
        [toolkit asyncSendToNetwork:cmd];
    }
    else {
        // Not connected, so just purge on-device credentials and cache
        [toolkit onLogoutResponse];
    }
}


- (void)asyncRequestDeregisterForNotification {
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (![KeyChainAccess isSecApnTokenRegistered]) {
        NSLog(@"asyncRequestRegisterForNotification : no device token to deregister");
        return;
    }
    
    NSString *deviceToken = [KeyChainAccess secRegisteredApnToken];
    if (deviceToken == nil) {
        NSLog(@"asyncRequestRegisterForNotification : device toke is nil");
        return;
    }
    
    NotificationDeleteRegistrationRequest *req = [NotificationDeleteRegistrationRequest new];
    req.regID = deviceToken;
    req.platform = @"iOS";
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_DEREGISTRATION;
    cmd.command = req;
    [toolkit asyncSendToNetwork:cmd];
}


#pragma mark action methods
- (void)gotoReviews{
    NSLog(@"gotoReviews");
    NSString *str;
    NSString *appID = @"908025757"; //got it from itunes under Apple ID
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"version : %f", ver);
    if (ver >= 7.0 && ver < 7.1) {
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appID];
    } else if (ver >= 8.0) {
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",appID];
    } else {
        str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appID];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}


//need to bind with enums
-(void)callControllersOnRowSelection:(NSInteger)row{
    NSDictionary *feature = self.moreFeatures[row];
    NSString *rowVal = feature.allValues.firstObject;
    
    if([rowVal isEqualToString:NSLocalizedString(@"rules", @"")]){
        RulesTableViewController *controller = (RulesTableViewController *)[self getStoryBoardController:@"Rules" ctrlID:@"RulesTableViewController"];
        [self setMoreBackButton];
        [self pushViewController:controller];
        
    }else if([rowVal isEqualToString:NSLocalizedString(@"my_subscriptions", @"")]){
        if(_subscriptionsPage == nil)
            _subscriptionsPage = [self getStoryBoardController:@"SiteMapStoryBoard" ctrlID:@"MySubscriptionsViewController"];
        [self pushViewController:_subscriptionsPage];
        
    }else if([rowVal isEqualToString:NSLocalizedString(@"add_almond", @"")] || [rowVal isEqualToString:NSLocalizedString(@"link_almond_account", @"")]){
        if(self.isLocal){
            RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
            editor.delegate = self;
            editor.makeLinkedAlmondCurrentOne = YES;
            UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
            [self presentViewCtrl:ctrl];
        }else{
            UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
            [self presentViewCtrl:ctrl];
        }
    }
    else if([rowVal isEqualToString:NSLocalizedString(@"almond_sharing", @"")]){
        if(!self.isLocal){
            [self shareAlmondTapped];
        }
    }
    else if([rowVal isEqualToString:NSLocalizedString(@"help_center", @"")]){
        HelpCenter *helpCenter = (HelpCenter *)[self getStoryBoardController:@"HelpScreenStoryboard" ctrlID:@"HelpCenter"];
        [self pushViewController:helpCenter];
    }
}


-(void)pushViewController:(UIViewController *)viewCtrl{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewCtrl animated:YES];
    });
}

-(void)presentViewCtrl:(UIViewController *)ctrl{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ctrl animated:YES completion:nil];
    });
}

-(id)getStoryBoardController:(NSString *)storyBoardName ctrlID:(NSString*)ctrlID{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    id controller = [storyboard instantiateViewControllerWithIdentifier:ctrlID];
    return controller;
}

-(void)setMoreBackButton{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"more", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}
#pragma mark tableviewcell delegates
-(void)onLogoutTapDelegate{
    NSLog(@"onLogoutTapDelegate");
    //disabled button touch in storyboard
    //moved code to did select row
}

- (void)onLogoutResponse:(id)sender {
    //dismissing controller code is in mainviewcontroller
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

-(void)onLogoutAllTapDelegate{
    [self presentLogoutAllView];
}


#pragma mark - SFILogoutAllDelegate method

- (void)presentLogoutAllView {
    // Delegate to the main view, which will manage presenting the logout all controller
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_LOGOUT_ALL object:nil]];
}


#pragma mark - RouterNetworkSettingsEditorDelegate methods
- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [self dismissNetWorkSettingView:editor];
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [self dismissNetWorkSettingView:editor];
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    [self dismissNetWorkSettingView:editor];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    [self dismissNetWorkSettingView:editor];
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {
    //can't unlink here
}

-(void)dismissNetWorkSettingView:(RouterNetworkSettingsEditor *)editor{
    dispatch_async(dispatch_get_main_queue(), ^{
        [editor dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark almond sharing
- (void)shareAlmondTapped{
    if([AlmondManagement currentAlmond] == nil){
        [self showToast:NSLocalizedString(@"almond_share_control", @"")];
        return;
    }
    
    //Invitation Email Input Box
    NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"almond_share_invite", @""), [AlmondManagement currentAlmond].almondplusName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.title", @"Invite By Email") message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.Invite", @"Invite"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = USER_INVITE_ALERT;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
}


#pragma  mark - Alertview delgate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSLog(@"alertViewShouldEnableFirstOtherButton");
    UITextField *textField = [alertView textFieldAtIndex:0];
    BOOL flag = TRUE;
    if (textField.text.length == 0) {
        flag = FALSE;
    }
    return flag;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button Index =%ld", (long) buttonIndex);
    
    if (alertView.tag == USER_INVITE_ALERT) {
        if (buttonIndex == 1) {  //Invite user to share Almond
            UITextField *emailID = [alertView textFieldAtIndex:0];
            NSLog(@"emailID: %@", emailID.text);
            //Send request to delete
            [self sendUserInviteRequest:emailID.text almondMAC:[AlmondManagement currentAlmond].almondplusMAC];
        }
    }
}

- (void)sendUserInviteRequest:(NSString *)emailID almondMAC:(NSString *)almondMAC {
    [self addHud:NSLocalizedString(@"accounts.hud.inviteUserToShareAlmond", @"Inviting user to share Almond...")];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestInviteForSharingAlmond:almondMAC inviteEmail:emailID];
}

- (void)userInviteResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    UserInviteResponse *obj = (UserInviteResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if (obj.isSuccessful) {
        [self showToast:@"Successfully Updated!"];
    }
    else {
        NSLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;
                
            case 2:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode2", @"This user does not have a Securifi account.");
                break;
                
            case 3:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode3", @"The user has not verified the Securifi account yet.");
                break;
                
            case 4:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode4", @"You do not own this almond.");
                break;
                
            case 5:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode5", @"You need to fill all the fields.");
                break;
                
            case 6:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode6", @"You have already shared this almond with the user.");
                break;
                
            case 7:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode7", @"You can not add yourself as secondary user.");
                break;
                
                
            default:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.default", @"Sorry! Sharing of Almond was unsuccessful.");
                break;
                
        }
        [self showToast:failureReason];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

#pragma mark - HUD mgt
- (void)addHud:(NSString *)text{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = text;
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
}

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

#pragma mark profile image methods
-(void)onImageTapDelegate:(UIButton *)button{
    NSLog(@"onImageTapDelegate");
    [self presentPhotoLibrary];
}

-(void)presentPhotoLibrary{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:imagePickerController animated:YES completion:nil];
    });
}

#pragma mark image delegate
// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //Or you can get the image url from AssetsLibrary
    //    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    NSLog(@"image: %@", image);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self saveImage:image withFileName:PROFILE_PIC ofType:@"jpg" inDirectory:documentsDirectory];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
    
}


-(void)loadProfileImage{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", PROFILE_PIC, @"jpg"]];
    NSLog(@"image path: %@", imgPath);
    //image should be fetched from accounts command
    if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]){
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
        NSLog(@"image: %@", image);
        [self saveImage:image withFileName:PROFILE_PIC ofType:@"jpg" inDirectory:documentsDirectory];
    }
    else{
        [self saveImage:[UIImage imageNamed:@"default_user_image"] withFileName:PROFILE_PIC ofType:@"jpg" inDirectory:documentsDirectory];
    }
}

-(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

//currently not being used, should be used when user wants to delete his dp
- (void)removeImage:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        UIAlertView *removedSuccessFullyAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removedSuccessFullyAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

#pragma mark Notifications
- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)onAlmondListDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

@end
