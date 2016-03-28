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
-(void)updateButtonStatus:(NSString *)newValue;
@end

@interface MultiButtonView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic) NSDictionary *deviceValueDict;
@property (nonatomic) Device *device;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)id<MultiButtonViewDelegate> delegate;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;
-(void)drawButton:(NSDictionary *)valuedict color:(UIColor *)color;
-(void)drawButton:(NSArray*)array selectedValue:(int)selectedValue;
@end
