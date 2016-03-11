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
#import "SensorButtonView.h"
#import "SensorTextView.h"
#import "SFIColors.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "clientTypeCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "CollectionViewCell.h"
#import "CommonCell.h"

@interface ClientEditViewController ()<UITableViewDelegate,UITableViewDataSource,SFIWiFiDeviceTypeSelectionCellDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewClientFields;

@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)NSDictionary *clientDeviceDict;

@property (weak, nonatomic) IBOutlet UIView *clientInfoView;
@property (weak, nonatomic) IBOutlet UIView *indexView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@property (nonatomic) UITableView *tableType;
@property (strong ,nonatomic) UISegmentedControl *allowOnNetworkSegment;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *clientTypesView;
@property (nonatomic)UIView *allowOnNetworkView;
@property (nonatomic)UICollectionView *collectionView;

@property (nonatomic)NSString *indexName;
@end

@implementation ClientEditViewController
static const float ITEM_SPACING = 2.0;
NSMutableArray * blockedDaysArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dummyNetWorkDeviceList];
//    [self drawClientField];
    CommonCell *commonView = [[CommonCell alloc]initWithFrame:CGRectMake(5, 18, self.view.frame.size.width -10, 70)];
    [self.view addSubview:commonView];
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
    self.clientDeviceDict = @{
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
                if([[[self.clientProperties valueForKey:[self.orderedArray objectAtIndex:indexPath.row]]valueForKey:@"indexName"] isEqualToString:@"AllowedType"]){
                    if([[self.clientDeviceDict valueForKey:@"AllowedType"] isEqualToString:@"0"])
                       cell.vsluesLabel.text = @"Never";
                    
                    else if([[self.clientDeviceDict valueForKey:@"AllowedType"] isEqualToString:@"1"])
                        cell.vsluesLabel.text = @"Blocked";
                    else
                        cell.vsluesLabel.text = @"onSchedule";
                }

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
    ctrl.deviceDict = self.clientDeviceDict;
    [self.navigationController pushViewController:ctrl animated:YES];
//    self.indexName = cell.indexName;
//    [self drawViews];
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



/*
-(void)drawViews{
    if([self.indexName isEqualToString:@"Name"]){
        self.indexLabel.text = self.indexName;
        
        [self textFieldView:@"android 02#"];
    }
    else if ([self.indexName isEqualToString:@"Type"]){
        NSLog(@"types:");
        self.indexView.hidden = YES;
        CGRect fr = self.indexView.frame;
        fr.origin.x = self.indexView.frame.origin.x;
        fr.origin.y = self.indexView.frame.origin.y ;
        fr.size.height = self.indexView.frame.size.height + 300;
        self.clientTypesView = [[UIView alloc]init];
        self.clientTypesView.frame = fr;
        
        self.tableType = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.clientTypesView.frame.size.width, self.clientTypesView.frame.size.height)];
        [self.tableType setDataSource:self];
        [self.tableType setDelegate:self];
        //        [self.tableType registerClass:[clientTypeCell class] forCellReuseIdentifier:@"clientTypeCell"];
        self.tableType.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableType.allowsSelection = NO;
        
        [self.tableType reloadData];
        //        self.indexView = self.tableType;
        [self.clientTypesView addSubview:self.tableType];
        [self.view addSubview:self.clientTypesView];
    }
    
    else if ([self.indexName isEqualToString:@"Allow"]){
        [self gridView];
        
    }
    else if ([self.indexName isEqualToString:@"pesenceSensor"]){
        self.indexLabel.text = self.indexName;
        [self buttonView];
    }
    else if ([self.indexName isEqualToString:@"inActiveTimeOut"]){
        self.indexLabel.text = self.indexName;
        [self textFieldView:@"2"];
    }
    else if ([self.indexName isEqualToString:@"Other"]){
        
    }
    
}
-(void)textFieldView:(NSString *)name{
    NSLog(@"self.indexName %@ ",self.indexName);
    SensorTextView *textView = [[SensorTextView alloc]initWithFrame:CGRectMake(4,20,self.indexView.frame.size.width - 8,40)];
    textView.color = [UIColor clearColor];
    [textView drawTextField:name];
    CGRect fr = self.indexView.frame;
    fr.origin.x = self.indexView.frame.origin.x;
    fr.origin.y = self.indexView.frame.origin.y;
    fr.size.height = self.indexView.frame.size.height - 200;
    self.indexView.frame = fr;
    [self.indexView addSubview:textView];
    
}

-(void)buttonView{
    SensorButtonView *presenceSensor = [[SensorButtonView alloc]initWithFrame:CGRectMake(5,40,self.indexView.frame.size.width - 8,30 )];
    presenceSensor.color = [SFIColors clientGreenColor];
    [presenceSensor drawButton:@[@"YES",@"NO"] selectedValue:0];
    [self.indexView addSubview:presenceSensor];
}

#pragma mark uitableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    NSArray *type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    return type.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    clientTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clientTypeCell"];
    if (cell == nil) {
        cell = [[clientTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientTypeCell"];
        [cell setupLabel];
        //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    cell.color = [SFIColors clientGreenColor];
    cell.backgroundColor = [SFIColors clientGreenColor];
    
    [cell writelabelName:[type objectAtIndex:indexPath.row]];
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
-(void)gridView{
    [self addSegmentControll];
    
}
-(void)addSegmentControll{
    NSLog(@"addSegmentControll ");
    self.allowOnNetworkView = [[UIView alloc]initWithFrame:CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y, self.indexView.frame.size.width, self.view.frame.size.height - self.indexView.frame.origin.y -150)];
    self.allowOnNetworkView.backgroundColor = [SFIColors clientGreenColor];
    [self.view addSubview:self.allowOnNetworkView];
    self.indexView.hidden = YES;
    
    UILabel *indexLabel = [[UILabel alloc]initWithFrame:self.indexLabel.frame];
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont securifiFont:14];
    indexLabel.text = @"Allow On network";
    indexLabel.backgroundColor = [UIColor clearColor];
    [self.allowOnNetworkView addSubview:indexLabel];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Always", @"Schedule", @"Block", nil];
    self.allowOnNetworkSegment = [[UISegmentedControl alloc]initWithItems:itemArray];
    self.allowOnNetworkSegment.frame = CGRectMake(self.indexView.frame.origin.x + 5, indexLabel.frame.size.height + 10, self.indexView.frame.size.width - 10, 25);
    self.allowOnNetworkSegment.center = CGPointMake(CGRectGetMidX(self.indexView.bounds), self.allowOnNetworkSegment.center.y);
    self.allowOnNetworkSegment.tintColor = [UIColor whiteColor];
    //    self.allowOnNetworkSegment.segmentedControlStyle = UISegmentedControlStylePlain;
    [self.allowOnNetworkSegment addTarget:self action:@selector(segmentControllChanged:) forControlEvents: UIControlEventValueChanged];
    self.allowOnNetworkSegment.selectedSegmentIndex = 1;
    [self.allowOnNetworkView addSubview:self.allowOnNetworkSegment];
    
    //self.indexView.frame = CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y, self.indexView.frame.size.width, 500);
    //    [self.view addSubview:self.indexView];
}
-(void)segmentControllChanged:(id)sender{
    switch (self.allowOnNetworkSegment.selectedSegmentIndex) {
        case 0:
        {
            self.scrollView.hidden = YES;
            self.collectionView.hidden = YES;
            [self.scrollView removeFromSuperview];
        }break;
        case 1:
        {
            
            self.scrollView.hidden = NO;
            self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.allowOnNetworkView.frame.origin.x, self.allowOnNetworkSegment.frame.origin.y + self.allowOnNetworkSegment.frame.size.height + 10, self.indexView.frame.size.width - 10, self.view.frame.size.height - self.indexView.frame.origin.y - 100)];
            self.scrollView.backgroundColor = [UIColor clearColor];
            [self.allowOnNetworkView addSubview:self.scrollView];
            [self addInfo];
            
            
            
        }break;
        case 2:
        {
            [self.scrollView removeFromSuperview];
            self.scrollView.hidden = YES;
            self.collectionView.hidden = YES;
        }break;
        default:
            break;
    }
}
-(void)addInfo{
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    infoView.backgroundColor = [UIColor clearColor];
    UILabel *blockImg;
    UILabel *blockLbl;
    UILabel *UnblockImg;
    UILabel *unBlockLbl;
    blockImg = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    blockLbl = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, 70, 20)];
    UnblockImg = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 20, 20)];
    unBlockLbl = [[UILabel alloc]initWithFrame:CGRectMake(122, 0, 70, 20)];
    
    blockImg.backgroundColor = [UIColor colorFromHexString:@"DADADC"];
    blockLbl.text = @"Block";
    blockLbl.textColor = [UIColor whiteColor];
    blockLbl.font = [UIFont securifiLightFont:14];
    
    UnblockImg.backgroundColor = [UIColor whiteColor];
    unBlockLbl.text = @"Unblock";
    unBlockLbl.textColor = [UIColor whiteColor];
    unBlockLbl.font = [UIFont securifiLightFont:14];
    
    [infoView addSubview:blockImg];
    [infoView addSubview:blockLbl];
    [infoView addSubview:UnblockImg];
    [infoView addSubview:unBlockLbl];
    
    infoView.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), infoView.center.y);
    [self.scrollView addSubview:infoView];
    UILabel *infoLabel = [[UILabel alloc]
                          initWithFrame:CGRectMake(0, infoView.frame.size.height, self.scrollView.frame.size.width, 80)];
    infoLabel.text = @"Tap on the 24/7 grid to create a schedule during which this device is blocked/unblocked on the network. Also, you can tap on (Su,Mo..) to block/unblock device on that particular day or (0,1..) for particular hour.";
    infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    infoLabel.backgroundColor = [SFIColors clientGreenColor];
    infoLabel.font = [UIFont securifiLightFont:12];
    infoLabel.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), infoLabel.center.y);
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.numberOfLines = 4;
    infoLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:infoLabel];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, infoLabel.frame.size.height + infoView.frame.size.height +5, self.scrollView.frame.size.width, 1020) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    self.collectionView.backgroundColor = [SFIColors clientGreenColor];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.allowsMultipleSelection = YES;
    [self.scrollView addSubview:self.collectionView];
    [self initializeblockedDaysArray];
    
    
}
-(void)initializeblockedDaysArray{
    blockedDaysArray = [NSMutableArray new];
    
    for(int i = 0; i <= 8; i++){
        NSMutableDictionary *blockedHours = [NSMutableDictionary new];
        for(int j = 0; j <= 25; j++){
            [blockedHours setValue:@"0" forKey:@(j).stringValue];
        }
        [blockedDaysArray addObject:blockedHours];
    }
}

#pragma mark collectionView delegates
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 26;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  9;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //You may want to create a divider to scale the size by the way..
    float itemSize = self.collectionView.bounds.size.width/10;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 26*itemSize + 26*ITEM_SPACING + 120);
    return CGSizeMake(itemSize, itemSize);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_SPACING;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_SPACING;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForItemAtIndexPath %@",indexPath);
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    if((row==0 && section==0) || (row==8 && section==0) || (row==0 && section==25) || (row==8 && section==25)){//corners
        [cell handleCornerCells];
        return cell;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.userInteractionEnabled = YES;
    [cell setlabel];
    NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:row];
    NSString *blockedVal = [blockedHours valueForKey:@(section).stringValue];
    if([blockedVal isEqualToString:@"1"]){
        NSLog(@"daytime if");
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell addDayTimeLable:indexPath isSelected:@"1"];
    }else{
        NSLog(@"daytime else");
        [cell addDayTimeLable:indexPath isSelected:@"0"];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)selectionOfHoursForRow:(NSInteger)row andSection:(NSInteger)section collectionView:(UICollectionView *)collectionView selected:(NSString*)selected{
    if((row==0 && section==0) || (row==8 && section==0) || (row==0 && section==25) || (row==8 && section==25))//corners
        return;
    
    NSMutableDictionary *blockedHours;
    blockedHours = [blockedDaysArray objectAtIndex:row];
    [blockedHours setValue:selected forKey:@(section).stringValue];
    
    if((section == 0 || section == 25) && (row >= 1 && row <= 7)){ //days click
        blockedHours = [blockedDaysArray objectAtIndex:row];
        for(int j = 0; j <= 25; j++){
            [blockedHours setValue:selected forKey:@(j).stringValue];
        }
        [collectionView reloadData];
    }
    else if((row == 0 || row == 8) && (section >= 1 && section <= 24)){ //hours click
        for(NSMutableDictionary *dict in blockedDaysArray){
            [dict setValue:selected forKey:@(section).stringValue];
        }
        [collectionView reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [self selectionOfHoursForRow:row andSection:section collectionView:collectionView selected:@"1"];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [self selectionOfHoursForRow:row andSection:section collectionView:collectionView selected:@"0"];
}

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(nonnull SEL)action forItemAtIndexPath:(nonnull NSIndexPath *)indexPath withSender:(nullable id)sender{
    return NO;
}
*/
@end
