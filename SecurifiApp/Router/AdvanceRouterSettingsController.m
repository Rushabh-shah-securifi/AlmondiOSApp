//
//  AdvanceRouterSettingsController.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvanceRouterSettingsController.h"
#import "AdvRouterTableViewCell.h"
#import "AdvRouterHelpController.h"

#define ADVANCE_ROUTER @"advance_router"
#define SUB_ADVANCE_ROUTER @"sub_advance_router"
#define TITLE @"title"
#define IS_EXPANDED @"is_expanded"

@interface AdvanceRouterSettingsController ()
@property (nonatomic) NSMutableArray *advRouterFeatuesArray;
@end

@implementation AdvanceRouterSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Advanced Features";
    [self initializeAdvRouterFeaturesArray];
    NSLog(@"router array: %@", self.advRouterFeatuesArray);
 
    // Do any additional setup after loading the view.
}

- (void)initializeAdvRouterFeaturesArray{
    NSArray *titles = @[@"VPN", @"Port Forwarding", @"DNS", @"Static IP Settings", @"UPnP"];
    self.advRouterFeatuesArray = [NSMutableArray new];
    for(NSString *title in titles){
        NSMutableDictionary *muDict = [NSMutableDictionary new];
        [muDict setObject:title forKey:TITLE];
        [muDict setObject:[NSNumber numberWithBool:NO] forKey:IS_EXPANDED];
        [self.advRouterFeatuesArray addObject:muDict];
    }
}
                    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.advRouterFeatuesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *routerFeature  = self.advRouterFeatuesArray[section];
    return [routerFeature[IS_EXPANDED] boolValue]? 3: 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 0? 50: 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    if(indexPath.row == 0){
        identifier = ADVANCE_ROUTER;
    }else{
        identifier = SUB_ADVANCE_ROUTER;
    }
    AdvRouterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[AdvRouterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *routerFeature  = self.advRouterFeatuesArray[indexPath.section];
    [cell setFeatureTitle:routerFeature[TITLE]];
    
    if([routerFeature[IS_EXPANDED] boolValue]){
        if(indexPath.row == 1)
            [cell setFeatureSubTitle:@"Open"];
        else
            [cell setFeatureSubTitle:@"Learn More"];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *routerFeature  = self.advRouterFeatuesArray[indexPath.section];
    if(indexPath.row == 0){
        NSNumber *isExpandedInvert = [NSNumber numberWithBool:![routerFeature[IS_EXPANDED] boolValue]];
        NSLog(@"invert: %@, did select router array: %@", isExpandedInvert, self.advRouterFeatuesArray);
        
        [routerFeature setObject:isExpandedInvert forKey:IS_EXPANDED];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if(indexPath.row == 1){
        
    }else{
        AdvRouterHelpController *ctrl = [AdvRouterHelpController new];
        ctrl.helpType = indexPath.section;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    
}


@end
