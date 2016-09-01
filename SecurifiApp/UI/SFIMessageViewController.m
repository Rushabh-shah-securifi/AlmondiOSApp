//
//  SFIMessageViewController.m
//  SecurifiApp
//
//  Created by Matthew Sinclair-Day on 9/15/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIMessageViewController.h"
#import "MessageView.h"
#import "SFICloudLinkViewController.h"

@interface SFIMessageViewController () <MessageViewDelegate, RouterNetworkSettingsEditorDelegate>
@end

@implementation SFIMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Welcome";
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 400;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createNoAlmondCell:tableView];
}

- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    static NSString *no_almond_cell_id = @"NoAlmondCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        MessageView *view = [MessageView linkRouterMessage];
        view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 400);
        view.delegate = self;

        [cell addSubview:view];
    }

    return cell;
}

#pragma mark - MessageViewDelegate methods

- (void)messageViewDidPressButton:(MessageView *)msgView {
    enum SFIAlmondConnectionMode mode = [[SecurifiToolkit sharedInstance] currentConnectionMode];

    switch (mode) {
        case SFIAlmondConnectionMode_cloud: {
            UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
            [self presentViewController:ctrl animated:YES completion:nil];
            break;
        }
        case SFIAlmondConnectionMode_local: {
            [self presentLocalNetworkSettingsEditor];
            break;
        }
    }
}

@end
