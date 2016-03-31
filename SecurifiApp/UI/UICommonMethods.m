//
//  UICommonMethods.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "UICommonMethods.h"

@implementation UICommonMethods

+(CGRect)adjustDeviceNameWidth:(NSString*)name fontSize:(int)fontSize maxLength:(int)maxLength{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGRect textRect;
    textRect.size = [name sizeWithAttributes:attributes];
    if(name.length > maxLength){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
}

@end
