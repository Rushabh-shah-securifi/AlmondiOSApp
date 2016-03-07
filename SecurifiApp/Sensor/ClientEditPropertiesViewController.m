//
//  ClientEditPropertiesViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 02/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientEditPropertiesViewController.h"
#import "SensorButtonView.h"
#import "SensorTextView.h"
#import "SFIColors.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"



@interface ClientEditPropertiesViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *clientInfoView;
@property (weak, nonatomic) IBOutlet UIView *indexView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableType;

@end

@implementation ClientEditPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawViews];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)drawViews{
    if([self.indexName isEqualToString:@"Name"]){
        self.indexLabel.text = self.indexName;
        [self textFieldView:@"android 02#"];
    }
    else if ([self.indexName isEqualToString:@"Type"]){
        NSLog(@"types:");
        self.indexView.frame = CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y, self.indexView.frame.size.width, self.indexView.frame.size.height + 200);
//        self.tableType.frame = CGRectMake(self.indexView.bounds.origin.x, self.indexView.bounds.origin.y + 20, self.tableType.frame.size.width, self.tableType.frame.size.height);
        NSLog(@" uiview size %f",self.indexView.frame.size.height);
        NSLog(@"self.tableType %f ",self.tableType.frame.size.height);
        self.tableType.hidden = NO;
        [self.tableType reloadData];
//        self.indexView = self.tableType;
        [self.indexView addSubview:self.tableType];
    }
    
    else if ([self.indexName isEqualToString:@"Allow"]){
       
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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [NSString stringWithFormat:@"Sensors (%d)",1];
    else
        return [NSString stringWithFormat:@"Network devices (%d)",1];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSArray *type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    SFIWiFiDeviceTypeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIWiFiDeviceTypeSelectionCell"];
    if (cell == nil) {
        cell = [[SFIWiFiDeviceTypeSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SFIWiFiDeviceTypeSelectionCell"];
        //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    cell.delegate = self;
    [cell createPropertyCell:type[indexPath.row]];
    [cell setTypeLabe:type[indexPath.row]];

    return cell;


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
/*
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
 return 1;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 return 50.0f;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 switch (self.editFieldIndex) {
 case typeIndexPathRow:
 return deviceTypes.count;
 break;
 case connectionIndexPathRow:
 return connectionTypes.count;
 break;
 case notifyMeIndexPathRow:
 return notifyTypes.count;
 break;
 
 default:
 break;
 }
 return 0;
 }
 
 - (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
 SFIWiFiDeviceTypeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIWiFiDeviceTypeSelectionCell"];
 
 cell.delegate = self;
 switch (self.editFieldIndex) {
 case typeIndexPathRow:
 [cell createPropertyCell:deviceTypes[indexPath.row]];
 cell.textLabel.text = [deviceTypes[indexPath.row] valueForKey:@"name"];
 break;
 case connectionIndexPathRow:
 [cell createPropertyCell:connectionTypes[indexPath.row]];
 cell.textLabel.text = [connectionTypes[indexPath.row] valueForKey:@"name"];
 break;
 case notifyMeIndexPathRow:
 [cell createPropertyCell:notifyTypes[indexPath.row]];
 cell.textLabel.text = [notifyTypes[indexPath.row] valueForKey:@"name"];
 break;
 
 default:
 break;
 }
 
 cell.backgroundColor = [UIColor clearColor];
 cell.textLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
 cell.textLabel.textColor = [UIColor whiteColor];
 cell.backgroundColor = [UIColor clearColor];
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 return cell;
 }
 
 
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
 return nil;
 }
 
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
 
 return nil;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
 return 0.0000001;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
 return 0.0000001;
 }

 
 */
@end
