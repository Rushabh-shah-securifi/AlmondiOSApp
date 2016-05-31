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
@property (nonatomic)UITableView *tableType;
@property (nonatomic)NSString *selectedType;
@property (nonatomic)NSMutableArray *displayArray;
@property (nonatomic)NSMutableArray *valueArr;
@end

@implementation ListButtonView

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        self.valueArr = [[NSMutableArray alloc] init];
        self.displayArray = [[NSMutableArray alloc] init];
        [self drawTypeTable];
    }
    return self;
}

-(void)drawTypeTable{
    NSArray *devicePosKeys = self.genericIndexValue.genericIndex.values.allKeys;
    NSArray *sortedKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    for(NSString *key in sortedKeys){
        GenericValue *gVal = [self.genericIndexValue.genericIndex.values valueForKey:key];
        [self.displayArray addObject:gVal.displayText];
        [self.valueArr addObject:gVal.value];
    }
    
    NSLog(@"types %@",self.displayArray);
    self.selectedType = self.genericIndexValue.genericValue.value;
    NSLog(@" self.genericIndexValue.genericValue.value %@",self.genericIndexValue.genericValue.value);
    self.tableType = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 110)];
    [self.tableType setDataSource:self];
    [self.tableType setDelegate:self];
    self.tableType.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableType.allowsSelection = NO;
    self.tableType.alwaysBounceVertical = NO ;
    self.tableType.backgroundColor = self.color;
    [self.tableType reloadData];
    [self addSubview:self.tableType];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.valueArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    clientTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clientTypeCell"];
    if (cell == nil) {
        cell = [[clientTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientTypeCell"];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 45);
        [cell setupLabel];
    }
    int currentvalPos = 0;
    for(NSString *str in self.valueArr){
        if([str isEqualToString:self.selectedType])
            break;
        currentvalPos++;
    }
    
    cell.delegate = self;
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = self.color;
    [cell writelabelName:[self.displayArray objectAtIndex:indexPath.row] value:[self.valueArr objectAtIndex:indexPath.row]];
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
    [self selectedTypes:[self.valueArr objectAtIndex:indexPath.row]];
    return;
}
#pragma mark cell delegate
-(void)selectedTypes:(NSString *)typeName{
    NSLog(@" typeName %@",typeName);
    self.selectedType = typeName;
    [self.tableType reloadData];
    [self.delegate save:typeName forGenericIndexValue:self.genericIndexValue currentView:self];
}

-(void)setListValue:(NSString*)value{
    self.selectedType = value;
    [self.tableType reloadData];
}

@end