//
//  SortTypeView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SortTypeViewDelegate <NSObject>
-(void)onTypeSelection:(id)sender;
@end
@interface SortTypeView : UIView
@property (nonatomic) NSDictionary *sortTypeDict;
@property (nonatomic)id<SortTypeViewDelegate> delegate;
-(id)initWithFrame:(CGRect)frame sortType:(NSDictionary *)sortTypeDict buttonTag:(NSInteger)buttonTag;
@end
