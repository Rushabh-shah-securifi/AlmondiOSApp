//
//  SFIOptionViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIOptionViewController.h"
#import "SNLog.h"

@interface SFIOptionViewController ()

@end

@implementation SFIOptionViewController
@synthesize optionList, optionTitle, optionType;
@synthesize selectedOptionDelegate;
@synthesize currentOption;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.optionTitle;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(setWirelessOptionHandler:)];
//    self.navigationItem.rightBarButtonItem = saveButton;

//    self.tableView.separatorColor = [UIColor clearColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DynamicAlmondListDeleteCallback:)
                                                 name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [optionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, self.tableView.frame.size.width - 20, 40)];
    backgroundLabel.userInteractionEnabled = YES;
    //backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];

    UILabel *lblOption = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.tableView.frame.size.width, 20)];
    lblOption.backgroundColor = [UIColor clearColor];
    [lblOption setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];

    lblOption.text = optionList[(NSUInteger) indexPath.row];
    lblOption.textColor = [UIColor blackColor];

    [backgroundLabel addSubview:lblOption];
    [cell addSubview:backgroundLabel];

    if ([lblOption.text isEqualToString:self.currentOption]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *value = optionList[(NSUInteger) indexPath.row];
    [[self selectedOptionDelegate] optionSelected:value forOptionType:self.optionType];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (IBAction)setWirelessOptionHandler:(id)sender {
    //Call Delegate
}
*/


#pragma mark - Cloud command handlers

- (void)DynamicAlmondListDeleteCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];

            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *currentMAC = [prefs objectForKey:CURRENT_ALMOND_MAC];

            SFIAlmondPlus *deletedAlmond = [obj.almondPlusMACList objectAtIndex:0];
            if ([currentMAC isEqualToString:deletedAlmond.almondplusMAC]) {
                NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];

                if ([almondList count] != 0) {
                    SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
                    currentMAC = currentAlmond.almondplusMAC;
                    NSString *currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs synchronize];
                    self.navigationItem.title = currentMACName;
                }
                else {
                    self.navigationItem.title = @"Get Started";
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                    [prefs synchronize];
                }

                [self.navigationController popToRootViewControllerAnimated:YES];
            }

        }

    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
