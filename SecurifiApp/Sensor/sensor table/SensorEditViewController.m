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
#import "HorzSlider.h"
#import "SensorButtonView.h"
#import "HueColorPicker.h"
#import "HueSliderView.h"
#import "SensorTextView.h"
#import "CommonCell.h"

#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "clientTypeCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "CollectionViewCell.h"
#import "GenericIndexValue.h"
#import "GenericIndexClass.h"
#import "GenericIndexValue.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "GridView.h"
#import "ClientTypeTableView.h"



#define ITEM_SPACING  2.0

#define VIEW_FRAME_SMALL CGRectMake(xIndent, yPos, self.indexesScroll.frame.size.width-xIndent, 25)
#define VIEW_FRAME_LARGE CGRectMake(xIndent, yPos, self.indexesScroll.frame.size.width-xIndent, 65)
#define LABEL_FRAME CGRectMake(0, 0, view.frame.size.width-16, 20)
#define SLIDER_FRAME CGRectMake(0, 25,view.frame.size.width-10, 35)
#define BUTTON_FRAME CGRectMake(0, 25,view.frame.size.width-10,  35)
static const int xIndent = 10;

@interface SensorEditViewController ()<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate,SensorButtonViewDelegate,SensorTextViewDelegate,HorzSliderDelegate,HueColorPickerDelegate,HorzSliderDelegate,HueSliderViewDelegate,CommonCellDelegate,SFIWiFiDeviceTypeSelectionCellDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,clientTypeCellDelegate,SensorButtonViewDelegate>
//can be removed
@property (weak, nonatomic) IBOutlet UIScrollView *indexesScroll;

