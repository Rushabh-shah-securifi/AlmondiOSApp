//
//  RulesViewController.h
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RulesTimeElement.h"
#import "Rule.h"

@interface AddRulesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *deviceListScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *deviceIndexButtonScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *triggersActionsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (nonatomic ,strong)NSMutableArray *deviceValueArray;
@property (copy, nonatomic)Rule *rule;

@property (nonatomic ,strong)NSMutableArray *wifiClientsArray;


@property (nonatomic)BOOL isInitialized;
@end