//
//  SFISceneViewController.h
//  SecurifiUI
//
//  Created by Priya Yerunkar on 09/10/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFISensor.h"
@interface SFISceneViewController : UITableViewController <UITableViewDataSource, UITabBarControllerDelegate>
@property (nonatomic, retain) NSArray  *sensors;
@property (nonatomic, retain) NSMutableDictionary  *sceneSensorMap;
@property (nonatomic, retain) NSArray  *scenes;
@property (nonatomic, retain) NSMutableArray *listAvailableColors;
@property (nonatomic, retain) NSMutableArray *sceneSensorColors;
@property (nonatomic) unsigned int baseBrightness;
@property (nonatomic) unsigned int changeBrightness;
@property (nonatomic) unsigned int changeHue;
@property (nonatomic) unsigned int changeSaturation;

- (IBAction)revealMenu:(id)sender;

@end
