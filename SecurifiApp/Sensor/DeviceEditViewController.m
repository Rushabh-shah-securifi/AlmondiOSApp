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
#import "RuleSceneUtil.h"
#import "SFIHighlightedButton.h"
#import "SFINotificationsViewController.h"
#import "Analytics.h"
#import "NotificationPreferenceResponse.h"
#import "BlinkLedView.h"
#import "GenericIndexClass.h"
#import "AlmondManagement.h"
#import "List_TypeView.h"
#import "LabelView.h"
#import "Rule.h"
#import "SFIButtonSubProperties.h"
#import "NewAddSceneViewController.h"
#import "AddRulesViewController.h"
#import "AlmondManagement.h"

#define ITEM_SPACING  2.0
#define LABELSPACING 20.0
#define LABELVALUESPACING 10.0
#define LABELHEIGHT 20.0

#define VIEW_FRAME_SMALL CGRectMake(xIndent, yPos, self.indexesScroll.frame.size.width-xIndent, LABELHEIGHT)
#define VIEW_FRAME_LARGE CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, 65)
#define LABEL_FRAME CGRectMake(0, 0, view.frame.size.width-16, LABELHEIGHT)
#define LABEL_FRAME2 CGRectMake(0, 0, view2.frame.size.width-16, LABELHEIGHT)
#define SLIDER_FRAME CGRectMake(0, LABELHEIGHT + LABELVALUESPACING,view.frame.size.width-10, 35)
#define BUTTON_FRAME CGRectMake(0, LABELHEIGHT + LABELVALUESPACING,view.frame.size.width-10,  35)
static const int xIndent = 10;

@interface DeviceEditViewController ()<MultiButtonViewDelegate,TextInputDelegate,HorzSliderDelegate,HueColorPickerDelegate,SliderViewDelegate,DeviceHeaderViewDelegate,MultiButtonViewDelegate,GridViewDelegate,ListButtonDelegate,UIGestureRecognizerDelegate,BlinkLedViewDelegate,List_TypeViewDelegate>

//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;

//wifi client @property
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceEditHeaderCell;
@property (nonatomic) UIView *dismisstamperedView;
@property (nonatomic)BOOL isLocal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indexScrollTopConstraint;
@property (nonatomic)GenericIndexValue *genericIndexVal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (nonatomic) NSInteger keyBoardComp;
@property (nonatomic) SecurifiToolkit *toolkit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstrain;
@property(nonatomic) NSMutableDictionary *miiTable;
@property (nonatomic) CGRect ViewFrame;
@property (nonatomic) NSInteger touchComp;
@property (nonatomic) CGRect hueFrame;

@end

@implementation DeviceEditViewController{
    NSArray *type;
    int mii;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)setUpDeviceEditCell{
    if(self.genericParams.isSensor){
        [self.deviceEditHeaderCell initialize:self.genericParams cellType:SensorEdit_Cell isSiteMap:NO];
    }
    else{
        [self.deviceEditHeaderCell initialize:self.genericParams cellType:ClientEditProperties_cell isSiteMap:NO];
    }
    self.deviceEditHeaderCell.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    
    [self initializeNotifications];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawIndexes];
    });
    
    self.isLocal = [[SecurifiToolkit sharedInstance] useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    self.navigationController.view.backgroundColor = [UIColor wheatColor];
   
    self.toolkit=[SecurifiToolkit sharedInstance];
    self.ViewFrame = self.view.frame;
    [self setUpDeviceEditCell];
    self.miiTable = [NSMutableDictionary new];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTest:)];
    [tap setDelegate:self];
    
    if(self.genericParams.isSensor)
        [self.indexesScroll addGestureRecognizer:tap];
    
    NSLog(@"viewWillAppear: %f",self.deviceEditHeaderCell.frame.origin.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self clearScrollView];
    });
    [self.miiTable removeAllObjects];
}

