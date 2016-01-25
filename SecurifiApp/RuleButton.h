//
//  RuleButton.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RuleButton : UIButton

- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden;
- (void)changeStylewithColor:(BOOL)isTrigger;
- (void)changeStyle;
- (void)changeBGColor:(UIColor*)color;
@end
