//
//  SFIAppDelegate.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "SFISingleton.h"

@interface SFIAppDelegate : UIResponder <UIApplicationDelegate>
{
   // SFISingleton *singleton_obj;
}

@property NSInteger state;
@property (strong, nonatomic) UIWindow *window;
-(void)networkUP:(id)sender;
-(void)networkDOWN:(id)sender;
-(void)connectCloud;
@end
