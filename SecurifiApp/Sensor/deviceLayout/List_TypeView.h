//
//  List_TypeView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 06/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
@protocol List_TypeViewDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue currentView:(UIView*)currentView;
@end
@interface List_TypeView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)id<List_TypeViewDelegate> delegate;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;

-(void)setListValue:(NSString*)value;
@end
