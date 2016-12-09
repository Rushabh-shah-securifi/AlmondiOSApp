//
//  IoTDeviceViewController.m
//  
//
//  Created by Securifi-Mac2 on 07/12/16.
//
//

#import "IoTDeviceViewController.h"
#import "BrowsingHistoryViewController.h"

@interface IoTDeviceViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *iotSwitch;

@end

@implementation IoTDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iotSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES ];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)viewActivityClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    BrowsingHistoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
    viewController.is_IotType = YES;
    
//    viewController.client = self.client;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
