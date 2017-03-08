//
//  DeviceNotificationViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 01/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DeviceNotificationViewController.h"
#import "UICommonMethods.h"
#import "NotificationCellTableViewCell.h"
#import "GridView.h"
#import "SFIColors.h"
#import "NotificationView.h"
#import "UIFont+Securifi.h"
#import "DevicePayload.h"
#import "iToast.h"
#import "AlmondManagement.h"
#import "ClientPayload.h"
#import "NotificationPreferenceResponse.h"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;

@interface DeviceNotificationViewController ()<GridViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,NotificationViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITableView *notifyMeTable;
@property (nonatomic )NSArray *staticList;
@property (nonatomic)NSMutableString *hexBlockedDays;

@property (weak, nonatomic) IBOutlet UIButton *doneButtoon;
@property (nonatomic)NSString *location;
@property (nonatomic)NSString *updateValue;
@property (nonatomic )NSMutableArray *blockArr;

@end

@implementation DeviceNotificationViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
        self.notifyMeTable.hidden = YES;
    NSString *schedule = [Client getScheduleById:@(_genericIndexValue.deviceID).stringValue];
    if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-3"]){
    NotificationView *notificationView = [[NotificationView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 250) andGenericIndexValue:self.genericIndexValue isSensor:self.isSensor];
        notificationView.delegate = self;
        notificationView.genericIndexValue = self.genericIndexValue;
        [self.doneButtoon addTarget:self action:@selector(onDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:notificationView];
    }
    if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-2"]){
        self.notifyMeTable.hidden = NO;
        self.staticList = @[@"Attic",@"Basement",@"Bedroom",@"Kitchen",@"Living Room",@"Office",@"Entryway",@"Default"];
        _location = self.genericIndexValue.genericValue.value;
        if ( [self.staticList containsObject: _location] ) {
            // do found
        } else {
            // do not found
            self.staticList = [self.staticList arrayByAddingObject:_location];
        }

        GenericIndexValue *gval = self.genericIndexValue;
        self.doneButtoon.titleLabel.font = [UIFont securifiFont:25];
        [self.doneButtoon setTitle:@"+" forState:UIControlStateNormal];
        [self.doneButtoon addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.notifyMeTable reloadData];
    }
    if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-40"]){
        _hexBlockedDays = [NSMutableString new];
        _blockArr = [[NSMutableArray alloc]init];
        GridView *gridView = [[GridView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - 70) color:[SFIColors clientGreenColor] genericIndexValue:_genericIndexValue onSchedule:(NSString*)schedule blockArr:_blockArr];
        gridView.delegate = self;
          [self.doneButtoon addTarget:self action:@selector(onDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        gridView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:gridView];
    }
   
//
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initNotification ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
    [center addObserver:self //sensor notification response 301
               selector:@selector(onNotificationPrefDidChange:)
                   name:kSFINotificationPreferencesListDidChange
                 object:nil];

}
#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.staticList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  45;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 30;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view;
//    int viewHt;
//            viewHt = defHeaderHeight + defHeaderLableHt;
//        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
//        [UICommonMethods setLableProperties:label text:@"NOTIFY ME" textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
//        [view addSubview:label];
//    return view;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"NotificationCellTableViewCell";
    NotificationCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NotificationCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.staticList objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont securifiFont:16]];
    
    if([_location isEqualToString:[self.staticList objectAtIndex:indexPath.row]]){
        [cell hideCheckButton:NO];
//        cell.chekButton.hidden = NO;
        [cell.textLabel setTextColor:[SFIColors ruleBlueColor]];
    }
    else{
//        cell.chekButton.hidden = YES;
        [cell hideCheckButton:YES];
         [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    
    return cell;
}
- (void )tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSString *location = [self.staticList objectAtIndex:indexPath.row];
    //send request
     mii = arc4random() % 10000;
    self.genericIndexValue.genericIndex.commandType = DeviceCommand_UpdateDeviceLocation;
     [DevicePayload getNameLocationChange:self.genericIndexValue mii:mii value:location];
    [self.notifyMeTable reloadData];
    
    
}
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)onDoneButtonClicked{
        mii = arc4random() % 10000;
    
        if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-3"])
            [DevicePayload sensorDidChangeNotificationSetting:self.updateValue.intValue deviceID:self.genericIndexValue.deviceID mii:mii];
        else if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-40"]){
            Client *client = [[Client findClientByID:@(self.genericIndexValue.deviceID).stringValue] copy];
            [Client getOrSetValueForClient:client genericIndex:self.genericIndexValue.index newValue:self.hexBlockedDays ifGet:NO];
            
            [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];

          
        }
}
-(void)plusButtonClicked:(id)sender{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Location" message:@"Please enter Location" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    mii = arc4random() % 10000;
    NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
    NSString *locationName =  [alertView textFieldAtIndex:0].text;
    self.staticList = [self.staticList arrayByAddingObject:locationName];
    [DevicePayload getNameLocationChange:self.genericIndexValue mii:mii value:locationName];
    [self.notifyMeTable reloadData];
    
   
}
#pragma mark notification delegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue {
    if([genericIndexValue.genericIndex.ID isEqualToString:@"-40"]){
        self.hexBlockedDays = [newValue mutableCopy];
    }
    self.updateValue = newValue;
