//
//  TextInput.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
@protocol TextInputDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue currentView:(UIView*)currentView;
@end
@interface TextInput : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)id<TextInputDelegate> delegate;
@property (nonatomic)GenericIndexValue *genericIndexValue;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;

-(void)setTextFieldValue:(NSString*)value;
@end
