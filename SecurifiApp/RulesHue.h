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

@property(nonatomic)AddRulesViewController *parentViewController;
@property(weak)id<RulesHueDelegate> delegate;
@property (nonatomic, strong)NSMutableArray *selectedButtonsPropertiesArray;


-(void) createHueCellLayoutWithDeviceId:(int)deviceId deviceType:(int)deviceType deviceIndexes:(NSArray*)deviceIndexes scrollView:(UIScrollView *)scrollView cellCount:(int)numberOfCells indexesDictionary:(NSDictionary*)deviceIndexesDict;

@end
