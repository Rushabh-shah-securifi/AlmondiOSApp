//
//  SFIViewController.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableDictionary *data;
+ (UIImage*)scaleImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
