//
//  SFISensorDetailEditViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 12.10.15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//
#define nameTag 1
#define locationTag 2

#import "SFISensorDetailEditViewController.h"
#import "UIViewController+Securifi.h"
#import "SFINotificationsViewController.h"
#import "UIFont+Securifi.h"
#import "UIColor+Securifi.h"
#import "SFIConstants.h"
#import "SFIHighlightedButton.h"
#import "MBProgressHUD.h"

@interface SFISensorDetailEditViewController ()<UITextFieldDelegate>{
    
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSave;
    
    IBOutlet UIView *viewEditproperty;
    IBOutlet UIImageView *imgIcon;
    IBOutlet UILabel *lblStatus;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblThemperatureMain;
    IBOutlet UIView *viewHeader;
    
    sfi_id dc_id;
    UIButton *btnSwitch1On;
    UIButton *btnSwitch1Off;
    UIButton *btnSwitch2On;
    UIButton *btnSwitch2Off;
    SFINotificationMode mode;
    UITextField * txtName;
    UITextField * txtLocation;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) NSTimer *mobileCommandTimer;
@property(nonatomic, readonly) float baseYCoordinate;

@end

@implementation SFISensorDetailEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _baseYCoordinate = 10;
    switch (self.device.deviceType) {
        case SFIDeviceType_MultiSwitch_43:
        {
            [self addNotificationsControl];
            [self addTextField:nameTag];
            [self addTextField:locationTag];
            
            UILabel *labelMode = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:225]];
            labelMode.backgroundColor = self.color;
            labelMode.text =  NSLocalizedString(@"Switch 1","Switch 1");
            labelMode.textColor = [UIColor whiteColor];
            labelMode.font = [UIFont securifiBoldFont];
            
            [viewEditproperty addSubview:labelMode];
            
            int button_width = 60;
            int right_margin = 10;
            
            CGRect frame = CGRectMake(viewEditproperty.frame.size.width - 2*button_width - 2*right_margin, self.baseYCoordinate, button_width, 30);
            
            btnSwitch1On = [self addButton:NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On") frame:frame];
            [btnSwitch1On addTarget:self action:@selector(btnSWitch1OnOff:) forControlEvents:UIControlEventTouchUpInside];
            
            //
            frame = CGRectMake(viewEditproperty.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30);
            btnSwitch1Off = [self addButton:NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off") frame:frame];
            [btnSwitch1Off addTarget:self action:@selector(btnSWitch1OnOff:) forControlEvents:UIControlEventTouchUpInside];
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY1];
            //
            if ([currentDeviceValue boolValue]) {
                [self changeButtonStyle:btnSwitch1On Style:1];
                [self changeButtonStyle:btnSwitch1Off Style:0];
            }else{
                [self changeButtonStyle:btnSwitch1On Style:0];
                [self changeButtonStyle:btnSwitch1Off Style:1];
            }
            
            [self markYOffsetUsingRect:labelMode.frame addAdditional:10];
            
            
            labelMode = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:225]];
            labelMode.backgroundColor = self.color;
            labelMode.text =  NSLocalizedString(@"Switch 2","Switch 2");
            labelMode.textColor = [UIColor whiteColor];
            labelMode.font = [UIFont securifiBoldFont];
            
            [viewEditproperty addSubview:labelMode];
            
            frame = CGRectMake(viewEditproperty.frame.size.width - 2*button_width - 2*right_margin, self.baseYCoordinate, button_width, 30);
            btnSwitch2On = [self addButton:NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On")frame:frame];
            [btnSwitch2On addTarget:self action:@selector(btnSWitch2OnOff:) forControlEvents:UIControlEventTouchUpInside];
            
            //
            frame = CGRectMake(viewEditproperty.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30);
            btnSwitch2Off = [self addButton:NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off") frame:frame];
            [btnSwitch2Off addTarget:self action:@selector(btnSWitch2OnOff:) forControlEvents:UIControlEventTouchUpInside];
            
            [self markYOffsetUsingRect:labelMode.frame addAdditional:10];
            
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY2];
            
            if ([currentDeviceValue boolValue]) {
                [self changeButtonStyle:btnSwitch2On Style:1];
                [self changeButtonStyle:btnSwitch2Off Style:0];
            }else{
                [self changeButtonStyle:btnSwitch2On Style:0];
                [self changeButtonStyle:btnSwitch2Off Style:1];
            }
            frame = viewEditproperty.frame;
            frame.size.height = self.baseYCoordinate+btnSave.frame.size.height+30;
            viewEditproperty.frame = frame;
        }
            break;
            
        default:
            break;
    }
    [self initializeNotifications];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onMobileCommandResponseCallback:)
                   name:MOBILE_COMMAND_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onNotificationPrefDidChange:)
                   name:kSFINotificationPreferencesDidChange
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onTabBarDidChange:)
                   name:@"TAB_BAR_CHANGED"
                 object:nil];
}

