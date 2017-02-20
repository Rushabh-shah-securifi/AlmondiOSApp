//
//  PickerComponentView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/01/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "PickerComponentView.h"
#import "GenericValue.h"

@interface PickerComponentView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) NSArray *displayArr;
@property (nonatomic) NSArray *valueArr;

@end

@implementation PickerComponentView
-(id) initWithFrame:(CGRect)frame arrayList:(NSDictionary *)dictOfValues;
{
    self = [super initWithFrame:frame];
    if(self){
        self.displayArr = [dictOfValues allValues];
        self.valueArr = [dictOfValues allKeys];
        
        [self drawPickerView];
    }
    return self;
}
-(void)drawPickerView{
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 150, 160)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.center = self.center;
    [self addSubview:_pickerView];
    
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.displayArr count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    GenericValue *gIndex = [self.displayArr objectAtIndex:row];
    title=gIndex.displayText;
    return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *value = [self.valueArr objectAtIndex:row];
    NSLog( @"selected value = %@",value);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