-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self //common dynamic reponse handler for sensor and clients
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
    
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    
    [center addObserver:self //sensor notification response 301
               selector:@selector(onNotificationPrefDidChange:)
                   name:kSFINotificationPreferencesListDidChange
                 object:nil];
    
    [center addObserver:self //mobile response 1525 - client notification
               selector:@selector(onClientPreferenceUpdateResponse:)
                   name:NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER
                 object:nil];
 
    [center addObserver:self
               selector:@selector(onKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onKeyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
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
        int deviceType = [Device getTypeForID:genericIndexValue.deviceID];
        if(deviceType == SFIDeviceType_DoorLock_5 || deviceType == SFIDeviceType_ZigbeeDoorLock_28){
            NSString *genId = genericIndexObj.ID;
            if(![genId isEqualToString:@"-1"] && ![genId isEqualToString:@"-2"] && ![genId isEqualToString:@"-3"] && ![genId isEqualToString:@"50"]){
                if(deviceType == SFIDeviceType_DoorLock_5)
                    propertyName = [NSString stringWithFormat:@"%@ %d", genericIndexObj.groupLabel, genericIndexValue.index-4];
                else
                    propertyName = [NSString stringWithFormat:@"%@ %d", genericIndexObj.groupLabel, genericIndexValue.index-3];
            }else
                propertyName = genericIndexObj.groupLabel;
        }
        
        else
            propertyName = [genericIndexObj.groupLabel uppercaseString];
    
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
            valueLabel.alpha = 0.85;
            [view addSubview:valueLabel];
            
            yPos = yPos + view.frame.size.height + LABELSPACING;
            [self.indexesScroll addSubview:view];
            
        }
        
        else{
            NSLog(@"ypos: %d", yPos);
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
                self.hueFrame = view.frame;
                NSLog(@"hue bounds: %@", NSStringFromCGRect(self.hueFrame));
                [view addSubview:hueView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:@"HUE_ONLY"]){
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                
                BlinkLedView * blinlk = [[BlinkLedView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) color:self.genericParams.color genericIndexValue:genericIndexValue];
                self.hueFrame = view.frame;
                blinlk.delegate = self;
                [view addSubview:blinlk];
            }
            else if ([genericIndexObj.layoutType isEqualToString: @"SLIDER"] || [genericIndexObj.layoutType isEqualToString:@"SLIDER_ICON"]){
                Slider *sliderView = [[Slider alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue];
                sliderView.delegate = self;
                [view addSubview:sliderView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:TEXT_VIEW] || [genericIndexObj.layoutType isEqualToString:@"TEXT_VIEW_ONLY"]){
                
                TextInput *textView = [[TextInput alloc]initWithFrame:SLIDER_FRAME color:self.genericParams.color genericIndexValue:genericIndexValue isSensor:self.genericParams.isSensor];
                textView.delegate = self;
                [view addSubview:textView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:GRID_VIEW]){
                NSString *schedule = [Client getScheduleById:@(genericIndexValue.deviceID).stringValue];
                view.frame = CGRectMake(xIndent, yPos , self.indexesScroll.frame.size.width-xIndent, self.view.frame.size.height - view.frame.origin.y - 5);
                GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(0, view.frame.origin.y + 5, view.frame.size.width, self.view.frame.size.height - 5) color:self.genericParams.color genericIndexValue:genericIndexValue onSchedule:(NSString*)schedule];
                grid.userInteractionEnabled = YES;
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
            else if ([genericIndexObj.layoutType isEqualToString:@"LIST_TYPE"]){
                NSLog(@"before update view frame %@ ",NSStringFromCGRect(view.frame));
                float height = genericIndexValue.genericIndex.values.allKeys.count *45;
                
                view.frame = CGRectMake(5, yPos, self.indexesScroll.frame.size.width, height);
                List_TypeView * typeTableView = [[List_TypeView alloc]initWithFrame:CGRectMake(0,LABELHEIGHT, view.frame.size.width , self.view.frame.size.height- 5)
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
    if(!self.isLocal && self.genericParams.isSensor){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp, self.indexesScroll.frame.size.width-xIndent, 65)];
        
        SFIHighlightedButton *historyButton = [[SFIHighlightedButton alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
        historyButton = [historyButton addButton:@"Device History" button:historyButton color:self.genericParams.color];
        [historyButton addTarget:self action:@selector(onShowSensorLogs) forControlEvents:UIControlEventTouchUpInside];
        CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.keyBoardComp + 60);
        yPos = yPos + view.frame.size.height;
        self.keyBoardComp = yPos;
        [self.indexesScroll setContentSize:scrollableSize];
        [view addSubview:historyButton];
        
        [self.indexesScroll addSubview:view];
    }
    if(self.genericParams.isSensor){
        NSArray *sceneArr = [self isPresentInRuleList:NO];
        NSLog(@"scn arr count %ld",sceneArr.count);
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp, self.indexesScroll.frame.size.width-xIndent, 65)];
        UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
        [self setUpLable:label withPropertyName:@"SCENES"];
        [view addSubview:label];
        [self.indexesScroll addSubview:view];
        yPos = yPos + view.frame.size.height - 20;
        self.keyBoardComp = yPos;
        if(sceneArr.count == 0){
            
            LabelView *lableView = [[LabelView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp,view.frame.size.width-10,  35) color:self.genericParams.color text:@"This device is not part of any scene" isRule:NO];
            lableView.delegate = self;
            CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.keyBoardComp + 65);
            yPos = yPos + lableView.frame.size.height + LABELSPACING;
            self.keyBoardComp = yPos;
            [self.indexesScroll setContentSize:scrollableSize];
            [self.indexesScroll addSubview:lableView];
        }
        else
        for(Rule *scene in sceneArr){
           
            LabelView *lableView = [[LabelView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp,view.frame.size.width-10,  35) color:self.genericParams.color rule:scene isRule:NO];
            lableView.delegate = self;
            CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.keyBoardComp + 35);
            yPos = yPos + lableView.frame.size.height + LABELSPACING;
            self.keyBoardComp = yPos;
            [self.indexesScroll setContentSize:scrollableSize];
            [self.indexesScroll addSubview:lableView];
        }
        NSArray *ruleArr = [self isPresentInRuleList:YES];
        NSLog(@"ruleArr arr count %ld",ruleArr.count);
        {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp, self.indexesScroll.frame.size.width-xIndent, 65)];
        UILabel *label2 = [[UILabel alloc]initWithFrame:LABEL_FRAME];
        [self setUpLable:label2 withPropertyName:@"RULES"];
        [view addSubview:label2];
        [self.indexesScroll addSubview:view];
        yPos = yPos + view.frame.size.height - 20;
         self.keyBoardComp = yPos;
        if(ruleArr.count == 0){
            LabelView *lableView2 = [[LabelView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp,view.frame.size.width-10,  35) color:self.genericParams.color text:@"This device is not part of any rules" isRule:YES];
            lableView2.delegate = self;
            CGSize scrollableSize2 = CGSizeMake(self.indexesScroll.frame.size.width,self.keyBoardComp + 35);
            yPos = yPos + lableView2.frame.size.height + LABELSPACING;
            [self.indexesScroll setContentSize:scrollableSize2];
            [self.indexesScroll addSubview:lableView2];

        }
        for(Rule *rule in ruleArr){
            
            LabelView *lableView2 = [[LabelView alloc]initWithFrame:CGRectMake(xIndent, self.keyBoardComp,view.frame.size.width-10,  35) color:self.genericParams.color rule:rule isRule:YES];
            lableView2.delegate = self;
            [view addSubview:lableView2];
            CGSize scrollableSize2 = CGSizeMake(self.indexesScroll.frame.size.width,self.keyBoardComp + 35);
            yPos = yPos + lableView2.frame.size.height + LABELSPACING;
            self.keyBoardComp = yPos;
            [self.indexesScroll setContentSize:scrollableSize2];
            [self.indexesScroll addSubview:lableView2];
            
        }
        }
    }
}


