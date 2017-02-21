//
//  PickerComponentView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/01/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@protocol PickerComponentViewDelegate

-(void)pickerViewSelectedValue:(NSString *)value genericIndexValue:(GenericIndexValue *)genericIndexValue;

@end
@interface PickerComponentView : UIView
@property (nonatomic )GenericIndexValue *genericIndexValue;
@property (nonatomic , weak)id<PickerComponentViewDelegate> delegate;
-(id) initWithFrame:(CGRect)frame arrayList:(NSDictionary *)dictOfValues;

@end
