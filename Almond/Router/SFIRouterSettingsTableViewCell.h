//
//  SFIRouterSettingsTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"

@class SFIWirelessSetting;

@interface SFIRouterSettingsTableViewCell : SFICardTableViewCell

@property (nonatomic) SFIWirelessSetting *setting;

@end
