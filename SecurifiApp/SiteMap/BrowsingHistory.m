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

@end
@implementation BrowsingHistory
-(void)getBrowserHistoryImages:(NSDictionary *)historyDict dispatchQueue:(dispatch_queue_t)imageDownloadQueue dayArr:(NSMutableArray *)dayArr imageDict:(NSMutableDictionary*)uriToImgDict{



    NSDictionary *dict1 = historyDict[@"Data"];
    for (NSString *dates in [dict1 allKeys]) {
        NSArray *alldayArr = dict1[dates];
        NSMutableArray *oneDayUri = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *uriDict in alldayArr)
            
            {
//            dispatch_async(imageDownloadQueue,^(){
                [uriDict setObject:[self getImage:uriDict[@"hostName"] imageDict:uriToImgDict dispatchQueue:imageDownloadQueue] forKey:@"image"];
                NSLog(@"downloading img...uriDict = %@",uriDict);
                 [self.delegate reloadTable];
//            });
            [oneDayUri addObject:uriDict];
        }
        [dayArr addObject:oneDayUri];
        
    }
    
}
//
-(UIImage*)getImage:(NSString*)hostName imageDict:(NSMutableDictionary*)uriToImgDic2t dispatchQueue:(dispatch_queue_t)imageDownloadQueue{
    UrlImgDict *imgDicts = [UrlImgDict sharedInstance];
    NSLog(@"imgDict:: %@ , hostName = %@, dict = %@",imgDicts.imgDict[hostName],hostName,imgDicts);
    __block UIImage *img;
    if(imgDicts.imgDict[hostName]){
        NSLog(@"returning with image ");
        
        return imgDicts.imgDict[hostName]; //todo: fetch locally upto 100 images.
    }else{
        

        __block NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", hostName];
        dispatch_async(imageDownloadQueue,^(){
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
           
        });
        if(!img){
            iconUrl = [NSString stringWithFormat:@"https://%@/favicon.ico", hostName];
            dispatch_async(imageDownloadQueue,^(){
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
               
             });
        }
        if(!img){
            img = [UIImage imageNamed:@"help-icon"];
        }
        [imgDicts.imgDict setObject:img forKey:hostName];
//        _urlToImageDict[hostName] = img;
        return img;
    }
}
@end
