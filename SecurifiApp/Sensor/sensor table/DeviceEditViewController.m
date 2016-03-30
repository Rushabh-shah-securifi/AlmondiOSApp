//
//  DeviceEditViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DeviceEditViewController.h"
#import "UIFont+Securifi.h"

#import "V8HorizontalPickerView.h"
#import "SFIPickerIndicatorView1.h"
#import "SFIColors.h"
#import "HorizontalPicker.h"
#import "MultiButtonView.h"
#import "HueColorPicker.h"
#import "Slider.h"
#import "TextInput.h"
#import "DeviceHeaderView.h"

#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "clientTypeCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "CollectionViewCell.h"
#import "GenericIndexValue.h"
#import "GenericIndexClass.h"
#import "GenericIndexValue.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "GridView.h"
#import "ListButtonView.h"
#import "DevicePayload.h"
#import "GenericIndexUtil.h"

#define ITEM_SPACING  2.0
#define LABELSPACING 20.0
#define LABELVALUESPACING 10.0
#define LABELHEIGHT 20.0

#define VIEW_FRAME_SMALL CGRectMake(xIndent, yPos, self.indexesScroll.frame.size.width-xIndent, LABELHEIGHT)
#define VIEW_FRAME_LARGE CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, 65)
#define LABEL_FRAME CGRectMake(0, 0, view.frame.size.width-16, LABELHEIGHT)
#define SLIDER_FRAME CGRectMake(0, LABELHEIGHT + LABELVALUESPACING,view.frame.size.width-10, 35)
#define BUTTON_FRAME CGRectMake(0, LABELHEIGHT + LABELVALUESPACING,view.frame.size.width-10,  35)
static const int xIndent = 10;

@interface DeviceEditViewController ()<MultiButtonViewDelegate,TextInputDelegate,HorzSliderDelegate,HueColorPickerDelegate,SliderViewDelegate,DeviceHeaderViewDelegate,clientTypeCellDelegate,MultiButtonViewDelegate>
//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;

//wifi client @property
@property (nonatomic) IBOutlet UIView *indexView;
@property (nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceEditHeaderCell;


@property (nonatomic) UITableView *tableType;
@property (strong ,nonatomic) UISegmentedControl *allowOnNetworkSegment;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *clientTypesView;
@property (nonatomic)UIView *allowOnNetworkView;
@property (nonatomic)UICollectionView *collectionView;
@property (nonatomic)NSString *selectedType;/*    NSMutableString *hexBlockedDays;
                                             */
@property (nonatomic)NSMutableString *hexBlockedDays;


@end

@implementation DeviceEditViewController{
    NSMutableArray * blockedDaysArray;
    NSString *blockedType;
    NSArray *type;
    int randomMobileInternalIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceEditHeaderCell.delegate = self;
    if(self.isSensor){
        self.scrollView.hidden = NO;
        [self.deviceEditHeaderCell initializeSensorCellWithGenericParams:self.genericParams cellType:SensorEdit_Cell];
        self.deviceEditHeaderCell.delegate = self;
        [self.deviceEditHeaderCell setUpDeviceCell];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawIndexes];
        });
    }
    else{
        // wifi clients
        self.scrollView.hidden = YES;
        self.deviceEditHeaderCell.cellType = ClientEditProperties_cell;
//        [self drawViews];
//        self.selectedType = [self.deviceDict valueForKey:@"Type"];
        type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"sensor viewWillAppear");
    [super viewWillAppear:YES];
    randomMobileInternalIndex = arc4random() % 10000;
    [self initializeNotifications];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearAllViews];
}

-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onUpdateDeviceIndexResponse:) name:NOTIFICATION_UPDATE_DEVICE_INDEX_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onDeviceListAndDynamicResponseParsed:) name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onDeviceNameChanged:) name:NOTIFICATION_UPDATE_DEVICE_NAME_NOTIFIER object:nil];
}
- (void)clearAllViews{
    for(UIView *view in self.scrollView.subviews){
        [view removeFromSuperview];
    }
    for(UIView *view in self.view.subviews){
        [view removeFromSuperview];
    }
}


