//
//  CollectionViewCell.h
//  GridViewTest
//
//  Created by Masood on 27/01/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *dayTimeLable;
-(void)addDayTimeLable:(NSIndexPath *)indexPath;
@end
