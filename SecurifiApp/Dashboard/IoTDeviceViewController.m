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
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;
@property (weak, nonatomic) IBOutlet UILabel *explanationLable;



@end

@implementation IoTDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iotSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
    if([self.iotDevice[@"case"] isEqualToString:@"1"])
       self.topView.backgroundColor = [UIColor redColor];
    else if([self.iotDevice[@"case"] isEqualToString:@"2"])
        self.topView.backgroundColor = [UIColor orangeColor];
    self.explanationLable.text = [self setExplanationText:self.iotDevice[@"Type"]];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
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
-(NSString *)setExplanationText:(NSString *)type{
    if([type isEqualToString:@"1"])
        return @"Your device  has an open telnet (port:80) and uses a weak username and password. Telnet enabled devices are highly vulnerable to Mirai Botnet attacks. We suggest you block this device or create a strong username and password if you can access the telnet. Contact your device vendor for more assistance.Learn More ";
    else if([type isEqualToString:@"2"])
        return @"Your device has open ports. These ports may be used by some applications for allowing remote access of your system. If you do not use this device for such applications,it may be vulnerable. We suggest you block this device or contact your device vendor Learn More ";
    else if([type isEqualToString:@"3"])
        return @"The local web interface for this device uses a weak username and password. We suggest you block the device or change the password. Typically, settings can be accessed by entering the ip address of the device in your web browser. Contact your device vendor for more assistance.Learn More";
    else if([type isEqualToString:@"4"])
        return @"Your device is being used for port forwarding. Port forwarding is usually enabled manually for gaming applications and for remote access of cameras and DVRs. If you are not aware of port forwarding for this device, we suggest you block this device or contact your device vendor.Learn More";
    else
        return @"UPnP is a protocol that applications use to automatically set up port forwarding in the router. Viruses and Malwares can use UPnP in devices to gain remote access of your network. You can disable UPnP on your Almond from the Wifi tab.Learn More";
}

@end