//wifi client @property
@property (nonatomic) IBOutlet UIView *indexView;
@property (nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet CommonCell *deviceEditHeaderCell;


@property (nonatomic) UITableView *tableType;
@property (strong ,nonatomic) UISegmentedControl *allowOnNetworkSegment;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *clientTypesView;
@property (nonatomic)UIView *allowOnNetworkView;
@property (nonatomic)UICollectionView *collectionView;
@property (nonatomic)NSString *selectedType;/*    NSMutableString *hexBlockedDays;
                                             */
@property (nonatomic)NSMutableString *hexBlockedDays;


@end

@implementation SensorEditViewController{
    NSMutableArray * pickerValuesArray1;
    NSMutableArray * blockedDaysArray;
    NSString *blockedType;
    NSArray *type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceEditHeaderCell.delegate = self;
    if(self.isSensor){
        self.scrollView.hidden = NO;
        pickerValuesArray1 = [[NSMutableArray alloc]init];
        self.deviceEditHeaderCell.cellType = SensorEdit_Cell;
        self.deviceEditHeaderCell.device = self.device;
        self.deviceEditHeaderCell.deviceName.text = self.device.name;
        self.deviceEditHeaderCell.delegate = self;
        [self.deviceEditHeaderCell setUPSensorCell];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawIndexes];
        });
        
    }
    else{
        // wifi clients
        self.scrollView.hidden = YES;
        self.deviceEditHeaderCell.cellType = ClientEditProperties_cell;
        [self drawViews];
        self.selectedType = [self.deviceDict valueForKey:@"Type"];
        type = @[@"PC",@"smartPhone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"printer",@"Router_switch",@"Nest",@"Hub",@"Camara",@"ChromeCast",@"android_stick",@"amazone_exho",@"amazone-dash",@"Other"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self clearAllViews];
}

- (void)clearAllViews{
    for(UIView *view in self.scrollView.subviews){
        [view removeFromSuperview];
    }
    for(UIView *view in self.view.subviews){
        [view removeFromSuperview];
    }
}


-(void)drawIndexes{
    int yPos = 10;
    CGSize scrollableSize = CGSizeMake(self.indexesScroll.frame.size.width,self.genericIndexValues.count * 80 + 210);
    [self.indexesScroll setContentSize:scrollableSize];
    [self.indexesScroll flashScrollIndicators];
    for(GenericIndexValue *genericIndexValue in self.genericIndexValues){
        GenericIndexClass *genericIndexObj = genericIndexValue.genericIndex;

        if([genericIndexObj.layoutType isEqualToString:@"Info"] || [genericIndexObj.layoutType.lowercaseString isEqualToString:@"off"] || genericIndexObj.layoutType == nil || [genericIndexObj.layoutType isEqualToString:@"NaN"]){
            continue;
        }
                NSLog(@"genericIndexValue loop");
        NSString *propertyName = genericIndexObj.groupLabel;
        if(genericIndexObj.readOnly){
            UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_SMALL];
            [self.indexesScroll addSubview:view];
            
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 0, 100, 15)];
            [self setUpLable:valueLabel withPropertyName:propertyName];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.alpha = 0.5;
            [view addSubview:valueLabel];
            
            yPos = yPos + view.frame.size.height;
        }
        else{
            UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_LARGE];
            UILabel *label = [[UILabel alloc]initWithFrame:LABEL_FRAME];
            [self setUpLable:label withPropertyName:propertyName];
            [view addSubview:label];
            
            if([genericIndexObj.layoutType isEqualToString:SLIDER]){
                HorzSlider *horzView = [[HorzSlider alloc]initWithFrame:SLIDER_FRAME];
                horzView.delegate = self;
                Formatter *formatter = genericIndexObj.formatter;
                horzView.min = formatter.min;
                horzView.max = formatter.max;
                horzView.color = [SFIColors ruleBlueColor];
                [horzView drawSlider];
                horzView.backgroundColor = [UIColor yellowColor];
                [view addSubview:horzView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:BUTTON]){
                SensorButtonView *buttonView = [[SensorButtonView alloc]initWithFrame:BUTTON_FRAME];
                buttonView.deviceValueDict = genericIndexObj.values;
                buttonView.device = self.device;
                buttonView.color = [SFIColors ruleBlueColor];
                [buttonView drawButton:genericIndexObj.values color:[SFIColors ruleBlueColor]];
                [view addSubview:buttonView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:HUE]){
                HueColorPicker *HueView = [[HueColorPicker alloc]initWithFrame:SLIDER_FRAME];
                HueView.delegate = self;
                HueView.color = [SFIColors ruleBlueColor];
                [HueView drawHueColorPicker];
                [view addSubview:HueView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:HUE_SLIDER]){
                HueSliderView *HuesliderView = [[HueSliderView alloc]initWithFrame:SLIDER_FRAME];
                Formatter *formatter = genericIndexObj.formatter;
                HuesliderView.min = formatter.min;
                HuesliderView.max = formatter.max;
                HuesliderView.color = [SFIColors ruleBlueColor];
                HuesliderView.delegate = self;
                [HuesliderView drawSlider];
                [view addSubview:HuesliderView];
            }
            else if ([genericIndexObj.layoutType isEqualToString:TEXT_INPUT]){
                SensorTextView *textView = [[SensorTextView alloc]initWithFrame:SLIDER_FRAME];
                [textView drawTextField:@"124"];
                [view addSubview:textView];
            }
            [self.indexesScroll addSubview:view];
            yPos = yPos + view.frame.size.height;
        }
    }
    [self addNameLocationNotifyMeViews:yPos];
}



- (void)setUpLable:(UILabel*)label withPropertyName:(NSString*)propertyName{
    label.text = propertyName;
    label.font = [UIFont securifiBoldFont];
    label.textColor = [UIColor whiteColor];
}


-(void)addNameLocationNotifyMeViews:(int)yPos{
    yPos = [self nameLocField:yPos withLabelText:@"NAME"];
    yPos = [self nameLocField:yPos withLabelText:@"LOCATION"];
    [self notifyField:yPos];
}

-(int)nameLocField:(int)yPos withLabelText:(NSString*)labelText{
    UIView *view = [[UIView alloc]initWithFrame:VIEW_FRAME_LARGE];
    UILabel *Name = [[UILabel alloc]initWithFrame:LABEL_FRAME];
    [self setUpLable:Name withPropertyName:labelText];
    [view addSubview:Name];
    
    SensorTextView *name = [[SensorTextView alloc]initWithFrame:CGRectMake(0,15,view.frame.size.width -10,35)];
    [name drawTextField:self.device.name];
    [self.indexesScroll addSubview:view];
    [view addSubview:name];
    return yPos = yPos + view.frame.size.height;
}

