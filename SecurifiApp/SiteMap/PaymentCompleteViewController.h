//
//  PaymentCompleteViewController.h
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlmondPlan.h"

typedef NS_ENUM(NSInteger, SubscriptionResponse){
    SubscriptionResponse_Success,
    SubscriptionResponse_Failed,
    SubscriptionResponse_Cancelled
};

@interface PaymentCompleteViewController : UIViewController
@property (nonatomic) SubscriptionResponse type;
@property (nonatomic) PlanType selectedPlanType;
@end
