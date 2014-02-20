//
//  SFIViewController.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIViewController.h"
#import "SFILoginViewController.h"
#import "SFIDimmerViewController.h"
#import "SFIThermViewController.h"

@interface SFIViewController ()
{
    //NSMutableArray  *data;
}

@end

@implementation SFIViewController
@synthesize tableView;
@synthesize data;

+ (UIImage*)scaleImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //data = [NSMutableArray arrayWithObjects:@"TEST1", @"TEST2", @"TEST3", nil];
   
    NSLog(@"from SFI View%@",data);
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    UINavigationBar *navbar = [[self navigationController] navigationBar];
   
    // navbar.tintColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
    navbar.tintColor = [UIColor darkTextColor];
    self.tableView.separatorColor = [UIColor grayColor];
}

- (void)logout
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *loginView = [storyboard instantiateViewControllerWithIdentifier:@"SFILoginViewController"];
    [self presentViewController:loginView animated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DeviceListCell";
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    /* load dictionary in to array */
    
    NSArray *keys = [self.data allKeys];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
   // cell.textLabel.text = [data objectAtIndex:indexPath.row];
    cell.textLabel.text = [keys objectAtIndex:indexPath.row];
    //cell.textLabel.text = [self.data objectForKey:[keys objectAtIndex:indexPath.row]];
   
    CGSize img = CGSizeMake(44.0,44.0);
    // cell.imageView.image = [UIImage imageNamed:@"logo_modified.png"];
    cell.imageView.image = [[self class] scaleImage:[UIImage imageNamed:@"logo_modified.png"] scaledToSize:img];
    
    /* has router on/off value */
    int val = [[self.data objectForKey:[keys objectAtIndex:indexPath.row]]integerValue];
    NSLog(@"ON / OFF Value %d",val);
               
    UIButton *accessoryView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    if (val == 1)
    {
        //[accessoryView setBackgroundColor:[UIColor greenColor]];
        UIImage *img = [UIImage imageNamed:@"tick_1.png"];
        
        [accessoryView setBackgroundImage:img forState:UIControlStateNormal];
        cell.userInteractionEnabled=YES;
    }
    else
    {
        UIImage *img = [UIImage imageNamed:@"cross_1.png"];
        [accessoryView setBackgroundImage:img forState:UIControlStateNormal];
        cell.textLabel.textColor = [UIColor lightGrayColor];
       // [accessoryView setBackgroundColor:[UIColor redColor]];
        cell.userInteractionEnabled = NO;
    }
    [cell setAccessoryView:accessoryView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableViewGlobal didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectedRowAtIndex -- Clicked on %d",indexPath.row);
    
   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
   NSString *cellText = cell.textLabel.text;
   
    //Parsing should be based on indexPath
    if ([cellText isEqualToString:@"Thermostate"])
        [self performSegueWithIdentifier:@"thermostate" sender:nil];
    else if ([cellText isEqualToString:@"Dimmer"])
        [self performSegueWithIdentifier:@"dimmer" sender:nil];
    else if ([cellText isEqualToString:@"Switch"])
        [self performSegueWithIdentifier:@"PowerSwitch" sender:nil];
    else if ([cellText isEqualToString:@"Door Sensor"])
        [self performSegueWithIdentifier:@"doorSensor" sender:nil];
    
    /*
    if (indexPath.row == 0)
    [self performSegueWithIdentifier:@"thermostate" sender:nil];
    else if (indexPath.row == 1)
    [self performSegueWithIdentifier:@"dimmer" sender:nil];
    else if (indexPath.row == 2)
        [self performSegueWithIdentifier:@"PowerSwitch" sender:nil];
     */
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"acessoryButton -- Clicked on %d",indexPath.row);
    //[self performSegueWithIdentifier:@"showDetail" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  /*
    if ([segue.identifier isEqualToString:@"dimmer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSLog(@"prepare for degue Clicked on %d",indexPath.row);
     
        SFI *destViewController = segue.destinationViewController;
        //destViewController.deviceName = [data objectAtIndex:indexPath.row];
    }

*/
}
@end
