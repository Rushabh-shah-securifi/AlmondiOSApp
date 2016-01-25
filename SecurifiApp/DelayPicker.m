//
//  DelayPicker.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 22/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DelayPicker.h"
#import "RulesConstants.h"
@interface DelayPicker()<UIPickerViewDelegate,UIPickerViewDataSource>
@end
@implementation DelayPicker

NSMutableArray * pickerMinsRange;
NSMutableArray *pickerSecsRange;
int delaySecs;
int secs;
int mins;

UIView * actionSheet;

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

- (void)setupPicker:(UIScrollView*)scrollView{
    NSLog(@"picker view called");
    int scrollViewHeight = 100;
    UIPickerView *pickerRange = [self createPickerView:CGRectMake(55, 0, 100, 100)];
    mins = (int)[self getMinsRow];
    secs = (int)[self getSecsRow];
    [pickerRange selectRow:[self getMinsRow] inComponent:0 animated:YES];
    [pickerRange selectRow:[self getSecsRow] inComponent:1 animated:YES];
    
    actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0,scrollViewHeight + 40, 200, 100)];
    actionSheet.backgroundColor = [UIColor whiteColor];
    //    actionSheet.backgroundColor = [UIColor grapeColor];
    UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 210, 100)];
    //    subView.backgroundColor = [UIColor grayColor];
    UILabel *minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, subView.frame.size.height/2 - textHeight/2, 50,textHeight)];
    minsLabel.textAlignment = NSTextAlignmentCenter;
    minsLabel.text = @"Mins";
    minsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    UILabel *secsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, subView.frame.size.height/2 - textHeight/2, 50,textHeight)];
    secsLabel.text = @"Secs";
    secsLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    secsLabel.textAlignment = NSTextAlignmentCenter;
    [subView addSubview:minsLabel];
    [subView addSubview:pickerRange];
    [subView addSubview:secsLabel];
    subView.backgroundColor = [UIColor yellowColor];
    [actionSheet addSubview:subView];
    subView.center = CGPointMake(actionSheet.bounds.size.width/2,
                                 actionSheet.bounds.size.height/2);
    
   [scrollView addSubview:actionSheet];
    
 
}

#pragma mark UIPickerViewDelegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 20;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return pickerMinsRange.count;
    }else{
        return pickerSecsRange.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"title for row");
    if(component == 0){
        return [pickerMinsRange objectAtIndex:row];
    }else{
        return [pickerSecsRange objectAtIndex:row];
    }
    return @"";
}

// Set the width of the component inside the picker
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    NSLog(@"widthForComponent");
    return 30;
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


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag!=1) {
        actionSheet = nil;
        //        [self invite:pickerSelectedIndex];
    }
}



@end
