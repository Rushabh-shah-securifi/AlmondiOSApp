//
//  NotificationView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 06/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
@protocol NotificationViewDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue;
@end
@interface NotificationView : UIView
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak,nonatomic) id<NotificationViewDelegate> delegate;
@property (nonatomic)GenericIndexValue *genericIndexValue;
- (id)initWithFrame:(CGRect)frame andGenericIndexValue:(GenericIndexValue *)genericIndexValue isSensor:(BOOL)isSensor;

@end
