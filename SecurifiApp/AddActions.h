//
//  AddActions.h
//  RulesUI
//
//  Created by Masood on 01/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRulesViewController.h"
#import <UIKit/UIKit.h>
#import "SFIDeviceIndex.h"

@protocol AddActionsDelegate

-(void) updateActionsButtonsPropertiesArray:(NSMutableArray*)actionButtonPropertiesArray;

@end

@interface AddActions : NSObject
@property (nonatomic, strong)NSMutableDictionary *deviceDict;
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArray;

@property(nonatomic)AddRulesViewController *parentViewController;
@property(nonatomic)id<AddActionsDelegate> delegate;

-(void)displayActionDeviceList;
-(BOOL)istoggle:(SFIDeviceType)device;
-(SFIDeviceIndex *)getToggelDeviceIndex;
-(void) createDeviceIndexesLayoutForDeviceId:(int)deviceId deviceType:(SFIDeviceType)deviceType deviceIndexes:(NSArray*)deviceIndexes;
@end