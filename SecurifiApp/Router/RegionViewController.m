//
//  RegionViewController.m
//  SecurifiApp
//
//  Created by Masood on 3/6/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "RegionViewController.h"
#import "RegionTableViewCell.h"
#import "NSString+securifi.h"
#import "RouterPayload.h"
#import "MBProgressHUD.h"
#import "UIViewController+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"

#define SLAVE_OFFLINE_TAG 1

@interface RegionViewController ()<UITextFieldDelegate, RegionTableViewCellDelegate, MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *otherTxtFld;

@property (weak, nonatomic) IBOutlet UILabel *locationLbl;

@property (weak, nonatomic) IBOutlet UIImageView *upArrow;
@property (weak, nonatomic) IBOutlet UIImageView *downArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherTopConstraint;


@property (weak, nonatomic) IBOutlet UIImageView *upperTick;
@property (weak, nonatomic) IBOutlet UIImageView *lowerTick;

@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UIView *americaView;
@property (weak, nonatomic) IBOutlet UIView *expandView;

@property (nonatomic) NSArray *regionList;
@property (nonatomic) NSMutableArray *filteredList;
@property (nonatomic) NSString *currentRegion;

@property (nonatomic) MBProgressHUD *HUD;
@end

@implementation RegionViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetUp];
    [self getRegions];
    [self setUpHUD];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    self.searchTxtFld.delegate = self;
    self.otherTxtFld.delegate = self;
    self.otherTxtFld.placeholder = @"\"France/Paris\" or \"NY/New_Rochelle\"";
    [self initializeNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onAlmondPropertyResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil]; //1064 response
    
    [center addObserver:self selector:@selector(onDynamicAlmondPropertyResponse:) name:NOTIFICATION_ALMOND_PROPERTIES_PARSED object:nil]; //list and each property change
}

- (void)initialSetUp{
    _filteredList = [NSMutableArray new];
    
    self.locationLbl.text = @"America";
    self.upperTick.hidden = NO;
    self.lowerTick.hidden = YES;
    self.expandView.hidden = YES;
    
    [self.searchTxtFld addTarget:self
                            action:@selector(editingChanged:)
                  forControlEvents:UIControlEventEditingChanged];
   
    self.currentRegion = [SecurifiToolkit sharedInstance].almondProperty.region;
}

- (void)getRegions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"usCity" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.regionList = [content componentsSeparatedByString:@"\n"];
    self.filteredList = [NSMutableArray arrayWithArray:_regionList];
}


-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = NO;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}
#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredList.count;
//    return self.timeZoneList.count/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"region";
    
    RegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[RegionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;

    NSString *region = self.filteredList[indexPath.row];
    [cell setupCell:region currentRegion:self.currentRegion];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self onRegionSelectedDelegate: self.filteredList[indexPath.row]];
}

#pragma mark action methods
- (IBAction)onSelectLocationTap:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    [self.otherTxtFld resignFirstResponder];
    if(btn.selected){
        self.upArrow.hidden = NO;
        self.downArrow.hidden = YES;
        self.expandView.hidden = NO;
        
        self.topConstraint.constant = 108;
        self.otherTopConstraint.constant = 100;
    }else{
        self.upArrow.hidden = YES;
        self.downArrow.hidden = NO;
        
        self.expandView.hidden = YES;
        self.topConstraint.constant = 1;
        self.otherTopConstraint.constant = 2;
    }
}

- (IBAction)onBckBtnTap:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAmericaTap:(id)sender {
    [self.otherTxtFld resignFirstResponder];
    self.locationLbl.text = @"America";
    
    self.americaView.hidden = NO;
    self.otherView.hidden = YES;
    
    self.upperTick.hidden = NO;
    self.lowerTick.hidden = YES;
}

- (IBAction)onOtherTap:(id)sender {
    [self.otherTxtFld resignFirstResponder];
    self.locationLbl.text = @"Other";
    
    self.americaView.hidden = YES;
    self.otherView.hidden = NO;
    
    self.upperTick.hidden = YES;
    self.lowerTick.hidden = NO;
}
#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/"

