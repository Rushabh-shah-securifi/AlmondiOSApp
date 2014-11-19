//
//  SFIRouterRebootTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardTableViewCell.h"

@protocol SFIRouterTableViewActions;

@interface SFIRouterRebootTableViewCell : SFICardTableViewCell

@property (weak) id<SFIRouterTableViewActions> delegate;


@end
