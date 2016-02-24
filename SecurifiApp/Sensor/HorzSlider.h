//
//  HorzSlider.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <V8HorizontalPickerView/V8HorizontalPickerView.h>
@protocol HorzSliderDelegate
-(void)updatePickerValue:(NSString *)newValue;
@end
@interface HorzSlider : UIView
@property (nonatomic)NSMutableArray *componentArray;
@property (nonatomic)id<HorzSliderDelegate> delegate;
@property (nonatomic)UIColor *color;
-(void)drawSlider;
@end
