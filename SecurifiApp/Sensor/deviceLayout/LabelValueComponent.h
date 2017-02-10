//
//  LabelValueComponent.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 08/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@protocol LabelValueComponentDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue;
@end
@interface LabelValueComponent : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)id<LabelValueComponentDelegate> delegate;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)BOOL isSensor;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue propertyName:(NSString *)propertyName;

@end
