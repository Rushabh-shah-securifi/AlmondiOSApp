//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import <UIKit/UIKit.h>

@class SFIColors;
@class SFISensorTableViewCell;
@class TemperatureView;

@protocol SFISensorTableViewCellDelegate

- (void)tableViewCellDidClickDevice:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidPressSettings:(SFISensorTableViewCell*)cell;

- (void)tableViewCellWillStartMakingChanges:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidCompleteMakingChanges:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidCancelMakingChanges:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidSaveChanges:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidPressShowLogs:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidDismissTamper:(SFISensorTableViewCell*)cell;

- (void)tableViewCellDidChangeValue:(SFISensorTableViewCell*)cell propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString*)newValue;
- (void)tableViewCellDidChangeValue:(SFISensorTableViewCell*)cell propertyName:(NSString*)propertyName newValue:(NSString*)newValue;

- (void)tableViewCellDidDidFailValidation:(SFISensorTableViewCell *)cell validationToast:(NSString *)toastMsg;

- (void)tableViewCell:(SFISensorTableViewCell *)cell setValue:(id)value forKey:(NSString *)key;

- (id)tableViewCell:(SFISensorTableViewCell *)cell valueForKey:(NSString *)key;

- (BOOL)tableViewCellNotificationsEnabled;

- (void)tableViewCellDidChangeNotificationSetting:(SFISensorTableViewCell *)cell newMode:(SFINotificationMode)mode;

@end


@interface SFISensorTableViewCell : UITableViewCell

@property (weak) id<SFISensorTableViewCellDelegate> delegate;

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) UIColor *cellColor;
@property(nonatomic, getter=isExpandedView) BOOL expandedView;

// Makes the cell show a message and icon indicating the sensor is being updated
- (void)showUpdatingMessage;

// Sets a status message that will be shown in lieu of the normal sensor status.
// Used to indicate, for example, that the sensor is being updated or failed to be updated.
// Call this method then call markWillReuseCell:YES
- (void)markStatusMessage:(NSString *)status;

// Called by the table view delegate prior to returning it to the controller
// Resets the view and prepares it for viewing.
// updating parameter YES forces the cell to show "updating" status message
- (void)markWillReuseCell:(BOOL)updating;

- (NSString*)deviceName;
- (NSString*)deviceLocation;

@end