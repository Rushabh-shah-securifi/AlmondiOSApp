//
//  SFIRulesActionButton.h
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 24/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFIButtonSubProperties.h"


@interface SFIRulesActionButton : UIButton

@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) unsigned int count;

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title;
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden;
- (void)changeStyle;
@end