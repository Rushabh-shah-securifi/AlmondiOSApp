//
//  SFIDoorSensorViewController.h
//  Securifi Cloud
//
//  Created by Nirav Uchat on 6/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SFISingleton.h"

@interface SFIDoorSensorViewController : UIViewController
{
    //SFISingleton *singletonObj;
}
@property (weak, nonatomic) IBOutlet UILabel *sensorStatus;

-(void)command;

@end
