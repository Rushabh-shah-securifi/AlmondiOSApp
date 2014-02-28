//
//  RouterTempController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 31/12/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "RouterTempController.h"
#import "AlmondPlusConstants.h"
@interface RouterTempController ()

@end

@implementation RouterTempController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	//Set title
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentMACName  = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC_NAME];
    if(currentMACName!=nil){
        self.navigationItem.title = currentMACName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
