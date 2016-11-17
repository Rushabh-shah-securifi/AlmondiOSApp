//
//  RulesHue.h
//  Tableviewcellpratic
//
//  Created by Masood on 17/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AddRulesViewController.h"
//#import "SecurifiToolkit/SFIDevice.h"
//#import "SecurifiToolkit/SFIDeviceValue.h"

@class SFIDevice;
@class SFIDeviceValue;
@class UITableViewCell;

//protocol
@protocol RulesHueDelegate

-(void) onSwitchButtonClick:(id)sender;
-(void) updateArray;
@end

//interface
@interface RulesHue : NSObject
@property(weak)id<RulesHueDelegate> delegate;
@property BOOL isScene;
@property (nonatomic, strong)NSMutableArray *triggers;
@property (nonatomic, strong)NSMutableArray *actions;

-(id)initWithPropertiesTrigger:(NSMutableArray*)triggers action:(NSMutableArray*)actions isScene:(BOOL)isScene;
-(void) createHueCellLayoutWithDeviceId:(int)deviceId deviceType:(int)deviceType deviceIndexes:(NSArray*)deviceIndexes deviceName:(NSString*)deviceName scrollView:(UIScrollView *)scrollView cellCount:(int)numberOfCells indexesDictionary:(NSDictionary*)deviceIndexesDict;
+(NSArray *)handleHue:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues modeFilter:(BOOL)modeFilter triggers:(NSMutableArray*)triggers;

@end