//
//  UIImageView+Securifi.m
//  SecurifiApp
//
//  Created by Masood on 7/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "UIImageView+Securifi.h"

@implementation UIImageView (Securifi)
- (void)setImageRenderingMode:(UIImageRenderingMode)renderMode
{
    NSLog(@"setImageRenderingMode");
    NSAssert(self.image, @"Image must be set before setting rendering mode");
    self.image = [self.image imageWithRenderingMode:renderMode];
}
@end
