//
//  BlinkLedView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 25/07/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "BlinkLedView.h"
#import "HueColorPicker.h"
#import "Slider.h"
#import "UIFont+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "CommonMethods.h"


#define ITEM_SPACING  2.0
#define LABELSPACING 20.0
#define LABELVALUESPACING 10.0
#define LABELHEIGHT 20.0

#define LABEL_FRAME CGRectMake(0, 0, view.frame.size.width-16, LABELHEIGHT)
#define SLIDER_FRAME CGRectMake(0, LABELHEIGHT + LABELVALUESPACING,view.frame.size.width-10, 35)
static const int xIndent = 0;
@interface BlinkLedView()<HueColorPickerDelegate,SliderViewDelegate>
@property (nonatomic) HueColorPicker *huePicker;
@property (nonatomic) Slider *saturationSlider;
@property (nonatomic) Slider *brightnessSlider;
@property (nonatomic) UIColor *color;
@property (nonatomic) GenericIndexValue *genericIndexValue;
@property int hue;
@property int sat;
@end

@implementation BlinkLedView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        self.sat = 100;
//        self.valueArr = [[NSMutableArray alloc] init];
//        self.displayArray = [[NSMutableArray alloc] init];
//        [self drawTypeTable];
    }
    return self;
}

-(void)layoutSubviews{
    int yPos = 0;
    NSLog(@"layoutSubView");
    NSArray *layoutArr = @[@"BRIGHTNESS"];
    for (int i = 0; i < layoutArr.count; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, yPos , self.frame.size.width-xIndent, 65)];
        
//        UILabel *label;
//        if(![@"SATURATION" isEqualToString:layoutArr[i]]){
//            label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
//            [self setUpLable:label withPropertyName:layoutArr[i]];
//            [view addSubview:label];
//        }

        if ([layoutArr[i] isEqualToString:@"HUE"]) {
            self.hue = [CommonMethods getHueValue:self.genericIndexValue.genericValue.value];
            self.genericIndexValue.genericValue.value = @(self.hue).stringValue;
            NSLog(@"self.hue = %d",self.hue);
            self.huePicker = [[HueColorPicker alloc]initWithFrame:SLIDER_FRAME color:self.color genericIndexValue:self.genericIndexValue];
            self.huePicker.delegate = self;
//            self.hueFrame = view.frame;
            [view addSubview:self.huePicker];
        }
        else if ([layoutArr[i] isEqualToString:@"BRIGHTNESS"]){
            NSLog(@"blink sat value: %@", self.genericIndexValue.genericValue.value);
            int brightness = [CommonMethods getBrightnessValue:self.genericIndexValue.genericValue.value];
            
            NSLog(@"brightness = %d", brightness);
            GenericIndexClass *genericIndex = [[GenericIndexClass alloc]initWithGenericIndex:self.genericIndexValue.genericIndex];
            genericIndex.formatter.min = 1;
            genericIndex.formatter.max = 100;
            GenericValue *genValue = [GenericValue  getCopy:self.genericIndexValue.genericValue];
            genValue.transformedValue = @(brightness).stringValue;
            GenericIndexValue *satGenericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genValue index:_genericIndexValue.index deviceID:_genericIndexValue.deviceID];

            self.brightnessSlider = [[Slider alloc]initWithFrame:SLIDER_FRAME color:self.color genericIndexValue:satGenericIndexValue];
            self.brightnessSlider.delegate = self;
            [view addSubview:self.brightnessSlider];

        }
        else if ([layoutArr[i] isEqualToString:@"SATURATION"]){
            self.saturationSlider = [[Slider alloc]initWithFrame:SLIDER_FRAME color:self.color genericIndexValue:self.genericIndexValue];
            self.saturationSlider.delegate = self;
            [view addSubview:self.saturationSlider];
            
        }
        yPos =  yPos + view.frame.size.height + LABELSPACING;
        [self addSubview:view];
    }
}

- (void)setUpLable:(UILabel*)label withPropertyName:(NSString*)propertyName{
    label.text = propertyName;
    label.font = [UIFont standardHeadingBoldFont];
    label.textColor = [UIColor whiteColor];
}

-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue currentView:(UIView*)currentView{
    NSLog(@"new value save = %@",newValue);
    self.hue = [newValue intValue];
    int new = [CommonMethods getRGBFromHSB:self.hue saturation:self.sat];
    NSLog(@"final value = %d",new);
    [self.delegate save:@(new).stringValue forGenericIndexValue:_genericIndexValue currentView:self];
}

-(void)blinkNew:(NSString *)newValue{
    NSLog(@"new brightness value %@", newValue);
    //new value range is 0-100 only
    float h, s, l;
    [CommonMethods getHSLFromDecimal:_genericIndexValue.genericValue.value.intValue h:&h s:&s l:&l];
    l = newValue.floatValue * 255.0 / 100.0; //had to convert to 255, only then its working.
    int new = [CommonMethods getRGBDecimalFromHSL:h s:s l:l];
    
    NSLog(@"final decimal value = %d",new);
    [self.delegate save:@(new).stringValue forGenericIndexValue:_genericIndexValue currentView:self];
}
@end