-(void)drawIndexes{
    int yPos = LABELSPACING;
    CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.genericParams.indexValueList.count * 80 + 210);
    [self.indexesScroll setContentSize:scrollableSize];
    [self.indexesScroll flashScrollIndicators];
    for(GenericIndexValue *genericIndexValue in self.genericParams.indexValueList){
        NSLog(@"genericIndexValue loop");
        GenericIndexClass *genericIndexObj = genericIndexValue.genericIndex;
        if([genericIndexObj.layoutType isEqualToString:@"Info"] || [genericIndexObj.layoutType.lowercaseString isEqualToString:@"off"] || genericIndexObj.layoutType == nil || [genericIndexObj.layoutType isEqualToString:@"NaN"]){
            continue;
        }
        
        NSString *propertyName = genericIndexObj.groupLabel;
        if([genericIndexObj.type isEqualToString:SENSOR]){
            UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_SMALL];
            [self.indexesScroll addSubview:view];
            
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 0, 100, 15)];
            [self setUpLable:valueLabel withPropertyName:genericIndexValue.genericValue.value];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.alpha = 0.5;
            [view addSubview:valueLabel];
            
            yPos = yPos + view.frame.size.height + LABELSPACING;
            NSLog(@" r-yPos %d",yPos);
        }
        else{
            UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_LARGE];
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            if([genericIndexObj.layoutType isEqualToString:SLIDER]){
                HorizontalPicker *horzView = [[HorizontalPicker alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                horzView.delegate = self;
                [horzView drawSlider];
                [view addSubview:horzView];
            }/*
            else if ([genericIndexObj.layoutType isEqualToString:Multi_Input]){
                MultiButtonView *buttonView = [[MultiButtonView alloc]initWithFrame:BUTTON_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                buttonView.delegate = self;
                buttonView.color = [SFIColors clientGreenColor];
                [buttonView drawButton:genericIndexObj.values color:[SFIColors ruleBlueColor]];
                [view addSubview:buttonView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:HUE]){
                HueColorPicker *HueView = [[HueColorPicker alloc]initWithFrame:SLIDER_FRAME];
                HueView.delegate = self;
                [HueView drawHueColorPicker];
                [view addSubview:HueView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:HUE_SLIDER]){
                Slider *sliderView = [[Slider alloc]initWithFrame:SLIDER_FRAME];
                Formatter *formatter = genericIndexObj.formatter;
                sliderView.min = formatter.min;
                sliderView.max = formatter.max;
                sliderView.color = [SFIColors ruleBlueColor];
                sliderView.delegate = self;
                [sliderView drawSlider];
                [view addSubview:sliderView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:TEXT_VIEW]){
                TextInput *textView = [[TextInput alloc]initWithFrame:SLIDER_FRAME];
                [textView drawTextField:genericIndexValue.genericValue.value];
                textView.delegate = self;
                [view addSubview:textView];
            }*/
            else if ([genericIndexObj.layoutType isEqualToString:LIST]){
                self.scrollView.hidden = YES;
                view.frame = CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, self.view.frame.size.height - view.frame.origin.y - 5);
                //self.view.frame.size.height - view.frame.origin.y - 5
                [self gridView:view];
            }
            else if (1){
                view.frame = CGRectMake(0, yPos , self.indexesScroll.frame.size.width-xIndent, self.view.frame.size.height - view.frame.origin.y - 5);
                [self drawTypeTable:view];
            }
            
            [self.indexesScroll addSubview:view];
            yPos = yPos + view.frame.size.height + LABELSPACING;
            NSLog(@" rw-yPos %d",yPos);
        }
    }
}
- (void)setUpLable:(UILabel*)label withPropertyName:(NSString*)propertyName{
    label.text = propertyName;
    label.font = [UIFont securifiBoldFontLarge];
    label.textColor = [UIColor whiteColor];
}

