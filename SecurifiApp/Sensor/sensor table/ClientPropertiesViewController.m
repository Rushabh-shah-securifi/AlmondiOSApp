//
//  ClientPropertiesViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientPropertiesViewController.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"
#import "ClientPropertiesCell.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "DeviceHeaderView.h"
#import "DeviceEditViewController.h"

#define CELLFRAME CGRectMake(8, 11, self.view.frame.size.width -16, 60)

@interface ClientPropertiesViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)NSDictionary *ClientDict;
@end

@implementation ClientPropertiesViewController
NSMutableArray * blockedDaysArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self dummyNetWorkDeviceList];
    DeviceHeaderView *commonView = [[DeviceHeaderView alloc]initWithFrame:CELLFRAME];
    commonView.delegate = self;
    commonView.cellType = ClientEdit_Cell;
    // set up images label and name
    [self.view addSubview:commonView];
}
#pragma mark common cell delegate
-(void)delegateClientEditTable{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dummyNetWorkDeviceList{
    NSArray *type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    NSDictionary *dict1 = @{@"1" : @{   @"indexName" : @"Name",
                                        @"DisplayName" : @"Name",
                                        @"Value" : @"FromDevice",
                                        @"isEditable" : @"true"
                                        },
                            @"2" : @{   @"indexName" : @"Type",
                                        @"DisplayName" : @"Type",
                                        @"Value" : type,
                                        @"isEditable" : @"true"
                                        },
                            
                            @"3" :@{    @"indexName" : @"Manufacture",
                                        @"DisplayName" : @"Manufacture",
                                        @"Value" : @"FromDevice",
                                        @"isEditable" : @"false"
                                              },
                            
                            @"4" : @{@"indexName" : @"MAC",
                                     @"DisplayName" : @"MAC Address",
                                               @"Value" : @"FromDevice",
                                               @"isEditable" : @"false"
                                               },
                            @"5" : @{@"indexName" : @"LastKnownIP",
                                     @"DisplayName" : @"Last Known IP",
                                     @"Value" : @"FromDevice",
                                     @"isEditable" : @"false"
                                                 },
                            @"6" : @{@"indexName" : @"Strength",
                                     @"DisplayName" : @"Signal Strength",
                                     @"Value" : @"FromDevice",
                                     @"isEditable" : @"false"
                                                   },
                            @"7" : @{@"indexName" : @"Connection",
                                     @"DisplayName" : @"Connection",
                                     @"Value" : @"FromDevice",
                                     @"isEditable" : @"false"
                                              },
                            @"8" :@{@"indexName" : @"AllowedType",
                                    @"DisplayName" : @"Allow On network",
                                    @"Value" : @{
                                                           @"0" : @"always",
                                                           @"2" : @"onSchedule",
                                                           @"1" : @"blocked"
                                                           },
                                    @"isEditable" : @"true"
                                                   },
                            @"9" : @{@"indexName" : @"pesenceSensor",
                                      @"DisplayName" : @"Use as pesence sensor",
                                      @"Value" : @{     @"YES" : @"true",
                                                        @"NO" : @"false"
                                                      },
                                    @"isEditable" : @"true"
                                                         },
                            @"10" : @{@"indexName" : @"inActiveTimeOut",
                                      @"DisplayName" : @"InActiveTimeOut",
                                                   @"Value" : @"43",
                                                   @"isEditable" : @"true"
                                                   },
                            };
    self.ClientDict = @{
                              @"Name" : @"android02#",
                              @"Type" : @"TV",
                               @"Manufacture" : @"freedom",
                              @"MAC" : @"10.21.45.53.58",
                              @"LastKnownIP" : @"10.21.1.100",
                               @"Strength" : @"-33 dBm",
                               @"Connection" : @"wireLess",
                              @"pesenceSensor" : @"YES",
                              @"inActiveTimeOut" : @"32",
                              @"Schedule" : @"000600,063000,ffffff,000000,000000,009785,000200",
                              @"AllowedType" :@"0",
                              @"ID" : @"13"

                              
                              };
    self.clientProperties = dict1;
    self.orderedArray = [NSMutableArray arrayWithArray:[[self.clientProperties allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 intValue]==[obj2 intValue])
            return NSOrderedSame;
        
        else if ([obj1 intValue]<[obj2 intValue])
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
        
    }]];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderedArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
        ClientPropertiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSTableViewCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ClientPropertiesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SKSTableViewCell"];
            //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        }
    cell.displayLabel.text = [[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"DisplayName"];
    
    cell.vsluesLabel.alpha = 0.5;
    cell.userInteractionEnabled = NO;
    if([[[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"isEditable"] isEqualToString:@"true"]){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.vsluesLabel.alpha = 1;
        cell.userInteractionEnabled = YES;
    }
    cell.indexName =[[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"indexName"];
    //values
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.vsluesLabel.text = [self.ClientDict valueForKey:[[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"indexName"]];
                if([[[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"indexName"] isEqualToString:@"AllowedType"]){
                    if([[self.ClientDict valueForKey:@"AllowedType"] isEqualToString:@"0"])
                       cell.vsluesLabel.text = @"Never";
                    
                    else if([[self.ClientDict valueForKey:@"AllowedType"] isEqualToString:@"1"])
                        cell.vsluesLabel.text = @"Blocked";
                    else
                        cell.vsluesLabel.text = @"onSchedule";
                }

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //[self performSegueWithIdentifier:@"modaltodetails" sender:[self.eventsTable cellForRowAtIndexPath:indexPath]];
}

- (void)checkButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.clientPropertiesTable];
    NSIndexPath *indexPath = [self.clientPropertiesTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        [self tableView: self.clientPropertiesTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    ClientPropertiesCell *cell = (ClientPropertiesCell*)[tableView cellForRowAtIndexPath:indexPath];
    DeviceEditViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceEditViewController"];
    ctrl.isSensor = NO;
    [self.navigationController pushViewController:ctrl animated:YES];
//    self.indexName = cell.indexName;
//    [self drawViews];
}
@end
