//
//  GridView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 18/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@protocol GridViewDelegate
@optional
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue currentView:(UIView*)currentView;
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue blockArr:(NSArray*)blockArr;
@end

@interface GridView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)id<GridViewDelegate> delegate;
//@property (nonatomic)
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue onSchedule:(NSString*)schedule;
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue onSchedule:(NSString*)schedule blockArr:(NSMutableArray*)blockArr;


@end
