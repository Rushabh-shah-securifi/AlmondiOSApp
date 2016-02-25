//
//  NameLocNotView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
@interface NameLocNotView : UIView

@property (nonatomic)UITextField *deviceNameField;

-(void)drawNameAndLoc:(NSString *)deviceName labelText:(NSString*)labelText;
-(void)notiFicationField:(NSString*)labelText andDevice:(Device*)device color:(UIColor*)color;
@end
