//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import <UIKit/UIKit.h>

@class SFIColors;
@class SFISensorTableViewCell;

@protocol SFISensorTableViewCellDelegate

- (void)tableViewCellDidClickDevice:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidPressSettings:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidSaveChanges:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidDismissTamper:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidChangeValue:(SFISensorTableViewCell*)cell propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString*)newValue;

@end


@interface SFISensorTableViewCell : UITableViewCell

@property (weak) id<SFISensorTableViewCellDelegate> delegate;

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) SFIColors *deviceColor;

- (void)markWillReuse;

- (NSString*)deviceName;
- (NSString*)deviceLocation;

@end