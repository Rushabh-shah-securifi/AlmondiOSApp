//
//  WeatherPicker.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 13/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "WeatherPicker.h"

@interface WeatherPicker () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic)UIView *maskView;
@property (nonatomic)UIPickerView *providerPickerView;
@property (nonatomic)UIToolbar *providerToolbar;
@property (nonatomic)NSNumber *amount;


@end

@implementation WeatherPicker
//-(instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if(self){
//    
//    }
//    return self;
//}
//- (void)layoutSubviews{
//    _providerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    _providerPickerView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
//    _providerPickerView.showsSelectionIndicator = YES;
//    _providerPickerView.dataSource = self;
//    _providerPickerView.delegate = self;
//    _providerPickerView.center = CGPointMake(CGRectGetMidX(self.bounds), _providerPickerView.center.y);//CGPointMake(CGRectGetMidX(self.scrollView.bounds), saveButton.center.y);
//    [self addSubview:_providerPickerView];
//    
//}
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 3;
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
//    return 20;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return 3;
//}
//
//// Set the width of the component inside the picker
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    return 60;
//}
//
// Item picked
//- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    if(component == 0){
//        mins = [[pickerMinsRange objectAtIndex:row] intValue];
//    }else{
//        secs = [[pickerSecsRange objectAtIndex:row] intValue];
//    }
//    [ruleButton setNewValue:[NSString stringWithFormat:@"%d", [self getDelay]]];
//}


//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    NSLog(@"viewforrow");
//    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
//    if(component == 0){
//        lable.text = @"123";
//    }else{
//        lable.text = @"abc";
//    }
//    lable.textAlignment = NSTextAlignmentCenter;
//    lable.backgroundColor = [UIColor clearColor];
//    lable.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:12];
//    return lable;
//}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return @"abc";
//}


- (void) createPickerView {
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.parentView.bounds.size.width, self.parentView.bounds.size.height)];
    [_maskView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    
    [self.parentView addSubview:_maskView];
    _providerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.parentView.bounds.size.height - 344, self.parentView.bounds.size.width, 44)];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissActionSheet:)];
    _providerToolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done];
    _providerToolbar.barStyle = UIBarStyleBlackOpaque;
    [self.parentView addSubview:_providerToolbar];
    
    _providerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.parentView.bounds.size.height - 300, 0, 0)];
    _providerPickerView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    _providerPickerView.showsSelectionIndicator = YES;
    _providerPickerView.dataSource = self;
    _providerPickerView.delegate = self;
    
    [self.parentView addSubview:_providerPickerView];
}

- (void)dismissActionSheet:(id)sender{
    [_maskView removeFromSuperview];
    [_providerPickerView removeFromSuperview];
    [_providerToolbar removeFromSuperview];
}

- (NSString*)getNominalFromRow:(NSInteger)row{
    NSString *nominal = @"";
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [numberFormatter setGroupingSeparator:@"."];
    nominal = [numberFormatter stringFromNumber:@(100000 * row + 100000)];
    
    return nominal;
}

#pragma mark UIPickerView Delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1500000 / 100000;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self getNominalFromRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _amount = [NSNumber numberWithLong:100000 * row + 100000];
}

@end
