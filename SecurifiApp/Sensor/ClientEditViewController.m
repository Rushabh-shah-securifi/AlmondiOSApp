//
//  ClientEditViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientEditViewController.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"


@interface ClientEditViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewClientFields;

@end

@implementation ClientEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dummyNetWorkDeviceList];
    [self drawClientField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dummyNetWorkDeviceList{
    NSDictionary *dict1 = @{@"Name" : @"unknown",
                            @"Type" : @{@"Tablate" : @"false",
                                        @"PC" : @"false",
                                        @"smartPhone" : @"true",
                                        @"iPhone" : @"false",
                                        @"iPad" : @"false",
                                        @"iPod" : @"false",
                                        @"MAC" : @"false",
                                        @"TV" : @"false",
                                        @"printer" : @"false",
                                        @"Router_switch" : @"false",
                                        @"Nest" : @"false",
                                        @"Hub" : @"false",
                                        @"Camara" : @"false",
                                        @"ChromeCast" : @"false",
                                        @"android_stick" : @"false",
                                        @"amazone_exho" : @"false",
                                        @"amazone-dash" : @"false ",
                                        @"Other" : @"false"
                                        },
                            @"Manufacture" : @"freedom",
                            @"MAC Address" : @"10.21.45.53.58",
                            @"Last Known IP" : @"10.21.1.100",
                            @"Signal Strength" : @"-33 dBm",
                            @"Connection" : @"wireLess",
                            @"Allow On network" : @{
                                                    @"always" : @"true",
                                                    @"Schedule" : @"false",
                                                    @"Never" : @"false"
                                                    },
                            @"use as pesence sensor" : @"true",
                            @"inActiveTimeOut" : @"32"
                            };
    self.clientProperties = dict1;
    
    
}
-(void)drawClientField{
     int yPos = 10;
        self.scrollViewClientFields.backgroundColor = [SFIColors clientGreenColor];
     NSArray *ordering = [self.connectedDevice allKeys];
    NSMutableArray *index = [[NSMutableArray alloc] init];
    NSEnumerator *sectEnum = [ordering objectEnumerator];
    id sKey;
    while((sKey = [sectEnum nextObject])) {
        if ([self.connectedDevice objectForKey:sKey] != nil ) {
            [index addObject:sKey];
        }
    }

    for(NSString *keys in index){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10 , yPos, self.scrollViewClientFields.frame.size.width -10, 40)];
        view.backgroundColor = [UIColor clearColor];
        [self.scrollViewClientFields addSubview:view];
        CGRect textRect = [self adjustDeviceNameWidth:keys];
        CGRect frame = CGRectMake(5 , 10, textRect.size.width + 10, 20);
        
        UILabel *label = [[UILabel alloc]initWithFrame:frame];
        label.text = keys;
        NSLog(@"keys %@ ",keys);
        label.font = [UIFont securifiFont:16];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        UIButton *valueButton = [[UIButton alloc]initWithFrame:CGRectMake(view.frame.size.width - 110, 10, 100, 20)];
        [valueButton setTitle:[self.connectedDevice valueForKey:keys] forState:UIControlStateNormal];
        valueButton.titleLabel.font = [UIFont securifiFont:14];
        valueButton.titleLabel.textColor = [UIColor whiteColor];
        valueButton.titleLabel.textAlignment = NSTextAlignmentRight;
        valueButton.alpha = 0.5;
        
        [view addSubview:valueButton];
        yPos = yPos + view.frame.size.height;
        
        
    }
    
}
-(CGRect)adjustDeviceNameWidth:(NSString*)deviceName{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont securifiFont:16]};
    CGRect textRect;
    
    textRect.size = [deviceName sizeWithAttributes:attributes];
    if(deviceName.length > 18){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
}
@end
