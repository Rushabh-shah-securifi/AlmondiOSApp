//
//  HistoryParser.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 15/07/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryParser : NSObject
@property (nonatomic) NSMutableArray *browsingHistoryDayWise;
-(void)getBrowserHistoryImages;
-(void)insertInToDB:(NSString *)fileName;
-(void)deletePrevious:(NSString *)fileName;
@end