- (IBAction)onSeettingButtonClicked:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark wifiClients methods
//-(void)drawViews{
//    self.scrollView.backgroundColor = [UIColor clearColor];
//    self.scrollView.hidden = YES;
//    self.indexView = [[UIView alloc]initWithFrame:CGRectMake(8 , 80, self.view.frame.size.width - 16, 74)];
//    self.indexView.backgroundColor = [SFIColors clientGreenColor];
//    [self.view addSubview:self.indexView];
//    
//    self.indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, 100, 25)];
//    self.indexLabel.backgroundColor = [UIColor clearColor];
//    self.indexLabel.textColor = [UIColor whiteColor];
//    self.indexLabel.text = self.indexName;
//    self.indexLabel.font = [UIFont securifiFont:15];
//    
//    [self.indexView addSubview:self.indexLabel];
//    
//    
//    if([self.indexName isEqualToString:@"Name"]){
//       // self.indexLabel.text = self.indexName;
//        [self textFieldView:[self.deviceDict valueForKey:self.indexName]];
//    }
//    else if ([self.indexName isEqualToString:@"Type"]){
//        [self drawTypeTable];
//    }
//    
//    else if ([self.indexName isEqualToString:@"AllowedType"]){
//        [self gridView];
//        
//    }
//    else if ([self.indexName isEqualToString:@"pesenceSensor"]){
//        NSArray *arr = @[@"YES",@"NO",@"ON",@"OFF"];
//        int currentValPos = 0;
//            for(NSString *str in arr){
//                if([str isEqualToString:[self.deviceDict valueForKey:self.indexName]])
//                    break;
//                currentValPos++;
//            }
//        self.indexLabel.text = self.indexName;
//        
//        [self buttonView:arr selectedValue:currentValPos];
//    }
//    else if ([self.indexName isEqualToString:@"inActiveTimeOut"]){
//        self.indexLabel.text = self.indexName;
//        [self textFieldView:[self.deviceDict valueForKey:self.indexName]];
//    }
//    else if ([self.indexName isEqualToString:@"Other"]){
//        
//    }
//    
//}
#pragma mark typeTable
-(void)drawTypeTable:(UIView *)view{
    self.indexView.hidden = YES;
    ListButtonView * typeTableView = [[ListButtonView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width , self.view.frame.size.height- 5)];
    [typeTableView drawTypeTable:@"MAC"];
    [view addSubview:typeTableView];

}
-(void)textFieldView:(NSString *)name{
    TextInput *textView = [[TextInput alloc]initWithFrame:CGRectMake(8,25,self.indexView.frame.size.width - 8,50)];
    textView.color = [UIColor clearColor];
    [textView drawTextField:name];
    [self.indexView addSubview:textView];
    
}
-(void)buttonView:(NSArray*)arr selectedValue:(int)selectedVal{
    
    MultiButtonView *presenceSensor = [[MultiButtonView alloc]initWithFrame:CGRectMake(5,40,self.indexView.frame.size.width - 8,30 )];
    presenceSensor.color = [SFIColors clientGreenColor];
    [presenceSensor drawButton:arr selectedValue:selectedVal];
    presenceSensor.delegate = self;
    [self.indexView addSubview:presenceSensor];
}



#pragma mark gridView
-(void)gridView:(UIView *)view{
    self.indexView.hidden = YES;
    GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width, self.view.frame.size.height - 5)];
    [grid addSegmentControll];
    [view addSubview:grid];
//    [self addSegmentControll];
    
}

#pragma mark delegate callback methods
-(void)updateNewValue:(NSString *)newValue{
    NSLog(@"updateNewValue %@",newValue);
    NSDictionary *payload = [DevicePayload getNameLocationChangePayloadForGenericProperty:self.genericParams.headerGenericIndexValue mii:randomMobileInternalIndex name:newValue location:@"my location"];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_NAME;
    command.command = [payload JSONString];
    
    [self asyncSendCommand:command];
}
-(void)updateSliderValue:(NSString*)newvalue{
    NSLog(@"updateSliderValue");
}
-(void)updateHueColorPicker:(NSString *)newValue{
    NSLog(@"updateHueColorPicker");
}

-(void)updateButtonStatus:(NSString *)newValue genericIndexValue:(GenericIndexValue*)genericIndexValue{//here we have to pass many things like deviceIndexId,deviceID,...

    NSLog(@" updateButtonStatus %@",newValue);
    NSDictionary *payload = [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex value:newValue];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_INDEX;
    command.command = [payload JSONString];
    [self asyncSendCommand:command];
}

-(void)updatePickerValue:(NSString *)newValue genericIndexValue:(GenericIndexValue*)genericIndexValue{
    NSLog(@"updatePickerValue");
    NSDictionary *payload = [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex value:newValue];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_INDEX;
    command.command = [payload JSONString];
    [self asyncSendCommand:command];
}

#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)delegateDeviceButtonClickWithGenericProperies:(GenericIndexValue *)genericIndexValue{
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    NSDictionary *payload = [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_INDEX;
    command.command = [payload JSONString];
    
    [self asyncSendCommand:command];
}

#pragma mark command responses
-(void)onUpdateDeviceIndexResponse:(id)sender{
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
}

-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
//    [self.deviceEditHeaderCell initializeSensorCellWithGenericParams:self.genericParams cellType:SensorEdit_Cell];
//    Device *device = [Device getDeviceForID:self.genericParams.headerGenericIndexValue.deviceID];
//    [self.genericParams setGenericParamsWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[UIColor greenColor]];
//    [self.deviceEditHeaderCell setUPSensorCell];
}

-(void)onDeviceNameChanged:(id)sender{
    NSLog(@"onDeviceNameChanged - ");
    
}

- (void)asyncSendCommand:(GenericCommand *)command {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    if(local){
        [[SecurifiToolkit sharedInstance] asyncSendToLocal:command almondMac:almond.almondplusMAC];
    }else{
        [[SecurifiToolkit sharedInstance] asyncSendToCloud:command];
    }
}

@end
