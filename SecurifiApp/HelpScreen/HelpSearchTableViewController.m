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

@interface HelpSearchTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchfBar;
@property (nonatomic) NSDictionary *helpItems;
@property (nonatomic) NSMutableArray *quickTipsItem;
@property (nonatomic) NSMutableArray *helpTopicsItem;
@end

@implementation HelpSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.helpItems = [[CommonMethods parseJson:@"helpCenterJson"] valueForKey:@"HelpItems"];
    NSLog(@"HelpSearchTableViewController");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _quickTipsItem.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.backgroundColor = [UIColor yellowColor];
    cell.textLabel.text = [self.quickTipsItem[indexPath.row] valueForKey:@"name"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark search delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchBar textDidChange: %@", searchText);
    _quickTipsItem = [NSMutableArray new];
    _helpTopicsItem = [NSMutableArray new];
    
    for(NSDictionary *helpItem in self.helpItems){
        NSString *helpItemName = NSLocalizedString(helpItem[S_NAME], @"");
        NSLog(@"help item name: %@", helpItemName);
        if([helpItemName isEqualToString:@"Quick Tips"] == NO){
            continue;
        }
        NSLog(@"cp 0");
        for(NSDictionary *item in helpItem[ITEMS]){
            NSLog(@"cp 1");
            NSString *itemName = NSLocalizedString(item[S_NAME], @"");
            NSLog(@"item name: %@", itemName);
            if([itemName containsString:searchText]){
                NSLog(@"cp 2");
                [self.quickTipsItem addObject:item];
                continue;
            }
            NSLog(@"cp 3");

            for(NSDictionary *screen in item[SCREENS]){
                NSLog(@"cp 4");
                NSString *screenTitle = NSLocalizedString(screen[TITLE], @"");
                NSString *screenDesc = NSLocalizedString(screen[DESCRIPTION], @"");
                if([screenTitle containsString:searchText] || [screenDesc containsString:searchText]){
                    [self.quickTipsItem addObject:item];
                    NSLog(@"cp 5");
                    break;
                }
            }
            NSLog(@"cp 6");
        }
    }
    
    NSLog(@"self.quicktipItems: %@", self.quickTipsItem);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    NSLog(@"quick tip item: %@", self.quickTipsItem);
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


@end
