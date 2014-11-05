//
//  SFICardView.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIFont;

@interface SFICardView : UIView

- (void)addLine;

- (void)addShortLine;

// adds centered header with given title
- (UILabel *)addHeader:(NSString *)title;

// adds left-aligned header with given title
- (UILabel *)addTitle:(NSString *)title;

- (UILabel *)addSummary:(NSArray *)msgs;

- (void)addEditIconTarget:(id)target action:(SEL)action editing:(BOOL)editing;

- (void)addOnOffSwitch:(id)target action:(SEL)action on:(BOOL)isOn;

@end
