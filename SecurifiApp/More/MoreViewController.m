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

#define USER_INVITE_ALERT               0

@interface MoreViewController ()<MoreCellTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RouterNetworkSettingsEditorDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic) NSArray *moreFeatures;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString *userName;
@property (nonatomic) BOOL isLocal;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    NSLog(@"more controller view did load");
    [super viewDidLoad];
    self.title = @"More";
    self.userName = @"";
    [self loadProfileImage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"i am called");
    self.isLocal = [[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local;
    self.moreFeatures= [self getFeaturesArray];
    [self initializeNotification];
    
    if(!self.isLocal)
        [self sendUserProfileRequest];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
    });
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
                   name:USER_PROFILE_NOTIFIER
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
}

- (void)sendUserProfileRequest {
    UserProfileRequest *userProfileRequest = [[UserProfileRequest alloc] init];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_USER_PROFILE_REQUEST;
    cloudCommand.command = userProfileRequest;
    
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cloudCommand];
}

- (void)userProfileResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    UserProfileResponse *obj = (UserProfileResponse *) [data valueForKey:@"data"];
    NSLog(@"User profile response: %@", obj);
    if (obj.isSuccessful) {
        //Store user profile information
        self.userName = [NSString stringWithFormat:@"%@ %@", obj.firstName, obj.lastName];
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });
    }
    else {
        DLog(@"Reason Code %d", obj.reasonCode);
    }
}

-(NSArray *)getFeaturesArray{
    NSMutableArray *moreFeatures = [NSMutableArray new];
    [moreFeatures addObject:@{@"rule_forward_icon":@"Rules"}];
    NSString *addAlmondText = self.isLocal? @"Add Almond": @"Link Almond to Account";
    [moreFeatures addObject:@{@"link_almond_icon":addAlmondText}];
    if(!self.isLocal)
        [moreFeatures addObject:@{@"help_center_icon":@"Almond Sharing"}];
    [moreFeatures addObject:@{@"almond_sharing_icon":@"Help Center"}];
    return moreFeatures;
}

#pragma mark check methods
-(BOOL)isFirmwareCompatible{
    return [SFIAlmondPlus checkIfFirmwareIsCompatible:[SecurifiToolkit sharedInstance].currentAlmond];
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isLocal ?2: 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isLocal){
        return section == 0? 3: 1;
    }else{
        return section == 1? 4: 1;
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
        if(section == 0){
            cell = [self getMorecell:tableView identifier:@"morecell1" indexPath:indexPath accessory:YES];
            [cell setUpMoreCell1:self.userName];
        }
        else if(section == 1){
            cell = [self getMorecell:tableView identifier:@"morecell2" indexPath:indexPath accessory:YES];
            [cell setUpMoreCell2:self.moreFeatures[indexPath.row]];
        }
        else if(section == 2){
            cell = [self getMorecell:tableView identifier:@"morecell3" indexPath:indexPath accessory:NO];
            [cell setUpMoreCell3];
        }
        else if(section == 3){
            cell = [self getMorecell:tableView identifier:@"morecell4" indexPath:indexPath accessory:NO];
        }
        else if(section == 4){
            cell = [self getMorecell:tableView identifier:@"morecell5" indexPath:indexPath accessory:NO];
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
        [CommonMethods setLableProperties:label text:@"The Almond firmware needs to be updated to remain compatible with this version of the app." textColor:[UIColor blackColor] fontName:@"Avenir-Light" fontSize:16 alignment:NSTextAlignmentCenter];
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
        else if(section == 3){
            //main view will catch the response.
            [self addHud:@"Logging out. Please wait!"];
            [self showHudWithTimeout];
            [[SecurifiToolkit sharedInstance] asyncSendLogout];
        }
    }
}

-(void)callControllersOnRowSelection:(NSInteger)row{
    if(row == 0){//rules
        RulesTableViewController *controller = (RulesTableViewController *)[self getStoryBoardController:@"Rules" ctrlID:@"RulesTableViewController"];
        [self setMoreBackButton];
        [self pushViewController:controller];
    }
    else if(row == 1){//add almond
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
    
    else if(row == 2){//help center
        if(self.isLocal){
            HelpCenter *helpCenter = (HelpCenter *)[self getStoryBoardController:@"HelpScreenStoryboard" ctrlID:@"HelpCenter"];
            [self pushViewController:helpCenter];
        }else{
            [self shareAlmondTapped];
        }
    }
    
    else if(row == 3){
        HelpCenter *helpCenter = (HelpCenter *)[self getStoryBoardController:@"HelpScreenStoryboard" ctrlID:@"HelpCenter"];
        [self.navigationController pushViewController:helpCenter animated:YES];
        //[self pushViewController:helpCenter];
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
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}
#pragma mark tableviewcell delegates
-(void)onLogoutTapDelegate{
    NSLog(@"onLogoutTapDelegate");
    //disabled button touch in storyboard
    //moved code to did select row
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
    if([[SecurifiToolkit sharedInstance] currentAlmond] == nil){
        [self showToast:@"Please add an Almond to share its control."];
        return;
    }
    
    //Invitation Email Input Box
    NSString *alertMessage = [NSString stringWithFormat:@"Share control of %@ by sending an invitation over email", [SecurifiToolkit sharedInstance].currentAlmond.almondplusName];
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
            [self sendUserInviteRequest:emailID.text almondMAC:[SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC];
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