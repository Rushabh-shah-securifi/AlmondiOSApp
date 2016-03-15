//
//  HueSliderView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HueSliderViewDelegate
-(void)updateSliderValue:(NSString*)newvalue;
@end
@interface HueSliderView : UIView
@property (nonatomic)NSMutableArray *componentArray;
@property (nonatomic)UIColor *color;
@property(nonatomic)id<HueSliderViewDelegate> delegate;
-(void)drawSlider;

@end
