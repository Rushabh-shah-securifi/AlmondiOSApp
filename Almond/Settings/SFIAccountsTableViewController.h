//
//  SFIAccountsTableViewController.h
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIUserProfile.h"

@class MBProgressHUD;

@class SFIAccountsTableViewController;

@protocol SFIAccountDeleteDelegate

- (void)userAccountDidDelete:(SFIAccountsTableViewController*)ctrl;
- (void)userAccountDidDone:(SFIAccountsTableViewController *)ctrl;

@end

@interface SFIAccountsTableViewController : UITableViewController <UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, retain) NSMutableArray *ownedAlmondList;
@property (nonatomic, retain) NSMutableArray *sharedAlmondList;
@property (nonatomic, retain) SFIUserProfile *userProfile;

@property (nonatomic, retain) NSString *changedFirstName;
@property (nonatomic, retain) NSString *changedLastName;
@property (nonatomic, retain) NSString *changedAddress1;
@property (nonatomic, retain) NSString *changedAddress2;
@property (nonatomic, retain) NSString *changedAddress3;
@property (nonatomic, retain) NSString *changedCountry;
@property (nonatomic, retain) NSString *changedZipcode;
@property (nonatomic, retain) NSString *changedAlmondName;
@property (nonatomic, retain) NSString *currentAlmondMAC;
@property (nonatomic, retain) NSString *changedEmailID;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property(nonatomic, readonly)UITextField *tfFirstName;
@property(nonatomic, readonly)UITextField *tfLastName;
@property(nonatomic, readonly)UITextField *tfAddress1;
@property(nonatomic, readonly)UITextField *tfAddress2;
@property(nonatomic, readonly)UITextField *tfAddress3;
@property(nonatomic, readonly)UITextField *tfCountry;
@property(nonatomic, readonly)UITextField *tfZipCode;
@property(nonatomic, readonly)UITextField *tfRenameAlmond;

@property(weak, nonatomic) id<SFIAccountDeleteDelegate> delegate;

@property (nonatomic) int nameChangedForAlmond;
@property NSTimer *almondNameChangeTimer;
@property BOOL isAlmondNameChangeSuccessful;

- (IBAction)doneButtonHandler:(id)sender;
@end
