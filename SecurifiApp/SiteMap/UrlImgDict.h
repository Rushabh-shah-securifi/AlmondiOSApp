//
//  UrlImgDict.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlImgDict : NSObject
@property (nonatomic,strong )NSMutableDictionary *imgDict;
+(UrlImgDict *)sharedInstance;

@end