-(void)onShowSensorLogs{
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //        ctrl.enableDebugMode = YES; // can uncomment for development/test
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    ctrl.almondMac = [AlmondManagement currentAlmond].almondplusMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];

}
- (SFIHighlightedButton *)addButton:(NSString *)buttonName button:(SFIHighlightedButton *)button color:(UIColor *)color{
    UIFont *heavy_font = [UIFont securifiBoldFontLarge];
    CGSize stringBoundingBox = [buttonName sizeWithAttributes:@{NSFontAttributeName : heavy_font}];
    
    int button_width = (int) (stringBoundingBox.width + 20);
    if (button_width < 60) {
        button_width = 60;
    }
    
    button.titleLabel.font = heavy_font;
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *normalColor = self.genericParams.color;
    UIColor *highlightColor = whiteColor;
    button.normalBackgroundColor = normalColor;
    button.highlightedBackgroundColor = highlightColor;
    [button setTitle:buttonName forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;
    
    return button;
}

- (void)setUpLable:(UILabel*)label withPropertyName:(NSString*)propertyName{
    label.text = propertyName;
    label.font = [UIFont standardHeadingBoldFont];
    label.textColor = [UIColor whiteColor];
}

-(void)disMissTamperedView{
    self.dismisstamperedView = [[UIView alloc]initWithFrame:CGRectMake(self.indexesScroll.frame.origin.x, self.deviceEditHeaderCell.frame.size.height + self.deviceEditHeaderCell.frame.origin.y + 5, self.indexesScroll.frame.size.width, 40)];
    self.dismisstamperedView.backgroundColor = [SFIColors ruleOrangeColor];
    UIImageView *tamperedImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 3, 30, 30)];
    tamperedImgView.image = [UIImage imageNamed:@"tamper"];
    [self.dismisstamperedView addSubview:tamperedImgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 3, self.dismisstamperedView.frame.size.width - 60, 30)];
     label.text = NSLocalizedString(@"deviceedit Device has been tampered", @"Device has been tampered");
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
    [self showToast:NSLocalizedString(@"saving", @"Saving...")];
    mii = arc4random()%10000;
    [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:self.genericIndexVal mii:mii value:@"false"];
    //tried to animate dismiss, currently not working. Need to fix this.
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:15 options:nil animations:^() {
        ///[DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:newValue];
        [self.dismisstamperedView removeFromSuperview];
        self.deviceEditHeaderCell.tamperedImgView.hidden = YES;
        self.indexScrollTopConstraint.constant = 2;
    } completion:nil];
}

