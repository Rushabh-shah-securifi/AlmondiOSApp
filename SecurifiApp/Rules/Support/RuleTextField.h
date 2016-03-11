//
//  RuleTextField.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 04/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIButtonSubProperties.h"

@interface RuleTextField : UITextField
@property(nonatomic) SFIButtonSubProperties *subProperties;
@property(nonatomic) SFIDevice *device;
@end
