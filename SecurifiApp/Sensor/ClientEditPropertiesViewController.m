//
//  ClientEditPropertiesViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 02/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientEditPropertiesViewController.h"
#import "SensorButtonView.h"
#import "SensorTextView.h"
#import "SFIColors.h"


@interface ClientEditPropertiesViewController ()
@property (weak, nonatomic) IBOutlet UIView *clientInfoView;
@property (weak, nonatomic) IBOutlet UIView *indexView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@end

@implementation ClientEditPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawViews];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)drawViews{
    if([self.indexName isEqualToString:@"Name"]){
        self.indexLabel.text = self.indexName;
        [self textFieldView:@"android 02#"];
    }
    else if ([self.indexName isEqualToString:@"Type"]){
        
    }
    
    else if ([self.indexName isEqualToString:@"Allow"]){
        
    }
    else if ([self.indexName isEqualToString:@"pesenceSensor"]){
        self.indexLabel.text = self.indexName;
        [self buttonView];
    }
    else if ([self.indexName isEqualToString:@"inActiveTimeOut"]){
        self.indexLabel.text = self.indexName;
        [self textFieldView:@"2"];
    }
    else if ([self.indexName isEqualToString:@"Other"]){
        
    }

}
-(void)textFieldView:(NSString *)name{
    NSLog(@"self.indexName %@ ",self.indexName);
    SensorTextView *textView = [[SensorTextView alloc]initWithFrame:CGRectMake(4,20,self.indexView.frame.size.width - 8,40)];
    textView.color = [UIColor clearColor];
    [textView drawTextField:name];
    [self.indexView addSubview:textView];

}

-(void)buttonView{
    SensorButtonView *presenceSensor = [[SensorButtonView alloc]initWithFrame:CGRectMake(5,40,self.indexView.frame.size.width - 8,30 )];
    presenceSensor.color = [SFIColors clientGreenColor];
    [presenceSensor drawButton:@[@"YES",@"NO"] selectedValue:0];
    [self.indexView addSubview:presenceSensor];
}

@end
