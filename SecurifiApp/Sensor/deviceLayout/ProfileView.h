//
//  ProfileView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 16/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProfileViewDelegate
-(void)callUserPropertyViewController;
@end

@interface ProfileView : UIView
@property(strong ,nonatomic)id<ProfileViewDelegate> delegate;
-(void)setButtonImages;

@end
