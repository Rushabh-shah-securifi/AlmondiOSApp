//
//  SearchTableViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 27/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericParams.h"
@interface SearchTableViewController : UITableViewController
@property (nonatomic) NSMutableDictionary *urlToImageDict;
@property (nonatomic) Client *client;
@end
