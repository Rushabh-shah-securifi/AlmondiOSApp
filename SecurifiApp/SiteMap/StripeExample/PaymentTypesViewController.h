//
//  PaymentTypesViewController.h
//  SecurifiApp
//
//  Created by Masood on 12/7/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPToken.h"
#import "AlmondPlan.h"

typedef NS_ENUM(NSInteger, STPBackendChargeResult) {
    STPBackendChargeResultSuccess,
    STPBackendChargeResultFailure,
};

typedef void (^STPTokenSubmissionHandler)(STPBackendChargeResult status, NSError *error);

@protocol STPBackendCharging <NSObject>

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion;

@end

@interface PaymentTypesViewController : UIViewController<STPBackendCharging>
@property (nonatomic) PlanType selectedPlan;
@end

