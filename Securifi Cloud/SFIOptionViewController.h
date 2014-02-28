//
//  SFIOptionViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol wirelessOptionDelegate;

@interface SFIOptionViewController : UITableViewController
@property (nonatomic, retain) NSArray *optionList;
@property (nonatomic,retain) NSString *optionTitle;
@property unsigned int optionType;
@property (nonatomic, assign) id<wirelessOptionDelegate> selectedOptionDelegate;
@property (nonatomic,retain) NSString *currentOption;
@end

@protocol wirelessOptionDelegate
@optional
-(void)optionSelected:(NSString *)optionValue forOptionType:(unsigned int)optionType;

@end
