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


@interface IRViewController ()<PickerComponentViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *LEDView;
@property (weak, nonatomic) IBOutlet UIView *labelSwitchView;
@property (weak, nonatomic) IBOutlet UITableView *buttonTableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic)NSArray *buttonArr;
@property (weak, nonatomic) IBOutlet UISwitch *configSwitch;
@property (weak, nonatomic) IBOutlet UITextField *NameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstrain;
@property BOOL isConfig;
@property BOOL isSelected;
@property CGFloat tableViewDefaultConstrain;
@property (nonatomic)NSArray *statusArr;
@property (nonatomic)NSMutableArray *buttonValueArr;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceHeaderCell;
@property (nonatomic) NSMutableArray *ledValueArr;

@end

@implementation IRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GenericIndexValue *gval = self.genericIndexValue;
    
    self.NameTextField.text =gval.genericIndex.groupLabel;
    _tableViewDefaultConstrain = self.tableViewTopConstrain.constant;
     [self setUpDeviceEditCell];
    NSLog(@"gval.genericIndex value %@",gval.genericValue.value);
    _buttonArr = [[NSArray alloc]initWithObjects:@"Default",@"Default",@"Default",@"Default",@"Default",@"Default",@"Default",@"Default", nil];
     self.buttonValueArr = [NSMutableArray new];
    self.ledValueArr = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",@"0",@"0",@"0", nil];
    
    [self setConfig:self.configSwitch];
    [self setButtonLayOut];
    // Do any additional setup after loading the view.
    [self setBackgroundColor];
    [self addDayView];
    
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
        //[self setPreviousHighlight:dayButton];
        xVal += dayButtonWidth + spacing;
        tag++;
    }
    dayView.center = CGPointMake(CGRectGetMidX(self.LEDView.bounds), dayView.center.y);
    //    dayView.backgroundColor = [UIColor orangeColor];
    [self.LEDView addSubview:dayView];
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
     NSLog(@"ledHexStr %@",ledHexStr);
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
        return [NSString stringWithFormat:@"%X", value];
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
//-(void)setPreviousHighlight:(UIButton*)dayButton{
//    NSMutableArray *earlierSelection = self.ruleTime.dayOfWeek;
//    for (NSString* tag in earlierSelection) {
//        if ([tag isEqualToString:@(dayButton.tag).stringValue]) {
//            dayButton.selected = YES;
//            dayButton.backgroundColor = [SFIColors ruleBlueColor];
//            
//        }
//    }
//}
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
    UILabel *cellTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 25)];
    cellTitle.text = [_buttonArr objectAtIndex:indexPath.row];
    
    
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
        textCheckMarkView.frame = CGRectMake(cell.contentView.frame.size.width - 30 , 7, 25 , 25);
        CALayer * l1 = [textCheckMarkView layer];
        [l1 setMasksToBounds:YES];
        [l1 setCornerRadius:25/2];
        
            
        l1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
//        textCheckMarkView.layer.masksToBounds = NO;
//        textCheckMarkView.layer.shadowOffset = CGSizeMake(-15, 20);
//        textCheckMarkView.layer.shadowRadius = 5;
//        textCheckMarkView.layer.shadowOpacity = 0.5;
        if(self.isSelected)
            textCheckMarkView.backgroundColor = [UIColor whiteColor];
        else
            textCheckMarkView.backgroundColor = [UIColor whiteColor];
        
    }
    if (self.indexPath == indexPath && self.isConfig)
    {
        for(UIView *picView in cell.contentView.subviews){
            if([picView isKindOfClass:[PickerComponentView class]])
                [picView removeFromSuperview];
        }
        textCheckMarkView.image = [UIImage imageNamed:@"up_arrow"];
        PickerComponentView *pickerView = [[PickerComponentView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width - 40, 160) arrayList:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25"] atRowPosition:indexPath.row];
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
        [self sendUpadateVelue:value genericIndexId:@"112"];
    }
}
-(void)setPickerValue:(NSString *)pickerSelectedValue rowPosition:(NSString*)rowPosition{
    NSLog(@"picker value delegate %@ rowPosition %@",pickerSelectedValue,rowPosition);
    NSArray *returnSelectedButtonArr = [self returnSelectedButtonArr:rowPosition];
    NSString *returnButtonString = [returnSelectedButtonArr componentsJoinedByString:@","];
    NSString *returnString = [NSString stringWithFormat:@"%@,%@",pickerSelectedValue,returnButtonString];
    NSLog(@"returnString = = %@",returnString);
     [self sendUpadateVelue:returnString genericIndexId:@"115"];

    
    
}
-(NSArray *)returnSelectedButtonArr:(NSString *)rowPosition{
    NSMutableArray *returnStatusArr = [NSMutableArray arrayWithArray:self.statusArr];
    for(int i= 0;i<=7;i++){
        if(i== [rowPosition intValue])
            returnStatusArr[i] = @"1";
    }
    return returnStatusArr;
}
-(void)sendUpadateVelue:(NSString *)value genericIndexId:(NSString *)gId{
    GenericIndexValue *genricIndexValue = [GenericIndexValue new];
    genricIndexValue.index = [gId intValue];
    genricIndexValue.deviceID = self.genericIndexValue.deviceID;
    [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genricIndexValue mii:121 value:value];
}
@end
