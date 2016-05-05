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
#import "UIViewController+Securifi.h"
#import "GridView.h"
#import "ListButtonView.h"
#import "DevicePayload.h"
#import "GenericIndexUtil.h"
#import "ClientPayload.h"
#import "CommonMethods.h"
#import "RulesNestThermostat.h"

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

@interface DeviceEditViewController ()<MultiButtonViewDelegate,TextInputDelegate,HorzSliderDelegate,HueColorPickerDelegate,SliderViewDelegate,DeviceHeaderViewDelegate,MultiButtonViewDelegate,GridViewDelegate,ListButtonDelegate>
//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;

//wifi client @property
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceEditHeaderCell;
@property (nonatomic) UIView *dismisstamperedView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic)BOOL isLocal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indexScrollTopConstraint;

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
    if(self.genericParams.isSensor){
        [self.deviceEditHeaderCell initialize:self.genericParams cellType:SensorEdit_Cell];
    }
    else{
        [self.deviceEditHeaderCell initialize:self.genericParams cellType:ClientEditProperties_cell];
    }
    self.deviceEditHeaderCell.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"deviceedit viewWillAppear");
    [super viewWillAppear:YES];
    randomMobileInternalIndex = arc4random() % 10000;
    [self initializeNotifications];
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    
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
    [center addObserver:self selector:@selector(onDeviceListAndDynamicResponseParsed:) name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil]; //indexupdate or name/location change both
}
- (void)clearAllViews{
    dispatch_async(dispatch_get_main_queue(), ^(){
        for(UIView *view in self.scrollView.subviews){
            [view removeFromSuperview];
        }
        for(UIView *view in self.view.subviews){
            [view removeFromSuperview];
        }
    });
}
#pragma mark drawerMethods
-(void)drawIndexes{
    int yPos = LABELSPACING;
    self.indexesScroll.backgroundColor = self.genericParams.color;
    NSLog(@"index count %ld",self.genericParams.indexValueList.count);
//    CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.genericParams.indexValueList.count  * 75 );
//    [self.indexesScroll setContentSize:scrollableSize];
    [self.indexesScroll flashScrollIndicators];
    
    for(GenericIndexValue *genericIndexValue in self.genericParams.indexValueList)
    {
        GenericIndexClass *genericIndexObj = genericIndexValue.genericIndex;
        if(self.isLocal && [genericIndexObj.ID isEqualToString:@"-3"])
            continue;
        
        NSLog(@"layout type :- %@",genericIndexObj.layoutType);
        if([genericIndexObj.layoutType isEqualToString:@"Info"] || [genericIndexObj.layoutType.lowercaseString isEqualToString:@"off"] || genericIndexObj.layoutType == nil || [genericIndexObj.layoutType isEqualToString:@"NaN"]){
            continue;
        }
        NSString *propertyName = genericIndexObj.groupLabel;
        NSLog(@"read only %d,layouttype %@ ,type %@ groupLabel %@",genericIndexObj.readOnly,genericIndexObj.layoutType,genericIndexObj.type,genericIndexObj.groupLabel);
        if(genericIndexObj.readOnly){
            UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_SMALL];
            if([genericIndexObj.ID isEqualToString:@"9"] && [genericIndexValue.genericValue.value isEqualToString:@"true"])
            {
                [self disMissTamperedView];
                continue;
            }
            if([genericIndexObj.ID isEqualToString:@"12"] || [genericIndexObj.ID isEqualToString:@"9"])//skipping low battery
                    continue;
            [self.indexesScroll addSubview:view];
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 0, 100, 15)];
            [self setUpLable:valueLabel withPropertyName:genericIndexValue.genericValue.displayText];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.alpha = 0.5;
            [view addSubview:valueLabel];
            yPos = yPos + view.frame.size.height + LABELSPACING;
        }
        
        else{
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, 65)];
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            if([CommonMethods isDimmerLayout:genericIndexObj.layoutType layout:@"SINGLE_TEMP"]){
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
            else if ([CommonMethods isDimmerLayout:genericIndexObj.layoutType layout:@"SLIDER"]){
                Slider *sliderView = [[Slider alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                sliderView.delegate = self;
                [view addSubview:sliderView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:TEXT_VIEW]){
            
                NSLog(@"view frame %@ and ypos = %d",NSStringFromCGRect(view.frame),yPos);
                TextInput *textView = [[TextInput alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                textView.delegate = self;
                [view addSubview:textView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:GRID_VIEW]){
                self.scrollView.hidden = YES;
                 NSString *schedule = [Client getScheduleById:@(genericIndexValue.deviceID).stringValue];
                view.frame = CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, self.view.frame.size.height - view.frame.origin.y - 5);
                GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width, self.view.frame.size.height - 5) color:self.genericParams.color genericIndexValue:genericIndexValue onSchedule:(NSString*)schedule];
                grid.delegate = self;
                [view addSubview:grid];
            }
            else if ([genericIndexObj.layoutType isEqualToString:LIST]){
                 NSLog(@"before update view frame %@ ",NSStringFromCGRect(view.frame));
                float height = genericIndexValue.genericIndex.values.allKeys.count *45;
                view.frame = CGRectMake(5, yPos, self.indexesScroll.frame.size.width, height);
                 NSLog(@"after update view frame %@ ",NSStringFromCGRect(view.frame));
                ListButtonView * typeTableView = [[ListButtonView alloc]initWithFrame:CGRectMake(0,LABELHEIGHT, view.frame.size.width , self.view.frame.size.height- 5) color:self.genericParams.color genericIndexValue:genericIndexValue];
                NSLog(@"after update typeTableView frame %@ ",NSStringFromCGRect(typeTableView.frame));
                typeTableView.delegate = self;
                [view addSubview:typeTableView];
            }
            [self.indexesScroll addSubview:view];
           
            NSLog(@"ypos %d",yPos);
            CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,yPos + 60);
             yPos = yPos + view.frame.size.height + LABELSPACING;
            [self.indexesScroll setContentSize:scrollableSize];
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
-(void)disMissTamperedView{
    self.dismisstamperedView = [[UIView alloc]initWithFrame:CGRectMake(self.indexesScroll.frame.origin.x, self.deviceEditHeaderCell.frame.size.height + self.deviceEditHeaderCell.frame.origin.y + 5, self.indexesScroll.frame.size.width, 40)];
    self.dismisstamperedView.backgroundColor = [SFIColors ruleOrangeColor];
    UIImageView *tamperedImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 3, 30, 30)];
    tamperedImgView.image = [UIImage imageNamed:@"tamper"];
    [self.dismisstamperedView addSubview:tamperedImgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 3, self.dismisstamperedView.frame.size.width - 60, 30)];
    label.text = @"Device has been tampered";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont securifiFont:12];
    [self.dismisstamperedView addSubview:label];
    UIImageView *crossIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.dismisstamperedView.frame.size.width -45, 8, 20, 20)];
    crossIcon.image = [UIImage imageNamed:@"cross_icon"];
    crossIcon.alpha = 0.5;
    [self.dismisstamperedView addSubview:crossIcon];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimissTamperTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.dismisstamperedView setUserInteractionEnabled:YES];
    [self.dismisstamperedView addGestureRecognizer:singleTap];
    self.indexScrollTopConstraint.constant = 40;
    [self.view addSubview:self.dismisstamperedView];
}

