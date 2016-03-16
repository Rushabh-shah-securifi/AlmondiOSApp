//
//  SensorTextView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericProperty.h"
@protocol SensorTextViewDelegate
-(void)updateNewValue:(NSString *)newValue;
@end
@interface SensorTextView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)id<SensorTextViewDelegate> delegate;
@property (nonatomic)GenericProperty *deviceProperty;
-(void)drawTextField:(NSString*)name;

@end
