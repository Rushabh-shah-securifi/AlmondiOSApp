//
//  SFISensorDetailView.h
//
//  Created by sinclair on 8/15/14.
//
#import <UIKit/UIKit.h>

@class SFIColors;


@interface SFISensorDetailView : UIView

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) SFIColors *currentColor;

@end