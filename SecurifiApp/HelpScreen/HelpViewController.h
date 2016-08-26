//
//  HelpViewController.h
//  SecurifiApp
//
//  Created by Masood on 8/23/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, HelpTopic){
    HelpTopic_Dashboard,
    HelpTopic_Scene,
    HelpTopic_Securiti
};

@interface HelpViewController : UIViewController
@property(nonatomic) NSDictionary *startScreen;
@property(nonatomic) HelpTopic helpTopic;
@property(nonatomic) BOOL isHelpTopic;
@end
