//
//  PickerComponentView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/01/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "PickerComponentView.h"
#import "GenericIndexValue.h"
#import "GenericValue.h"
#import "UIFont+Securifi.h"

@interface PickerComponentView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) NSArray *displayArr;
@property (nonatomic) NSArray *valueArr;

@end

@implementation PickerComponentView
-(id) initWithFrame:(CGRect)frame displayList:(NSArray *)dispArr valueList:(NSArray *)valArr genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.displayArr = dispArr;
        self.valueArr = valArr;
        self.genericIndexValue = genericIndexValue;
        [self drawPickerView];
    }
    return self;
}
-(void)drawPickerView{
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 150, 160)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.center = self.center;
    [_pickerView selectRow:[self selectRow] inComponent:0 animated:YES];
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
    
    title=[self.displayArr objectAtIndex:row];
    return title;
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    
    
    title=[self.displayArr objectAtIndex:row];

   // title=[self.arrayOfState objectAtIndex:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                                                  NSFontAttributeName:[UIFont securifiFont:8]                                                   }];
    
    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *value = [self.valueArr objectAtIndex:row];
    NSLog( @"selected value = %@",value);
    [self.delegate pickerViewSelectedValue:value genericIndexValue:self.genericIndexValue];
}
-(NSInteger)selectRow{
    NSString *selectedValue = self.genericIndexValue.genericValue.value;
    NSInteger i =0;
    for(NSString *value in self.valueArr){
        if([value isEqualToString:selectedValue])
            return i;
        i++;
    }
    return 0;
}

@end
