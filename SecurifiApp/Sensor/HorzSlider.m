//
//  HorzSlider.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HorzSlider.h"
#import "V8HorizontalPickerView.h"
#import "SFIColors.h"
#import "SFIPickerIndicatorView1.h"

@interface HorzSlider ()<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate>
@end

@implementation HorzSlider
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
    //    return self;
}
-(void)drawSlider{// it will take color
    //self.componentArray = [NSMutableArray new];
    V8HorizontalPickerView *horzPicker = [[V8HorizontalPickerView alloc]initWithFrame:self.frame];
//    horzPicker.layer.cornerRadius = 4;
//    horzPicker.layer.borderWidth = 1.5;
    horzPicker.backgroundColor = [UIColor whiteColor];
//    horzPicker.layer.borderColor = [SFIColors clientGreenColor].CGColor;
    horzPicker.selectedTextColor = self.color;
    horzPicker.elementFont = [UIFont systemFontOfSize:11];
    horzPicker.elementFont = [UIFont fontWithName:@"AvenirLTStd-Roman" size:11];
    horzPicker.textColor = self.color;
    horzPicker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    horzPicker.delegate = self;
    horzPicker.dataSource = self;
    [horzPicker scrollToElement:49 animated:YES];// here value will be device knownVaklue.value
    const NSInteger element_width = [self horizontalPickerView:horzPicker widthForElementAtIndex:0];
    SFIPickerIndicatorView1 *indicatorView = [[SFIPickerIndicatorView1 alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    horzPicker.selectionPoint = CGPointMake((horzPicker.frame.size.width) / 2, 0);
    indicatorView.color1 = self.color;
    horzPicker.selectionIndicatorView = indicatorView;
    [self addSubview:horzPicker];
    
}
- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    return 40;
}


- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return self.componentArray.count;
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    
    //return [NSString stringWithFormat:@"%ld\u00B0", (long) index];
    
    return @(index).stringValue;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    [self setDelegate:self.componentArray[index]];
}
-(void)setDelegate:(NSString*)finalValue{
    [self.delegate updatePickerValue:finalValue];
}

@end
