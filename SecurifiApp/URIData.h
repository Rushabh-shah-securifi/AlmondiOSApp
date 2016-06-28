//
//  BrowsingHistory.h
//  SecurifiApp
//
//  Created by Masood on 6/27/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URIData : NSObject
@property (nonatomic) NSString *hostName;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSDate *lastActiveTime;
@property (nonatomic) int count;
@end
