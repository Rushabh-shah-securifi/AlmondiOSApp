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

@interface MoreViewController ()<MoreCellTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) NSArray *moreFeatures;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    NSLog(@"more controller view did load");
    [super viewDidLoad];
    self.title = @"More";
    self.moreFeatures= @[@{@"rule_forward_icon":@"Rules"},
                           @{@"link_almond_icon":@"Link Almond to Account"},
                           @{@"help_center_icon":@"Help Center"}];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self saveImage:[UIImage imageNamed:@"canada"] withFileName:PROFILE_PIC ofType:@"jpg" inDirectory:documentsDirectory];
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1)
        return 3;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreCellTableViewCell *cell;
    NSInteger section = indexPath.section;
    if(section == 0){
        cell = [self getMorecell:tableView identifier:@"morecell1" indexPath:indexPath];
        [cell setUpMoreCell1];
    }
    else if(section == 1){
        cell = [self getMorecell:tableView identifier:@"morecell2" indexPath:indexPath];
        [cell setUpMoreCell2:self.moreFeatures[indexPath.row]];
    }
    else if(section == 2){
        cell = [self getMorecell:tableView identifier:@"morecell3" indexPath:indexPath];
        [cell setUpMoreCell3];
    }
    else if(section == 3){
        cell = [self getMorecell:tableView identifier:@"morecell4" indexPath:indexPath];
    }

    return cell;
}

- (MoreCellTableViewCell *)getMorecell:(UITableView *)tableView identifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath{
    MoreCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MoreCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.section == 2 || indexPath.section == 3)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)
        return 80;
    else
        return 40;
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
    if(section == 0){
        // Delegate to the main view, which will manage presenting the account controller
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UI_ON_PRESENT_ACCOUNTS object:nil]];
    }
    else if(section == 1){
        if(row == 0){//rules
            //will do it later
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
            RulesTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"RulesTableViewController"];
            //back button with empty title
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            [self.navigationItem setBackBarButtonItem:backItem];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if(row == 1){//add almond
            UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
            [self presentViewController:ctrl animated:YES completion:nil];
        }
        else if(row == 2){//help center
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
            HelpCenter *helpCenter = [storyboard instantiateViewControllerWithIdentifier:@"HelpCenter"];
            
//            [self presentViewController:helpCenter animated:YES completion:nil]; //nice way if you don't want tabbar.
            [self.navigationController pushViewController:helpCenter animated:YES];
        }
    }
}

#pragma mark tableviewcell delegates
-(void)onLogoutTapDelegate{
    NSLog(@"onLogoutTapDelegate");
    [[SecurifiToolkit sharedInstance] asyncSendLogout];
    //main view will catch the response.
}

-(void)onImageTapDelegate:(UIButton *)button{
    NSLog(@"onImageTapDelegate");
    [self presentPhotoLibrary];
}

-(void)presentPhotoLibrary{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
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
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
