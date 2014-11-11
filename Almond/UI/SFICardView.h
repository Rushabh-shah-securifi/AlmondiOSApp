//
//  SFICardView.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIFont;

// A SFICardView provides a container for laying out UI forms according to the standard Securifi style.
// Subclasses and clients can declare layouts, line by line, row by row, by adding name-values, controls,
// and icons. Rows are generally demarcated visually by calling addLine and addShortLine, though this is
// by convention. Internally, rows are simply demarcated by advancing the Y-offset counter, which manages
// the Y-coordinate offset from the container's top. Methods follow naming conventions:
//          addXXX both instantiate the visual controls and add them to the card's as a subview, as well as
//              advance the Y-offset.
//          makeXXX only instantiate and configure the control. It is the caller's responsibility to
//              add it to the view hierarchy and mark the Y-offset. These methods are useful for laying out multiple
//              controls in a single "row".
@interface SFICardView : UIView

- (void)markYOffset:(unsigned int)val;

// Can be called after layouts to provide a preferred height for the table view cell
- (CGFloat)computedLayoutHeight;

// Adds a top border to the card
- (void)addTopBorder:(UIColor *)color;

- (void)addLeftBorder:(UIColor *)color;

// Draws a line across the width of the card, at the current Y-offset.
// Used for demarcating a group of rows.
- (void)addLine;

// Draws a shorter line across the card, at the current Y-offset. Used for demarcating rows within a group.
- (void)addShortLine;

- (void)setCardIcon:(UIImage*)image;

// Draws a centered header with given title
- (UILabel *)addHeader:(NSString *)title;

// Draws a left-aligned header with given title
- (UILabel *)addTitle:(NSString *)title;

- (void)addTitleAndOnOffSwitch:(NSString*)title target:(id)target action:(SEL)action on:(BOOL)isSwitchOn;

- (void)addTitleAndButton:(NSString*)title target:(id)target action:(SEL)action buttonTitle:(NSString*)buttonTitle;

// Draws a summary message. Usually added after calling addTitle and addHeader to create the standard
// card header view.
- (UILabel *)addSummary:(NSArray *)msgs;

// Standard method for laying out a row of info. The name label is left justified, and the value label is right justified.
- (void)addNameLabel:(NSString *)name valueLabel:(NSString *)value;

// For cards or UI elements that can be "edited" or otherwise "expanded", this draws a standard "edit" icon
// on the card, relative to the current Y-offset, and wires up the button to the specified target and action selector.
// The parameter "editing" controls the current visual state, which changes when the card is being edited or not.
- (void)addEditIconTarget:(id)target action:(SEL)action editing:(BOOL)editing;

//- (UISwitch *)makeOnOffSwitch:(id)target action:(SEL)action on:(BOOL)isOn;

@end
