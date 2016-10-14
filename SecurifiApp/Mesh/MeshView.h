//
//  MeshView.h
//  SecurifiApp
//
//  Created by Masood on 7/27/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MeshViewDelegate
- (void)dismissControllerDelegate;
- (void)showHudWithTimeoutMsgDelegate:(NSString*)hudMsg time:(NSTimeInterval)sec;
- (void)hideHUDDelegate;

@optional
- (void)showToastDelegate:(NSString *)msg;
- (void)requestSetSlaveNameDelegate:(NSString *)newName;
@end


@interface MeshView : UIView
@property (nonatomic) BOOL isMeshEditView;
@property (nonatomic) id<MeshViewDelegate> delegate;
- (void)addInterfaceView:(CGRect)frame;
- (void)removeNotificationObserver;
- (void)addNamingScreen:(CGRect)frame;

/* meshhekp - start */
- (void)addInfoScreen:(CGRect)frame;
- (void)initializeFirstScreen:(NSDictionary *)item;
/* meshhelp - end */
@end
