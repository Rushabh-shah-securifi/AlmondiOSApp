//
//  AddRuleSceneClass.h
//  SecurifiApp
//
//  Created by Masood on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddRuleSceneClass : NSObject

@property (strong, nonatomic) UIScrollView *triggersActionsScrollView;
@property (strong, nonatomic) UIScrollView *deviceListScrollView;
@property (strong, nonatomic) UIScrollView *deviceIndexScrollView;
@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic)UILabel *informationLabel;
@property (nonatomic) BOOL isScene;
@property (nonatomic,strong) NSMutableArray *triggers;
@property (nonatomic,strong) NSMutableArray *actions;

- (id)initWithParentView:(UIView*)parentView deviceIndexScrollView:(UIScrollView*)deviceIndexScrollView deviceListScrollView:(UIScrollView*)deviceListScrollView topScrollView:(UIScrollView*)triggersActionsScrollView informationLabel:(UILabel*)infoLable triggers:(NSMutableArray*)triggers actions:(NSMutableArray*)actions isScene:(BOOL)isScene;
- (void)redrawDeviceIndexView:(sfi_id)deviceId clientEvent:(NSString*)eventType;
- (void)updateInfoLabel;
- (void)getTriggersDeviceList:(BOOL)isTrigger;
- (void)buildTriggersAndActions;
@end
