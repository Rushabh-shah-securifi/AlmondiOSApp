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
@property (nonatomic)GenericIndexValue *genericIndexVal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (nonatomic) NSInteger keyBoardComp;
@property (nonatomic) SecurifiToolkit *toolkit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstrain;
@property(nonatomic) NSMutableDictionary *miiTable;
@end

@implementation DeviceEditViewController{
    NSArray *type;
    int mii;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolkit=[SecurifiToolkit sharedInstance];
    [self setUpDeviceEditCell];
    self.miiTable = [NSMutableDictionary new];
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
    
    [self initializeNotifications];
    
    self.isLocal = [self.toolkit useLocalNetwork:[self.toolkit currentAlmond].almondplusMAC];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearAllViews];
    [self.miiTable removeAllObjects];
}

-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil]; //indexupdate or name/location change both
    
    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(keyboardOnScreen:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
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
    NSLog(@"index count %ld",(unsigned long)self.genericParams.indexValueList.count);
    [self.indexesScroll flashScrollIndicators];
    
    for(GenericIndexValue *genericIndexValue in self.genericParams.indexValueList)
    {
        GenericIndexClass *genericIndexObj = genericIndexValue.genericIndex;
        if(self.isLocal && [genericIndexObj.ID isEqualToString:@"-3"]) //skip notify me in local
            continue;
        
        NSLog(@"layout type :- %@",genericIndexObj.layoutType);
        if([genericIndexObj.layoutType isEqualToString:@"Info"] || [genericIndexObj.layoutType.lowercaseString isEqualToString:@"off"] || genericIndexObj.layoutType == nil || [genericIndexObj.layoutType isEqualToString:@"NaN"]){
            continue;
        }
        NSString *propertyName;
        if([Device getTypeForID:genericIndexValue.deviceID] == SFIDeviceType_DoorLock_5)
            propertyName = [NSString stringWithFormat:@"%@ %d", genericIndexObj.groupLabel, genericIndexValue.index-4];
        else
            propertyName = genericIndexObj.groupLabel;
        
        NSLog(@"read only %d,layouttype %@ ,type %@ groupLabel %@ GINDEX %@ Dindex %d",genericIndexObj.readOnly,genericIndexObj.layoutType,genericIndexObj.type,genericIndexObj.groupLabel,genericIndexObj.ID,genericIndexValue.index);
        
        if(genericIndexObj.readOnly){
            UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_SMALL];
            if([genericIndexObj.ID isEqualToString:@"9"] && [genericIndexValue.genericValue.value isEqualToString:@"true"])
            {   self.genericIndexVal = genericIndexValue;
                [self disMissTamperedView];
                continue;
            }
            if([genericIndexObj.ID isEqualToString:@"12"] || [genericIndexObj.ID isEqualToString:@"9"])//skipping low battery
                    continue;
            
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 0, 100, 15)];
            [self setUpLable:valueLabel withPropertyName:genericIndexValue.genericValue.displayText];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.alpha = 0.5;
            [view addSubview:valueLabel];
            
            yPos = yPos + view.frame.size.height + LABELSPACING;
            [self.indexesScroll addSubview:view];
            
        }
        
        else{
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, 65)];
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            if([genericIndexObj.layoutType isEqualToString:@"SINGLE_TEMP"]){
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
            else if ([genericIndexObj.layoutType isEqualToString: @"SLIDER"] || [genericIndexObj.layoutType isEqualToString:@"SLIDER_ICON"]){
                Slider *sliderView = [[Slider alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                sliderView.delegate = self;
                [view addSubview:sliderView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:TEXT_VIEW] || [genericIndexObj.layoutType isEqualToString:@"TEXT_VIEW_ONLY"]){
                
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
                ListButtonView * typeTableView = [[ListButtonView alloc]initWithFrame:CGRectMake(0,LABELHEIGHT, view.frame.size.width , self.view.frame.size.height- 5)
                                                                                color:self.genericParams.color
                                                                    genericIndexValue:genericIndexValue];
                NSLog(@"after update typeTableView frame %@ ",NSStringFromCGRect(typeTableView.frame));
                typeTableView.delegate = self;
                [view addSubview:typeTableView];
            }
            
            [self.indexesScroll addSubview:view];
           
            NSLog(@"ypos %d",yPos);
            CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,yPos + 60);
             yPos = yPos + view.frame.size.height + LABELSPACING;
            self.keyBoardComp = yPos;
            [self.indexesScroll setContentSize:scrollableSize];
        }
    }
}

