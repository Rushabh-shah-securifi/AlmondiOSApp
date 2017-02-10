//
//  IRView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@protocol IRViewDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue;
@end
@interface IRView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)id<IRViewDelegate> delegate;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)BOOL isSensor;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue isSensor:(BOOL)isSensor;

@end
