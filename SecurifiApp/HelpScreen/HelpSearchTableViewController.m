//
//  HelpSearchTableViewController.m
//  SecurifiApp
//
//  Created by Masood on 11/7/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpSearchTableViewController.h"
#import "CommonMethods.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "NSString+securifi.h"
#import "HelpViewController.h"
#import "SFIColors.h"

#define HEADER_TITLE @"headerTitle"
#define TOPIC_ICON  @"topicIcon"
#define ITEMS_ARRAY @"itemsArray"


static const int headerHeight = 40;

@interface HelpSearchTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchfBar;
@property (nonatomic) NSDictionary *helpItems;
@property (nonatomic) NSMutableArray *searchArray;
@end

@implementation HelpSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.helpItems = [[CommonMethods parseJson:@"helpCenterJson"] valueForKey:@"HelpItems"];
    [self initializeSearchArray];
    NSLog(@"HelpSearchTableViewController");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *searchItem = self.searchArray[section];
    NSArray *itemsArray = searchItem[ITEMS_ARRAY];
    return itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight-1)];
    NSDictionary *searchItem = self.searchArray[section];

    [CommonMethods setLableProperties:label text:NSLocalizedString(searchItem[HEADER_TITLE], @"") textColor:[UIColor lightGrayColor] fontName:@"Avenir-Heavy" fontSize:18 alignment:NSTextAlignmentCenter];
    [headerView addSubview:label];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *searchItem = self.searchArray[indexPath.section];
    NSArray *itemsArray = searchItem[ITEMS_ARRAY];
    cell.textLabel.text = NSLocalizedString([itemsArray[indexPath.row] valueForKey:S_NAME], @"");
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
    HelpViewController *ctrl = [storyBoard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    NSDictionary *searchItem = self.searchArray[indexPath.section];
    NSArray *itemsArray = searchItem[ITEMS_ARRAY];
    
    ctrl.startScreen = [itemsArray objectAtIndex:indexPath.row];
    ctrl.isHelpTopic = [self isHelpTopic:NSLocalizedString(searchItem[HEADER_TITLE], @"")];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ctrl animated:YES completion:nil];
    });
}

- (BOOL)isHelpTopic:(NSString *)title{
    NSLog(@"title: %@", title);
    if([title isEqualToString:@"Help Topics"]){
        return YES;
    }
    return NO;
}

#pragma mark search delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchBar textDidChange: %@", searchText);
    self.searchArray = [NSMutableArray new];
    if(searchText.length == 0){
        [self initializeSearchArray];
        return;
    }
    
    for(NSDictionary *helpItem in self.helpItems){
        NSMutableArray *itemsArray = [NSMutableArray new];
        NSString *helpItemName = NSLocalizedString(helpItem[S_NAME], @"");
        NSLog(@"help item name: %@", helpItemName);
        if([helpItemName isEqualToString:@"Support"]){
            continue;
        }
        for(NSDictionary *item in helpItem[ITEMS]){
            NSString *itemName = NSLocalizedString(item[S_NAME], @"");
            if([itemName containsString:searchText]){
                [itemsArray addObject:item];
                continue;
            }

            for(NSDictionary *screen in item[SCREENS]){
                NSString *screenTitle = NSLocalizedString(screen[TITLE], @"");
                NSString *screenDesc = NSLocalizedString(screen[DESCRIPTION], @"");
                if([screenTitle containsString:searchText] || [screenDesc containsString:searchText]){
                    [itemsArray addObject:item];
                    break;
                }
            }
        }
        if(itemsArray.count > 0)
            [self addItemsToDict:helpItem itemsArray:itemsArray];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)initializeSearchArray{
    self.searchArray = [NSMutableArray new];
    for(NSDictionary *helpItem in self.helpItems){
        NSMutableArray *itemsArray = [NSMutableArray new];
        NSString *helpItemName = NSLocalizedString(helpItem[S_NAME], @"");
        if([helpItemName isEqualToString:NSLocalizedString(@"Support", @"")]){
            continue;
        }
        for(NSDictionary *item in helpItem[ITEMS]){
            [itemsArray addObject:item];
        }
        [self addItemsToDict:helpItem itemsArray:itemsArray];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)addItemsToDict:(NSDictionary *)helpItem itemsArray:(NSArray *)itemsArray{
    NSDictionary *searchItem = @{HEADER_TITLE: helpItem[S_NAME],
                                 TOPIC_ICON: helpItem[S_ICON],
                                 ITEMS_ARRAY: itemsArray};
    NSLog(@"search item: %@", searchItem);
    [self.searchArray addObject:searchItem];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
   NSLog(@"searchBarTextDidBeginEditing");
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked");
    [searchBar resignFirstResponder];
}

#pragma mark action event
- (IBAction)onCrossBtnTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


@end