#pragma mark delegate callback methods
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue currentView:(UIView*)currentView{// index is genericindex for clients, normal index for sensors
    NSLog(@"newvalue %@",newValue);
    mii = arc4random() % 10000;

    [self.deviceEditHeaderCell reloadIconImage];

    DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
    genericIndexValue = [GenericIndexValue getLightCopy:genericIndexValue];
    genericIndexValue.currentValue = newValue;
    genericIndexValue.clickedView = currentView;
    [self.miiTable setValue:genericIndexValue forKey:@(mii).stringValue];
    
    if(self.genericParams.isSensor){
        if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation){
            [DevicePayload getNameLocationChange:genericIndexValue mii:mii value:newValue];
        }else if(deviceCmdType == DeviceCommand_NotifyMe){
            NSLog(@"device - notifyme");
            [DevicePayload sensorDidChangeNotificationSetting:newValue.intValue deviceID:genericIndexValue.deviceID mii:mii];
        }
        else{
            [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:mii value:newValue];
        }
    }
    else{
        Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
        if(deviceCmdType == DeviceCommand_NotifyMe){
            NSLog(@"client - notifyme");
            [ClientPayload clientDidChangeNotificationSettings:client mii:mii newValue:newValue];
        }else{
            NSLog(@"client update %@,%d,%@,%@",genericIndexValue.genericIndex.ID,genericIndexValue.index,genericIndexValue.currentValue,genericIndexValue.genericIndex.groupLabel);
            int index = genericIndexValue.index;
            NSLog(@"enable / disable %d - %d",client.webHistoryEnable,client.bW_Enable);
            NSLog(@"enable / disable dns  %d - %d",client.iot_serviceEnable,client.iot_dnsEnable);
            client = [client copy];
            
            
            [Client getOrSetValueForClient:client genericIndex:index newValue:newValue ifGet:NO];
            
            
            [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];
        }
    }
    NSLog(@"save mii genindexval: %@", self.miiTable[@(mii).stringValue]);
}

-(void)delegateDeviceEditSettingClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)tapTest:(UITapGestureRecognizer *)sender {
    self.touchComp = [sender locationInView:self.view].y;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(!CGRectIsEmpty(self.hueFrame)){
        NSLog(@"hue bounds: %@, \ntouch point: %@", NSStringFromCGRect(self.hueFrame), NSStringFromCGPoint([touch locationInView:self.view]));
        CGRect actualFrame = self.hueFrame;
        actualFrame.origin = CGPointMake(actualFrame.origin.x, 80.0 + actualFrame.origin.y); //includeing height of header
        NSLog(@"actual frame: %@", NSStringFromCGRect(actualFrame));
        if (CGRectContainsPoint(actualFrame, [touch locationInView:self.view])){
            NSLog(@"contains point");
            return NO;
        }
    }
   
    
    
    return YES;
}

