//
//  SFIOptionViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIOptionViewController.h"

@interface SFIOptionViewController ()
@property(nonatomic, strong) SFIAlmondPlus *currentAlmond;
@end

@implementation SFIOptionViewController
@synthesize optionList, optionTitle, optionType;
@synthesize selectedOptionDelegate;
@synthesize currentOption;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.optionTitle;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.currentAlmond = [[SecurifiToolkit sharedInstance] currentAlmond];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidUpdateAlmondList object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFIDidUpdateAlmondList object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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


#pragma mark - Dynamic updates

- (void)onAlmondListDidChange:(id)sender {
    if (self.currentAlmond == nil) {
        return; // shouldn't happen
    }

    SFIAlmondPlus *plus = [[SecurifiToolkit sharedInstance] currentAlmond];
    if ([plus.almondplusMAC isEqualToString:self.currentAlmond.almondplusMAC]) {
        return; // no changes
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