//    mii = arc4random() % 10000;
//    if([genericIndexValue.genericIndex.ID isEqualToString:@"-3"])
//        [DevicePayload sensorDidChangeNotificationSetting:newValue.intValue deviceID:genericIndexValue.deviceID mii:mii];
//    else{
//        [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:newValue];
//    }
}
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue blockArr:(NSArray*)blockArr{
   
    if([genericIndexValue.genericIndex.ID isEqualToString:@"-40"]){
        self.hexBlockedDays = [newValue mutableCopy];
        [self convertDaysDictToHex:blockArr];
    }
}
-(void)convertDaysDictToHex:(NSArray *)blockArr{
    _hexBlockedDays = [@"" mutableCopy];
    for(int i = 1; i <= 7; i++){
        NSMutableDictionary *blockedHours = [blockArr objectAtIndex:i];
        NSMutableString *boolStr = [NSMutableString new];
        for(int j = 24; j >= 1; j--){
            [boolStr appendString:[blockedHours valueForKey:@(j).stringValue]];
        }
        
        NSMutableString *hexStr = [self boolStringToHex:[NSString stringWithString:boolStr]];
        while(6-[hexStr length]){
            [hexStr insertString:@"0" atIndex:0];
        }
        if(i == 1)
            [_hexBlockedDays appendString:hexStr];
        else
            [_hexBlockedDays appendString:[NSString stringWithFormat:@",%@", hexStr]];
    }
}
-(NSMutableString*)boolStringToHex:(NSString*)str{
    char* cstr = [str cStringUsingEncoding: NSASCIIStringEncoding];
    NSUInteger len = strlen(cstr);
    char* lastChar = cstr + len - 1;
    NSUInteger curVal = 1;
    NSUInteger result = 0;
    while (lastChar >= cstr) {
        if (*lastChar == '1')
        {
            result += curVal;
        }
        lastChar--;
        curVal <<= 1;
    }
    NSString *resultStr = [NSString stringWithFormat: @"%lx", (unsigned long)result];
    return [resultStr mutableCopy];
}
-(void)onCommandResponse:(id)sender{ //mobile command sensor and client 1064
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    
    if (dataInfo==nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    
    if(local){
        payload = dataInfo[@"data"];
    }else{
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
    //    if (self.miiTable[payload[@"MobileInternalIndex"]] == nil || payload[@"MobileInternalIndex"] == nil) {
    //        return;
    //    }
    
    NSLog(@"payload mobile command: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if(self.genericParams.isSensor){
        NSLog(@"sensor");
        if(isSuccessful == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
            });
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

- (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        iToast *toast = [iToast makeText:msg];
        toast = [toast setGravity:iToastGravityBottom];
        toast = [toast setDuration:2000];
        [toast show:iToastTypeWarning];
    });
}
-(void)onNotificationPrefDidChange:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NotificationPreferenceResponse* res = dataInfo[@"data"];
    if (res.internalIndex == nil )
        return;
    
    if(res.isSuccessful == NO){
        NSLog(@"notify unsuccessful");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
        });
    }
    else{
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
//        });
    }
}
@end
