//
//  PickerComponentView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/01/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PickerComponentViewDelegate
-(void)setPickerValue:(NSString *)pickerSelectedValue rowPosition:(NSString*)rowPosition;
@end
@interface PickerComponentView : UIView
@property (nonatomic,weak) id<PickerComponentViewDelegate> delegate;
-(id) initWithFrame:(CGRect)frame arrayList:(NSArray *)arrayOfState atRowPosition:(NSInteger)rowPosition;
@end
