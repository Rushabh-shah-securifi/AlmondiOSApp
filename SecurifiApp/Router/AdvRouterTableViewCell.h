//
//  AdvRouterTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL @"Label"
#define VALUE @"Value"
#define CELL_TYPE @"CellType"
#define CELLS @"Cells"

typedef NS_ENUM(NSInteger, AdvCellType){
    Adv_LocalWebInterface,
    Adv_UPnP,
    Adv_AlmondScreenLock,
    Adv_DiagnosticSettings,
    Adv_Language,
    Adv_Help
};

@protocol  AdvRouterTableViewCellDelegate
- (void)onSwitchTapDelegate:(AdvCellType)type value:(BOOL)value;
- (void)onDoneTapDelegate:(AdvCellType)type value:(NSString *)values;
@end

@interface AdvRouterTableViewCell : UITableViewCell
@property (nonatomic, weak) id<AdvRouterTableViewCellDelegate> delegate;

- (void)setUpSection:(NSDictionary *)sectionDict  indexPath:(NSIndexPath *)indexPath;
@end
