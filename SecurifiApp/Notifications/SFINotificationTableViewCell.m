//
//  SFINotificationTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/19/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFINotificationTableViewCell.h"
#import "UIFont+Securifi.h"
#import "CircleView.h"
#import "Colours.h"
#import "SensorSupport.h"
#import "GenericDeviceClass.h"
#import "DeviceIndex.h"
#import "Device.h"
#import "DeviceKnownValues.h"
#import "GenericIndexClass.h"
#import "GenericValue.h"
#import "DeviceIndex.h"
#import "CommonMethods.h"

typedef NS_ENUM(unsigned int, SFINotificationTableViewCellDebugMode) {
    SFINotificationTableViewCellDebugMode_normal,
    SFINotificationTableViewCellDebugMode_details,
    SFINotificationTableViewCellDebugMode_external_id,
};

@interface SFINotificationTableViewCell ()
@property(nonatomic) BOOL reset;
@property(nonatomic, strong) UITextField *dateLabel;
@property(nonatomic, strong) UIView *verticalLine;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UITextView *messageTextField;
@property(nonatomic, strong) UILabel *messageText;
@property(nonatomic, strong) CircleView *circleView;
@property(nonatomic, strong, readonly) SensorSupport *sensorSupport;
@property(nonatomic) SFINotificationTableViewCellDebugMode debugMessageMode;
@end

@implementation SFINotificationTableViewCell

- (void)dealloc {
    [self removeTextViewObserver];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.reset) {
        return;
    }
    
    [self clearContentView];
    
    CGFloat cell_width = CGRectGetWidth(self.bounds);
    CGFloat cell_height = CGRectGetHeight(self.bounds);
    CGFloat date_width = 70;
    CGFloat circle_width = 60;
    CGFloat padding = 5;
    CGFloat left_padding = 5;
    
    UIColor *grayColor = [UIColor colorFromHexString:@"dddddd"];
    
    CGRect rect;
    
    rect = CGRectMake(left_padding, 5, date_width, circle_width);
    self.dateLabel = [[UITextField alloc] initWithFrame:rect];
    self.dateLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.dateLabel.userInteractionEnabled = NO;
    
    // Draw a vertical gray line centered on the circle
    //
    CGFloat line_width = 4.0;
    CGFloat line_center_x = (circle_width - line_width) / 2;
    rect = CGRectMake(left_padding + date_width + padding + line_center_x, 0, line_width, cell_height);
    self.verticalLine = [[UIView alloc] initWithFrame:rect];
    self.verticalLine.backgroundColor = grayColor;
    //
    // Then draw the circle on top
    CGFloat y = (cell_height - circle_width) / 2; // center in the cell
    rect = CGRectMake(left_padding + date_width + padding, y, circle_width, circle_width);
    self.circleView = [[CircleView alloc] initWithFrame:rect];
    UIColor *circleColor = [self notificationStatusColor];
    self.circleView.fillColor = circleColor;
    self.circleView.edgeColor = circleColor;
    //
    // Then draw the sensor icon on top of the circle
    rect = CGRectMake(0, 0, circle_width, circle_width);
    rect = CGRectInset(rect, 15, 15);
    self.iconView = [[UIImageView alloc] initWithFrame:rect];
    self.iconView.tintColor = [UIColor whiteColor];
    [self.circleView addSubview:self.iconView];
    
    CGFloat message_x = left_padding + date_width + padding + circle_width + padding;
    rect = CGRectMake(message_x, 5, cell_width - message_x - padding, circle_width);
    
    if (self.enableDebugMode) {
        UITextView *textView = [[UITextView alloc] initWithFrame:rect];
        self.messageTextField = textView;
        // allow copy but not edit/paste
        textView.userInteractionEnabled = YES;
        textView.editable = NO;
        // remove left margin
        textView.textContainer.lineFragmentPadding = 0;
        textView.textContainerInset = UIEdgeInsetsZero;
        // vertically center the content
        [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        // tapping on label will change text to show Notification external ID
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDebugMessageTap)];
        recognizer.numberOfTapsRequired = 1;
        [textView addGestureRecognizer:recognizer];
        CGFloat fontSize = 25.0;
        textView.font = [textView.font fontWithSize:fontSize];
        //
        while (textView.contentSize.height > textView.frame.size.height && fontSize > 8.0) {
            fontSize -= 1.0;
            textView.font = [textView.font fontWithSize:fontSize];
        }
        [self.contentView addSubview:self.messageTextField];
    }
    else{
        
        UILabel *textView = [[UILabel alloc] initWithFrame:rect];
        self.messageText = textView;
        // allow copy but not edit/paste
        textView.userInteractionEnabled = YES;
        // remove left margin
        textView.textAlignment = NSTextAlignmentLeft;
        textView.userInteractionEnabled = NO;
        textView.numberOfLines = 2;
        textView.lineBreakMode = NSLineBreakByWordWrapping;
        textView.font = [UIFont securifiFont:12];
        
        // vertically center the content
        [self.contentView addSubview:self.messageText];
    }
    //
    // auto resize text to fit view bounds
    
    
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.verticalLine];
    [self.contentView addSubview:self.circleView];
    
    
    SFINotification *notification = self.notification;

    Device *device = [Device getDeviceForID:notification.deviceId];
    NSLog(@"notification text %@,device type %d,value type %d",notification.value,notification.deviceType,notification.valueType);
    NSLog(@"device name %@ ID: %d",notification.deviceName,notification.deviceId);
    [self getGenericIndexValuesByPlacementForDevice:device value:notification.value  devicetype:notification.deviceType notification:(SFINotification *)notification];
