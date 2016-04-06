//
//  MultiButtonView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "GenericIndexValue.h"

@protocol MultiButtonViewDelegate
@optional
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue;
@end

@interface MultiButtonView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)id<MultiButtonViewDelegate> delegate;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;
@end
