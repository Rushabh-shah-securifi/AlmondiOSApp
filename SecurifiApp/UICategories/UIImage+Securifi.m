//
// Created by Matthew Sinclair-Day on 2/4/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "UIImage+Securifi.h"
#import "SFIAppDelegate.h"


@implementation UIImage (Securifi)

+ (UIImage *)assetImageNamed:(NSString *)imageName {
    UIApplication *app = [UIApplication sharedApplication];
    SFIAppDelegate *del = (SFIAppDelegate *) app.delegate;

    NSString *image = [del.assetsPrefixId stringByAppendingFormat:@"-%@", imageName];
    return [UIImage imageNamed:image];
}

+ (UIImage *)routerImage {
    return [UIImage imageNamed:@"router-icon"];
}

@end