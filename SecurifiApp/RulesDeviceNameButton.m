//
//  RulesDeviceNameButton.m
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "RulesDeviceNameButton.h"
#import "Colours.h"

@implementation RulesDeviceNameButton

-(id) initWithFrame: (CGRect) frame
{
    return [super initWithFrame:frame];
    //    return self;
}

- (void)setSelected:(BOOL)selected{
    //NSLog(@" button selected");
    [super setSelected:selected];
//    [self changeStyle];
}

- (void)changeStyle{
    if (self.selected) {
        //NSLog(@" button selected");
        super.backgroundColor = [UIColor colorFromHexString:@"02a8f3"];
    }else{
        super.backgroundColor = [UIColor colorFromHexString:@"757575"];
    }
}



@end
