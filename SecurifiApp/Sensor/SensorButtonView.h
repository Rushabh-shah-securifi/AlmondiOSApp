//
//  SensorButtonView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SensorButtonViewDelegate
-(void)updateButtonStatus;
@end
@interface SensorButtonView : UIView
-(void)drawButton:(NSDictionary *)valuedict color:(UIColor *)color;
@end
