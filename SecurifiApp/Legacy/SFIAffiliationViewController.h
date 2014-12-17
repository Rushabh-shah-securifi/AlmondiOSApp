//
//  SFIAffiliationViewController.h
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/29/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIAffiliationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblEnterMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblHooray;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSSID;
@property (weak, nonatomic) IBOutlet UILabel *lblMAC;
@property (weak, nonatomic) IBOutlet UILabel *lblNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSSIDTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMACTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine1;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine2;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine3;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine4;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine5;
@property (weak, nonatomic) IBOutlet UITextField *txtAffiliationCode;
@property (weak, nonatomic) IBOutlet UIButton *btnAffiliationCode;

- (IBAction)sendAffiliationCode:(id)sender;
- (IBAction)cancelButtonHandler:(id)sender;

@end
