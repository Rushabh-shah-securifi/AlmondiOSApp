//
//  DetailsPeriodViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 27/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DetailsPeriodViewControllerDelegate
-(void)updateDetailPeriod:(NSString *)value date:(NSString*)date;
@end
@interface DetailsPeriodViewController : UIViewController
@property (nonatomic, weak)id<DetailsPeriodViewControllerDelegate> delegate;
@end
