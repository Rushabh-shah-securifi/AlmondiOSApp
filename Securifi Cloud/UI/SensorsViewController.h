//
//  SensorsViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 2/13/12.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>

// A HACK: we mark a UIView shown inside an expanded Sensor tile with the tag number, so that the UIGestureRecognizer
// used for swiping the table drawer open and closed can be shutdown when the user swipes on the tagged view.
// This is a gross hack to handle a conflict between that recognizer and the UISlider shown on some of these tiles.
// See also SFIMainViewController.m
#define SENSOR_VIEW_EXCLUDE_TOUCHES_BACKGROUND_VIEW_TAG 99112233

@interface SensorsViewController : UITableViewController

@end
