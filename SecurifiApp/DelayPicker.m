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
const int pickerRangeHeight = 108; //here are only three valid heights for UIPickerView (162.0, 180.0 and 216.0).
const int pickerSpacing = 5;

const int pickerRowHeight = 50;
const int pickerRowWidth = 30;
const int rowFontSize = 19;
const int lableFontSize = 15;

NSMutableArray * pickerMinsRange;
NSMutableArray *pickerSecsRange;
UIView * actionSheet;

PreDelayRuleButton *ruleButton;
int delaySecs;
int secs;
int mins;

-(void)addPickerForButton:(UIButton*)delayButton{
    delayButton.selected = !delayButton.selected;
    ruleButton = (PreDelayRuleButton *)[delayButton superview];
    
    if(delayButton.selected){
        if(self.isPresentDelayPicker){
            [self removeDelayView];
            
        }
        delayButton.backgroundColor = [SFIColors ruleLightOrangeColor];
        (ruleButton->actionbutton).userInteractionEnabled = NO;
        self.deviceIndexButtonScrollView.userInteractionEnabled = NO;
        
        delaySecs = [ruleButton.subProperties.delay intValue];
        
        pickerMinsRange = [[NSMutableArray alloc]init];
        pickerSecsRange = [[NSMutableArray alloc]init];
        for (int i = 0; i <= 4; i++) {
            [pickerMinsRange addObject:[NSString stringWithFormat:@"%d",i]];
        }
        for (int i = 0; i <= 59; i++) {
            [pickerSecsRange addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self setupPicker];
        self.isPresentDelayPicker = YES;
    }else{
        [self removeDelayView];
        delayButton.backgroundColor = [SFIColors ruleOrangeColor];
        self.deviceIndexButtonScrollView.userInteractionEnabled = YES;
        (ruleButton->actionbutton).userInteractionEnabled = YES;
        delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
        [delayButton setBackgroundColor:[UIColor colorFromHexString:@"FF9500"]];
        ruleButton.subProperties.delay = [NSString stringWithFormat:@"%d", [self getDelay]];
        
    }
}

- (void)setupPicker {
    int scrollViewY = self.triggersActionsScrollView.frame.origin.y + self.triggersActionsScrollView.bounds.size.height;
    
    UIPickerView *pickerRange = [self createPickerView:CGRectMake(lableWidth + pickerSpacing, 0, pickerRangeWidth, pickerRangeHeight*2)];
    [self transformPickerView:pickerRange];
    //    pickerRange.backgroundColor = [UIColor orangeColor];
    mins = (int)[self getMinsRow];
    secs = (int)[self getSecsRow];
    [pickerRange selectRow:[self getMinsRow] inComponent:0 animated:YES];
    [pickerRange selectRow:[self getSecsRow] inComponent:1 animated:YES];
    
    actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, scrollViewY, self.parentView.frame.size.width, pickerRangeHeight)];
    actionSheet.backgroundColor = [UIColor whiteColor];
    
    UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2*lableWidth + pickerRangeWidth + 2*pickerSpacing, pickerRangeHeight)];
    
    UILabel *minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, subView.frame.size.height/2 - lableHeight/2, lableWidth,lableHeight)];
    minsLabel.textAlignment = NSTextAlignmentCenter;
    minsLabel.text = @"Mins";
    minsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:lableFontSize];
    
    UILabel *secsLabel = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth + pickerRangeWidth + 2*pickerSpacing, subView.frame.size.height/2 - lableHeight/2, lableWidth,lableHeight)];
    secsLabel.text = @"Secs";
    secsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:lableFontSize];
    secsLabel.textAlignment = NSTextAlignmentCenter;
    
    [subView addSubview:minsLabel];
    [subView addSubview:pickerRange];
    [subView addSubview:secsLabel];
    //    subView.backgroundColor = [UIColor yellowColor];
    
    [actionSheet addSubview:subView];
    subView.center = CGPointMake(actionSheet.bounds.size.width/2,
                                 actionSheet.bounds.size.height/2);
    [self.parentView addSubview:actionSheet];
}

-(void)transformPickerView:(UIPickerView *)pickerview{
    CGAffineTransform t0 = CGAffineTransformMakeTranslation (0, pickerview.bounds.size.height/2);
    CGAffineTransform s0 = CGAffineTransformMakeScale       (1.0, 0.5);
    CGAffineTransform t1 = CGAffineTransformMakeTranslation (0, -pickerview.bounds.size.height/2);
    pickerview.transform = CGAffineTransformConcat          (t0, CGAffineTransformConcat(s0, t1));
    //The above code change the height of picker view to half and re-position it to the exact (Left-x1, Top-y1) position.
}

-(int)getDelay{
    return secs + (mins * 60);
}


-(void)removeDelayView{
    for(UIView *view in [actionSheet subviews]){
        [view removeFromSuperview];
    }
    [actionSheet removeFromSuperview];
    self.isPresentDelayPicker = NO;
}

-(UIPickerView*)createPickerView:(CGRect)frame{
    UIPickerView *chPicker = [[UIPickerView alloc] init];
    chPicker.frame = frame;
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
    if(component == 0){
        return pickerMinsRange.count;
    }else{
        return pickerSecsRange.count;
    }
    return 0;
}

// Set the width of the component inside the picker
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerRowWidth;
}

// Item picked
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0){
        mins = [[pickerMinsRange objectAtIndex:row] intValue];
    }else{
        secs = [[pickerSecsRange objectAtIndex:row] intValue];
    }
    [ruleButton setNewValue:[NSString stringWithFormat:@"%d", [self getDelay]]];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSLog(@"viewforrow");
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerRowWidth, pickerRowHeight)];
    if(component == 0){
        lable.text = [pickerMinsRange objectAtIndex:row];
    }else{
        lable.text = [pickerSecsRange objectAtIndex:row];
    }
    lable.textAlignment = NSTextAlignmentCenter;
    lable.backgroundColor = [UIColor clearColor];
    lable.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:rowFontSize];
    return lable;
}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag!=1) {
//        actionSheet = nil;
//        //        [self invite:pickerSelectedIndex];
//    }
//}



@end