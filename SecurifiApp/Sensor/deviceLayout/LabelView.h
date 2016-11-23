//
//  LabelView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rule.h"
@protocol LabelViewDelegate
-(void)lableArrowClicked:(Rule *)rule isRule:(BOOL)isRule;
@end
@interface LabelView : UIView
@property (nonatomic)id<LabelViewDelegate> delegate;
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color rule:(Rule *)rule isRule:(BOOL)isRule;
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color text:(NSString *)text isRule:(BOOL)isRule;
@end
