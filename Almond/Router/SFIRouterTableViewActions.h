//
//  SFIRouterTableViewActions.h
//
//  Created by sinclair on 11/11/14.
//
#import <Foundation/Foundation.h>

// Delegate protocol adopted by the SFIRouterTableViewController and used to communicate UI actions from the table view cells.
@protocol SFIRouterTableViewActions <NSObject>

- (void)onRebootRouterActionCalled;

@end