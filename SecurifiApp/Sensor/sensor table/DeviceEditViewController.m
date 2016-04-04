//
//  DeviceEditViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DeviceEditViewController.h"
#import "UIFont+Securifi.h"

#import "SFIColors.h"
#import "HorizontalPicker.h"
#import "MultiButtonView.h"
#import "HueColorPicker.h"
#import "Slider.h"
#import "TextInput.h"
#import "DeviceHeaderView.h"

#import "clientTypeCell.h"
#import "Colours.h"
#import "CollectionViewCell.h"
#import "GenericIndexValue.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "GridView.h"
#import "ListButtonView.h"
#import "DevicePayload.h"
#import "GenericIndexUtil.h"
#import "ClientPayload.h"

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

@interface DeviceEditViewController ()<MultiButtonViewDelegate,TextInputDelegate,HorzSliderDelegate,HueColorPickerDelegate,SliderViewDelegate,DeviceHeaderViewDelegate,clientTypeCellDelegate,MultiButtonViewDelegate,GridViewDelegate,ListButtonDelegate>
//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;

//wifi client @property
@property (nonatomic) IBOutlet UIView *indexView;
@property (nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceEditHeaderCell;

@property (nonatomic) UIScrollView *scrollView;
@end

@implementation DeviceEditViewController{
    NSArray *type;
    int randomMobileInternalIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDeviceEditCell];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawIndexes];
    });
}

-(void)setUpDeviceEditCell{
    if(self.isSensor){
        [self.deviceEditHeaderCell initializeSensorCellWithGenericParams:self.genericParams cellType:SensorEdit_Cell];
    }
    else{
        [self.deviceEditHeaderCell initializeSensorCellWithGenericParams:self.genericParams cellType:ClientEditProperties_cell];
    }
    self.deviceEditHeaderCell.delegate = self;
    [self.deviceEditHeaderCell setUpDeviceCell];

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
    self.indexesScroll.backgroundColor = self.genericParams.color;
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
            NSLog(@"layout type %@",genericIndexObj.layoutType );
            if([genericIndexObj.layoutType isEqualToString:SLIDER]){
                HorizontalPicker *horzView = [[HorizontalPicker alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                horzView.delegate = self;
                [view addSubview:horzView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:MULTI_BUTTON]){
                MultiButtonView *buttonView = [[MultiButtonView alloc]initWithFrame:BUTTON_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                buttonView.delegate = self;
                [view addSubview:buttonView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:HUE]){
                HueColorPicker *hueView = [[HueColorPicker alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                hueView.delegate = self;
                [view addSubview:hueView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:HUE_SLIDER]){
                Slider *sliderView = [[Slider alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                sliderView.delegate = self;
                [view addSubview:sliderView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:TEXT_VIEW]){
                TextInput *textView = [[TextInput alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                textView.delegate = self;
                [view addSubview:textView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:GRID_VIEW]){
                self.scrollView.hidden = YES;
                 NSString *schedule = [Client getScheduleById:@(genericIndexValue.deviceID).stringValue];
                NSLog(@" schedule %@",schedule);
                view.frame = CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, self.view.frame.size.height - view.frame.origin.y - 5);

                GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width, self.view.frame.size.height - 5) color:self.genericParams.color genericIndexValue:genericIndexValue onSchedule:(NSString*)schedule];
                grid.delegate = self;
                [view addSubview:grid];
            }
            else if ([genericIndexObj.layoutType isEqualToString:LIST]){
                view.frame = CGRectMake(0, yPos , self.indexesScroll.frame.size.width-xIndent, self.view.frame.size.height - view.frame.origin.y - 5);
                ListButtonView * typeTableView = [[ListButtonView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width , self.view.frame.size.height- 5) color:self.genericParams.color genericIndexValue:genericIndexValue];
                typeTableView.delegate = self;
                
                [view addSubview:typeTableView];
            }
            
            [self.indexesScroll addSubview:view];
            yPos = yPos + view.frame.size.height + LABELSPACING;
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


#pragma mark typeTable
-(void)textFieldView:(NSString *)name{
    TextInput *textView = [[TextInput alloc]initWithFrame:CGRectMake(8,25,self.indexView.frame.size.width - 8,50)];
    textView.color = [UIColor clearColor];
    [self.indexView addSubview:textView];
    
}
-(void)buttonView:(NSArray*)arr selectedValue:(int)selectedVal{
    
    MultiButtonView *presenceSensor = [[MultiButtonView alloc]initWithFrame:CGRectMake(5,40,self.indexView.frame.size.width - 8,30 )];
    presenceSensor.color = [SFIColors clientGreenColor];
    presenceSensor.delegate = self;
    [self.indexView addSubview:presenceSensor];
}



#pragma mark gridView
-(void)gridView:(UIView *)view{
    self.indexView.hidden = YES;
    GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width, self.view.frame.size.height - 5)];
    [view addSubview:grid];
    
}
#pragma mark delegate callback methods
-(void)saveDeviceNewValue:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue{// index is genericindex for clients, normal index for sensors
    NSLog(@"saveDeviceNewValue %@",newValue);
    GenericCommand *command = [[GenericCommand alloc] init];
    NSDictionary *payload;
    int index = genericIndexValue.index;
    if(self.isSensor){
        DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
        if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
            Device *device = [Device getDeviceForID:_genericParams.headerGenericIndexValue.deviceID];
            device = [Device getDeviceCopy:device];
            [Device setDeviceNameLocation:device forGenericID:index value:newValue];
            payload = [DevicePayload getNameLocationChangePayloadForGenericProperty:self.genericParams.headerGenericIndexValue mii:randomMobileInternalIndex device:device];
            NSLog(@"sensor name location payload: %@", payload);
            command.commandType = CommandType_UPDATE_DEVICE_NAME;//same for location
 
        }else{
            NSDictionary *payload = [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex value:newValue];
            GenericCommand *command = [[GenericCommand alloc] init];
            command.commandType = CommandType_UPDATE_DEVICE_INDEX;
            NSLog(@"sensor update index payload: %@", payload);
            [self asyncSendCommand:command];
        }
    }else{
        NSLog(@"saveDeviceNewValue - clients");
        Client *client = [Client findClientByID:@(_genericParams.headerGenericIndexValue.deviceID).stringValue];
        //Need to create client copy and set.
        [Client getOrSetValueForClient:client genericIndex:index newValue:newValue ifGet:NO];
        payload = [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:randomMobileInternalIndex];
        command.commandType = CommandType_UPDATE_CLIENT;
        
        NSLog(@"client payload  : %@", payload);
    }
    command.command = [payload JSONString];
    [self asyncSendCommand:command];
}

#pragma mark delegate callback methods
-(void)updateSliderValue:(NSString*)newvalue{
    NSLog(@"updateSliderValue");
}
-(void)updateHueColorPicker:(NSString *)newValue{
    NSLog(@"updateHueColorPicker");
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