- (void)onTabBarDidChange:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (![[data valueForKey:@"title"] isEqualToString:@"Router"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    viewEditproperty.hidden = NO;
    CGRect fr = viewEditproperty.frame;
    fr.origin.x = viewHeader.frame.origin.x;
    fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
    viewEditproperty.frame = fr;
    
    fr = btnSave.frame;
    fr.origin.y = viewEditproperty.frame.origin.y + viewEditproperty.frame.size.height-50;
    btnSave.frame = fr;
    
    fr = btnBack.frame;
    fr.origin.y = viewEditproperty.frame.origin.y + viewEditproperty.frame.size.height-50;
    btnBack.frame = fr;
    
    
    viewHeader.backgroundColor = self.color;
    viewEditproperty.backgroundColor = self.color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addTextField:(int)fTag{
    UILabel *labelMode = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:225]];
    labelMode.backgroundColor = self.color;
    
    labelMode.textColor = [UIColor whiteColor];
    labelMode.font = [UIFont securifiBoldFont];
    [viewEditproperty addSubview:labelMode];
    [self markYOffsetUsingRect:labelMode.frame addAdditional:5];
    
    UITextField * txtField = [[UITextField alloc] initWithFrame:CGRectMake(10, self.baseYCoordinate, self.view.frame.size.width-20, 30)];
    txtField.delegate = self;
    txtField.tag = fTag;
    txtField.backgroundColor = [UIColor whiteColor];
    [viewEditproperty addSubview:txtField];
    [self markYOffsetUsingRect:labelMode.frame addAdditional:10];
    
    switch (fTag) {
        case nameTag:
            labelMode.text = NSLocalizedString(@"Device.propertyeditview.controller.Name",@"Name";);
            txtField.text = self.device.deviceName;
            txtName = txtField;
            break;
        case locationTag:
            labelMode.text = NSLocalizedString(@"Device.propertyeditview.controller.Location",@"Location";);
            txtField.text = self.device.location;
            txtLocation = txtField;
            break;
        default:
            break;
    }
}

- (void)addNotificationsControl {
    UILabel *labelMode = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:225]];
    labelMode.backgroundColor = self.color;
    labelMode.text = NSLocalizedString(@"sensor.notificaiton.label.notificationMode", @"Notify me");
    labelMode.textColor = [UIColor whiteColor];
    labelMode.font = [UIFont securifiBoldFont];
    
    [viewEditproperty addSubview:labelMode];
    
    //Add notification mode control
    UISegmentedControl *control = [self makeNotificationModeSegment:self action:@selector(onNotificationModeChanged:)];
    
    int segment_index;
    switch (self.device.notificationMode) {
        case SFINotificationMode_off:
            segment_index = 2;
            break;
        case SFINotificationMode_always:
            segment_index = 0;
            break;
        case SFINotificationMode_home:
            segment_index = 0;
            break;
        case SFINotificationMode_away:
            segment_index = 1;
            break;
        case SFINotificationMode_unknown:
        default:
            segment_index = UISegmentedControlNoSegment; // do not select anything when preference is not known
    }
    control.selectedSegmentIndex = segment_index;
    
    [viewEditproperty addSubview:control];
    [self markYOffsetUsingRect:labelMode.frame addAdditional:10];
    
    SFIHighlightedButton *button = [self addButton:NSLocalizedString(@"sensor.deivice-showlog.button.viewlogs", @"View Logs")];
    [button addTarget:self action:@selector(onShowSensorLogs:) forControlEvents:UIControlEventTouchUpInside];
    
    [self markYOffsetUsingRect:labelMode.frame addAdditional:10];
}



#pragma mark -

