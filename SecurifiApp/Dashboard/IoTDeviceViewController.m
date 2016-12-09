//
//  IoTDeviceViewController.m
//  
//
//  Created by Securifi-Mac2 on 07/12/16.
//
//

#import "IoTDeviceViewController.h"

@interface IoTDeviceViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *iotSwitch;

@end

@implementation IoTDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iotSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
