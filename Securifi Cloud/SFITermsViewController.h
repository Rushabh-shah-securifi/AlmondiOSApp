//
//  SFITermsViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 24/02/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFITermsViewController;

@protocol SFITermsViewControllerDelegate
- (void)termsViewControllerDidDismiss:(SFITermsViewController *)ctrl userAcceptedLicense:(BOOL)didAccept;
@end


@interface SFITermsViewController : UIViewController

@property (weak) id<SFITermsViewControllerDelegate> delegate;

@end
