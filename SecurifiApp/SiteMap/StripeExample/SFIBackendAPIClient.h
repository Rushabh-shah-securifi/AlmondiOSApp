//
//  SFIBackendAPIClient.h
//  SecurifiApp
//
//  Created by Masood on 12/6/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stripe.h"

@interface SFIBackendAPIClient : NSObject<STPBackendAPIAdapter>

@property (nonatomic) NSString *baseURLString;

+ (instancetype)sharedInstance;
@end
