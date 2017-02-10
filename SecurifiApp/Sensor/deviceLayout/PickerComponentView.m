//
//  PickerComponentView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/01/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "PickerComponentView.h"

@interface PickerComponentView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) NSArray *arrayOfState;
@property (nonatomic) NSString *rowPostionString;
@end

@implementation PickerComponentView
-(id) initWithFrame:(CGRect)frame arrayList:(NSArray *)arrayOfState atRowPosition:(NSInteger)rowPosition
{
    self = [super initWithFrame:frame];
    if(self){
        self.rowPostionString = @(rowPosition).stringValue;
        self.arrayOfState = arrayOfState;
        [self drawPickerView];
    }
    return self;
}
-(void)drawPickerView{
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 100, 160)];
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
    return [self.arrayOfState count];
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    title=[self.arrayOfState objectAtIndex:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//    NSString *title;
//    title=[self.arrayOfState objectAtIndex:row];
//    return title;
//}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"did selct row %@",[self.arrayOfState objectAtIndex:row]);
    [self.delegate setPickerValue:[self.arrayOfState objectAtIndex:row] rowPosition:self.rowPostionString];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
