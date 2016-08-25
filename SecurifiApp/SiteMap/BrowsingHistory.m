//
//  BrowsingHistory.m
//  SecurifiApp
//
//  Created by Masood on 6/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "BrowsingHistory.h"
@interface BrowsingHistory ()
@property (nonatomic) NSMutableDictionary *urlToImageDict;
@property (nonatomic) NSMutableData *responseData;
@end
@implementation BrowsingHistory
-(void)getBrowserHistoryImages:(NSDictionary *)historyDict dispatchQueue:(dispatch_queue_t)imageDownloadQueue dayArr:(NSMutableArray *)dayArr{

    NSDictionary *dict1 = historyDict[@"Data"];
    for (NSString *dates in [dict1 allKeys]) {
        NSArray *alldayArr = dict1[dates];
        NSMutableArray *oneDayUri = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *uriDict in alldayArr)
            
            {
            dispatch_async(imageDownloadQueue,^(){
                [uriDict setObject:[self getImage:uriDict[@"hostName"]] forKey:@"image"];
            });
            [oneDayUri addObject:uriDict];
        }
        [dayArr addObject:oneDayUri];
        
    }
        [self.delegate reloadTable];
}
//
-(UIImage*)getImage:(NSString*)hostName{
    
    __block UIImage *img;
    if(self.urlToImageDict[hostName]){
        return self.urlToImageDict[hostName]; //todo: fetch locally upto 100 images.
    }else{
        

        __block NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", hostName];
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
        if(!img){
            iconUrl = [NSString stringWithFormat:@"https://%@/favicon.ico", hostName];
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
            
        }
        if(!img){
            img = [UIImage imageNamed:@"help-icon"];
        }
        self.urlToImageDict[hostName] = img;
        
        return img;
    }
}
@end
