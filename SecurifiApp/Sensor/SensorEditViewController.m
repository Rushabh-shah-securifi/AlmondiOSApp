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

@interface SensorEditViewController ()<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate,SensorButtonViewDelegate,SensorTextViewDelegate,HorzSliderDelegate,HueColorPickerDelegate,HorzSliderDelegate,HueSliderViewDelegate>
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
                           @"Layout": @"Button",
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
                            @"ReadOnly": @"false",
                            @"Placement": @"Detail",
                            @"SecondaryPlacement": @"NaN",
                            @"Layout": @"Hue",
                            @"Min": @"1",
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
                horzView.device = self.device;
                horzView.delegate = self;
                for (NSInteger i=[[dict valueForKey:@"Min"] integerValue]; i<=[[dict valueForKey:@"Max"] integerValue]; i++) {
                    [horzView.componentArray addObject:[NSString stringWithFormat:@"%ld",i]];}
                    horzView.color = [SFIColors clientGreenColor];
                    [horzView drawSlider];
                [view addSubview:horzView];
                }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"Button"]){
                SensorButtonView *buttonView = [[SensorButtonView alloc]initWithFrame:CGRectMake(0,5,view.frame.size.width -10,30)];
                buttonView.deviceValueDict = [dict valueForKey:@"Values"];
                buttonView.device = self.device;
                buttonView.color = [SFIColors clientGreenColor];
                [buttonView drawButton:[dict valueForKey:@"Values"] color:[SFIColors clientGreenColor]];
                [view addSubview:buttonView];
            }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"Hue"]){
                HueColorPicker *HueView = [[HueColorPicker alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                HueView.device = self.device;// we should match index
                HueView.delegate = self;
                HueView.color = [SFIColors clientGreenColor];
                [HueView drawHueColorPicker];
                [view addSubview:HueView];
            }
            else if ([[dict valueForKey:@"Layout"] isEqualToString:@"HueSlider"]){
                HueSliderView *HuesliderView = [[HueSliderView alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                HuesliderView.componentArray = [NSMutableArray new];
                for (NSInteger i=[[dict valueForKey:@"Min"] integerValue]; i<=[[dict valueForKey:@"Max"] integerValue]; i++) {
                    [HuesliderView.componentArray addObject:[NSString stringWithFormat:@"%ld",i]];}
                HuesliderView.color = [SFIColors clientGreenColor];
                HuesliderView.delegate = self;
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
            [nameAndLocView notiFicationField:label andDevice:self.device color:[SFIColors clientGreenColor]];
        else
        [nameAndLocView drawNameAndLoc:self.device.name labelText:label];
        
        yPos = yPos + 60;
        [self.indexesScroll addSubview:nameAndLocView];
        
    }
}
- (IBAction)onSeettingButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark delegate callback methods
-(void)updateNewValue:(NSString *)newValue{
    NSLog(@"updateNewValue");
}
-(void)updateSliderValue:(NSString*)newvalue{
    NSLog(@"updateSliderValue");
}
-(void)updateHueColorPicker:(NSString *)newValue{
    NSLog(@"updateHueColorPicker");
}
-(void)updateButtonStatus{
    NSLog(@"updateButtonStatus");
}
-(void)updatePickerValue:(NSString *)newValue{
    NSLog(@"updatePickerValue");
}
@end
