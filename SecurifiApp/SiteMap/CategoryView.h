//
//  CategoryView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CategoryViewDelegate
-(void )didChangeCategoryWithTag:(NSInteger)tag;
-(void)closeMoreView;
@end
@interface CategoryView : UIView
@property (nonatomic)id<CategoryViewDelegate> delegate;
- (id)initMoreClickView;
@end
