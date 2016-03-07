//
//  SFIWiFiDeviceTypeSelectionCell.h
//  Scenes
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFIWiFiDeviceTypeSelectionCell;

@protocol SFIWiFiDeviceTypeSelectionCellDelegate
- (void)btnSelectTypeTapped:(SFIWiFiDeviceTypeSelectionCell*)cell Info:(NSDictionary*)cellInfo;
@end

@interface SFIWiFiDeviceTypeSelectionCell : UITableViewCell

@property (weak) id<SFIWiFiDeviceTypeSelectionCellDelegate> delegate;
@property(nonatomic)NSDictionary * cellInfo;
- (void)createPropertyCell:(id)info;
-(void)setTypeLabe:(NSString *)typeLabel;
@end
