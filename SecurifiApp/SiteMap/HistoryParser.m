//
//  HistoryParser.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 15/07/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HistoryParser.h"
#import "NSDate+Convenience.h"
#import "DataBaseManager.h"
#import "URIData.h"
#import "BrowsingHistory.h"
#import "BrowsingHistoryDataBase.h"


@interface HistoryParser()

@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property (nonatomic) NSMutableDictionary *urlToImageDict;


@end
@implementation HistoryParser


-(void)getBrowserHistoryImages{
    NSLog(@"getBrowserHistoryImages");
    self.urlToImageDict = [NSMutableDictionary new];

    NSDictionary *historyData;
    
    historyData = [DataBaseManager getHistoryData];//first time reading from file

    NSLog(@"historyData: %@", historyData);
    self.browsingHistoryDayWise = [NSMutableArray new];
    NSArray *history = historyData[@"Data"];
    for(NSString *Day in [historyData allKeys]){
        BrowsingHistory *browsingHist = [BrowsingHistory new];
        browsingHist.date = [NSDate convertStirngToDate:Day];
        NSDictionary *dayDict = historyData[Day];
        NSMutableArray *urisArray = [NSMutableArray new];
        for (NSString *time in [dayDict allKeys]) {
            NSDictionary *uriDict = dayDict[time];
            URIData *uri = [URIData new];
            uri.hostName = uriDict[@"Hostname"];
            uri.image = [UIImage imageNamed:@"Mail_icon"];
            uri.lastActiveTime = [NSDate getDateFromEpoch:uriDict[@"Epoch"]];
            uri.count = [uriDict[@"Count"] intValue];
            [urisArray addObject:uri];
        }
        browsingHist.URIs = urisArray;
    [self.browsingHistoryDayWise addObject:browsingHist];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE_FETCH object:nil];
    }
    
    
}

-(UIImage*)getImage:(NSString*)hostName{
    NSLog(@"getImage");
    UIImage *img;
    if(self.urlToImageDict[hostName]){
        NSLog(@"one");
        return self.urlToImageDict[hostName]; //todo: fetch locally upto 100 images.
    }else{
        
        //        img = [UIImage imageNamed:@"Mail_icon"];
        
        NSLog(@"two");
        NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", hostName];
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
        if(!img){
            NSLog(@"three");
            iconUrl = [NSString stringWithFormat:@"https://%@/favicon.ico", hostName];
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
        }
        if(!img){
            NSLog(@"four");
            img = [UIImage imageNamed:@"Mail_icon"];
        }
        NSLog(@"five");
        self.urlToImageDict[hostName] = img;
        
        return img;
    }
}
-(void)deletePrevious:(NSString *)fileName{
    NSDictionary *historyData;
    historyData = [self parseJson:fileName];// inserting parser data to database table
    NSDictionary *UpdatedDict = [self storeUptoLimit:[DataBaseManager getHistoryData] resDict:historyData];
    
    
//    [DataBaseManager deleteHistoryTable];//clear the previous data
    [DataBaseManager updateDB:@"2015/04/10" with:UpdatedDict];
    [DataBaseManager InsertRecords:UpdatedDict];
    [self getBrowserHistoryImages];
        

}
-(void)insertInToDB:(NSString *)fileName{
    NSDictionary *historyData;
    historyData = [self parseJson:fileName];// inserting parser data to database table
//    NSDictionary *latestSict = [self storeUptoLimit:[DataBaseManager getHistoryData] resDict:historyData];
    
    [DataBaseManager InsertRecords:[self insertDbAboveTimeresDict:historyData]];//checking just above time epoch
    
    [self getBrowserHistoryImages];
}

- (NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}
-(NSDictionary *)insertDbAboveTimeresDict:(NSDictionary*)resDict{
    
    NSMutableDictionary *toBeStoreDict = [[NSMutableDictionary alloc]init];
    int count = 0;
    for(NSString *Day in [resDict allKeys]){
        NSMutableDictionary *dayD = [NSMutableDictionary new];
        NSDictionary *dayDict = resDict[Day];
        for (NSString *time in [dayDict allKeys]) {
            if(time.integerValue >= 1428217666){
                NSDictionary *uriDict = dayDict[time];
                [dayD setObject:uriDict forKey:time];
                [toBeStoreDict setObject:dayD forKey:Day];
                count++;
            }
            else{
                
            }
        }
    }
    return toBeStoreDict;
}
// these method will store resData + dbData upto limited number
-(NSDictionary *)storeUptoLimit:(NSDictionary *)dbDict resDict:(NSDictionary*)resDict {
//   resDict = [self parseJson:@"response2"];
    
    NSMutableDictionary *toBeStoreDict = [[NSMutableDictionary alloc]init];
    int count = 0;
    for(NSString *Day in [resDict allKeys]){
        NSMutableDictionary *dayD = [NSMutableDictionary new];
        NSDictionary *dayDict = resDict[Day];
        for (NSString *time in [dayDict allKeys]) {
            
            if(count <= 250 /*&& time.integerValue >= 1428217666*/){
                NSDictionary *uriDict = dayDict[time];
                [dayD setObject:uriDict forKey:time];
                [toBeStoreDict setObject:dayD forKey:Day];
                count++;
            }
            else{
                // delete Db
                break;
            }
        }
    }
    for(NSString *Day in [dbDict allKeys]){
        NSMutableDictionary *dayD = [NSMutableDictionary new];
        NSDictionary *dayDict = dbDict[Day];
        for (NSString *time in [dayDict allKeys]) {
            
            if(count <= 250){
                NSDictionary *uriDict = dayDict[time];
                [dayD setObject:uriDict forKey:time];
                [toBeStoreDict setObject:dayD forKey:Day];
                count++;
            }
            else
                break;
        }
    }
   NSLog(@"tobestoreDict = %@ ,%ld",toBeStoreDict,[toBeStoreDict allKeys].count);
    return toBeStoreDict;
}

@end
