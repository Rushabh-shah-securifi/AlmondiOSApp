//
//  CollectionViewCell.h
//  GridViewTest
//
//  Created by Masood on 27/01/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
//@property (strong, nonatomic) IBOutlet UILabel *dayTimeLable;
@property (nonatomic) UILabel *dayLabel;
-(void)addDayTimeLable:(NSIndexPath *)indexPath isSelected:(NSString*)selected;
-(void)handleCornerCells;
-(void)setlabel;
@end
