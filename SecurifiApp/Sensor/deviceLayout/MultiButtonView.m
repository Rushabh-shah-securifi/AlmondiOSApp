//
//  SensorButtonView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MultiButtonView.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"
#import "UICommonMethods.h"

#define FONT_SIZE 16
#define MAX_LENGTH 18
@interface MultiButtonView()
@property (nonatomic) NSArray *displayValueArray;
@property (nonatomic)NSArray *valueArray;
@end
@implementation MultiButtonView
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        [self drawButton:self.genericIndexValue.genericIndex.values];
    }
    return self;
}

-(void)drawButton:(NSDictionary *)valuedict{
    NSString *deviceValue = [NSString new];
    int selectedValue = -1;
    if(self.genericIndexValue.genericValue.value){
        deviceValue  = self.genericIndexValue.genericValue.value;
    }

    NSArray *devicePosKeys = valuedict.allKeys;
    self.valueArray = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    
    NSMutableArray *labelsArray = [[NSMutableArray alloc]init];
    
    for(int i =0;i < self.valueArray.count ;i++){
        if([deviceValue isEqualToString:[self.valueArray objectAtIndex:i]]){
            selectedValue = i;
        }
        GenericValue *gVal = [valuedict valueForKey:[self.valueArray objectAtIndex:i]];
        [labelsArray addObject:gVal.displayText];
    }
    [self drawButton:labelsArray selectedValue:selectedValue];
}

-(void)drawButton:(NSArray*)array selectedValue:(int)selectedValue{//here we have to pass many things like deviceIndexId,deviceID,...
    self.displayValueArray = array;
    int xPos = -10;
    for(int i = 0; i<array.count;i++){
        CGRect textRect = [UICommonMethods adjustDeviceNameWidth:[array objectAtIndex:i] fontSize:FONT_SIZE maxLength:MAX_LENGTH];
        CGRect frame = CGRectMake(xPos + 10, 0, textRect.size.width + 15, self.frame.size.height);
        UIButton *button = [[UIButton alloc ]initWithFrame:frame];
        
        [button setTitle:[[array objectAtIndex:i] capitalizedString] forState:UIControlStateNormal];
        button.backgroundColor = [SFIColors darkerColorForColor:self.color];
        button.titleLabel.font = [UIFont securifiBoldFontLarge];
        button.tag = i;
        button.opaque = YES;
        button.userInteractionEnabled = YES;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if(selectedValue == button.tag){
             button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:self.color forState:UIControlStateNormal];
        }
        
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        xPos = xPos + button.frame.size.width ;
    }
}

-(void)onButtonClicked:(UIButton *)sender{
    for(UIButton *button in [[sender superview] subviews ]){
        if([button isKindOfClass:[UILabel class]])
            continue;
        if( button.tag == sender.tag){
            button.selected = YES;
            [button setTitleColor:self.color forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor whiteColor]];
        }
        else{
            button.selected = NO;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[SFIColors darkerColorForColor:self.color]];
        }
    }
    [self.delegate save:[self.valueArray objectAtIndex:sender.tag] forGenericIndexValue:_genericIndexValue currentView:self];
}



@end