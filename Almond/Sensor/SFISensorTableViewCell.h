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

// called to indicate that the device/device value is being updated with the cloud;
// causes the view to show intermediate "updating" state
- (void)showUpdatingDeviceValuesStatus;

// Called by the table view delegate prior to returning it to the controller
// Resets the view and prepares it for viewing.
// updating parameter YES forces the cell to show "updating" message
- (void)markWillReuseCell:(BOOL)updating;

- (NSString*)deviceName;
- (NSString*)deviceLocation;

@end