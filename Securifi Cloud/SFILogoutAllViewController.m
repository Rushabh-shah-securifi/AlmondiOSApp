//
//  SFILogoutAllViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFILogoutAllViewController.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SNLog.h"
#import "SFIDatabaseUpdateService.h"
#import "AlmondPlusConstants.h"
#import "SFIOfflineDataManager.h"

@implementation SFILogoutAllViewController
@synthesize emailID,password,keyboardToolbar;
@synthesize logMessageLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    UIToolbar *toolbar = [[UIToolbar alloc] init];
//    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
//    toolbar.tintColor=[UIColor blackColor];

//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [[SNLog logManager] addLogStrategy:logger];

    
  //  NSMutableArray *items = [[NSMutableArray alloc] init];
    
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    
//    [items addObject:flexibleSpace];
//    [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneHandler)]];
//    
//    [toolbar setItems:items animated:NO];
//    [self.view addSubview:toolbar];
    //Register callback for signup response
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LogoutAllResponseCallback:)
                                                 name:LOGOUT_ALL_NOTIFIER
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
//    if (keyboardToolbar == nil)
//    {
//        keyboardToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
//        
//        UIBarButtonItem *previousButton = [[UIBarButtonItem alloc]
//                                           initWithTitle:@"Previous"
//                                           style:UIBarButtonItemStyleBordered
//                                           target:self action:@selector(previousField:)];
//        
//        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
//                                       initWithTitle:@"Next"
//                                       style:UIBarButtonItemStyleBordered
//                                       target:self action:@selector(nextField:)];
//        
//        UIBarButtonItem *extra  =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        
//        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
//        
//        [keyboardToolbar setItems:[[NSArray alloc] initWithObjects:previousButton, nextButton, extra, doneButton, nil]];
//        [keyboardToolbar setBarStyle:UIBarStyleBlackTranslucent];
//        
//        emailID.inputAccessoryView = keyboardToolbar;
//        password.inputAccessoryView = keyboardToolbar;
//        
//        //change text user and pass field
////        password.borderStyle = UITextBorderStyleRoundedRect;
////        emailID.borderStyle = UITextBorderStyleRoundedRect;
//    }
    
}

#pragma mark - Keyboard Methods
//- (void)keyboardDidShow:(NSNotification *)notification
//{
//    //Assign new frame to your view
//    [self.view setFrame:CGRectMake(0,-10,self.view.frame.size.width,self.view.frame.size.height)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
//    
//}
//
//-(void)keyboardDidHide:(NSNotification *)notification
//{
//    [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//}


- (void) resignKeyboard:(id)sender {
    
    if ([emailID isFirstResponder])
        [emailID resignFirstResponder];
    
    else if ([password isFirstResponder])
        [password resignFirstResponder];
}

- (void) previousField:(id)sender {
    if ([emailID isFirstResponder])
        [password becomeFirstResponder];
    else if ([password isFirstResponder])
        [emailID becomeFirstResponder];
}

- (void) nextField:(id)sender{
    if ([emailID isFirstResponder])
        [password becomeFirstResponder];
    else if ([password isFirstResponder])
        [emailID becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailID) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)backClick:(id)sender {
    if ([emailID isFirstResponder])
        [emailID resignFirstResponder];
    
    else if ([password isFirstResponder])
        [password resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cloud commands
-(void)LogoutAllResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received Logout response", __PRETTY_FUNCTION__];
        
        LogoutAllResponse *obj = [[LogoutAllResponse alloc] init];
        obj = (LogoutAllResponse *)[data valueForKey:@"data"];
        
        [SNLog Log:@"Method Name: %s is Successful : %d", __PRETTY_FUNCTION__,obj.isSuccessful];
        [SNLog Log:@"Method Name: %s Reason : %@", __PRETTY_FUNCTION__,obj.reason];
        

        if (obj.isSuccessful == 0)
        {
            logMessageLabel.text=obj.reason;
        }
        else
        {

            
            [SNLog Log:@"Method Name: %s Logout All successful - All connections closed!", __PRETTY_FUNCTION__];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SFIDatabaseUpdateService stopDatabaseUpdateService];
            });
            
            //PY 170913 - Use navigation controller
            //[self.navigationController popViewControllerAnimated:YES];
            //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs removeObjectForKey:EMAIL];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
            [prefs removeObjectForKey:USERID];
            [prefs removeObjectForKey:PASSWORD];
            [prefs removeObjectForKey:COLORCODE];
            [prefs synchronize];
            
            //Delete files
            [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
            [SFIOfflineDataManager deleteFile:HASH_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
            [self presentViewController:mainView animated:YES completion:nil];
            
//            //PY 170913 - Use navigation controller
//            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    else{
        [SNLog Log:@"Method Name: %s Logout All successful - All connections closed!", __PRETTY_FUNCTION__];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SFIDatabaseUpdateService stopDatabaseUpdateService];
        });
        
        //PY 170913 - Use navigation controller
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs removeObjectForKey:EMAIL];
        [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
        [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
        [prefs removeObjectForKey:USERID];
        [prefs removeObjectForKey:PASSWORD];
        [prefs removeObjectForKey:COLORCODE];
        [prefs synchronize];
        
        //Delete files
        [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        [self presentViewController:mainView animated:YES completion:nil];

    }
    
    
}

- (void)doneHandler
{

    //PY 170913 - Use navigation controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutAllButtonHandler:(id)sender {
    self.logMessageLabel.text = @"";

    if ([self.emailID isFirstResponder]) {
        [self.emailID resignFirstResponder];

    }
    else if ([self.password isFirstResponder]) {
        [self.password resignFirstResponder];
    }

    LogoutAllRequest *logoutAllCommand = [[LogoutAllRequest alloc] init];
    logoutAllCommand.UserID = [NSString stringWithString:self.emailID.text];
    logoutAllCommand.Password = [NSString stringWithString:self.password.text];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = LOGOUT_ALL_COMMAND;
    cloudCommand.command = logoutAllCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"LogoutAllResponseNotifier"
                                                  object:nil];
}


@end