//    [self setIcon];
//    [self setMessageLabelText:notification];
    [self setDateLabelText:notification];
}
-(NSArray*)deviceIndexArr:(int)deviceID{
    Device *device = [Device getDeviceForID:deviceID];
    NSMutableArray *deviceIndexes = [NSMutableArray new];
    for(DeviceKnownValues *knownvalue in device.knownValues){
        [deviceIndexes addObject:@(knownvalue.index).stringValue];
    }
    NSLog(@"devices Index %@",deviceIndexes);
    return deviceIndexes;
}
-(NSArray *)deviceGenericIndex:(int)deviceType{
    NSMutableSet *genericIndexesSet = [NSMutableSet new];
    GenericDeviceClass *genericDeviceObj = [SecurifiToolkit sharedInstance].genericDevices[@(deviceType).stringValue];
    for(NSString *index in genericDeviceObj.Indexes.allKeys){
        DeviceIndex *indexObj = genericDeviceObj.Indexes[index];
        [genericIndexesSet addObject:indexObj.genericIndex];
    }
    return [genericIndexesSet allObjects];
}
- (NSMutableArray*)getGenericIndexValuesByPlacementForDevice:(Device*)devicert value:(NSString *)value devicetype:(int)devicetype notification:(SFINotification *)not{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(devicetype).stringValue];
    if(genericDevice==nil)
        return [NSMutableArray new];
    NSDictionary *deviceIndexes = genericDevice.Indexes;
    NSLog(@"deviceIndexes %@",deviceIndexes);
    
    NSString *indexID = [self getgenericIndexfor:not.deviceType andIndex:@(not.valueIndex).stringValue];
    NSLog(@"deviceIndexArr cll keys id %@",indexID);
    GenericValue *gval;
    gval = [self getMatchingGenericValueForGenericIndexID:indexID forValue:value];
   
    
    NSString *notificationString = [NSString stringWithFormat:@"%@",gval.value];
    NSLog(@"outer notificaation obj.value %@",notificationString);
    if(devicetype != SFIDeviceType_WIFIClient){
    NSDictionary *notificationDict = @{
                                       @"devicename":not.deviceName?not.deviceName:@"",
                                       @"notificationText":gval.notificationText?gval.notificationText:@"",
                                       @"prefix":gval.notificationPrefix?gval.notificationPrefix:@"",
                                      @"value":gval.value,
                                       @"unit":gval.unit?gval.unit:@""
                                       
                                       };
        NSLog(@"outer notificaation obj dict  %@",notificationDict);
    [self seticon:gval.icon];
    [self setNotificationLabel:notificationDict];
    }
    if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
        NSString *deviceName;
        UIFont *bold_font = [UIFont securifiBoldFont];
        UIFont *normal_font = [UIFont securifiNormalFont];
         NSMutableAttributedString *mutableAttributedString = nil;
        NSDictionary *attr;
        
        attr = @{
                 NSFontAttributeName : bold_font,
                 NSForegroundColorAttributeName : [UIColor grayColor],
                 };
        
        
        Client *client = [Client new];
        client.deviceType = @"other";
        self.iconView.image = [UIImage imageNamed:[client iconName]];
        
        NSArray * properties = [not.deviceName componentsSeparatedByString:@"|"];
        NSString *name = properties[3];
        //        NSLog(@" name notification Name == %@",name);
        if([name rangeOfString:@"An unknown device" options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSArray *nameArr = [name componentsSeparatedByString:@"An unknown device"];
            deviceName = nameArr[1];
        }
        else
            deviceName = name;
        
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
        //NSLog(@"notification msg: %@", message);
        
        [self setTextFieldOrTextView:nameStr];
        
        
    }
    return nil;
}
-(void)setTextFieldOrTextView:(NSAttributedString*)attributedString{
    if(self.enableDebugMode)
        self.messageTextField.attributedText = attributedString;
    else
        self.messageText.attributedText = attributedString;
}
-(NSString *)getgenericIndexfor:(int)devicetype andIndex:(NSString *)indexId{
    NSString *deviceTypeString = @(devicetype).stringValue;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[deviceTypeString];
    NSDictionary *deviceIndexes = genericDevice.Indexes;
    NSLog(@"deviceIndexes %@",deviceIndexes);
    NSLog(@"deviceIndexArr all keys id %@",indexId);
    BOOL match = NO;
   
    //    for(NSString *key in deviceIndexArr){
    //        DeviceIndex *index = deviceIndexes[key];
    //        [genericIndexes addObject:index.genericIndex];
    for (NSString * ID in deviceIndexes.allKeys) {
            DeviceIndex *index = deviceIndexes[indexId];
            if(index){
                return index.genericIndex;
            }
        }
    return @"0";
}
-(void)seticon:(NSString *)iconName{
    if(iconName != NULL){
    self.iconView.image = [UIImage imageNamed:iconName];
    self.iconView.tintColor = [UIColor whiteColor];
    }
}
-(void)setNotificationLabel:(NSDictionary *)notification{
    if (notification == nil) {
        //self.messageTextField.attributedText = [[NSAttributedString alloc] initWithString:@""];
        [self setTextFieldOrTextView:[[NSAttributedString alloc] initWithString:@""]];
        return;
    }
    UIFont *bold_font = [UIFont securifiBoldFont];
    UIFont *normal_font = [UIFont securifiNormalFont];
    NSDictionary *attr;
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor blackColor],
             };
    NSString *deviceName = notification[@"devicename"];
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
    
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    
    NSString *message;
    
    NSMutableAttributedString *mutableAttributedString = nil;
    message = notification[@"notificationText"];
    if (message == nil) {
        message = @"";
    }
    if(![message isEqualToString:@""]){
        NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];
        NSMutableAttributedString *container = [NSMutableAttributedString new];
        [container appendAttributedString:nameStr];
        [container appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:nil]];
        [container appendAttributedString:eventStr];
        
        [self setTextFieldOrTextView:container];
