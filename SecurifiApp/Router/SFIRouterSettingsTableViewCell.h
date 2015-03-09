//
//  SFIRouterSettingsTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"

@class SFIWirelessSetting;
@class SFIWirelessSummary;
@protocol SFIRouterTableViewActions;

@interface SFIRouterSettingsTableViewCell : SFICardTableViewCell

@property(weak) id <SFIRouterTableViewActions> delegate;
@property(nonatomic) SFIWirelessSetting *wirelessSetting;
@property(nonatomic) BOOL enableRouterWirelessControl;

@end
