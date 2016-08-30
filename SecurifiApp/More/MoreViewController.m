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

@interface MoreViewController ()<MoreCellTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RouterNetworkSettingsEditorDelegate>
@property (nonatomic) NSArray *moreFeatures;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString *userName;
@property (nonatomic) BOOL isLocal;
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
    
}

- (void)sendUserProfileRequest {
    UserProfileRequest *userProfileRequest = [[UserProfileRequest alloc] init];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_USER_PROFILE_REQUEST;
    cloudCommand.command = userProfileRequest;

    
    [[SecurifiToolkit sharedInstance] asyncSendCommand:cloudCommand];
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
        NSLog(@"image account: %@", [UIImage imageNamed:@"help_center_icon"]);
        [self saveImage:[UIImage imageNamed:@"help_center_icon"] withFileName:PROFILE_PIC ofType:@"jpg" inDirectory:documentsDirectory];
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
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    headerView.backgroundColor = [UIColor whiteColor];
    [CommonMethods addLineSeperator:headerView yPos:headerView.frame.size.height-1];
    return headerView;
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
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_ACCOUNTS object:nil]];
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
    [[SecurifiToolkit sharedInstance] asyncSendLogout];
    //main view will catch the response.
}

-(void)onLogoutAllTapDelegate{
    [self presentLogoutAllView];
}

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

@end