//        self.messageTextField.text = [NSString stringWithFormat:@"%@ %@",deviceName,message];
    }
    else{
        NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@%@",notification[@"prefix"],message,notification[@"value"],notification[@"unit"]] attributes:attr];
        NSMutableAttributedString *container = [NSMutableAttributedString new];
        [container appendAttributedString:nameStr];
       [container appendAttributedString:eventStr];

        [self setTextFieldOrTextView:container];
       // self.messageTextField.text = [NSString stringWithFormat:@"%@ %@ %@ %@%@",deviceName,notification[@"prefix"],message,notification[@"value"],notification[@"unit"]];
            }
 
}
- (GenericValue*)getMatchingGenericValueForGenericIndexID:(NSString*)genericIndexID forValue:(NSString*)value{
    //NSLog(@"value: %@", value);
    //    if(value.length == 0 || value == nil)
    //        value = @"NaN";
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericIndexClass *genericIndexObject = toolkit.genericIndexes[genericIndexID];
    NSLog(@"genericIndex obj %@",genericIndexObject.layoutType);
    if(genericIndexObject == nil || value == nil)
        return nil;
    if([genericIndexObject.ID isEqualToString:@"30"]){
        NSString *colorShade = [CommonMethods colorShadesforValue:65535 byValueOfcolor:value];
        GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:colorShade prefix:genericIndexObject.formatter.prefix];
    }
   else if([genericIndexObject.ID isEqualToString:@"31"]){
        NSString *colorShade = [CommonMethods colorShadesforValue:255 byValueOfcolor:value];
        GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:colorShade prefix:genericIndexObject.formatter.prefix];
    }
    else if(genericIndexObject.values != nil){
        GenericValue *gval = genericIndexObject.values[value];
        NSString *notificationString = [NSString stringWithFormat:@"%@,%@,%@,%@",gval.notificationText,gval.notificationPrefix,value,gval.icon];
        NSLog(@"notificaation obj %@",notificationString);

    return genericIndexObject.values[value]? genericIndexObject.values[value]: [[GenericValue alloc]initWithDisplayText:value icon:genericIndexObject.icon toggleValue:nil value:value excludeFrom:nil eventType:nil notificationText:gval.notificationText];
    }
    else if(genericIndexObject.formatter != nil && ([genericIndexObject.layoutType isEqualToString:@"HUE_ONLY"])){
        if([genericIndexObject.ID isEqualToString:@"99"]){
            int brightnessValue = (int)roundf([CommonMethods getBrightnessValue:value]);
            NSString *str = @(brightnessValue).stringValue;
             NSLog(@"slider icon1 - display text: %@, value: %@ units : %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units);
            
            GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:str prefix:genericIndexObject.formatter.prefix andUnit:genericIndexObject.formatter.units];
            return genericValue1;
        }
        
    }
    else if(genericIndexObject.formatter != nil && ![genericIndexObject.layoutType isEqualToString:@"SLIDER_ICON"] && ![genericIndexObject.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] && ![genericIndexObject.layoutType isEqualToString:@"HUE_ONLY"]){
        NSString *formattedValue=[genericIndexObject.formatter transform:value genericId:genericIndexID];
         NSLog(@"slider icon2 - display text: %@, value: %@ units : %@ ,formattedValue = %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units,formattedValue);
        //NSString *formattedValue = [NSString stringWithFormat:@"",[value floatValue] * genericIndexObject.formatter.factor];
        GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:formattedValue prefix:genericIndexObject.formatter.prefix andUnit:@""];
        
//        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:formattedValue
//                                                                     iconText:formattedValue
//                                                                        value:value
//                                                                  excludeFrom:genericIndexObject.excludeFrom
//                                                             transformedValue:[genericIndexObject.formatter transformValue:value] prefix:genericIndexObject.formatter.prefix];
        
        return genericValue1;
    }
    else if(genericIndexObject.formatter != nil && ([genericIndexObject.layoutType isEqualToString:@"SLIDER_ICON"] || [genericIndexObject.layoutType isEqualToString:@"TEXT_VIEW_ONLY"])){
        NSLog(@"slider icon - display text: %@, value: %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value);
        int brightnessValue;
        if([genericIndexObject.ID isEqualToString:@"100"])
            brightnessValue = (int)roundf([CommonMethods getBrightnessValue:value]);
        NSString *value = @(brightnessValue).stringValue;
         NSLog(@"slider icon3 - display text: %@, value: %@ units : %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units);
        NSString *formattedValue = [NSString stringWithFormat:@"",[value floatValue] * genericIndexObject.formatter.factor];
        return [[GenericValue alloc]initWithDisplayText:[genericIndexObject.formatter transform:value genericId:genericIndexID]
                                                   icon:genericIndexObject.icon
                                            toggleValue:nil
                                                  value:formattedValue
                                            excludeFrom:nil
                                              eventType:nil
                                       transformedValue:[genericIndexObject.formatter transformValue:value] prefix:genericIndexObject.formatter.prefix andUnits:genericIndexObject.formatter.units]; //need icon aswell as transformedValue
        
    }
    
    return [[GenericValue alloc]initWithDisplayText:value icon:genericIndexObject.icon toggleValue:value value:value excludeFrom:genericIndexObject.excludeFrom eventType:nil notificationText:@""];
}
- (UIColor *)notificationStatusColor {
    /*
     FOR ORANGE : RED : 255 : Green :-133  Blue : 0 (ff8500)
     FOR BLUE : RED : 0 : Green : 164    Blue : 230 (00a4e6)
     */
    return self.notification.viewed ? /*blue */[UIColor colorFromHexString:@"00a4e6"] : /*orange*/[UIColor colorFromHexString:@"ff8500"];
}

- (void)clearContentView {
    [self removeTextViewObserver];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)removeTextViewObserver {
    [self.messageTextField removeObserver:self forKeyPath:@"contentSize"];
}

- (void)setNotification:(SFINotification *)notification {
    _notification = notification;
    self.reset = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDateLabelText:(SFINotification *)notification {
    if (notification == nil) {
        self.dateLabel.attributedText = [[NSAttributedString alloc] initWithString:@""];
        return;
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    
    NSDictionary *attr;
    NSString *str;
    
    attr = @{
             NSFontAttributeName : [UIFont securifiBoldFontLarge],
             NSForegroundColorAttributeName : [UIColor grayColor],
             };
    formatter.dateFormat = @"hh:mm";
    str = [formatter stringFromDate:date];
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    
    attr = @{
             NSFontAttributeName : [UIFont securifiBoldFontLarge],
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    formatter.dateFormat = @"a";
    str = [formatter stringFromDate:date];
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    
    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];
    
    self.dateLabel.attributedText = container;
    self.dateLabel.textAlignment = NSTextAlignmentRight;
}

- (void)setMessageLabelText:(SFINotification *)notification {
    //NSLog(@"Notification: %@", notification);
    if (notification == nil) {
        [self setTextFieldOrTextView:[[NSAttributedString alloc] initWithString:@""]];
//        self.messageTextField.attributedText = [[NSAttributedString alloc] initWithString:@""];
        return;
    }
    UIFont *bold_font = [UIFont securifiBoldFont];
    UIFont *normal_font = [UIFont securifiNormalFont];
    
    NSDictionary *attr;
    
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor blackColor],
             };
        NSString *deviceName = notification.deviceName;
    //md01<<<
    if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
        //NSLog(@"client device name: %@", self.notification.deviceName);
        NSArray * properties = [notification.deviceName componentsSeparatedByString:@"|"];
        NSString *name = properties[3];
        //        NSLog(@" name notification Name == %@",name);
        if([name rangeOfString:@"An unknown device" options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSArray *nameArr = [name componentsSeparatedByString:@"An unknown device"];
            deviceName = nameArr[1];
        }
        else
            deviceName = name;
    }
    
    //md01>>>
    // debug logging
    if (self.enableDebugMode) {
        deviceName = [NSString stringWithFormat:@"(%ld) %@", (long) self.debugCellIndexNumber, deviceName];
    }
    
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
    
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    
    NSString *message;
    
    NSMutableAttributedString *mutableAttributedString = nil;
    switch (self.debugMessageMode) {
        case SFINotificationTableViewCellDebugMode_normal: {
            message = self.sensorSupport.notificationText;
            
            //md01<<<
            
            if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
                NSArray * properties = [self.notification.deviceName componentsSeparatedByString:@"|"];
                message = properties[3];
                //NSLog(@"notification msg: %@", message);
                NSRange nameRangeInMessage = [message rangeOfString:deviceName];
                if (nameRangeInMessage.location != NSNotFound) {
                    mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:attr];
           
                    [mutableAttributedString addAttribute:NSFontAttributeName value:bold_font range:nameRangeInMessage];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:nameRangeInMessage];
                    
                }
                
            }
            //md01>>>
           
            break;
        }
            
        case SFINotificationTableViewCellDebugMode_details: {
            NSString *indexName = [SFIDeviceKnownValues propertyTypeToName:notification.valueType];
            message = [NSString stringWithFormat:@" device_type:%d, device_id:%d, index:%d, index_value:%@, index_type:%@",
                       notification.deviceType, notification.deviceId, notification.valueIndex, notification.value, indexName];
            
            break;
        };
        case SFINotificationTableViewCellDebugMode_external_id: {
            message = [NSString stringWithFormat:@" cloud_id:%@", notification.externalId];
            
            break;
        };
    }
    if (message == nil) {
        message = @"";
    }
    
    
    if (!mutableAttributedString) {
        NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];
        NSMutableAttributedString *container = [NSMutableAttributedString new];
        [container appendAttributedString:nameStr];
        [container appendAttributedString:eventStr];
        
