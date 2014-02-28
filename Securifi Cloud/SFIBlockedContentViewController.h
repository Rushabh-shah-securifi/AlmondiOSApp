//
//  SFIBlockedContentViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIBlockedContentViewController : UITableViewController
@property (nonatomic, retain) NSMutableArray *blockedContentArray;
@property (nonatomic, retain) NSMutableArray *addBlockedContentArray;
@property (nonatomic, retain) NSMutableArray *setBlockedContentArray;
@property unsigned int mobileInternalIndex;
@property (nonatomic, retain)UITextField* txtBlockedText;
@property (nonatomic, retain) NSString* actionType;
@end
