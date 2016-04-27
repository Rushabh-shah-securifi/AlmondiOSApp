//
//  labelAndCheckButtonView.h
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 05/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "GenericIndexValue.h"
#import <UIKit/UIKit.h>

extern int const hueLabelWidth;
extern int const hueButtonSize;
extern int const hueButtonLabelSize;
extern int const hueLableFontSize;

@interface labelAndCheckButtonView : UIView
@property (nonatomic )UILabel *propertyNameLabel;
@property (nonatomic)UIButton *selectButton;
@property (nonatomic)UILabel *countLable;
@property (nonatomic)BOOL isScene;
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)NSString *value;
- (void)setUpValues:(NSString*)propertyName withSelectButtonTitle:(NSString*)checkButtonText;
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden;
- (void)setSelected:(BOOL)selected;

@end