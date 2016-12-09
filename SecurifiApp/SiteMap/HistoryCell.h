//
//  HistoryCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *webImg;//temp
@property (weak, nonatomic) IBOutlet UIImageView *categoryImg;
@property (weak, nonatomic) IBOutlet UILabel *siteName;//temp
@property (weak, nonatomic) IBOutlet UILabel *lastActTime;//temp
@property (weak, nonatomic) IBOutlet UIImageView *settingImg;//temp
@property (nonatomic) NSString *httpString;
@property (nonatomic) BOOL is_IotType;

//-(void)setCell:(NSDictionary*)uri hideItem:(BOOL)hideItem;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImg;
-(void)setCell:(NSDictionary*)uri hideItem:(BOOL)hideItem isCategory:(BOOL)isCategory showTime :(BOOL)showTime count:(NSInteger)count hideCheckMarkIMg:(BOOL)hideCheckImg;
@end
