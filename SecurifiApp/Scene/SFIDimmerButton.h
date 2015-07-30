//
//  SFIDimmerButton.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIDimmerButton : UIButton

@property(nonatomic)NSString* prefix;
@property(nonatomic)NSString* dimValue;

- (void)setupValues:(NSString*)text  Title:(NSString*)title Prefix:(NSString*)prefix;
- (void)changeStyle;
- (void)setNewValue:(NSString*)text;

@end

