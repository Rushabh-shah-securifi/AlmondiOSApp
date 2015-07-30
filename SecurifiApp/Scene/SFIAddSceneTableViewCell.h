//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import <UIKit/UIKit.h>

@class SFIColors;
@class SFIAddSceneTableViewCell;

@protocol SFIAddSceneTableViewCellDelegate

- (void)tableViewCellValueDidChange:(SFIAddSceneTableViewCell*)cell CellInfo:(NSDictionary*)cellInfo Index:(int)index Value:(NSString*)value;

- (void)btnDimDidTap:(SFIAddSceneTableViewCell*)cell CellInfo:(NSDictionary*)cellInfo Index:(int)index Value:(NSString*)value PickerValueArray:(NSArray*)pickerValueArray;

- (void)sceneNameDidChange:(SFIAddSceneTableViewCell*)cell SceneName:(NSString*)name ActiveField:(UITextField*)textField;

- (void)deleteSceneDidTapped:(SFIAddSceneTableViewCell*)cell;


//- (void)tableViewCellDidClickDevice:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellDidPressSettings:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellWillStartMakingChanges:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellDidCompleteMakingChanges:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellDidCancelMakingChanges:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellDidSaveChanges:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellDidDismissTamper:(SFIAddSceneTableViewCell*)cell;
//
//- (void)tableViewCellDidChangeValue:(SFIAddSceneTableViewCell*)cell propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString*)newValue;
//- (void)tableViewCellDidChangeValue:(SFIAddSceneTableViewCell*)cell propertyName:(NSString*)propertyName newValue:(NSString*)newValue;
//
//- (void)tableViewCellDidDidFailValidation:(SFIAddSceneTableViewCell *)cell validationToast:(NSString *)toastMsg;
//
//- (void)tableViewCell:(SFIAddSceneTableViewCell *)cell setValue:(id)value forKey:(NSString *)key;
//
//- (id)tableViewCell:(SFIAddSceneTableViewCell *)cell valueForKey:(NSString *)key;
//
//- (BOOL)tableViewCellNotificationsEnabled;
//
//- (void)tableViewCellDidChangeNotificationSetting:(SFIAddSceneTableViewCell *)cell newMode:(SFINotificationMode)mode;
//
@end


@interface SFIAddSceneTableViewCell : UITableViewCell

@property (weak) id<SFIAddSceneTableViewCellDelegate> delegate;

@property(assign)BOOL isSceneProperiesCell;
@property(assign)BOOL showDeleteButton;
@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) UIColor *cellColor;
@property(nonatomic) NSDictionary *cellInfo;
@property(nonatomic, getter=isExpandedView) BOOL expandedView;
@property(nonatomic)UIViewController * parentViewController;
@property(nonatomic)NSString *sceneName;

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