-(void)dimissTamperTap:(id)sender{
    [self showToast:@"Saving..."];
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:15 options:nil animations:^() {
        ///[DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex value:newValue];
        [self.dismisstamperedView removeFromSuperview];
        self.deviceEditHeaderCell.tamperedImgView.hidden = YES;
        self.indexScrollTopConstraint.constant = 2;
    } completion:nil];
}

#pragma mark gridView
-(void)gridView:(UIView *)view{
    GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width, self.view.frame.size.height - 5)];
    [view addSubview:grid];
    
}
#pragma mark delegate callback methods
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue{// index is genericindex for clients, normal index for sensors
    NSLog(@"newvalue %@",newValue);
    [self.deviceEditHeaderCell reloadIconImage];
    int index = genericIndexValue.index;
    if([Device getTypeForID:genericIndexValue.deviceID]){
//        [self handleNest3PointDiffForIndex:index newValue:newValue];
    }
    if(self.genericParams.isSensor){
        DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
        if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
            [DevicePayload getNameLocationChange:genericIndexValue mii:randomMobileInternalIndex value:newValue];
        }else{
            [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex value:newValue];
        
        }
    }else{
        Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
        client = [client copy];
        [Client getOrSetValueForClient:client genericIndex:index newValue:newValue ifGet:NO];
        [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:randomMobileInternalIndex];
    }
}

-(void)delegateDeviceEditSettingClick{
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)handleNest3PointDiffForIndex:(int)index newValue:(NSString*)value{
//    NSLog(@"handleNest3PointDiffForIndex - index: %d, value: %@", index, value);
//    NSArray *scrollSubViews = [self.indexesScroll subviews];
//    for(UIView *view in scrollSubViews){
//        NSLog(@"view: %@", view);
//        if(![view isKindOfClass:[UIImageView class]]){
//            UIView *insideView = [[view subviews] objectAtIndex:1];
//            if([insideView isKindOfClass:[HorizontalPicker class]]){
//                NSLog(@"horizantal picker");
//                HorizontalPicker *picker = (HorizontalPicker*)insideView;
//                
//                if(picker.genericIndexValue.index == 6 && index == 5){
//                    if([picker.genericIndexValue.genericValue.value intValue] - [value intValue] < 3){
//                        NSLog(@"updating value");
//                        [picker.horzPicker scrollToElement:([value intValue] + 3) + picker.genericIndexValue.genericIndex.formatter.min animated:YES];
//                    }
//                }else if(picker.genericIndexValue.index == 5 && index == 6){
//                    if([value intValue] - [picker.genericIndexValue.genericValue.value intValue]< 3){
//                        [picker.horzPicker scrollToElement:([value intValue]-3) + picker.genericIndexValue.genericIndex.formatter.min animated:YES];
//                    }
//                }
//                
//            }
//        }
//    }
//}

#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)toggle:(GenericIndexValue *)genericIndexValue{
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    [DevicePayload getSensorIndexUpdate:genericIndexValue mii:randomMobileInternalIndex];
}

#pragma mark command responses
-(void)onCommandResponse:(id)sender{ //mobile command sensor and client
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
}


-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
    dispatch_async(dispatch_get_main_queue(), ^(){
//        [self.navigationController popToRootViewControllerAnimated:YES];
    });
    
     
//    [self.deviceEditHeaderCell initializeSensorCellWithGenericParams:self.genericParams cellType:SensorEdit_Cell];
//    Device *device = [Device getDeviceForID:self.genericParams.headerGenericIndexValue.deviceID];
//    [self.genericParams setGenericParamsWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[UIColor greenColor]];
//    [self.deviceEditHeaderCell setUPSensorCell];
}


@end