-(void)notifyField:(int)yPos{
    UIView *viewNotify = [[UIView alloc]initWithFrame:CGRectMake(10 , yPos, self.indexesScroll.frame.size.width -10, 65)];
    viewNotify.backgroundColor = [UIColor clearColor];
    UILabel *notify = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    notify.text = @"NOTIFY ME";
    notify.font = [UIFont securifiBoldFont];
    notify.textColor = [UIColor whiteColor];
    [viewNotify addSubview:notify];
    
    SensorButtonView *sensorbuttons = [[SensorButtonView alloc]initWithFrame:CGRectMake(0,25,viewNotify.frame.size.width -10,35)];
    NSArray *array = @[@"Always",@"When I'm away",@"Never"];
    sensorbuttons.color = [SFIColors ruleBlueColor];
    [sensorbuttons drawButton:array selectedValue:5];
    [self.indexesScroll addSubview:viewNotify];
    [viewNotify addSubview:sensorbuttons];
    
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


#pragma mark wifiClients methods
-(void)drawViews{
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.hidden = YES;
    self.indexView = [[UIView alloc]initWithFrame:CGRectMake(8 , 80, self.view.frame.size.width - 16, 74)];
    self.indexView.backgroundColor = [SFIColors clientGreenColor];
    [self.view addSubview:self.indexView];
    
    self.indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, 100, 25)];
    self.indexLabel.backgroundColor = [UIColor clearColor];
    self.indexLabel.textColor = [UIColor whiteColor];
    self.indexLabel.text = self.indexName;
    self.indexLabel.font = [UIFont securifiFont:15];
    
    [self.indexView addSubview:self.indexLabel];
    
    
    if([self.indexName isEqualToString:@"Name"]){
       // self.indexLabel.text = self.indexName;
        
        [self textFieldView:[self.deviceDict valueForKey:self.indexName]];
    }
    else if ([self.indexName isEqualToString:@"Type"]){
        [self drawTypeTable];
            }
    
    else if ([self.indexName isEqualToString:@"AllowedType"]){
        [self gridView];
        
    }
    else if ([self.indexName isEqualToString:@"pesenceSensor"]){
        NSArray *arr = @[@"YES",@"NO",@"ON",@"OFF"];
        int currentValPos = 0;
            for(NSString *str in arr){
                if([str isEqualToString:[self.deviceDict valueForKey:self.indexName]])
                    break;
                currentValPos++;
            }
        self.indexLabel.text = self.indexName;
        
        [self buttonView:arr selectedValue:currentValPos];
    }
    else if ([self.indexName isEqualToString:@"inActiveTimeOut"]){
        self.indexLabel.text = self.indexName;
        [self textFieldView:[self.deviceDict valueForKey:self.indexName]];
    }
    else if ([self.indexName isEqualToString:@"Other"]){
        
    }
    
}
#pragma mark typeTable
-(void)drawTypeTable{
    self.indexView.hidden = YES;
    ClientTypeTableView * typeTableView = [[ClientTypeTableView alloc]initWithFrame:CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y + 7, self.indexView.frame.size.width, self.view.frame.size.height - self.indexView.frame.origin.y - 5)];
    [typeTableView drawTypeTable:@"MAC"];
    [self.view addSubview:typeTableView];

}
-(void)textFieldView:(NSString *)name{
    SensorTextView *textView = [[SensorTextView alloc]initWithFrame:CGRectMake(8,25,self.indexView.frame.size.width - 8,50)];
    textView.color = [UIColor clearColor];
    [textView drawTextField:name];
    [self.indexView addSubview:textView];
    
}
-(void)buttonView:(NSArray*)arr selectedValue:(int)selectedVal{
    
    SensorButtonView *presenceSensor = [[SensorButtonView alloc]initWithFrame:CGRectMake(5,40,self.indexView.frame.size.width - 8,30 )];
    presenceSensor.color = [SFIColors clientGreenColor];
    [presenceSensor drawButton:arr selectedValue:selectedVal];
    presenceSensor.delegate = self;
    [self.indexView addSubview:presenceSensor];
}
-(void)updateButtonStatus:(NSString *)newValue{//here we have to pass many things like deviceIndexId,deviceID,...
}


#pragma mark gridView
-(void)gridView{
    self.indexView.hidden = YES;
    GridView * grid = [[GridView alloc]initWithFrame:CGRectMake(self.indexView.frame.origin.x, self.indexView.frame.origin.y + 5, self.indexView.frame.size.width, self.view.frame.size.height - self.indexView.frame.origin.y - 5)];
    [grid addSegmentControll];
    [self.view addSubview:grid];
//    [self addSegmentControll];
    
}
@end
