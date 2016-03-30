//
//  ListButtonView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 18/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ListButtonView.h"
#import "clientTypeCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
@interface ListButtonView()<UITableViewDataSource,UITableViewDelegate,clientTypeCellDelegate>
@property (nonatomic) UITableView *tableType;
@property (nonatomic)NSString *selectedType;
@end
@implementation ListButtonView
NSArray *type;

-(void)drawTypeTable:selectedType{
    type = [[NSArray alloc]initWithObjects:@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other", nil];
    self.selectedType = selectedType;
    self.tableType = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 100)];
    [self.tableType setDataSource:self];
    [self.tableType setDelegate:self];
    //        [self.tableType registerClass:[clientTypeCell class] forCellReuseIdentifier:@"clientTypeCell"];
    self.tableType.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableType.allowsSelection = NO;
    self.tableType.alwaysBounceVertical = NO ;
    [self.tableType setAlwaysBounceVertical:NO];
    self.tableType.alwaysBounceHorizontal = NO;
    [self.tableType reloadData];
  
    //        self.indexView = self.tableType;
    [self addSubview:self.tableType];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return type.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    clientTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clientTypeCell"];
    if (cell == nil) {
        cell = [[clientTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientTypeCell"];
        [cell setupLabel];
        //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    int currentvalPos = 0;
    for(NSString *str in type){
        if([str isEqualToString:self.selectedType])
            break;
        currentvalPos++;
    }
    cell.delegate = self;
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.color = [SFIColors clientGreenColor];
    cell.backgroundColor = [SFIColors clientGreenColor];
    [cell writelabelName:[type objectAtIndex:indexPath.row]];
    if(currentvalPos == indexPath.row)
        [cell changeButtonColor];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath ");
    [self selectedTypes:[type objectAtIndex:indexPath.row]];
    return;
}
#pragma mark cell delegate
-(void)selectedTypes:(NSString *)typeName{
    NSLog(@" typeName %@",typeName);
    self.selectedType = typeName;
    [self.tableType reloadData];
}


@end
