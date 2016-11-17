//
//  AdvRouterHelpController.h
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, Feature){
    Feature_Vpn = 0,
    Feature_Port_Forwarding,
    Feature_DNS,
    Feature_Static_IP_Settings,
    Feature_UPnP
};

@interface AdvRouterHelpController : UIViewController
@property (nonatomic) Feature helpType;
@end
