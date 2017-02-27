//
//  AdvanceInformationViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "AdvanceInformationViewController.h"
#import "ClientPropertiesCell.h"
#import "GenericIndexUtil.h"

@interface AdvanceInformationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)SecurifiToolkit *toolkit;
@property (nonatomic)NSArray *genericIndexes;
@end

@implementation AdvanceInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = @[@-13, @-14, @-15, @-16, @20];
    NSArray *genericIndexes = [GenericIndexUtil getDetailForNavigationItems:self.genericIndexValue.genericIndex.navigateElements clientID:@(self.genericIndexValue.deviceID).stringValue];
    self.genericIndexes = genericIndexes;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.genericIndexes.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"client properties cell for row");
    ClientPropertiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ClientPropertiesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SKSTableViewCell"];
    }
    GenericIndexValue *genericIndexeValue = [self.genericIndexes objectAtIndex:indexPath.row];
    cell.displayLabel.text = genericIndexeValue.genericIndex.groupLabel;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.vsluesLabel.alpha = 0.75;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    cell.vsluesLabel.text = genericIndexeValue.genericValue.displayText;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //[self performSegueWithIdentifier:@"modaltodetails" sender:[self.eventsTable cellForRowAtIndexPath:indexPath]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
