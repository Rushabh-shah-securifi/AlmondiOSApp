//
//  SFISensorDetailView.h
//
//  Created by sinclair on 8/15/14.
//
#import <UIKit/UIKit.h>

@class SFIColors;
@class SFISensorDetailView;

@protocol SFISensorDetailViewDelegate

// called when Save button is pressed
- (void)sensorDetailViewDidPressSaveButton:(SFISensorDetailView*)view;

- (void)sensorDetailViewDidPressDismissTamperButton:(SFISensorDetailView*)view;

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView*)view valueName:(NSString*)valueName newValue:(NSString*)aValue;

@end


@interface SFISensorDetailView : UIView

@property(weak) id<SFISensorDetailViewDelegate> delegate;

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) SFIColors *currentColor;

- (NSString*)deviceName;
- (NSString*)deviceLocation;

@end