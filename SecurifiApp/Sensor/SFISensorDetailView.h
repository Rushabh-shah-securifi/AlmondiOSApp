//
//  SFISensorDetailView.h
//
//  Created by sinclair on 8/15/14.
//
#import <UIKit/UIKit.h>

@class SFIColors;
@class SFISensorDetailView;

@protocol SFISensorDetailViewDelegate

// called to ask whether notifications are supported in the app
- (BOOL)sensorDetailViewNotificationsEnabled;

// called when Save button is pressed
- (void)sensorDetailViewDidPressSaveButton:(SFISensorDetailView*)view;

- (void)sensorDetailViewWillStartMakingChanges:(SFISensorDetailView*)view;

- (void)sensorDetailViewDidCompleteMakingChanges:(SFISensorDetailView*)view;

- (void)sensorDetailViewDidCancelMakingChanges:(SFISensorDetailView*)view;

- (void)sensorDetailViewDidPressDismissTamperButton:(SFISensorDetailView*)view;

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView*)view propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString*)aValue;

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView*)view propertyName:(NSString*)propertyName newValue:(NSString*)aValue;

- (void)sensorDetailViewDidRejectSensorValue:(SFISensorDetailView *)view validationToast:(NSString*)aMsg;

- (void)sensorDetailViewCell:(SFISensorDetailView *)view setValue:(id)value forKey:(NSString *)key;

- (id)sensorDetailViewCell:(SFISensorDetailView *)view valueForKey:(NSString *)key;

- (void)sensorDetailViewDidChangeNotificationPref:(SFISensorDetailView *)view notificationSettingEnabled:(BOOL)enabled;

@end


@interface SFISensorDetailView : UIView

@property(weak) id<SFISensorDetailViewDelegate> delegate;

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) UIColor *color;

+ (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor tamperedDevice:(BOOL)isTampered expandedCell:(BOOL)isExpanded notificationEnabled:(BOOL)isNotificationsEnabled;

- (NSString*)deviceName;
- (NSString*)deviceLocation;

@end