//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import <Foundation/Foundation.h>

@class SFIColors;

@interface SFISensorTableViewCell : UITableViewCell

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) SFIColors *currentColor;

- (void)markWillReuse;

@end