//
//  SortView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SortViewDelegate <NSObject>
- (void)onCloseBtnTapDelegate;
- (void)onAddAlmondTapDelegate;
- (void)onAlmondSelectedDelegate:(SFIAlmondPlus *)almond;
@end
@interface SortView : UITableView
@property (nonatomic, weak)id<SortViewDelegate> methodsDelegate;
- (void)initializeView:(CGRect)maskFrame:(NSArray *)filterList SortType:(NSDictionary *)dict;
@end
