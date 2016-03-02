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


@interface ClientEditPropertiesViewController ()
@property (weak, nonatomic) IBOutlet UIView *clientInfoView;

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
        
    }
    else if ([self.indexName isEqualToString:@"Type"]){
        
    }
    
    else if ([self.indexName isEqualToString:@"Allow"]){
        
    }
    else if ([self.indexName isEqualToString:@"pesenceSensor"]){
        
    }
    else if ([self.indexName isEqualToString:@"inActiveTimeOut"]){
        [self textFieldView];
    }
    else if ([self.indexName isEqualToString:@"Other"]){
        
    }

}
-(void)textFieldView{
    
}

-(void)buttonView{
    
}

@end
