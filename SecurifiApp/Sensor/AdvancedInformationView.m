//
//  AdvancedInformationView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 06/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "AdvancedInformationView.h"
#import "ClientPropertiesCell.h"
@interface AdvancedInformationView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic)UITableView *tableView;
@property (nonatomic)NSMutableArray *displayArray_copy;
@end
@implementation AdvancedInformationView
-(id)initWithFrame:(CGRect)frame{
     self = [super initWithFrame:frame];
    if(self){
         [self drawTable];
    }
    return self;
}
-(void)drawTable{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 36, self.frame.size.width, self.frame.size.height - 160)];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.alwaysBounceVertical = NO ;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
    [self addSubview:self.tableView];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayArray_copy.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClientPropertiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ClientPropertiesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SKSTableViewCell"];
    }
    
    cell.vsluesLabel.text = @"";
    cell.displayLabel.text = @"";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}
@end
