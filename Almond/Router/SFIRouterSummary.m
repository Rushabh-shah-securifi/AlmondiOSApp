//
//  SFIRouterSummary.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIRouterSummary.h"
#import "SFIWirelessSetting.h"
#import "SFIWirelessSummary.h"

@interface SFIRouterSummary ()
@property(nonatomic, strong) NSMutableDictionary *summaryBySsid;
@end

@implementation SFIRouterSummary

- (void)setWirelessSummaries:(NSArray *)wirelessSummaries {
    _wirelessSummaries = wirelessSummaries;

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (SFIWirelessSummary *summary in wirelessSummaries) {
        NSString *key = summary.ssid;

        if (key != nil) {
            dict[key] = summary;
        }
    }

    self.summaryBySsid = dict;
}

- (SFIWirelessSummary *)summaryFor:(NSString *)ssid {
    if (ssid == nil) {
        return nil;
    }

    return self.summaryBySsid[ssid];
}


@end
