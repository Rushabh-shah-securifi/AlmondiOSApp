//
//  AdvRouterHelpController.m
//  SecurifiApp
//
//  Created by Masood on 10/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AdvRouterHelpController.h"
#import "CommonMethods.h"
#import "SFIColors.h"

@interface AdvRouterHelpController ()

@end

@implementation AdvRouterHelpController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    [self showHelp];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHelp{
    switch (self.helpType) {
        case Feature_Vpn:
            [self showVpnHelp];
            break;
        case Feature_Port_Forwarding:
            break;
        case Feature_DNS:
            break;
        case Feature_Static_IP_Settings:
            break;
        case Feature_UPnP:
            break;
        default:
            break;
    }
}

- (void)showVpnHelp{
    
    UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    NSString *text = @"Scenes make adjusting multiple smart devices much easier and faster. For example, when you go to bed you might have two or three lights to turn off, the temperature on the thermostat to adjust, and set the alarm to activate. A Scene means you can do all of them with just one tap.\n\nYou can create and manage Scenes from the Scenes tab in the Almond app. Tap the add button to create a scene. And then tap on a device and select one or more actions from the available options. ";
    [CommonMethods setLableProperties:detail text:text textColor:[SFIColors ruleGraycolor] fontName:@"AvenirLTStd-Roman" fontSize:16 alignment:NSTextAlignmentLeft];
    [CommonMethods setLineSpacing:detail text:text spacing:3];
    [detail sizeToFit];
    detail.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:detail];
}
@end
