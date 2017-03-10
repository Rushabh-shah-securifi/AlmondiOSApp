//
//  DataUsageView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@interface DataUsageView : UIView
- (id)initWithFrame:(CGRect)frame genericIndexValue:(GenericIndexValue *)gval amac:(NSString *)amac cmac:(NSString *)cmac;
@end
