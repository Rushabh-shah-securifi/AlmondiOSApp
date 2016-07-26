//
//  BrowsingHistory.h
//  SecurifiApp
//
//  Created by Masood on 6/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URIData.h"

@interface BrowsingHistory : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSArray *URIs;
@property (nonatomic) NSString *almondMac;
@property (nonatomic) NSString *clientMac;
@property (nonatomic) NSMutableDictionary *allDateRecord;
@property (nonatomic) URIData *uriInfo;

@end
