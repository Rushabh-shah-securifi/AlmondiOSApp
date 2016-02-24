//
//  SensorEditViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorEditViewController.h"
#import "UIFont+Securifi.h"

#import "V8HorizontalPickerView.h"
#import "SFIPickerIndicatorView1.h"
#import "SFIColors.h"
#import "NameLocNotView.h"
#import "HorzSlider.h"
#import "SensorButtonView.h"
#import "HueColorPicker.h"
#import "HueSliderView.h"
#import "SensorTextView.h"

@interface SensorEditViewController ()<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate>
@property(nonatomic,strong)NSMutableArray *genericIndexArray;//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;


@end

@implementation SensorEditViewController{
   NSMutableArray * pickerValuesArray1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.genericIndexArray = [[NSMutableArray alloc]init];
    pickerValuesArray1 = [[NSMutableArray alloc]init];
    NSLog(@"SensorEditViewController");
    [self getGenericIndex];
    [self drawIndexes];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)getGenericIndex{
    NSDictionary *value1 = @{@"ToggleValue": @"NaN",
                              @"Icon": @"binarysensoron",
                              @"Label": @"ACTIVE"};
    NSDictionary *value2 = @{@"ToggleValue": @"NaN",
                             @"Icon": @"binarysensoroff",
                             @"Label": @"INACTIVE"};
    NSDictionary *value3 = @{@"ToggleValue": @"false",
                             @"Icon": @"emergency",
                             @"Label": @"Emergency Alarm"};
    NSDictionary *value4 = @{@"ToggleValue": @"NaN",
                             @"Icon": @"binarysensoroff",
                             @"Label": @"INACTIVE"};
    NSDictionary *dic1 = @{
                           @"IndexName": @"SENSOR BINARY",
                           @"IndexTypeEnum": @"2",
                           @"IndexBehaviour": @"Sensor",
                           @"DataType": @"Bool",
                           @"ReadOnly": @"false",
                           @"Placement": @"Header",
                           @"SecondaryPlacement": @"NaN",
                           @"Layout": @"HueSlider",
                           @"Min": @"10",
                           @"Max": @"20",
                           @"Range": @"NaN",
                           @"Unit": @"NaN",
                           @"GroupLabel": @"SENSOR",
                           @"Conditional": @"false",
                           @"UseInScenes": @"false",
                           @"DefaultVisibility": @"true",
                           @"Values": @{
                               @"true": value1,
                               @"false": value2
                               }
                           };
    NSDictionary *dict2 = @{
                            @"IndexName": @"EMER_ALARM",
                            @"IndexTypeEnum": @"11",
                            @"IndexBehaviour": @"Actuator",
                            @"DataType": @"Bool",
                            @"ReadOnly": @"true",
                            @"Placement": @"Detail",
                            @"SecondaryPlacement": @"NaN",
                            @"Layout": @"textInput",
                            @"Min": @"0",
                            @"Max": @"100",
                            @"Range": @"NaN",
                            @"Unit": @"NaN",
                            @"GroupLabel": @"STATUS ",
                            @"Conditional": @"false",
                            @"UseInScenes": @"false",
                            @"DefaultVisibility": @"false",
                            @"Values": @{
                                @"true": value3,
                                @"false": value4
                                }
                            };
    [self.genericIndexArray addObject:dic1];
    [self.genericIndexArray addObject:dict2];
}
-(void)drawIndexes{
    int yPos = 10;
    for(NSDictionary *dict in self.genericIndexArray){
        NSString *propertyName = [dict valueForKey:@"GroupLabel"];
        if([[dict valueForKey:@"ReadOnly"] isEqualToString:@"true"]){
         UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10 , yPos, self.indexesScroll.frame.size.width -10, 25)];
            view.backgroundColor = [UIColor clearColor];
            [self.indexesScroll addSubview:view];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
            label.text = propertyName;
            label.font = [UIFont securifiBoldFont];
            label.textColor = [UIColor whiteColor];
            [view addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 0, 100, 15)];
            valueLabel.text = propertyName;
            valueLabel.font = [UIFont securifiBoldFont];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.alpha = 0.5;

            [view addSubview:valueLabel];
            yPos = yPos + view.frame.size.height;
            
        }
        else{
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10 , yPos, self.indexesScroll.frame.size.width -10, 60)];
            view.backgroundColor = [UIColor clearColor];
            [self.indexesScroll addSubview:view];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
            label.text = propertyName;
            label.font = [UIFont securifiBoldFont];
            label.textColor = [UIColor whiteColor];
            [view addSubview:label];
            if([[dict valueForKey:@"Layout"] isEqualToString:@"Slider"]){
                HorzSlider *horzView = [[HorzSlider alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                horzView.componentArray = [NSMutableArray new];
                for (NSInteger i=[[dict valueForKey:@"Min"] integerValue]; i<=[[dict valueForKey:@"Max"] integerValue]; i++) {
                    [horzView.componentArray addObject:[NSString stringWithFormat:@"%ld",i]];}
                    horzView.color = [SFIColors clientGreenColor];
                    [horzView drawSlider];
                [view addSubview:horzView];
                }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"Button"]){
                SensorButtonView *buttonView = [[SensorButtonView alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                [buttonView drawButton:[dict valueForKey:@"Values"] color:[SFIColors clientGreenColor]];
                [view addSubview:buttonView];
            }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"Hue"]){
                HueColorPicker *HueView = [[HueColorPicker alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                [HueView drawHueColorPicker];
                [view addSubview:HueView];
            }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"HueSlider"]){
                HueSliderView *HuesliderView = [[HueSliderView alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                [HuesliderView drawSlider];
                [view addSubview:HuesliderView];
            }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"textInput"]){
                SensorTextView *textView = [[SensorTextView alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                [textView drawTextField:@"124"];
                [view addSubview:textView];
            }

            yPos = yPos + view.frame.size.height;
        }
        
        }
    NSArray *array = @[@"Name",@"Location",@"Notify me"];
    for(NSString *label in array){
        NameLocNotView *nameAndLocView = [[NameLocNotView alloc]initWithFrame:CGRectMake(10, yPos, self.indexesScroll.frame.size.width -10, 60)];
        
        if([label isEqualToString:@"Notify me"])
            [nameAndLocView notiFicationField:label andDevice:self.device];
        else
        [nameAndLocView drawNameAndLoc:self.device.name labelText:label];
        
        yPos = yPos + 60;
        [self.indexesScroll addSubview:nameAndLocView];
        
    }
    
}
-(void)drawNameLocTemplateAt:(int)yPos{
   UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10 , yPos, self.indexesScroll.frame.size.width -10, 60)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    label.text = @"NAME";
    label.font = [UIFont securifiBoldFont];
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    
    UITextField *deviceNameField = [[UITextField alloc]initWithFrame:CGRectMake(0,20,view.frame.size.width -10,30)];
    deviceNameField.text = self.device.name;
    deviceNameField.textColor = [UIColor whiteColor];
    deviceNameField.font = [UIFont securifiLightFont];
    [view addSubview:deviceNameField];
    
    
    //CGRectMake(0,20,view.frame.size.width -10,30)

}
-(void)drawButton:(NSDictionary *)valuedict view:(UIView *)view{
    NSArray *allkeys = [valuedict allKeys];
    int xPos = 0;
    for(int i =0;i < allkeys.count ;i++){
        NSDictionary *dict = [valuedict valueForKey:[allkeys objectAtIndex:i]];
        CGRect textRect = [self adjustDeviceNameWidth:[dict valueForKey:@"Label"]];
        CGRect frame = CGRectMake(xPos, 20, textRect.size.width + 5, 30);
        UIButton *button = [[UIButton alloc ]initWithFrame:frame];
        [button setTitle:[dict valueForKey:@"Label"] forState:UIControlStateNormal];
        button.backgroundColor = [SFIColors clientGreenColor];
        button.titleLabel.font = [UIFont securifiBoldFont];
        button.tag = i;
        button.alpha = 0.3;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        xPos = xPos + button.frame.size.width;
    }
    
    
}

-(void)onButtonClicked:(UIButton*)senderButton{
    for(UIButton *button in [[senderButton superview] subviews]){
        if([button isKindOfClass:[UILabel class]])
            continue;
        if( button.tag == senderButton.tag){
            button.alpha = 1.0;
            button.selected = YES;
        }
        else{
            button.alpha = 0.3;
            button.selected = NO;
        }
    }
    
    
}
-(CGRect)adjustDeviceNameWidth:(NSString*)deviceName{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGRect textRect;
    
    textRect.size = [deviceName sizeWithAttributes:attributes];
    if(deviceName.length > 18){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
}

@end
