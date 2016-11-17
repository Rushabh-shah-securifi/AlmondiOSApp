//
//  UrlImgDict.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "UrlImgDict.h"

@implementation UrlImgDict

+(UrlImgDict *)sharedInstance{
    static UrlImgDict *imgDict = nil;
    if(!imgDict){
        imgDict = [[super allocWithZone:nil]init];
    }
    return imgDict;
}
+(id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}
-(id)init{
    self = [super init];
    if(self){
        self.imgDict = [[NSMutableDictionary alloc]init];
    }
    return  self;
}
@end
