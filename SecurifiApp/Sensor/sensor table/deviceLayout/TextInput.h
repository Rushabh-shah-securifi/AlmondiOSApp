//
//  TextInput.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericProperty.h"
@protocol TextInputDelegate
-(void)updateNewValue:(NSString *)newValue;
@end
@interface TextInput : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)id<TextInputDelegate> delegate;
@property (nonatomic)GenericProperty *deviceProperty;
-(void)drawTextField:(NSString*)name;

@end