- (void)setUpLable:(UILabel*)label withPropertyName:(NSString*)propertyName{
    label.text = propertyName;
    label.font = [UIFont securifiBoldFontLarge];
    label.textColor = [UIColor whiteColor];
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
    mii = arc4random()%10000;
    [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:self.genericIndexVal mii:mii value:@"false"];
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:15 options:nil animations:^() {
        ///[DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:newValue];
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
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue currentView:(UIView*)currentView{// index is genericindex for clients, normal index for sensors
    NSLog(@"newvalue %@",newValue);
    mii = arc4random() % 10000;

    [self.deviceEditHeaderCell reloadIconImage];
    
    if([Device getTypeForID:genericIndexValue.deviceID]){
//        [self handleNest3PointDiffForIndex:index newValue:newValue];
    }
    if(self.genericParams.isSensor){
        genericIndexValue = [GenericIndexValue getLightCopy:genericIndexValue];
        genericIndexValue.currentValue = newValue;
        genericIndexValue.clickedView = currentView;
        [self.miiTable setValue:genericIndexValue forKey:@(mii).stringValue];
        
        DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
        if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
            [DevicePayload getNameLocationChange:genericIndexValue mii:mii value:newValue];
        }else{
            [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:newValue];
        
        }
    }else{
        Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
        int index = genericIndexValue.index;
        client = [client copy];
        [Client getOrSetValueForClient:client genericIndex:index newValue:newValue ifGet:NO];
        [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];
    }
}


-(void)delegateDeviceEditSettingClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark uiwindow delegate methods
- (void)onKeyboardDidShow:(id)notification {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)onKeyboardDidHide:(id)notice {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.indexScrollTopConstraint.constant = 2 + self.dismisstamperedView.frame.size.height;
    self.scrollViewBottom.constant = 8;
    self.headerTopConstrain.constant = 8;
    //    self.dismisstamperedView.frame = CGRectMake(self.indexesScroll.frame.origin.x, self.deviceEditHeaderCell.frame.size.height + self.deviceEditHeaderCell.frame.origin.y + 5, self.indexesScroll.frame.size.width, 40);
    self.dismisstamperedView.hidden = NO;
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    int constnt = self.keyBoardComp - keyboardFrame.origin.y + 70;
    
    if(constnt > (int)self.indexesScroll.frame.size.height)
        constnt = (int)self.indexesScroll.frame.size.height - keyboardFrame.size.height;
    
    self.scrollViewBottom.constant = constnt ;
    self.headerTopConstrain.constant = -(constnt);
    self.indexScrollTopConstraint.constant = -(constnt);
    self.dismisstamperedView.hidden = YES;
    //    self.dismisstamperedView.frame = CGRectMake(0, self.indexesScroll.frame.origin.y, self.dismisstamperedView.frame.size.width, self.dismisstamperedView.frame.size.height);
}


#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)toggle:(GenericIndexValue *)headerGenericIndexValue{
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    mii = arc4random()%10000;
    [self.miiTable setValue:headerGenericIndexValue forKey:@(mii).stringValue];
    [DevicePayload getSensorIndexUpdate:headerGenericIndexValue mii:mii];
}

