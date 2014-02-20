//
//  SFIMainViewController.h
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/30/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SFIDatabaseUpdateService.h"


@interface SFIMainViewController : UIViewController // : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate>
{
    MBProgressHUD               *HUD;
    SFIDatabaseUpdateService *databaseUpdateService;
} 
@property (nonatomic, retain) NSMutableArray *viewData;
@property NSInteger state;
@property (nonatomic, retain) IBOutlet UIImageView *imgSplash;
@property BOOL isConnectedToCloud;
@property NSTimer *displayNoCloudTimer;


- (IBAction)LogsButtonHandler:(id)sender;
@end