- (UISegmentedControl *)makeNotificationModeSegment:(id)target action:(SEL)action {
    CGFloat width = CGRectGetWidth(viewEditproperty.bounds);
    CGFloat control_width = 175;
    CGFloat padding = 10;
    CGFloat control_x = width - control_width - padding;
    
    NSArray *segment_items = @[
                               NSLocalizedString(@"sensor.notificaiton.segment.Always", @"Always"),
                               NSLocalizedString(@"sensor.notificaiton.segment.Away", @"Away"),
                               NSLocalizedString(@"sensor.notificaiton.segment.Off", @"Off"),
                               ];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:segment_items];
    control.frame = CGRectMake(control_x, self.baseYCoordinate, control_width, 25.0);
    [control addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    
    UIFont *const heavy_12 = [UIFont securifiBoldFont];
    UIColor *const white_color = [UIColor whiteColor];
    NSDictionary *const attributes = @{NSFontAttributeName : heavy_12};
    control.tintColor = white_color;
    [control setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    return control;
}


- (CGRect)makeFieldNameLabelRect:(int)width {
    return CGRectMake(10, self.baseYCoordinate, width, 30);
}

- (void)markYOffsetUsingRect:(CGRect)rect addAdditional:(unsigned int)add {
    _baseYCoordinate += CGRectGetHeight(rect) + add;
}

- (void)onNotificationModeChanged:(id)sender {
    UISegmentedControl *ctrl = (UISegmentedControl *) sender;
    
    switch (ctrl.selectedSegmentIndex) {
        case 0:
            mode = SFINotificationMode_always;
            break;
        case 1:
            mode = SFINotificationMode_away;
            break;
        case 2:
            mode = SFINotificationMode_off;
            break;
        default:
            mode = SFINotificationMode_always;
            break;
    }
}

- (SFIHighlightedButton *)addButton:(NSString *)buttonName {
    UIFont *heavy_font = [self standardButtonFont];
    
    CGSize stringBoundingBox = [buttonName sizeWithAttributes:@{NSFontAttributeName : heavy_font}];
    
    int button_width = (int) (stringBoundingBox.width + 20);
    if (button_width < 60) {
        button_width = 60;
    }
    
    int right_margin = 10;
    CGRect frame = CGRectMake(viewEditproperty.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30);
    
    SFIHighlightedButton *button = [self addButton:buttonName frame:frame];
    button.titleLabel.font = heavy_font;
    
    return button;
}

- (UIFont *)standardButtonFont {
    return [UIFont securifiBoldFontLarge];
}

- (SFIHighlightedButton *)addButton:(NSString *)buttonName frame:(CGRect)frame {
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *normalColor = self.color;
    UIColor *highlightColor = whiteColor;
    
    UIButton *button = [[SFIHighlightedButton alloc] initWithFrame:frame];
    button.tag = self.view.tag;
    //    button.normalBackgroundColor = normalColor;
    //    button.highlightedBackgroundColor = highlightColor;
    [button setTitle:buttonName forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;
    
    [viewEditproperty addSubview:button];
    
    return button;
}

#pragma mark Actions
- (void)onShowSensorLogs{
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.deviceID = self.device.deviceID;
    ctrl.almondMac = self.device.almondMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}

- (IBAction)btnSWitch1OnOff:(id)sender{
    SFIDeviceKnownValues *deviceValues = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY1];
    
    if ([((UIButton*)sender) isEqual:btnSwitch1On]) {
        [self changeButtonStyle:btnSwitch1On Style:1];
        [self changeButtonStyle:btnSwitch1Off Style:0];
        deviceValues.value = @"true";
    }else{
        [self changeButtonStyle:btnSwitch1On Style:0];
        [self changeButtonStyle:btnSwitch1Off Style:1];
        deviceValues.value = @"false";
    }
    
    self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:SFIDevicePropertyType_SWITCH_BINARY1];
}

- (IBAction)btnSWitch2OnOff:(id)sender{
    SFIDeviceKnownValues *deviceValues = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY2];
    
    if ([((UIButton*)sender) isEqual:btnSwitch2On]) {
        [self changeButtonStyle:btnSwitch2On Style:1];
        [self changeButtonStyle:btnSwitch2Off Style:0];
        deviceValues.value = @"true";
    }else{
        [self changeButtonStyle:btnSwitch2On Style:0];
        [self changeButtonStyle:btnSwitch2Off Style:1];
        deviceValues.value = @"false";
    }
    self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:SFIDevicePropertyType_SWITCH_BINARY2];
}

- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSaveTap:(id)sender {
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    [txtName resignFirstResponder];
    [txtLocation resignFirstResponder];
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"sensor.hud.UpdatingSensordata", @"Updating Sensor Data...");
    
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    
    [self sensorDidChangeNotificationSetting:mode];
    
    SFIDeviceKnownValues *deviceValues;
    
    deviceValues = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY1];
    [self sendMobileCommandForDevice:self.device deviceValue:deviceValues];
    
    deviceValues = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY2];
    [self sendMobileCommandForDevice:self.device deviceValue:deviceValues];
    
    [self sendMobileCommandForDevice:self.device name:txtName.text location:txtLocation.text];
    
    
    
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

