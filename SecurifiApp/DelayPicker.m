//
//  DelayPicker.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 22/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DelayPicker.h"
#import "RulesConstants.h"
#import "PreDelayRuleButton.h"
#import "SFIColors.h"
#import "Colours.h"

@interface DelayPicker()<UIPickerViewDelegate,UIPickerViewDataSource>
@end

@implementation DelayPicker
const int lableWidth = 50;
const int lableHeight = 20;
const int pickerRangeWidth = 100;
const int pickerRangeHeight = 80;
const int pickerSpacing = 5;

const int pickerRowHeight = 20;
const int pickerRowWidth = 30;

NSMutableArray * pickerMinsRange;
NSMutableArray *pickerSecsRange;
UIView * actionSheet;
int delaySecs;
int secs;
int mins;


- (void)setupPicker:(AddRulesViewController*)parentController {
    NSLog(@"picker view called");
    int scrollViewY = parentController.triggersActionsScrollView.frame.origin.y + parentController.triggersActionsScrollView.bounds.size.height;
    
    UIPickerView *pickerRange = [self createPickerView:CGRectMake(lableWidth + pickerSpacing, 0, pickerRangeWidth, pickerRangeHeight)];
    mins = (int)[self getMinsRow];
    secs = (int)[self getSecsRow];
    [pickerRange selectRow:[self getMinsRow] inComponent:0 animated:YES];
    [pickerRange selectRow:[self getSecsRow] inComponent:1 animated:YES];
    
    actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, scrollViewY, parentController.view.frame.size.width, pickerRangeHeight)];
    actionSheet.backgroundColor = [UIColor whiteColor];
    
    UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2*lableWidth + pickerRangeWidth + 2*pickerSpacing, pickerRangeHeight)];
    //    subView.backgroundColor = [UIColor whiteColor];
    
    UILabel *minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, subView.frame.size.height/2 - lableHeight/2, lableWidth,lableHeight)];
    minsLabel.textAlignment = NSTextAlignmentCenter;
    minsLabel.text = @"Mins";
    minsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    
    UILabel *secsLabel = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth + pickerRangeWidth + 2*pickerSpacing, subView.frame.size.height/2 - lableHeight/2, lableWidth,lableHeight)];
    secsLabel.text = @"Secs";
    secsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    secsLabel.textAlignment = NSTextAlignmentCenter;
    
    [subView addSubview:minsLabel];
    [subView addSubview:pickerRange];
    [subView addSubview:secsLabel];
    //    subView.backgroundColor = [UIColor yellowColor];
    
    [actionSheet addSubview:subView];
    subView.center = CGPointMake(actionSheet.bounds.size.width/2,
                                 actionSheet.bounds.size.height/2);
    [parentController.view addSubview:actionSheet];
}

-(void)addPickerForButton:(UIButton*)delayButton parentController:(AddRulesViewController*)parentController{
    delayButton.selected = !delayButton.selected;
    PreDelayRuleButton *ruleButton = (PreDelayRuleButton *)[delayButton superview];
    delaySecs = [ruleButton.subProperties.delay intValue];
    if(delayButton.selected){
        pickerMinsRange = [[NSMutableArray alloc]init];
        pickerSecsRange = [[NSMutableArray alloc]init];
        for (int i = 0; i <= 4; i++) {
            [pickerMinsRange addObject:[NSString stringWithFormat:@"%d",i]];
        }
        for (int i = 0; i <= 59; i++) {
            [pickerSecsRange addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self setupPicker:parentController];
    }else{
        [self removeDelayView];
        delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
        [delayButton setBackgroundColor:[UIColor colorFromHexString:@"FF9500"]];
        ruleButton.subProperties.delay = [NSString stringWithFormat:@"%d", [self getDelay]];
        [ruleButton setNewValue:[NSString stringWithFormat:@"%d", [self getDelay]]];
        //        [self.delegate updateActionsArray:self.rule.actions andDeviceIndexesForId:rulesButtonViewClick.subProperties.deviceId];
    }
}

-(int)getDelay{
    return secs + (mins * 60);
}


-(void)removeDelayView{
    //    if(actionSheet != nil){ //todo
    NSLog(@"removeDelayView");
    [UIView animateWithDuration:0.3 animations:^{
        actionSheet.alpha = 1;
    }completion:^(BOOL finished) {
        [actionSheet removeFromSuperview];
        //            actionSheet = nil;
    }];
    //    }
}

-(UIPickerView*)createPickerView:(CGRect)frame{
    UIPickerView *chPicker = [[UIPickerView alloc] initWithFrame:frame];
    chPicker.dataSource = self;
    chPicker.delegate = self;
    chPicker.showsSelectionIndicator = NO;
    chPicker.backgroundColor = [UIColor whiteColor];
    return chPicker;
}

-(NSInteger)getSecsRow{
    int secsRow = 0;
    if(delaySecs <= 59){
        secsRow = delaySecs;
    }else if(delaySecs >= 60 && secs <= 3599){
        secsRow = delaySecs % 60;
    }
    return @(secsRow).integerValue;
}

-(NSInteger)getMinsRow{
    int minsRow = 0;
    if(delaySecs <= 59){
        minsRow = 0;
    }
    else if(delaySecs >= 60 && delaySecs <= 3599){
        minsRow = delaySecs/60;
    }
    else{
        minsRow = delaySecs/3600;
    }
    return @(minsRow).integerValue;
}


#pragma mark UIPickerViewDelegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return pickerRowHeight;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSLog(@"numberOfRowsInComponent");
    if(component == 0){
        return pickerMinsRange.count;
    }else{
        return pickerSecsRange.count;
    }
    return 0;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSLog(@"title for row");
//    if(component == 0){
//        return [pickerMinsRange objectAtIndex:row];
//    }else{
//        return [pickerSecsRange objectAtIndex:row];
//    }
//    return @"";
//}

// Set the width of the component inside the picker
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    NSLog(@"widthForComponent");
    return pickerRowWidth;
}

// Item picked
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0){
        mins = [[pickerMinsRange objectAtIndex:row] intValue];
    }else{
        secs = [[pickerSecsRange objectAtIndex:row] intValue];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSLog(@"viewforrow");
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    if(component == 0){
        label.text = [pickerMinsRange objectAtIndex:row];
    }else{
        label.text = [pickerSecsRange objectAtIndex:row];
    }
    label.textAlignment = NSTextAlignmentCenter; //Changed to NS as UI is deprecated.
    label.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    return label;
}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag!=1) {
//        actionSheet = nil;
//        //        [self invite:pickerSelectedIndex];
//    }
//}



@end
