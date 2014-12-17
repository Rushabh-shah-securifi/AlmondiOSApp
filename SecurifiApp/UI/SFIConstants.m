//
//  SFIConstants.m
//  SecurifiUI
//
//  Created by Priya Yerunkar  on 11/10/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SFIConstants.h"

@implementation SFIConstants

+ (void) globalResignFirstResponderRec:(UIView*) view {
    if ([view respondsToSelector:@selector(resignFirstResponder)]){
        [view resignFirstResponder];
    }
    for (UIView * subview in [view subviews]){
        [self globalResignFirstResponderRec:subview];
    }
}
@end