#pragma  mark uiwindow delegate methods
- (void)onKeyboardDidShow:(id)notification {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(self.touchComp  > keyboardSize.height){
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect f = self.view.frame;
            CGFloat y = -keyboardSize.height ;
            f.origin.y =  y + 80;
            self.view.frame = f;
            //        NSLog(@"keyboard frame %@",NSStringFromCGRect(self.parentView.frame));
        }];
    }
}

-(void)onKeyboardDidHide:(id)notice {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = self.ViewFrame.origin.y + 64;
        self.view.frame = f;
    }];
}

#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)toggle:(GenericIndexValue *)headerGenericIndexValue{
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    mii = arc4random()%10000;
    
    headerGenericIndexValue = [GenericIndexValue getLightCopy:headerGenericIndexValue];
    headerGenericIndexValue.currentValue = headerGenericIndexValue.genericValue.toggleValue;
    headerGenericIndexValue.clickedView = nil;
    
    [self.miiTable setValue:headerGenericIndexValue forKey:@(mii).stringValue];
    [DevicePayload getSensorIndexUpdate:headerGenericIndexValue mii:mii];
}

#pragma mark command responses
-(void)onCommandResponse:(id)sender{ //mobile command sensor and client 1064
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [self.toolkit useLocalNetwork:almond.almondplusMAC];
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
    
    if (self.miiTable[payload[@"MobileInternalIndex"]] == nil || payload[@"MobileInternalIndex"] == nil) {
        return;
    }
    
    NSLog(@"payload mobile command: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    GenericIndexValue *genIndexVal = self.miiTable[payload[@"MobileInternalIndex"]];
    int dType = [Device getTypeForID:genIndexVal.deviceID];
    
    if(self.genericParams.isSensor){
        NSLog(@"sensor");
        if(isSuccessful == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(dType == SFIDeviceType_AlmondBlink_64){
                    [self repaintBottomView:dType];
                }else{
                    [self revertToOldValue:genIndexVal];
                }
                
                [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
            });
        }
        else{
            NSLog(@"successful");
            DeviceCommandType deviceCmdType = genIndexVal.genericIndex.commandType;
            if(deviceCmdType == DeviceCommand_UpdateDeviceName ||deviceCmdType == DeviceCommand_UpdateDeviceLocation || deviceCmdType == DeviceCommand_NotifyMe){
                [Device updateDeviceData:deviceCmdType value:genIndexVal.currentValue deviceID:genIndexVal.deviceID];
            }else{
                [Device updateValueForID:genIndexVal.deviceID index:genIndexVal.index value:genIndexVal.currentValue];
            }
            NSLog(@"updated value: %@", [Device getValueForIndex:genIndexVal.index deviceID:genIndexVal.deviceID]);
            
            
            if(dType == SFIDeviceType_NestThermostat_57 || dType == SFIDeviceType_HueLamp_48 || dType == SFIDeviceType_AlmondSiren_63){
                [self repaintBottomView:dType];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showToast:NSLocalizedString(@"successfully_updated", @"")];
            });
            [self updateGenericIndexValueList:genIndexVal];
        }
        
        //Repaint header
        dispatch_async(dispatch_get_main_queue(), ^{
            [self repaintHeader:genIndexVal];
        });
        
        [self.miiTable removeObjectForKey:payload[@"MobileInternalIndex"]];
        NSLog(@"end response");
    }
    else{
        if(isSuccessful == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [self showToast:NSLocalizedString(@"successfully_updated", @"")];
        }
    }
}

-(void)updateGenericIndexValueList:(GenericIndexValue*)genIndexVal{
    NSArray* genericIndexValues = [GenericIndexUtil getDetailListForDevice:genIndexVal.deviceID];
    //NSLog(@"gvalues: %@", genericIndexValues);
    if([Device getTypeForID:genIndexVal.deviceID] == SFIDeviceType_NestThermostat_57){
        genericIndexValues = [RulesNestThermostat handleNestThermostatForSensor:genIndexVal.deviceID genericIndexValues:genericIndexValues];
    }
    self.genericParams.indexValueList = genericIndexValues;
}

-(void)repaintBottomView:(int)dType{
    NSLog(@"repaintBottomView");
    int deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    NSArray* genericIndexValues = [GenericIndexUtil getDetailListForDevice:deviceID];
    if(dType == SFIDeviceType_NestThermostat_57) //mk - move this to util
        genericIndexValues = [RulesNestThermostat handleNestThermostatForSensor:deviceID genericIndexValues:genericIndexValues];
    self.genericParams.indexValueList = genericIndexValues;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearScrollView];
        NSLog(@"draw indexes start");
        [self drawIndexes];
    });
}

