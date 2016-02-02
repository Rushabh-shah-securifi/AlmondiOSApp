//
//  RulesViewController.h
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RulesTimeElement.h"
#import "SecurifiToolkit/Rule.h"


@protocol AddRulesViewControllerDelegate

- (void)updateRulesWithTriggers:(NSArray*)triggerProperties andActions:(NSArray*)actionProperties withName:(NSString*)ruleName atIndexPath:(int)indexPathRow;
- (void)updateRule:(Rule*)rule atIndexPath:(int)indexPathRow;

@end


@interface AddRulesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containView;
@property (weak, nonatomic) IBOutlet UIScrollView *deviceListScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *deviceIndexButtonScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *triggersActionsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UITextField *ruleNameField;

@property (weak, nonatomic) IBOutlet UIView *TimeSectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeSegmentSelector;/*layer.borderWidth
                                                                              layer.borderUIColor                                                                    */
@property (weak, nonatomic) IBOutlet UIDatePicker *timerPikerPrecisely;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePikerBetween1;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePikerBetween2;
@property (weak, nonatomic) IBOutlet UILabel *andLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowerInformationLabel;
@property (weak, nonatomic) IBOutlet UIView *dayView;


//@property (nonatomic ,strong)NSMutableArray *deviceArray;
@property (nonatomic ,strong)NSMutableArray *deviceValueArray;

//@property (nonatomic,strong)NSMutableArray *actuatorDeviceArray;
@property (copy, nonatomic)Rule *rule;

@property (nonatomic ,strong)NSMutableArray *wifiClientsArray;


@property (nonatomic)BOOL isInitialized;
@property (nonatomic)int indexPathRow;
@property (nonatomic) id<AddRulesViewControllerDelegate> delegate;
-(void)redrawDeviceIndexView:(sfi_id)deviceId clientEvent:(NSString*)eventType;
@end
