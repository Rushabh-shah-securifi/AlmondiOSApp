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
#import "AlmondJsonCommandKeyConstants.h"

#define CELLFRAME CGRectMake(8, 8, self.view.frame.size.width -16, 70)

@interface ClientPropertiesViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)NSDictionary *ClientDict;
@property (nonatomic) BOOL isLocal;
@end

@implementation ClientPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clientPropertiesTable.backgroundColor = self.genericParams.color;
    [self setHeaderCell];
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
}

#pragma mark common cell delegate
-(void)delegateClientEditTable{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setHeaderCell{
    DeviceHeaderView *commonView = [[DeviceHeaderView alloc]initWithFrame:CELLFRAME];
    [commonView initialize:self.genericParams cellType:ClientProperty_Cell];
    commonView.delegate = self;
    // set up images label and name
    [self.view addSubview:commonView];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    NSLog(@"indexID = %@ islOCAL %d",self.genericParams.headerGenericIndexValue.genericIndex.ID,self.isLocal);
    if([self.genericParams.headerGenericIndexValue.genericIndex.ID isEqualToString:@"-3"] && self.isLocal)
        return self.genericParams.indexValueList.count -1;
    return self.genericParams.indexValueList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClientPropertiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ClientPropertiesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SKSTableViewCell"];
    }
    GenericIndexValue *genericIndexValue = [self.genericParams.indexValueList objectAtIndex:indexPath.row];
    cell.displayLabel.text = genericIndexValue.genericIndex.groupLabel;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(genericIndexValue.genericIndex.readOnly == NO){
        cell.vsluesLabel.alpha = 1;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }else{
        cell.vsluesLabel.alpha = 0.7;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    cell.vsluesLabel.text = genericIndexValue.genericValue.displayText;
    cell.backgroundColor = self.genericParams.color;
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
    NSLog(@"didSelectRowAtIndexPath");
    DeviceEditViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceEditViewController"];
    ctrl.genericParams = [[GenericParams alloc]initWithGenericIndexValue:self.genericParams.headerGenericIndexValue
                                                          indexValueList:[NSArray arrayWithObject:[self.genericParams.indexValueList objectAtIndex:indexPath.row]]
                                                              deviceName:self.genericParams.deviceName color:self.genericParams.color isSensor:NO];
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end
