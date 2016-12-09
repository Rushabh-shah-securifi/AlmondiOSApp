//
//  SFIBackendAPIClient.m
//  SecurifiApp
//
//  Created by Masood on 12/6/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFIBackendAPIClient.h"


@interface SFIBackendAPIClient()
/*
 var defaultSource: STPCard? = nil
 var sources: [STPCard] = []
 */
@property (nonatomic) STPCard *defaultSource;
@property (nonatomic) NSArray *sources;
@end

@implementation SFIBackendAPIClient

+ (instancetype)sharedInstance
{
    static SFIBackendAPIClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFIBackendAPIClient alloc] init];
    });
    return sharedInstance;
}

-(void)retrieveCustomer:(STPCustomerCompletionBlock)completion{
    NSLog(@"retrieveCustomer");
    /*
     let customer = STPCustomer(stripeID: "cus_test", defaultSource: self.defaultSource, sources: self.sources)
    completion(customer, nil)
    return
     */
    STPCustomer *customer = [STPCustomer customerWithStripeID:@"cus_test" defaultSource:[STPCard new] sources:[NSArray new]];
    completion(customer, nil);
}

-(void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion{
    NSLog(@"attachSourceToCustomer");
}

-(void)selectDefaultCustomerSource:(id<STPSource>)source completion:(STPErrorBlock)completion{
    NSLog(@"selectDefaultCustomerSource");
    
}
@end
