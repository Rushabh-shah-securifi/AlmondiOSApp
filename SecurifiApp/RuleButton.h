//
//  RuleButton.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIButtonSubProperties.h"
#import "RuleTextField.h"

@interface RuleButton : UIButton
@property (nonatomic)UIView * bgView;
@property (nonatomic)UILabel * topLabel;
@property (nonatomic)UILabel *bottomLabel;
@property (nonatomic)RuleTextField *textField;

- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden;
- (void)changeBGColor:(BOOL)isTrigger clearColor:(BOOL)clearColor showTitle:(BOOL)showTitle;
- (void)setNewValue:(NSString*)text;
@property(nonatomic)SFIButtonSubProperties* subProperties;

@end
