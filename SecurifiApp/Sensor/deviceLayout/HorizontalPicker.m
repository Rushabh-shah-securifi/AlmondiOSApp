//
//  HorzSlider.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HorizontalPicker.h"
#import "SFIColors.h"
#import "SFIPickerIndicatorView1.h"
#import "UIFont+Securifi.h"
#import "CommonMethods.h"

@interface HorizontalPicker ()<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate>
@end

@implementation HorizontalPicker
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        self.isInitialised = NO;
        [self drawSlider];
    }
    return self;
}
-(void)drawSlider{// it will take color
    //self.componentArray = [NSMutableArray new];
    self.horzPicker = [[V8HorizontalPickerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //    self.horzPicker.layer.cornerRadius = 4;
    //    self.horzPicker.layer.borderWidth = 1.5;
    self.horzPicker.backgroundColor = [UIColor whiteColor];
    //    self.horzPicker.layer.borderColor = [SFIColors clientGreenColor].CGColor;
    self.horzPicker.selectedTextColor = self.color;
    self.horzPicker.elementFont = [UIFont securifiFont:15];
    self.horzPicker.textColor = self.color;
    self.horzPicker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    self.horzPicker.delegate = self;
    self.horzPicker.dataSource = self;
    //    [self.genericIndexValue.genericValue.value integerValue] - self.genericIndexValue.genericIndex.formatter.min
    self.horzPicker.selectionPoint = CGPointMake((self.horzPicker.frame.size.width) / 2, 0);
    NSLog(@"self.genericIndexValue.genericValue.value %@",self.genericIndexValue.genericValue.value);
    
    [self.horzPicker scrollToElement:[self.genericIndexValue.genericValue.value integerValue] - self.genericIndexValue.genericIndex.formatter.min  animated:YES];// here value will be device knownVaklue.value
    
    
    const NSInteger element_width = [self horizontalPickerView:self.horzPicker widthForElementAtIndex:0];
    SFIPickerIndicatorView1 *indicatorView = [[SFIPickerIndicatorView1 alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    indicatorView.color1 = [self darkerColorForColor:self.color];
    self.horzPicker.selectionIndicatorView = indicatorView;
    [self addSubview:self.horzPicker];
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    return 40;
}

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return (self.genericIndexValue.genericIndex.formatter.max - self.genericIndexValue.genericIndex.formatter.min) + 1;
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    return @(index + self.genericIndexValue.genericIndex.formatter.min).stringValue ;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    if(self.isInitialised){
        NSInteger value = self.genericIndexValue.genericIndex.formatter.min + index;
        if([[SecurifiToolkit sharedInstance].almondProperty.weatherCentigrade isEqualToString:@"C"]){
            value = [CommonMethods convertToFarenheit:(int)value];
    
        }
        [self.delegate save:@(value).stringValue forGenericIndexValue:_genericIndexValue currentView:self];
        
    }
    
    self.isInitialised = YES;
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}
@end
