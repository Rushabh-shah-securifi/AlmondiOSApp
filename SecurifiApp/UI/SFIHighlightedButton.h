//
//  SFIHighlightedButton.h
//
//  Created by sinclair on 6/25/14.
//
#import <Foundation/Foundation.h>


@interface SFIHighlightedButton : UIButton

@property UIColor *highlightedBackgroundColor;
@property UIColor *normalBackgroundColor;
- (SFIHighlightedButton *)addButton:(NSString *)buttonName button:(SFIHighlightedButton *)button color:(UIColor *)color;
@end