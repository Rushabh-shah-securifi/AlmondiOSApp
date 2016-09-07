//
//  AlmondSelectionTableView.h
//  SecurifiApp
//
//  Created by Masood on 9/6/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlmondSelectionTableViewDelegate <NSObject>
- (void)onCloseBtnTapDelegate;
- (void)onAddAlmondTapDelegate;
- (void)onAlmondSelectedDelegate:(SFIAlmondPlus *)almond;
@end

@interface AlmondSelectionTableView : UITableView
@property (nonatomic, weak)id<AlmondSelectionTableViewDelegate> methodsDelegate;
-(void)initializeView:(CGRect)maskFrame;
@end
