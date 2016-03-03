//
//  ClientEditViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientEditViewController.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "SKSTableViewCellIndicator.h"
#import "ClientPropertiesCell.h"
#import "ClientEditPropertiesViewController.h"


@interface ClientEditViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewClientFields;

@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)NSDictionary *clientDeviceDict;

@end

@implementation ClientEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dummyNetWorkDeviceList];
//    [self drawClientField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                            @"8" :@{@"indexName" : @"Allow",
                                    @"DisplayName" : @"Allow On network",
                                    @"Value" : @{
                                                           @"always" : @"true",
                                                           @"Schedule" : @"false",
                                                           @"Never" : @"false"
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
    self.clientDeviceDict = @{
                              @"Name" : @"android02#",
                              @"Type" : @"TV",
                               @"Manufacture" : @"freedom",
                              @"MAC" : @"10.21.45.53.58",
                              @"LastKnownIP" : @"10.21.1.100",
                               @"Strength" : @"-33 dBm",
                               @"Connection" : @"wireLess",
                               @"Allow" : @"YES",
                              @"pesenceSensor" : @"YES",
                              @"inActiveTimeOut" : @"32",
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
    NSLog(@"self.orderedArray %@ ",self.orderedArray);
    
}

-(CGRect)adjustDeviceNameWidth:(NSString*)deviceName{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont securifiFont:16]};
    CGRect textRect;
    
    textRect.size = [deviceName sizeWithAttributes:attributes];
    if(deviceName.length > 18){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderedArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
   
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
    cell.vsluesLabel.text = [self.clientDeviceDict valueForKey:[[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"indexName"]];
        return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@" heightForRowAtIndexPath ");
    return 50;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"reaching accessoryButtonTappedForRowWithIndexPath:");
    //[self performSegueWithIdentifier:@"modaltodetails" sender:[self.eventsTable cellForRowAtIndexPath:indexPath]];
}

- (void)checkButtonTapped:(id)sender event:(id)event{
    NSLog(@"reaching accessoryButtonTappedForRowWithIndexPath:");
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
    NSLog(@" cell.display label %@",cell.indexName);
    NSLog(@"reaching accessoryButtonTappedForRowWithIndexPath:");
    ClientEditPropertiesViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"ClientEditPropertiesViewController"];
    ctrl.indexName = cell.indexName;
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

/*
 NewAddSceneViewController *newAddSceneViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewAddSceneViewController"];
 newAddSceneViewController.isInitialized = YES;
 newAddSceneViewController.scene = [self getScene:scenesArray[indexPath.row]];
 [self.navigationController pushViewController:newAddSceneViewController animated:YES];
 */
/*-(void)drawClientField{
    int yPos = 10;
    self.scrollViewClientFields.backgroundColor = [SFIColors clientGreenColor];
    NSArray *ordering = [self.connectedDevice allKeys];
    NSMutableArray *index = [[NSMutableArray alloc] init];
    NSEnumerator *sectEnum = [ordering objectEnumerator];
    id sKey;
    while((sKey = [sectEnum nextObject])) {
        if ([self.connectedDevice objectForKey:sKey] != nil ) {
            [index addObject:sKey];
        }
    }
    
    for(NSString *keys in index){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10 , yPos, self.scrollViewClientFields.frame.size.width -10, 40)];
        view.backgroundColor = [UIColor clearColor];
        [self.scrollViewClientFields addSubview:view];
        CGRect textRect = [self adjustDeviceNameWidth:keys];
        CGRect frame = CGRectMake(5 , 10, textRect.size.width + 10, 20);
        
        UILabel *label = [[UILabel alloc]initWithFrame:frame];
        label.text = keys;
        NSLog(@"keys %@ ",keys);
        label.font = [UIFont securifiFont:16];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        UIButton *valueButton = [[UIButton alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 10, 100, 20)];
        [valueButton setTitle:[self.connectedDevice valueForKey:keys] forState:UIControlStateNormal];
        valueButton.titleLabel.font = [UIFont securifiFont:14];
        valueButton.titleLabel.textColor = [UIColor whiteColor];
        valueButton.titleLabel.textAlignment = NSTextAlignmentRight;
        valueButton.alpha = 0.5;
        
        [view addSubview:valueButton];
        yPos = yPos + view.frame.size.height;
        
        
    }
    
}*/
@end