//        self.messageTextField.attributedText = container;
        [self setTextFieldOrTextView:container];
    }else{
        [self setTextFieldOrTextView:mutableAttributedString];
//        self.messageTextField.attributedText = mutableAttributedString;
    }
}

- (void)setIcon {
    //md01<<<
    if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
        NSArray * properties = [self.notification.deviceName componentsSeparatedByString:@"|"];
        Client *client;
//        NSString *mac = [SFIAlmondPlus convertDecimalToMacHex:self.notification.almondMAC];
//        client = [Client getClientByMAC:mac];
//        NSLog(@"decimal mac: %@, client mac : %@",self.notification.almondMAC, mac);
//        NSLog(@"client: %@, client type: %@",client, client.deviceType);
//        if(client == nil){
            client = [Client new];
            client.deviceType = @"other";
//        }
        
        
        self.iconView.image = [UIImage imageNamed:[client iconName]];
        return;
    }
    //md01>>>
    self.iconView.image = self.sensorSupport.notificationImage;
    self.iconView.tintColor = [UIColor whiteColor];
}

// center the message text inside the view
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *textView = object;
    
    CGFloat boundsHeight = CGRectGetHeight(textView.bounds);
    CGFloat contentHeight = textView.contentSize.height;
    
    CGFloat topOffset = (CGFloat) ((boundsHeight - contentHeight * textView.zoomScale) / 2.0);
    if (topOffset < 0) {
        topOffset = 0;
    }
    
    textView.contentOffset = CGPointMake(0, -topOffset);
}

- (void)onDebugMessageTap {
    dispatch_async(dispatch_get_main_queue(), ^() {
        SFINotificationTableViewCellDebugMode nextMode = (self.debugMessageMode + 1) % 3;
        self.debugMessageMode = nextMode;
        [self setMessageLabelText:self.notification];
    });
}

@end
