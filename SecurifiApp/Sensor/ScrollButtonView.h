//
//  ScrollButtonView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 02/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollButtonViewDelegate

-(void)updateDeviceListLocation:(NSString *)location;

@end
@interface ScrollButtonView : UIScrollView
@property (weak,nonatomic) id<ScrollButtonViewDelegate> delegate;
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color location:(NSString *)location;
@end
