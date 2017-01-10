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
#import "AlmondManagement.h"

static const int rowHeight = 40;
static const int headerHt = 70;
static const int footerHt = 60;


@interface AlmondSelectionTableView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic)NSArray *almondList;
@end

@implementation AlmondSelectionTableView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)initializeView:(CGRect)maskFrame{
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bounces = NO;
    NSLog(@"i am called");
    enum SFIAlmondConnectionMode modeValue = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    self.almondList = [self buildAlmondList:modeValue];
    self.frame = CGRectMake(0, CGRectGetHeight(maskFrame)-[self getHeight], CGRectGetWidth(maskFrame), [self getHeight]);
}

-(CGFloat)getHeight{
    if([self hasNoAlmond])
        return headerHt+footerHt+40+10;
    
    if(self.almondList.count >= 4)
        return 300;
    
    int footerHeight = self.needsAddAlmond?footerHt:0;
    int baseHt = headerHt + footerHeight;
    NSInteger rowsHt = self.almondList.count * rowHeight;
    return baseHt +rowsHt + 10;
}

- (NSArray *)buildAlmondList:(enum SFIAlmondConnectionMode)mode5 {
    switch (mode5) {
        case SFIAlmondConnectionMode_cloud: {
            NSArray *cloud = [AlmondManagement almondList];
            if (!cloud)
                cloud = @[];
            
            if(!self.needsAddAlmond)
                cloud = [AlmondManagement getPrimaryAL3s:cloud];
            
            return cloud;
        }
        case SFIAlmondConnectionMode_local: {
            NSArray *local = [AlmondManagement localLinkedAlmondList];
            if (!local)
                local = @[];
            return local;
        }
        default:
            return @[];
    }
}



#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self hasNoAlmond]? 1: self.almondList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Almond selection cell for row");
    if([self hasNoAlmond])
        return [self createNoAlmondCell:(UITableView *)tableView];
    
    AlmondSelectionCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"almondCell"];
    
    if (cell == nil) {
        cell = [[AlmondSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"almondCell"];
        [cell initializeCell:self.frame];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SFIAlmondPlus *almond = self.almondList[indexPath.row];
    [cell setUpCell:almond.almondplusName isCurrent:[self isCurrentAlmond:almond.almondplusMAC]];
    return cell;
}

-(UITableViewCell *)createNoAlmondCell:(UITableView *)tableView{
    NSLog(@"no almond cell");
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"noAlmond"];
    
    if (cell == nil) {
        cell = [[AlmondSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noAlmond"];
        cell.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), rowHeight);
        UILabel *noAlmondLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), rowHeight)];
        [CommonMethods setLableProperties:noAlmondLbl text:@"Tap on below button to add an Almond." textColor:[SFIColors helpTextDescription] fontName:@"Avenir-Roman" fontSize:15 alignment:NSTextAlignmentCenter];
        [cell addSubview:noAlmondLbl];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.almondList.count == 0)
        return;
    
    [self.methodsDelegate onAlmondSelectedDelegate:self.almondList[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return headerHt;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, headerHt)];
    headerBgView.backgroundColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, 40)];
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [CommonMethods setButtonProperties:closeButton title:@"Close" titleColor:[SFIColors lightBlueColor] bgColor:[UIColor whiteColor] font:[UIFont securifiFont:16]];
    [closeButton addTarget:self action:@selector(onCloseBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeButton];
    
    UILabel *selectAlmond = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
    selectAlmond.center = CGPointMake(headerView.bounds.size.width/2, selectAlmond.center.y);
    [CommonMethods setLableProperties:selectAlmond text:@"Select Almond" textColor:[UIColor blackColor] fontName:@"Avenir-Heavy" fontSize:18 alignment:NSTextAlignmentCenter];
    [headerView addSubview:selectAlmond];
    
    [CommonMethods addLineSeperator:headerBgView yPos:49];
    [CommonMethods addLineSeperator:headerBgView yPos:64];
    
    [headerBgView addSubview:headerView];
    return headerBgView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return self.needsAddAlmond? footerHt: 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(self.needsAddAlmond == NO)
        return [[UIView alloc]initWithFrame:CGRectZero];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, footerHt)];
    footerView.backgroundColor = [UIColor whiteColor];
    [CommonMethods addLineSeperator:footerView yPos:0];
    
    UIButton *addAlmond = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width-20, 40)];
    [CommonMethods setButtonProperties:addAlmond title:@"Add Almond" titleColor:[UIColor whiteColor] bgColor:[SFIColors lightBlueColor] font:[UIFont securifiFont:16]];
    [addAlmond addTarget:self action:@selector(onAddAlmondTap:) forControlEvents:UIControlEventTouchUpInside];
    addAlmond.backgroundColor = [SFIColors lightBlueColor];
    [footerView addSubview:addAlmond];
    
    return footerView;
}


#pragma mark button tap methods
- (void)onCloseBtnTap:(id)sender{
    [self.methodsDelegate onCloseBtnTapDelegate];
}

- (void)onAddAlmondTap:(id)sender{
    [self.methodsDelegate onAddAlmondTapDelegate];
}

#pragma mark helper methods
-(BOOL)isCurrentAlmond:(NSString *)mac{
    return [self.currentMAC isEqualToString:mac];
}

-(BOOL)hasNoAlmond{
    return [AlmondManagement currentAlmond] == nil;
}

@end
