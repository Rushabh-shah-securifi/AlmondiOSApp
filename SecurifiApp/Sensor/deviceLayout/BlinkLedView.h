//
//  BlinkLedView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 25/07/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@protocol BlinkLedViewDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue currentView:(UIView*)currentView;
@end
@interface BlinkLedView : UIView
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;
@property(nonatomic)id<BlinkLedViewDelegate> delegate;
@end