#pragma mark - Cloud command senders and handlers

- (void)sendMobileCommandForDevice:(SFIDevice *)device deviceValue:(SFIDeviceKnownValues *)deviceValues {
    if (device == nil) {
        return;
    }
    if (deviceValues == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    // Tell the cell to show 'updating' type message to user
    //    [cell showUpdatingMessage];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        //todo decide what to do about this
        [self.mobileCommandTimer invalidate];
        
        self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                   target:self
                                                                 selector:@selector(onSendMobileCommandTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];
        
        // dispatch request and keep track of its correlation ID so we can process the response
        //todo for future: note potential race condition: if we do not process command response on main queue it's possible response is processed before we have completed marking updating state.
        dc_id = [[SecurifiToolkit sharedInstance] asyncChangeAlmond:plus device:device value:deviceValues];
        //        [self markDeviceUpdatingState:device correlationId:c_id statusMessage:nil];
    });
}

- (void)sendMobileCommandForDevice:(SFIDevice *)device name:(NSString*)deviceName location:(NSString*)deviceLocation {
    if (device == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    // Tell the cell to show 'updating' type message to user
    //    [cell showUpdatingMessage];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        //todo decide what to do about this
        [self.mobileCommandTimer invalidate];
        
        self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                   target:self
                                                                 selector:@selector(onSendMobileCommandTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];
        
        // dispatch request and keep track of its correlation ID so we can process the response
        //todo for future: note potential race condition: if we do not process command response on main queue it's possible response is processed before we have completed marking updating state.
        dc_id = [[SecurifiToolkit sharedInstance] asyncChangeAlmond:plus device:device name:deviceName location:deviceLocation];
        //        [self markDeviceUpdatingState:device correlationId:c_id statusMessage:nil];
    });
}

- (void)onSendMobileCommandTimeout:(id)sender {
    
    
    [self.mobileCommandTimer invalidate];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        //Cancel the mobile event - Revert back
        [self.HUD hide:YES];
    });
}

- (void)onMobileCommandResponseCallback:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        
        if (self.isViewLoaded) {
            [self.HUD hide:YES];
        }
        
        // Timeout the commander timer
        [self.mobileCommandTimer invalidate];
        
        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *data = [notifier userInfo];
        if (data == nil) {
            return;
        }
        
        MobileCommandResponse *res = data[@"data"];
        sfi_id c_id = res.mobileInternalIndex;
        
        if (res.isSuccessful && c_id == dc_id) {
            // command succeeded; clear "status" state; new device values should be transmitted
            // via different callback and handled there.
            //            [self.delegate updateDeviceInfo:self.device :self.deviceValue];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSString *status = res.reason;
            if (status.length > 0) {
                //                [self markDeviceUpdatingState:device correlationId:c_id statusMessage:status];
                [self showToast:status];
            }
            else {
                // it failed but we did not receive a reason; clear the updating state and pretend nothing happened.
                [self showToast:NSLocalizedString(@"device property on mobile hud Unable to update sensor",@"Unable to update sensor")];
            }
            
            [self btnBackTap:nil];
        }
    });
}

- (void)onNotificationPrefDidChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    if (self.isViewLoaded) {
        [self.HUD hide:YES];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        
        //        [self.delegate updateDeviceInfo:self.device :self.deviceValue];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)changeButtonStyle:(UIButton*)btn Style:(int)style{
    if (style==1) {
        
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:self.color forState:UIControlStateNormal];
        
    }else{
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
}

- (void)sensorDidChangeNotificationSetting:(SFINotificationMode)newMode {
    //Send command to set notification
    
    NSArray *notificationDeviceSettings = [self.device updateNotificationMode:newMode deviceValue:self.deviceValue];
    
    
    NSString *action = (newMode == SFINotificationMode_off) ? kSFINotificationPreferenceChangeActionDelete : kSFINotificationPreferenceChangeActionAdd;
    
    //    [self showSavingToast];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [[SecurifiToolkit sharedInstance] asyncRequestNotificationPreferenceChange:plus.almondplusMAC deviceList:notificationDeviceSettings forAction:action];
}

#pragma mark textField Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //    switch (textField.tag) {
    //        case nameTag:
    //            labelMode.text = NSLocalizedString(@"Device.propertyeditview.controller.Name",@"Name";);
    //            txtField.text = self.device.deviceName;
    //            break;
    //        case locationTag:
    //            labelMode.text = NSLocalizedString(@"Device.propertyeditview.controller.Location",@"Location";);
    //            txtField.text = self.device.location;
    //            break;
    //        default:
    //            break;
    //    }
    return YES;
}
@end
