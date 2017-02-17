//
//  IRViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "IRViewController.h"
#import "PickerComponentView.h"
#import "GenericIndexUtil.h"
#import "DevicePayload.h"
#import "SFIColors.h"
#import "DeviceHeaderView.h"
#import "UICommonMethods.h"
#import "AlmondManagement.h"


@interface IRViewController ()<PickerComponentViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *LEDView;
@property (weak, nonatomic) IBOutlet UIView *labelSwitchView;
@property (weak, nonatomic) IBOutlet UITableView *buttonTableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic)NSArray *buttonsValueArr;
@property (weak, nonatomic) IBOutlet UISwitch *configSwitch;
@property (weak, nonatomic) IBOutlet UITextField *NameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstrain;
@property BOOL isConfig;
@property BOOL isSelected;
@property CGFloat tableViewDefaultConstrain;
@property (nonatomic)NSArray *statusArr;
@property (nonatomic)NSMutableArray *buttonValueArr;
@property (nonatomic)NSMutableArray *defaultLedValusArr;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceHeaderCell;
@property (nonatomic) NSMutableArray *ledValueArr;

@end

@implementation IRViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    _NameTextField.delegate = self;
    GenericIndexValue *gval = self.genericIndexValue;
    self.defaultLedValusArr = [NSMutableArray new];
    self.NameTextField.text =gval.genericValue.displayText;
    _tableViewDefaultConstrain = self.tableViewTopConstrain.constant;
     [self setUpDeviceEditCell];
    NSLog(@"gval.genericIndex value %@",gval.genericValue.value);
    _buttonsValueArr  = @[@"Default",@"On",@"Off",@"Menu",@"Next",@"Back",@"Up",@"Down",@"Ok",@"Volume",@"Play",@"Stop",@"Pause",@"Ac Cool Mode",@"Ac Heat Mode",@"Ac Auto Mode",@"Ac Dry Mode",@"Ac Sleep Mode",@"Ac Fan On",@"Ac Fan Off",@"Ac Fan Speed",@"Ac Swing On",@"Ac Swing Off",@"Ac Set Timer",@"Ac Set Temp",@"Set TV Channel"];
     self.buttonValueArr = [NSMutableArray new];
    self.ledValueArr = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",@"0",@"0",@"0", nil];
    
    [self setConfig:self.configSwitch];
    [self setButtonLayOut];
    // Do any additional setup after loading the view.
    [self setBackgroundColor];
    [self initializeNotifications];
    if(self.genericIndexValue.index != 7)
        [self addDayView];
   
    
}
-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onMobileCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
}
-(void)setBackgroundColor{
    _NameTextField.backgroundColor = [UIColor clearColor];
    _labelSwitchView.backgroundColor = self.genericParams.color;
    _LEDView.backgroundColor = self.genericParams.color;
}
-(void)setUpDeviceEditCell{
     [self.deviceHeaderCell initialize:self.genericParams cellType:SensorEdit_Cell isSiteMap:NO];
//    self.deviceHeaderCell.delegate = self;
}
-(void)setButtonLayOut{
    GenericIndexValue *gval = self.genericIndexValue;
    Device *device = [Device getDeviceForID:gval.deviceID];
    int correspondingButtonId = gval.index  + 7;
    NSString  *str = [GenericIndexUtil getHeaderValueFromKnownValuesForDevice:device indexID:@(correspondingButtonId).stringValue];
    NSLog(@"STr = %@",str);
    self.statusArr = [str componentsSeparatedByString:@","];
   
    for(int i= 0;i<=7;i++){
        NSString *returnValue = [NSString stringWithFormat:@"%d%d",gval.index -1,i+1];
        [self.buttonValueArr addObject:returnValue];
    }
    NSLog( @"buttonValueArr %@",self.buttonValueArr);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addDayView{
    int xVal = 4;
    int spacing = 8;
    double dayButtonWidth = 45;
    UIView *dayView = [[UIView alloc]initWithFrame:CGRectMake(0, 18, (dayButtonWidth+spacing)*6, 70)];
    int tag = 0;
    NSString *selectedLed = [self getLedValueForDevice];
    NSArray* dayArray = [[NSArray alloc]initWithObjects:@"01",@"02",@"03",@"04",@"05",@"06", nil];
    for(NSString* day in dayArray){
        UIButton *dayButton = [[UIButton alloc] initWithFrame:CGRectMake(xVal, 0, dayButtonWidth, dayButtonWidth)];
        dayButton.center = CGPointMake(dayButton.center.x, dayView.bounds.size.height/2);
        [self setDayButtonProperties:dayButton withRadius:dayButtonWidth];
        [dayButton setTitle:day forState:UIControlStateNormal];
        dayButton.titleLabel.font = [UIFont systemFontOfSize:12];
        dayButton.tag = tag;
        [dayButton addTarget:self action:@selector(onDayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [dayView addSubview:dayButton];
        dayButton.selected = NO;
        [self setPreviousHighlight:dayButton selectedValue:selectedLed];
        xVal += dayButtonWidth + spacing;
        tag++;
    }
    dayView.center = CGPointMake(CGRectGetMidX(self.LEDView.bounds), dayView.center.y);
    //    dayView.backgroundColor = [UIColor orangeColor];
    [self.LEDView addSubview:dayView];
}
-(NSString *)getLedValueForDevice{
    Device *device = [Device getDeviceForID:self.genericIndexValue.deviceID];
    NSString  *str = [GenericIndexUtil getHeaderValueFromKnownValuesForDevice:device indexID:@(8).stringValue];
    NSLog(@"STr = %@",str);
    int deviceID = self.genericIndexValue.index;
    NSMutableArray *deviceLedValues = [NSMutableArray new];
    for(int i = 2;i < str.length ; i++)
    {
        
        NSString *value = [NSString stringWithFormat:@"%c%c",[str characterAtIndex:i],[str characterAtIndex:i+1]];
        [deviceLedValues addObject:value];
        i++;
    }
    NSLog(@"deviceLedValues %@",deviceLedValues);
    self.defaultLedValusArr = [deviceLedValues mutableCopy];
    NSString *hex = [deviceLedValues objectAtIndex:self.genericIndexValue.index -2];
    NSUInteger hexAsInt;
    [[NSScanner scannerWithString:hex] scanHexInt:&hexAsInt];
    NSString *binary = [NSString stringWithFormat:@"%@", [self toBinary:hexAsInt]];
    NSLog(@"binary  %@",binary);
    [self setLedValueArrFromBinaryString:binary];
    
    return  binary;
}
-(void)setLedValueArrFromBinaryString:(NSString *)binary{
    NSMutableArray *letterArray = [NSMutableArray array];
    NSString *letters = binary;
    [letters enumerateSubstringsInRange:NSMakeRange(0, [letters length])
                                options:(NSStringEnumerationByComposedCharacterSequences)
                             usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 [letterArray addObject:substring];
                             }];
    
    self.ledValueArr = [letterArray mutableCopy];
    
}
-(NSString *)toBinary:(NSUInteger)input
{
    if (input == 1 || input == 0)
        return [NSString stringWithFormat:@"%lu", (unsigned long)input];
    return [NSString stringWithFormat:@"%@%lu", [self toBinary:input / 2], input % 2];
}

-(void)onDayBtnClicked:(id)sender{
    NSMutableArray *selectedLed = [NSMutableArray new];
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    if(button.selected)
    {
        [selectedLed addObject:@(button.tag).stringValue];
        [self setLedvlueArr:button.tag setValue:@"1"];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:self.genericParams.color forState:UIControlStateNormal];
    }
    else{
         [selectedLed removeObject:@(button.tag).stringValue];
         [self setLedvlueArr:button.tag setValue:@"0"];
        button.backgroundColor = [SFIColors darkerColorForColor:self.genericParams.color];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
}
-(void)setLedvlueArr:(NSInteger)tag setValue:(NSString *)value{
    [self.ledValueArr setObject:value atIndexedSubscript:tag];
    NSLog(@"self.ledValueArr %@",self.ledValueArr);
}
- (IBAction)LEDSaveClicked:(id)sender {
    
    NSLog(@"self.ledValueArr %@",self.ledValueArr);
    NSString *ledValueString = [self.ledValueArr componentsJoinedByString:@""];
    NSLog(@"ledValueString %@",ledValueString);
    
    NSString *ledHexStr = [self convertBin:ledValueString];
    [self.defaultLedValusArr replaceObjectAtIndex:self.genericIndexValue.index -2 withObject:ledHexStr];
     NSLog(@"self.defaultLedValusArr %@",self.defaultLedValusArr);
    NSString *LedValue = [self.defaultLedValusArr componentsJoinedByString:@","];
    [self sendUpadateVelue:LedValue genericIndexId:@"4"];
}
- (NSString*)convertBin:(NSString *)bin
{
    if ([bin length] > 16) {
        
        NSMutableArray *bins = [NSMutableArray array];
        for (int i = 0;i < [bin length]; i += 16) {
            [bins addObject:[bin substringWithRange:NSMakeRange(i, 16)]];
        }
        
        NSMutableString *ret = [NSMutableString string];
        for (NSString *abin in bins) {
            [ret appendString:[self convertBin:abin]];
        }
        
        return ret;
        
    } else {
        int value = 0;
        for (int i = 0; i < [bin length]; i++) {
            value += pow(2,i)*[[bin substringWithRange:NSMakeRange([bin length]-1-i, 1)] intValue];
        }
        return [NSString stringWithFormat:@"%1X", value];
    }
}
-(void) setDayButtonProperties:(UIButton*)dayButton withRadius:(double)dayButtonWidth{
    CALayer * l1 = [dayButton layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:dayButtonWidth/2];
    
    
    l1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
    [[dayButton layer]setBorderColor:(__bridge CGColorRef _Nullable)([UIColor whiteColor])];
    [dayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dayButton.backgroundColor = [SFIColors darkerColorForColor:self.genericParams.color];
    dayButton.titleLabel.textAlignment  = NSTextAlignmentCenter;
}

-(void)setPreviousHighlight:(UIButton*)dayButton selectedValue:(NSString *)selectedLed{
    if([selectedLed characterAtIndex:dayButton.tag] == '1'){
        dayButton.selected = YES;
        dayButton.backgroundColor = [UIColor whiteColor];
        [dayButton setTitleColor:self.genericParams.color forState:UIControlStateNormal];
    }

}
- (IBAction)configSwitchAction:(id)sender {
    UISwitch *confiG = (UISwitch*)sender;
    [self setConfig:confiG];
}
-(void)setConfig:(UISwitch *)switchconfig{
    if(switchconfig.on == YES)
    {
        self.isConfig = YES;
        self.NameTextField.userInteractionEnabled = YES;
        self.LEDView.hidden = NO;
        self.tableViewTopConstrain.constant = _tableViewDefaultConstrain;
        if(self.genericIndexValue.index != 7)
            [self addDayView];
        [self.buttonTableView reloadData];
        
    }
    else{
        self.isConfig = NO;
        self.NameTextField.userInteractionEnabled = NO;
        self.LEDView.hidden = YES;
        self.tableViewTopConstrain.constant = _tableViewDefaultConstrain - 100;
        [self.buttonTableView reloadData];
    }
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 8;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat kExpandedCellHeight = 160;
    CGFloat kNormalCellHeigh = 40;
    
    if (self.indexPath == indexPath && self.isConfig == YES)
    {
        return kExpandedCellHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"IRButtonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    for(UIView *textCheckMarkView in cell.contentView.subviews){
        if([textCheckMarkView isKindOfClass:[UIImageView class]])
            [textCheckMarkView removeFromSuperview];
        if([textCheckMarkView isKindOfClass:[UILabel class]])
            [textCheckMarkView removeFromSuperview];
    }
    NSString *StatusValue = [self.statusArr objectAtIndex:indexPath.row];
    
    UILabel *cellTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 25)];
    cellTitle.text = [_buttonsValueArr objectAtIndex:[StatusValue intValue]];
    
    
    cellTitle.numberOfLines = 2;
    cellTitle.lineBreakMode = NSLineBreakByWordWrapping;
    cellTitle.font = [UIFont systemFontOfSize:14];
    cellTitle.textColor = [UIColor whiteColor];
    cell.backgroundColor = self.genericParams.color;
    [cell.contentView addSubview:cellTitle];
    
    
    
    UIImageView *textCheckMarkView = [[UIImageView alloc]init];
    
    textCheckMarkView.frame = CGRectMake(cell.contentView.frame.size.width - 20 , 10, 15 , 15);
    textCheckMarkView.alpha = 0.7;
   [cell.contentView addSubview:textCheckMarkView];
    if(self.isConfig){
        //cell.textLabel.textAlignment = NSTextAlignmentLeft;
       
        textCheckMarkView.image = [UIImage imageNamed:@"down_arrow"];
    }
    else{
//        textCheckMarkView.frame = CGRectMake(cell.contentView.frame.size.width - 30 , 7, 25 , 25);
//        CALayer * l1 = [textCheckMarkView layer];
//        [l1 setMasksToBounds:YES];
//        [l1 setCornerRadius:25/2];
//        
//            
//        l1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
////        textCheckMarkView.layer.masksToBounds = NO;
////        textCheckMarkView.layer.shadowOffset = CGSizeMake(-15, 20);
////        textCheckMarkView.layer.shadowRadius = 5;
////        textCheckMarkView.layer.shadowOpacity = 0.5;
//        if(self.isSelected)
//            textCheckMarkView.backgroundColor = [UIColor whiteColor];
//        else
//            textCheckMarkView.backgroundColor = [UIColor whiteColor];
//        textCheckMarkView.alpha = 1;
        
    }
    if (self.indexPath == indexPath && self.isConfig)
    {
        for(UIView *picView in cell.contentView.subviews){
            if([picView isKindOfClass:[PickerComponentView class]])
                [picView removeFromSuperview];
        }
        textCheckMarkView.image = [UIImage imageNamed:@"up_arrow"];
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width , 160) arrayList:_buttonsValueArr atRowPosition:indexPath.row];
         [pickerView removeFromSuperview];
        pickerView.delegate = self;
        pickerView.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.center.y);
        [cell.contentView addSubview:pickerView];
            if(self.isConfig == NO)
              [pickerView removeFromSuperview];
    }
    else{
        [UICommonMethods addLineSeperator:cell.contentView yPos:0];
//        [UICommonMethods addLineSeperator:cell.contentView yPos:cell.contentView.frame.size.height - 1];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isConfig){
        if(self.indexPath == indexPath)
            self.indexPath = nil;
        else
            self.indexPath = indexPath;
        
        [tableView beginUpdates]; // Animate the height change
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    else{
        NSLog(@"button Position %@",[self.buttonValueArr objectAtIndex:indexPath.row]);
        NSString *value = [self.buttonValueArr objectAtIndex:indexPath.row];
        self.isSelected = YES;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self sendUpadateVelue:value genericIndexId:@(self.genericIndexValue.index).stringValue];
    }
}
-(void)setPickerValue:(NSString *)pickerSelectedValue rowPosition:(NSString*)rowPosition{
    NSLog(@"picker value delegate %@ rowPosition %@",pickerSelectedValue,rowPosition);
    NSArray *returnSelectedButtonArr = [self returnSelectedButtonArr:rowPosition pickerValue:pickerSelectedValue];
    NSString *returnButtonString = [returnSelectedButtonArr componentsJoinedByString:@","];
    NSString *returnString = [NSString stringWithFormat:@"%@,%@",pickerSelectedValue,returnButtonString];
    NSLog(@"returnString = = %@",returnString);
     [self sendUpadateVelue:returnString genericIndexId:@(self.genericIndexValue.index + 7).stringValue];

    
    
}
-(NSArray *)returnSelectedButtonArr:(NSString *)rowPosition pickerValue:(NSString *)pickerValue{
    NSMutableArray *returnStatusArr = [NSMutableArray arrayWithArray:self.statusArr];
    for(int i= 0;i<=7;i++){
        if(i== [rowPosition intValue])
            returnStatusArr[i] = pickerValue;
    }
    return returnStatusArr;
}
-(void)sendUpadateVelue:(NSString *)value genericIndexId:(NSString *)gId{
     mii = arc4random()%10000;
    GenericIndexValue *genricIndexValue = [GenericIndexValue new];
    genricIndexValue.index = [gId intValue];
    genricIndexValue.deviceID = self.genericIndexValue.deviceID;
    [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genricIndexValue mii:mii value:value];
}
#pragma mark - TextField Delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"Text field did begin editing");
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"Text field ended editing");
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self sendUpadateVelue:textField.text genericIndexId:@"1"];
    [textField resignFirstResponder];
    
    return YES;
}
-(void)onMobileCommandResponse:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSDictionary *resDict;
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:almond.almondplusMAC];
    if(local){
        resDict = [data valueForKey:@"data"];
    }else{
        resDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    
    if([resDict[@"Success"] isEqualToString:@"true"]){
         dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
         });
    }
    
    
}
@end