-(BOOL)regionTextValidator:(NSString *)location{
     NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[location componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [location isEqualToString:filtered];
//    if([location containsString:@" "]|| [location containsString:@","] || [location containsString:@"@"] || [location containsString:@"@"]){
//        return NO;
//    }
//    else
//        return YES;
}
- (IBAction)onOtherTickTap:(id)sender {
    NSString *value = self.otherTxtFld.text;
    if(![self regionTextValidator:value]){
        [self showToast:@"NOTE: Please enter the Almond Region in any of \"France/Paris\" or \"NY/New_Rochelle\" these formats."];
        return;
    }
    if(value.length == 0){
        [self showToast:@"Please Enter a value of atleast 1 character."];
        return;
    }
    if([value containsString:@"/"]){
        NSArray *components = [value componentsSeparatedByString:@"/"];
        value = [NSString stringWithFormat:@"%@/%@", components[1], components[0]];
    }
    [self showHudWithTimeoutMsg:@"Please wait!" time:10];
    [RouterPayload requestAlmondPropertyChange:mii action:@"GeoLocation" value:value uptime:nil];
}

#pragma mark text field delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // add your method here
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *value = textField.text;
    if(![self regionTextValidator:value]){
        [self showToast:@"NOTE: Please enter the Almond Region in any of \"France/Paris\" or \"NY/New_Rochelle\" these formats."];
        return;
    }
    if(value.length == 0){
        [self showToast:@"Please Enter a value of atleast 1 character."];
        return;
    }
    
    if([value containsString:@"/"]){
        NSArray *components = [value componentsSeparatedByString:@"/"];
        value = [NSString stringWithFormat:@"%@/%@", components[1], components[0]];
    }
    [self showHudWithTimeoutMsg:@"Please wait!" time:5];
    [RouterPayload requestAlmondPropertyChange:mii action:@"GeoLocation" value:value uptime:nil];
}
-(void)editingChanged:(id)sender{
    [self.filteredList removeAllObjects];
    
    UITextField *textfield = sender;
    NSString *newString = textfield.text;
    
    if(newString.length == 0)
        self.filteredList = [NSMutableArray arrayWithArray:self.regionList];
    else{
        for(NSString *region in self.regionList){
            if ([region containsString:newString]){
                [self.filteredList addObject:region];
            }
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark cell delegate method
-(void)onRegionSelectedDelegate:(NSString *)region{
    /* {"MobileInternalIndex":-1074164845,"AlmondMAC":"251176215908032","CommandType":"ChangeAlmondProperties","GeoLocation":" NY\/Chatham"}
     */
    [self showHudWithTimeoutMsg:@"Please Wait!" time:10];
    self.searchTxtFld.text = region;
    
    NSArray *components = [region componentsSeparatedByString:@", "];
    NSString *value = [NSString stringWithFormat:@"%@/%@", components[1], components[0]];
    
    [RouterPayload requestAlmondPropertyChange:mii action:@"GeoLocation" value:value uptime:nil];
}

#pragma mark hud methods
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg time:(NSTimeInterval)sec{
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:sec];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

#pragma mark command response
-(void)onAlmondPropertyResponse:(id)sender{
    NSLog(@"onAlmondPropertyResponse");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NSDictionary *payload;
    if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"payload: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    /* {"CommandType":"ChangeAlmondProperties","Success":"false","OfflineSlaves":"Downstairs","Reason":"Slave in offline","MobileInternalIndex":"-1442706141"}
     */
    if(isSuccessful){
        //        [self showToast:@"Successfully Updated!"];
    }else{
        if([[payload[REASON] lowercaseString] hasSuffix:@"offline"]){
            NSArray *slaves = [payload[OFFLINE_SLAVES] componentsSeparatedByString:@","];
            NSString *subMsg = slaves.count == 1? @"Almond is": @"Almonds are";
            
            NSString *msg = [NSString stringWithFormat:@"Unable to change settings. Check if \"%@\" %@ active and with in range of other \nAlmond 3 units in your Home WiFi network.", payload[OFFLINE_SLAVES], subMsg];
            [self showAlert:@"" msg:msg cancel:@"OK" other:nil tag:SLAVE_OFFLINE_TAG];
            
        }
        else{
            [self showToast:@"Sorry! Could not update"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
        });
    }
}

-(void)onDynamicAlmondPropertyResponse:(id)sender{
    NSLog(@"onDynamicAlmondPropertyResponse");
    //don't reload the dictionary will have old values
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
        [self showToast:@"Successfully Updated!"];
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark alert methods
- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:other, nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        if(alertView.tag == SLAVE_OFFLINE_TAG){
            
        }
    }
    else{
        
    }
}

@end
