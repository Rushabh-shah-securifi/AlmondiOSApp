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

#define CELLFRAME CGRectMake(8, 11, self.view.frame.size.width -16, 60)

@interface ClientPropertiesViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)NSDictionary *ClientDict;
@end

@implementation ClientPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHeaderCell];
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
    [self clearAllViews];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    if([genericIndexValue.genericIndex.type isEqualToString:ACTUATOR]){
        cell.vsluesLabel.alpha = 1;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }else{
        cell.vsluesLabel.alpha = 0.5;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    cell.vsluesLabel.text = genericIndexValue.genericValue.displayText;
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
    ctrl.isSensor = NO;
    ctrl.genericParams = [[GenericParams alloc]initWithGenericIndexValue:self.genericParams.headerGenericIndexValue
                                                          indexValueList:[NSArray arrayWithObject:[self.genericParams.indexValueList objectAtIndex:indexPath.row]]
                                                              deviceName:self.genericParams.deviceName color:self.genericParams.color];
    [self.navigationController pushViewController:ctrl animated:YES];
}
-(void)clearAllViews{
    NSLog(@"clearAllViews ");
//    [self.clientPropertiesTable removeFromSuperview];
//    for (UIView *view in [self.view subviews]) {
//        [view removeFromSuperview];
//    }
}
@end
