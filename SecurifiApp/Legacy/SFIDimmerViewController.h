//
//  SFIDimmerViewController.h
//  Securifi Cloud
//
//  Created by Securifi on 13/01/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SFISingleton.h"

@interface SFIDimmerViewController : UIViewController
{
    UIActivityIndicatorView *ai;
   // SFISingleton *singleton;
}

@property (weak, nonatomic) IBOutlet UISlider *dimmerSlider;
@property (weak, nonatomic) IBOutlet UIButton *onDimmer;
@property (weak, nonatomic) IBOutlet UIButton *offDimmer;
@property (weak, nonatomic) IBOutlet UIButton *dimmerOn;
@property (weak, nonatomic) IBOutlet UIButton *dimmerOff;
@property (weak, nonatomic) IBOutlet UILabel *dimmerLabelValue;

- (IBAction)dimmerON:(id)sender;
- (IBAction)dimmerOFF:(id)sender;
- (IBAction)dimmerValueChanged:(UISlider *)sender;
- (void)sendCommand:(unsigned int)value;
@end