- (void)clearScrollView{
    NSLog(@"clearScrollView start");

    for(UIView *view in self.indexesScroll.subviews){
        if (![view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
    }
    NSLog(@"clearScrollView end");
}

-(void)repaintHeader:(GenericIndexValue*)genIndexVal{
    NSLog(@"repaintHeader");
    Device *device = [Device getDeviceForID:genIndexVal.deviceID];
    GenericIndexValue *headerGenIndexVal = [GenericIndexUtil getHeaderGenericIndexValueForDevice:device];
    self.genericParams.headerGenericIndexValue = headerGenIndexVal;
    self.genericParams.deviceName = device.name;
    
    [self.deviceEditHeaderCell resetHeaderView];
    [self.deviceEditHeaderCell initialize:self.genericParams cellType:SensorEdit_Cell isSiteMap:NO];
     NSLog(@"resetHeader: %f",self.deviceEditHeaderCell.frame.origin.y);
}

-(void)revertToOldValue:(GenericIndexValue*)genIndexVal{
    NSLog(@"revertToOldValue");
    if(genIndexVal.clickedView == nil)
        return;

    NSString *layout = genIndexVal.genericIndex.layoutType;
    NSString* value = [Device getValueForIndex:genIndexVal.index deviceID:genIndexVal.deviceID];
    
    if(layout){
        if([layout isEqualToString:@"SINGLE_TEMP"]){
            HorizontalPicker *horzPicker = (HorizontalPicker *)genIndexVal.clickedView;
            horzPicker.isInitialised = NO;
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
            NSLog(@"slider update");
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

-(void)onNotificationPrefDidChange:(id)sender{//sensor individual 301
    NSLog(@"device edit - onNotificationPrefDidChange");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NotificationPreferenceResponse* res = dataInfo[@"data"];
    if (res.internalIndex == nil || self.miiTable[res.internalIndex] == nil)
        return;
    GenericIndexValue *genIndexVal = self.miiTable[res.internalIndex];
    
    NSLog(@"res mii: *%@*, actual: *%@*", res.internalIndex, @(mii).stringValue);
    
    
    if(res.isSuccessful == NO){
        NSLog(@"notify unsuccessful");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self revertToOldValue:genIndexVal];
            [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
        });
    }
    else{
        NSLog(@"notify successful - commandtype: %d", genIndexVal.genericIndex.commandType);
        DeviceCommandType deviceCmdType = genIndexVal.genericIndex.commandType;
        
        [Device updateDeviceData:deviceCmdType value:genIndexVal.currentValue deviceID:genIndexVal.deviceID];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:NSLocalizedString(@"successfully_updated", @"")];
        });
        [self updateGenericIndexValueList:genIndexVal];
    }
    
    //Repaint header
    dispatch_async(dispatch_get_main_queue(), ^{
        [self repaintHeader:genIndexVal];
    });
    
    [self.miiTable removeObjectForKey:res.internalIndex]; //internalIndex is nsstring
    
    
}

-(void)onClientPreferenceUpdateResponse:(id)sender{//client individual 1525
    NSLog(@"device edit - onClientPreferenceUpdateResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    if ([mainDict[@"MobileInternalIndex"] integerValue]!=mii) {
        return;
    }
    if ([mainDict[@"Success"] boolValue] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }
    else{
        [self showToast:NSLocalizedString(@"successfully_updated", @"")];
    }
}

-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
    
    if(self.genericParams.isSensor){
        NSLog(@"device edit - dynamic response - currently handling only mobile response in controller");
        //perhaps you have to check device id of dynamic response and pop if matches, perhaps
    }
    
    else{
        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *dataInfo = [notifier userInfo];
        if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
            return;
        }
        NSDictionary *payload = dataInfo[@"data"];
        NSString *commandType = payload[COMMAND_TYPE];
        if([commandType isEqualToString:@"DynamicAllClientsRemoved"]){
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
        else{ //checking if response is of only that particular client, only then pop
            if(payload[CLIENTS]){
                NSDictionary *clientPayload = payload[CLIENTS];
                NSString *clientID = clientPayload.allKeys.firstObject;
                [self popViewController:[clientID intValue] curClientID:self.genericParams.headerGenericIndexValue.deviceID];
            }else{//for notify me
                int clientID = [payload[@"ClientID"] intValue];
                [self popViewController:clientID curClientID:self.genericParams.headerGenericIndexValue.deviceID];
            }
        }
    }
}

