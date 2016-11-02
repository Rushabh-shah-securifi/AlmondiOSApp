//
//  BrowsingHistory.h
//  SecurifiApp
//
//  Created by Masood on 6/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol BrowsingHistoryDelegate
-(void)reloadTable;
@end
@interface BrowsingHistory : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSArray *URIs;
@property (nonatomic) NSString *almondMac;
@property (nonatomic) NSString *clientMac;
@property (nonatomic) NSMutableDictionary *allDateRecord;
@property (nonatomic,weak) id<BrowsingHistoryDelegate> delegate;
-(void)getBrowserHistoryImages:(NSDictionary *)historyDict dispatchQueue:(dispatch_queue_t)imageDownloadQueue dayArr:(NSMutableArray *)dayArr;

@end
