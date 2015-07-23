//
//  SFISwitchButton.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFISwitchButton : UIButton

@property(nonatomic)NSString* dimOnValue;
@property(nonatomic)NSString* dimOffValue;

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title;
- (void)changeStyle;
@end