-(void)popViewController:(int)resClientID curClientID:(int)curClientID{
    if(resClientID == curClientID){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
-(void)lableArrowClicked:(Rule *)rule isRule:(BOOL)isRule{
    if(isRule){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rules" bundle:nil];
        AddRulesViewController * addRuleController = [storyboard instantiateViewControllerWithIdentifier:@"AddRulesViewController"];
        addRuleController.rule = rule;
        addRuleController.isInitialized = YES;
//        [self presentViewController:addRuleController animated:YES completion:nil];
        [self.navigationController pushViewController:addRuleController animated:YES];
    }
    else{
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
        NewAddSceneViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"NewAddSceneViewController"];
        viewController.scene = rule;
        viewController.isInitialized = YES;
//        [self presentViewController:viewController animated:YES completion:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
-(NSMutableArray *)isPresentInRuleList:(BOOL)isRule{
    NSMutableArray *ruleArr = [[NSMutableArray alloc]init];
    
    NSArray *ruleList = isRule?self.toolkit.ruleList:self.toolkit.scenesArray;
    NSLog(@"ruleList arr %@",ruleList);
    if(!isRule){
        for(NSDictionary *sceneDict in ruleList){
            Rule *scene = [self getScene:sceneDict];
             NSLog(@"Scene name %@",scene.name);
            for(SFIButtonSubProperties *subProperty in scene.triggers){
                NSLog(@"subProperty.deviceId == self.genericParams.headerGenericIndexValue.deviceID %d == %d",subProperty.deviceId,self.genericParams.headerGenericIndexValue.deviceID);
               
                if(subProperty.deviceId == self.genericParams.headerGenericIndexValue.deviceID){
                    if(![subProperty.eventType isEqualToString:@"AlmondModeUpdated"])
                        {
                        [ruleArr addObject: scene];
                        break ;
                        }
                }
            }
            
        }
        return ruleArr;
    }
    for(Rule *rules in ruleList){
        BOOL isRuleFound = NO;
        for(SFIButtonSubProperties *subProperty in rules.triggers){
            
            if(subProperty.deviceId == self.genericParams.headerGenericIndexValue.deviceID){
                if(![self checkEventType:subProperty.eventType]){
                    [ruleArr addObject: rules];
                    isRuleFound = YES;
                    break ;
                    }
                }
            }
        if(isRuleFound)
            continue;
        
        for(SFIButtonSubProperties *subProperty in rules.actions){
            if(subProperty.deviceId == self.genericParams.headerGenericIndexValue.deviceID){
                if(![self checkEventType:subProperty.eventType]){
                    [ruleArr addObject: rules];
                    isRuleFound = YES;
                    break;
                }
            }
        }
        if(isRuleFound)
            continue;
    }
return ruleArr;
}
-(BOOL)checkEventType:(NSString *)eventType{
    if([eventType isEqualToString:@"AlmondModeUpdated"] || [eventType isEqualToString:@"ClientJoined"] || [eventType isEqualToString:@"ClientLeft"]){
        return YES;
    }
    else
        return NO;
}
-(Rule *)getScene:(NSDictionary*)dict{
    Rule *scene = [[Rule alloc]init];
    scene.ID = [dict valueForKey:@"ID"];
    scene.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    scene.isActive = [[dict valueForKey:@"Active"] boolValue];
    scene.triggers= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"SceneEntryList"] list:scene.triggers];
    return scene;
}
-(void)getEntriesList:(NSArray*)sceneEntryList list:(NSMutableArray *)triggers{
    for(NSDictionary *triggersDict in sceneEntryList){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        NSLog(@"triggersDict %@",triggersDict);
        subProperties.deviceId = [[triggersDict valueForKey:@"ID"] intValue];
        subProperties.index = [[triggersDict valueForKey:@"Index"] intValue];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.valid = [[triggersDict valueForKey:@"Valid"] boolValue];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        //        subProperties.type = subProperties.deviceId==0?@"EventTrigger":@"DeviceTrigger";
        //        subProperties.delay=[triggersDict valueForKey:@"PreDelay"];
        //        [self addTime:triggersDict timeProperty:subProperties];
        [triggers addObject:subProperties];
    }
}
@end
