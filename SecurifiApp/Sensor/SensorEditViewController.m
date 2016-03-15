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

#define GROUPLABEL @"GroupLabel"
#define READONLY @"ReadOnly"
#define TRUE_ @"true"
#define SLIDER @"Slider"
#define LAYOUT @"Layout"
#define BUTTON @"Button"
#define VALUES @"Values"
#define HUE @"Hue"
#define HUESLIDER @"HueSlider"
#define TEXTINPUT @"textInput"
#define MINIMUM @"Min"
#define MAXIMUM @"Max"









@interface SensorEditViewController ()<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate,SensorButtonViewDelegate,SensorTextViewDelegate,HorzSliderDelegate,HueColorPickerDelegate,HorzSliderDelegate,HueSliderViewDelegate>
//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;


@end

@implementation SensorEditViewController{
   NSMutableArray * pickerValuesArray1;
}

- (void)viewDidLoad {
    NSLog(@"SensorEditViewController");
    [super viewDidLoad];
    pickerValuesArray1 = [[NSMutableArray alloc]init];
    
    [self drawIndexes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)drawIndexes{
    int yPos = 10;
    CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.genericIndexArray.count * 80 + 210);
    [self.indexesScroll setContentSize:scrollableSize];
    [self.indexesScroll flashScrollIndicators];
    NSLog(@"self.genericIndexArray %@",self.genericIndexArray);
    for(NSDictionary *dict in self.genericIndexArray){
        
        NSString *propertyName = [dict valueForKey:GROUPLABEL];
        if([[dict valueForKey:READONLY] isEqualToString:TRUE_]){
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
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
            label.text = propertyName;
            label.font = [UIFont securifiBoldFont];
            label.textColor = [UIColor whiteColor];
            
            [view addSubview:label];
            if([[dict valueForKey:LAYOUT] isEqualToString:SLIDER]){
                HorzSlider *horzView = [[HorzSlider alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                horzView.componentArray = [NSMutableArray new];
                horzView.device = self.device;
                horzView.delegate = self;
                NSDictionary *formattedValues = [[dict valueForKey:VALUES] valueForKey:@"Formatter"];
                NSLog(@"formattedValues %@ ",formattedValues);
                for (NSInteger i=[[formattedValues valueForKey:MINIMUM] integerValue]; i<=[[formattedValues valueForKey:MAXIMUM] integerValue]; i++) {
                    [horzView.componentArray addObject:[NSString stringWithFormat:@"%ld",i]];
                }
                horzView.color = [SFIColors ruleBlueColor];
                [horzView drawSlider];
                [self.indexesScroll addSubview:view];
                [view addSubview:horzView];
                yPos = yPos + view.frame.size.height;
                }
            else if ([[dict valueForKey:LAYOUT] isEqualToString:BUTTON]){
                SensorButtonView *buttonView = [[SensorButtonView alloc]initWithFrame:CGRectMake(0,19,view.frame.size.width -10,30)];
                buttonView.deviceValueDict = [dict valueForKey:VALUES];
                buttonView.device = self.device;
                buttonView.color = [SFIColors ruleBlueColor];
                [buttonView drawButton:[dict valueForKey:VALUES] color:[SFIColors ruleBlueColor]];
                [self.indexesScroll addSubview:view];
                [view addSubview:buttonView];
                yPos = yPos + view.frame.size.height;
            }
            else if ([[dict valueForKey:LAYOUT] isEqualToString:HUE]){
                HueColorPicker *HueView = [[HueColorPicker alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                HueView.device = self.device;// we should match index
                HueView.delegate = self;
                HueView.color = [SFIColors ruleBlueColor];
                [HueView drawHueColorPicker];
                [self.indexesScroll addSubview:view];
                [view addSubview:HueView];
                yPos = yPos + view.frame.size.height;
            }
            else if ([[dict valueForKey:LAYOUT] isEqualToString:HUESLIDER]){
                HueSliderView *HuesliderView = [[HueSliderView alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                HuesliderView.componentArray = [NSMutableArray new];
                NSDictionary *formattedValues = [[dict valueForKey:VALUES] valueForKey:@"Formatter"];
                NSLog(@"formattedValues %@ ",formattedValues);
                for (NSInteger i=[[formattedValues valueForKey:MINIMUM] integerValue]; i<=[[formattedValues valueForKey:MAXIMUM] integerValue]; i++) {
                    [HuesliderView.componentArray addObject:[NSString stringWithFormat:@"%ld",i]];
                }
                HuesliderView.color = [SFIColors ruleBlueColor];
                HuesliderView.delegate = self;
                [HuesliderView drawSlider];
                [self.indexesScroll addSubview:view];
                [view addSubview:HuesliderView];
                yPos = yPos + view.frame.size.height;
            }
            else if ([[dict valueForKey:LAYOUT] isEqualToString:TEXTINPUT]){
                SensorTextView *textView = [[SensorTextView alloc]initWithFrame:CGRectMake(0,10,view.frame.size.width -10,30)];
                [textView drawTextField:@"124"];
                [self.indexesScroll addSubview:view];
                [view addSubview:textView];
                yPos = yPos + view.frame.size.height;
            }

            
        }
        
        }
    NSArray *array = @[@"NAME",@"LOCATION",@"NOTIFY ME"];
    for(NSString *label in array){
        NameLocNotView *nameAndLocView = [[NameLocNotView alloc]initWithFrame:CGRectMake(10, yPos, self.indexesScroll.frame.size.width -10, 60)];
        
        if([label isEqualToString:@"NOTIFY ME"])
            [nameAndLocView notiFicationField:label andDevice:self.device color:[SFIColors ruleBlueColor]];
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
