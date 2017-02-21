//
//  ClientTableViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "ClientTableViewController.h"
#import "ClientTypeTableViewCell.h"

@interface ClientTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *typeTable;
@property (nonatomic)NSMutableArray *displayArray;
@property (nonatomic)NSMutableArray *valueArr;
@property (nonatomic)NSMutableArray *displayArray_copy;
@property (nonatomic)NSMutableArray *valueArr_copy;
@property (nonatomic )NSArray *iconArr;
@property (nonatomic)NSString *selectedType;
@property (nonatomic)NSMutableDictionary *displayText_value;
@end

@implementation ClientTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"Device Type";
    self.valueArr = [[NSMutableArray alloc] init];
    self.displayArray = [[NSMutableArray alloc] init];
    self.valueArr_copy = [[NSMutableArray alloc] init];
    self.displayArray_copy = [[NSMutableArray alloc] init];
    
    self.selectedType = self.genericIndexValue.genericValue.value;
    NSLog(@"self.selectedType %@",self.selectedType);
    NSLog(@" self.genericIndexValue.genericValue.value %@",self.genericIndexValue.genericValue.value);
    NSArray *devicePosKeys = self.genericIndexValue.genericIndex.values.allKeys;
    
    NSArray *sortedKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    NSMutableArray *iconArr = [NSMutableArray new];
    for(NSString *key in sortedKeys){
        if([key isEqualToString:@"identifying"])
            continue;
        GenericValue *gVal = [self.genericIndexValue.genericIndex.values valueForKey:key];
        
        //        if(!isAl3)
        //            if([self isIoTdevice:gVal.value])
        //                continue;
        
        [self.displayArray addObject:gVal.displayText];
        [self.valueArr addObject:gVal.value];
        [iconArr addObject:gVal.icon];
        [self.displayArray_copy addObject:gVal.displayText];
        [self.valueArr_copy addObject:key];
    }
    self.iconArr = iconArr;
     self.displayText_value = [[NSMutableDictionary alloc]initWithObjects:self.valueArr_copy forKeys:self.displayArray_copy];

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayArray_copy.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClientTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClientTypeTableViewCell"];
    if (cell == nil) {
        cell = [[ClientTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClientTypeTableViewCell"];
//        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 45);
    }
    int currentvalPos = 0;
    for(NSString *str in self.displayArray_copy){
        NSString *value = [self.displayText_value valueForKey:str];
        if([value isEqualToString:self.selectedType])
            break;
        currentvalPos++;
    }
     NSString *value = [self.displayText_value valueForKey:[self.displayArray_copy objectAtIndex:indexPath.row]];
    [cell writelabelName:[self.displayArray_copy objectAtIndex:indexPath.row] value:value icon:[self.iconArr objectAtIndex:indexPath.row]];
   
    if(currentvalPos == indexPath.row)
        [cell changeButtonColor:[self.iconArr objectAtIndex:indexPath.row]];
    else{
        
    }
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath{
    
    NSString *value = [self.displayText_value valueForKey:[self.displayArray_copy objectAtIndex:indexPath.row]];
    NSLog(@"didSelectRowAtIndexPath value = %@",value);
    [self selectedTypes:value];
    return;
}
#pragma mark cell delegate
-(void)selectedTypes:(NSString *)typeName{
    NSLog(@" typeName %@",typeName);
    self.selectedType = typeName;
    [self.typeTable reloadData];
    //[self.delegate save:typeName forGenericIndexValue:self.genericIndexValue currentView:self];
}


@end
