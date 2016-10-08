//
//  BrowsingHistory.m
//  SecurifiApp
//
//  Created by Masood on 6/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "BrowsingHistory.h"
#import "UrlImgDict.h"
@interface BrowsingHistory ()
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSMutableDictionary *urlToImageDict;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;

@end
@implementation BrowsingHistory

-(void)getBrowserHistoryImages:(NSDictionary *)historyDict dispatchQueue:(dispatch_queue_t)imageDownloadQueue dayArr:(NSMutableArray *)dayArr{
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    NSDictionary *dict1 = historyDict[@"Data"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSMutableArray *dateArr = [NSMutableArray new];
    for (NSString *dates in [dict1 allKeys]){
    NSDate *date = [dateFormat dateFromString:dates];
        [dateArr addObject:date];
    }
    NSArray *sortedArray = [dateArr sortedArrayUsingComparator: ^(NSDate *d1, NSDate *d2) {
        return [d2 compare:d1];
    }];
    [dateArr removeAllObjects];
    for(NSDate *date in sortedArray){
    NSString *string = [dateFormat stringFromDate:date];
        [dateArr addObject:string];
    }
    for (NSString *dates in dateArr) {
        NSArray *alldayArr = dict1[dates];
        NSMutableArray *oneDayUri = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *uriDict in alldayArr)
            
            {
            dispatch_async(self.imageDownloadQueue,^(){
                [uriDict setObject:[self getImage:uriDict[@"hostName"] dispatchQueue:imageDownloadQueue] forKey:@"image"];
                 [self.delegate reloadTable];
            });
            [oneDayUri addObject:uriDict];
        }
        [dayArr addObject:oneDayUri];
        
    }
    
}
//
-(UIImage*)getImage:(NSString*)hostName dispatchQueue:(dispatch_queue_t)imageDownloadQueue{
    UrlImgDict *imgDicts = [UrlImgDict sharedInstance];
    __block UIImage *img;
    if(imgDicts.imgDict[hostName]){
        
        return imgDicts.imgDict[hostName]; //todo: fetch locally upto 100 images.
    }else{
        

        __block NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", hostName];
//        dispatch_async(imageDownloadQueue,^(){
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
           
//        });
        if(!img){
            iconUrl = [NSString stringWithFormat:@"https://%@/favicon.ico", hostName];
//            dispatch_async(imageDownloadQueue,^(){
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
               
//             });
        }
        if(!img){
            img = [UIImage imageNamed:@"globe"];//globe
        }
        [imgDicts.imgDict setObject:img forKey:hostName];
//        _urlToImageDict[hostName] = img;
        return img;
    }
}
@end
