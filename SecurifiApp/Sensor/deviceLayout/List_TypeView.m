//
//  List_TypeView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 06/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "List_TypeView.h"
#import "clientTypeCell.h"
#import "SFIColors.h"
#import "Colours.h"
#import "UIFont+Securifi.h"
#import "AlmondManagement.h"
#import "SFIAlmondPlus.h"
#import "CommonMethods.h"
#import "AlmondPlan.h"

@interface List_TypeView()<UITableViewDataSource,UITableViewDelegate,clientTypeCellDelegate,UITextFieldDelegate>
@property (nonatomic)UITableView *tableType;
@property (nonatomic)UITextField *searchtextField;
@property (nonatomic)NSString *selectedType;
@property (nonatomic)NSMutableArray *displayArray;
@property (nonatomic)NSMutableArray *valueArr;
@property (nonatomic)NSMutableArray *displayArray_copy;
@property (nonatomic)NSMutableArray *valueArr_copy;
@property (nonatomic)NSMutableDictionary *displayText_value;
@property BOOL hasPaymentDone;

@end
@implementation List_TypeView

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        self.valueArr = [[NSMutableArray alloc] init];
        self.displayArray = [[NSMutableArray alloc] init];
        self.valueArr_copy = [[NSMutableArray alloc] init];
        self.displayArray_copy = [[NSMutableArray alloc] init];
        [self addSearchTextField];
        [self drawTypeTable];
    }
    return self;
}
-(void)addSearchTextField{
    SFIAlmondPlus *currentAlmond = [AlmondManagement currentAlmond];
    self.hasPaymentDone = [AlmondPlan hasSubscription:currentAlmond.almondplusMAC];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 18, 18)];
    imageView.image  = [UIImage imageNamed:@"search_icon_white"];
    [self addSubview:imageView];
    imageView.alpha = 0.5;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 30, self.frame.size.width -30, 1)];
    view.alpha = 0.5;
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    self.searchtextField = [[UITextField alloc]initWithFrame:CGRectMake(50, 5, self.frame.size.width - 40, 25)];
    self.searchtextField.delegate = self;
    self.searchtextField.backgroundColor = self.color;
    self.searchtextField.textColor = [UIColor whiteColor];
    
    self.searchtextField.font = [UIFont securifiFont:14];
    self.searchtextField.placeholder = @" Search from here...";
    UIColor *color = [UIColor colorFromHexString:@"F4F2F7"];
    self.searchtextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search from here..." attributes:@{NSForegroundColorAttributeName: color}];
    [self.searchtextField addTarget:self
                            action:@selector(editingChanged:)
                  forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.searchtextField];

}
-(void)drawTypeTable{
    NSArray *devicePosKeys = self.genericIndexValue.genericIndex.values.allKeys;
    
    NSArray *sortedKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    SFIAlmondPlus *alm = [AlmondManagement currentAlmond];
    BOOL isAl3 = [alm siteMapSupportFirmware:alm.firmware];
    
    NSLog(@"isAl3 %d",isAl3);
    
    for(NSString *key in sortedKeys){
        if([key isEqualToString:@"identifying"])
            continue;
        GenericValue *gVal = [self.genericIndexValue.genericIndex.values valueForKey:key];
        
//        if(!isAl3)
//            if([self isIoTdevice:gVal.value])
//                continue;
        
        [self.displayArray addObject:gVal.displayText];
        [self.valueArr addObject:gVal.value];
        [self.displayArray_copy addObject:gVal.displayText];
        [self.valueArr_copy addObject:gVal.value];
    }
    self.displayText_value = [[NSMutableDictionary alloc]initWithObjects:self.valueArr_copy forKeys:self.displayArray_copy];
    NSLog(@"types %@",self.displayArray);
    self.selectedType = self.genericIndexValue.genericValue.value;
    NSLog(@" self.genericIndexValue.genericValue.value %@",self.genericIndexValue.genericValue.value);
    self.tableType = [[UITableView alloc]initWithFrame:CGRectMake(0, 36, self.frame.size.width, self.frame.size.height - 160)];
    [self.tableType setDataSource:self];
    [self.tableType setDelegate:self];
    self.tableType.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableType.allowsSelection = NO;
    self.tableType.alwaysBounceVertical = NO ;
    self.tableType.backgroundColor = self.color;
    [self.tableType reloadData];
    [self addSubview:self.tableType];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayArray_copy.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    clientTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clientTypeCell"];
    if (cell == nil) {
        cell = [[clientTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientTypeCell"];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 45);
        [cell setupLabel:self.hasPaymentDone];
    }
    int currentvalPos = 0;
    
    for(NSString *str in self.displayArray_copy){
        NSString *value = [self.displayText_value valueForKey:str];
        if([value isEqualToString:self.selectedType])
            break;
        currentvalPos++;
    }
    
    cell.delegate = self;
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = self.color;
    NSString *value = [self.displayText_value valueForKey:[self.displayArray_copy objectAtIndex:indexPath.row]];
    cell.iconView.image = [UIImage imageNamed:@"ic_security_black"];
    if([CommonMethods isIoTdevice:value])
    {
        cell.iconView.alpha = 1.0;
    }
    else
        cell.iconView.alpha = 0.3;
    
    [cell writelabelName:[self.displayArray_copy objectAtIndex:indexPath.row] value:value];
    if(currentvalPos == indexPath.row)
        [cell changeButtonColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
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
    [self.tableType reloadData];
    [self.delegate save:typeName forGenericIndexValue:self.genericIndexValue currentView:self];
}

-(void)setListValue:(NSString*)value{
    self.selectedType = value;
    [self.tableType reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
     [textField resignFirstResponder];
    NSLog(@"textFieldDidEndEditing string = %@",textField.text);
    if([textField.text isEqualToString:@""] || textField.text == NULL){
        [self.displayArray_copy removeAllObjects];
        for(NSString *display in self.displayArray){
            [self.displayArray_copy addObject:display];
        }
    }
     [self.tableType reloadData];
}
-(void)editingChanged:(id)sender{
    [self.valueArr_copy removeAllObjects];
    [self.displayArray_copy removeAllObjects];
    UITextField *textfield = sender;
    NSString *newString = textfield.text;
    NSLog(@"new string = %@",newString);
    
    for(NSString *sceneName in self.displayArray){
        if ([sceneName rangeOfString:newString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.displayArray_copy addObject:sceneName];
        }
    }
    NSLog(@"self.valueArr_copy count %ld",self.displayArray_copy.count);
    
    [self.tableType reloadData];
}
-(BOOL)isIoTdevice:(NSString *)clientType{
    NSArray *iotTypes = @[@"withings",@"dlink_cameras",@"hikvision",@"foscam",@"motorola_connect",@"ibaby_monitor",@"osram_lightify",@"honeywell_appliances",@"ge_appliances",@"wink",@"airplay_speakers",@"sonos",@"belkin_wemo",@"samsung_smartthings",@"ring_doorbell",@"piper",@"canary",@"august_connect",@"nest_cam",@"skybell_wifi",@"scout_home_system",@"nest_protect",@"nest_thermostat",@"amazon_dash",@"amazon_echo",@"nest",@"philips_hue"];
    if([iotTypes containsObject: clientType] )
        return YES;
    else return  NO;
}
@end
