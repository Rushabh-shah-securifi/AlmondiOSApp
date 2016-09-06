//
//  AlmondSelectionTableView.m
//  SecurifiApp
//
//  Created by Masood on 9/6/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondSelectionTableView.h"
#import "AlmondSelectionCell.h"
#import "CommonMethods.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"


@interface AlmondSelectionTableView()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation AlmondSelectionTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initializeView{
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor greenColor];
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Almond selection cell for row");
    AlmondSelectionCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"almondCell"];

    if (cell == nil) {
        cell = [[AlmondSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"almondCell"];
        [cell initializeCell:self.frame];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0)
        cell.backgroundColor = [UIColor orangeColor];
    else if(indexPath.row == 1)
        cell.backgroundColor = [UIColor redColor];
    [cell setUpCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width-10, 50)];
    headerView.backgroundColor = [UIColor yellowColor];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    closeButton.backgroundColor = [UIColor orangeColor];
    [CommonMethods setButtonProperties:closeButton title:@"Close" selector:@selector(onCloseBtnTap:) titleColor:[SFIColors lightBlueColor]];
    closeButton.titleLabel.font = [UIFont securifiFont:16];
    [headerView addSubview:closeButton];
    
    UILabel *selectAlmond = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
    selectAlmond.center = CGPointMake(headerView.bounds.size.width/2, selectAlmond.center.y);
    [CommonMethods setLableProperties:selectAlmond text:@"Select Almond" textColor:[UIColor blackColor] fontName:@"AvenirLTStd-Heavy" fontSize:16 alignment:NSTextAlignmentCenter];
    
    selectAlmond.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:selectAlmond];
    
    [CommonMethods addLineSeperator:headerView yPos:39];
    [CommonMethods addLineSeperator:headerView yPos:49];
    
    [headerBgView addSubview:headerView];
    return headerBgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    return footerView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark button tap methods
- (void)onCloseBtnTap:(id)sender{
    
}
@end