#pragma mark command responses
-(void)onCommandResponse:(id)sender{ //mobile command sensor and client 1064
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
    SFIAlmondPlus *almond = [self.toolkit currentAlmond];
    BOOL local = [self.toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    
    if(local){
        payload = dataInfo[@"data"];
    }else{
        payload = [dataInfo[@"data"] objectFromJSONData];
    }

    NSLog(@"payload mobile command: %@", payload);
//    if (self.miiTable[payload[@"MobileInternalIndex"]] == nil) {
//        return;
//    }
//    
//    BOOL isSuccessful = [[payload valueForKey:@"Success"] boolValue];
//    GenericIndexValue *genIndexVal = self.miiTable[payload[@"MobileInternalIndex"]];
//    NSLog(@"genIndexVal: %@", genIndexVal);
//    if(isSuccessful == NO){
//        [self revertToOldValue:genIndexVal];
//        [self showToast:[NSString stringWithFormat:@"Sorry, Could not update %@", genIndexVal.genericIndex.groupLabel]];
//    }
//    else{
//        DeviceCommandType deviceCmdType = genIndexVal.genericIndex.commandType;
//        if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
//            [Device updateDeviceData:deviceCmdType value:genIndexVal.currentValue deviceID:genIndexVal.deviceID];
//        }else{
//            [Device updateValueForID:genIndexVal.deviceID index:genIndexVal.index value:genIndexVal.currentValue];
//        }
//        
//        [self showToast:[NSString stringWithFormat:@"%@ successfully updated", genIndexVal.genericIndex.groupLabel]];
//    }
//    
//    //Repaint header
//    [self repaintHeader:genIndexVal];
//    [self.miiTable removeObjectForKey:payload[@"MobileInternalIndex"]];
}

-(void)repaintHeader:(GenericIndexValue*)genIndexVal{
    NSLog(@"repaintHeader");
    Device *device = [Device getDeviceForID:genIndexVal.deviceID];
    GenericIndexValue *headerGenIndexVal = [GenericIndexUtil getHeaderGenericIndexValueForDevice:device];
    self.genericParams.headerGenericIndexValue = headerGenIndexVal;
    self.genericParams.deviceName = device.name;
    [self.deviceEditHeaderCell resetHeaderView];
    
    [self.deviceEditHeaderCell initialize:self.genericParams cellType:SensorEdit_Cell];
}

-(void)revertToOldValue:(GenericIndexValue*)genIndexVal{
    if(genIndexVal == nil)
        return;
    NSString *layout = genIndexVal.genericIndex.layoutType;
    NSString* value = [Device getValueForIndex:genIndexVal.index deviceID:genIndexVal.deviceID];
    
    if(layout){
        if([layout isEqualToString:@"SINGLE_TEMP"]){
            HorizontalPicker *horzPicker = (HorizontalPicker *)genIndexVal.clickedView;
            [horzPicker.horzPicker scrollToElement:[value integerValue] - genIndexVal.genericIndex.formatter.min  animated:YES];
        }
        else if ([layout isEqualToString:MULTI_BUTTON]){
            MultiButtonView *buttonView = (MultiButtonView *)genIndexVal.clickedView;
            int selectedValuePos = -1;
            NSString *deviceValue = value;

            NSArray *devicePosKeys = genIndexVal.genericIndex.values.allKeys;
            NSArray *valueArray = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
            }];
            
            for(int i =0;i < valueArray.count ;i++){
                if([deviceValue isEqualToString:[valueArray objectAtIndex:i]]){
                    selectedValuePos = i;
                }
            }
            for(UIButton *button in [buttonView subviews]){
                if([button isKindOfClass:[UILabel class]])
                    continue;
                if( button.tag == selectedValuePos){
                    button.selected = YES;
                    [button setTitleColor:self.genericParams.color forState:UIControlStateNormal];
                    [button setBackgroundColor:[UIColor whiteColor]];
                }
                else{
                    button.selected = NO;
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [button setBackgroundColor:[SFIColors darkerColorForColor:self.genericParams.color]];
                }
            }
        }
        else if ([layout isEqualToString:HUE]){
            HueColorPicker *hueView = (HueColorPicker *)genIndexVal.clickedView;
            float val = [value floatValue];
            [hueView.huePickerView setConvertedValue:val];
        }
        else if ([layout isEqualToString: @"SLIDER"] || [layout isEqualToString:@"SLIDER_ICON"]){
            Slider *sliderView = (Slider *)genIndexVal.clickedView;
            [sliderView setSliderValue:[[genIndexVal.genericIndex.formatter transformValue:value] intValue]];
        }
        else if ([layout isEqualToString:TEXT_VIEW] || [layout isEqualToString:@"TEXT_VIEW_ONLY"]){
            DeviceCommandType deviceCmdType = genIndexVal.genericIndex.commandType;
            if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
                Device *device = [Device getDeviceForID:genIndexVal.deviceID];
                if(deviceCmdType == DeviceCommand_UpdateDeviceName)
                    value = device.name;
                else if(deviceCmdType == DeviceCommand_UpdateDeviceLocation)
                    value = device.location;
            }
            
            TextInput *textView = (TextInput *)genIndexVal.clickedView;
            
            NSLog(@"textviewValue: %@ - value : %@", textView, value);
            [textView setTextFieldValue:value];
        }
        else if ([layout isEqualToString:LIST]){
            ListButtonView * typeTableView = (ListButtonView *)genIndexVal.clickedView;
            [typeTableView setListValue:value];
        }
    }
}


-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
    
    if(self.deviceEditHeaderCell.cellType == ClientEditProperties_cell){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    else if(self.deviceEditHeaderCell.cellType == SensorEdit_Cell){
        //        NSArray* genericIndexValues = [GenericIndexUtil getDetailListForDevice:self.genericParams.headerGenericIndexValue.deviceID];
        //        int deviceID = self.genericParams.headerGenericIndexValue.deviceID;
        //        NSLog(@"gvalues: %@", genericIndexValues);
        //        if([Device getTypeForID:deviceID] == SFIDeviceType_NestThermostat_57){
        //            genericIndexValues = [RuleSceneUtil handleNestThermostatForSensor:deviceID genericIndexValues:genericIndexValues];
        //        }
        //        self.genericParams.indexValueList = genericIndexValues;
        //
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [self clearAllViews];
        //            [self setUpDeviceEditCell];
        //            [self drawIndexes];
        //        });
    }
    
}

@end
