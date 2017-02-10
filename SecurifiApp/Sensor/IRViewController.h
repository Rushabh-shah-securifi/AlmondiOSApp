//
//  IRViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
#import "GenericParams.h"

@interface IRViewController : UIViewController
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)GenericParams *genericParams;

@end
