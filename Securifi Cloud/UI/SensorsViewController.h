//
//  SampleTableViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 2/13/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "SFIColors.h"
#import "MBProgressHUD.h"
#import "BVReorderTableView.h"

@interface SensorsViewController : UITableViewController <UITableViewDataSource, UITabBarControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate>{
    MBProgressHUD               *HUD;
}
- (IBAction)revealMenu:(id)sender;
- (IBAction)refreshSensorData:(id)sender;

@property (nonatomic, retain) NSMutableArray  *sensors;
@property (nonatomic, retain) NSArray  *sensorsCopy;
@property (nonatomic) NSInteger checkHeight;
@property (nonatomic) unsigned int changeBrightness;
@property (nonatomic) unsigned int baseBrightness;
@property (nonatomic) unsigned int changeHue;
@property (nonatomic) unsigned int baseHue;
@property (nonatomic) unsigned int changeSaturation;
@property (nonatomic) id prevObject;
@property (nonatomic) int moveCount;
@property (nonatomic) int startIndex;
@property BOOL isReverseMove;
@property (nonatomic, retain) NSMutableArray *listAvailableColors;
@property (nonatomic) NSInteger currentColorIndex;
@property (nonatomic, retain) SFIColors *currentColor;

//PY 111013 - Integration with new UI
@property (nonatomic,retain) NSString *currentMAC;
@property (nonatomic, retain) NSMutableArray *deviceList;
@property (nonatomic, retain) NSMutableArray *deviceValueList;
@property (nonatomic,retain) NSString *offlineHash;
@property NSString *currentDeviceID;
@property unsigned int currentIndexID;
@property NSString *currentValue;
@property unsigned int currentInternalIndex;
@property BOOL isEmpty;

@property NSTimer *mobileCommandTimer;
@property NSTimer *sensorChangeCommandTimer;
@property NSTimer *sensorDataCommandTimer;
@property BOOL isMobileCommandSuccessful;
@property BOOL isSensorChangeCommandSuccessful;
//@property BOOL isSensorDataCommandSuccessful;
@property BOOL isEditing;

@property BOOL isSliderExpanded;
@property (nonatomic, retain) IBOutlet BVReorderTableView *sensorTable;
@property (nonatomic, retain) IBOutlet UITextField *txtInvisible;

@property unsigned int expandedRowHeight;

//PY 200114 - Sensor and Location name change
@property (nonatomic,retain) NSString *currentChangedName;
@property (nonatomic,retain) NSString *currentChangedLocation;

-(UITableViewCell*) createAddSymbolCell: (UITableViewCell*)cell;
-(UITableViewCell*) createColoredListCell: (UITableViewCell*)cell listRow:(int)indexPathRow;
@end
