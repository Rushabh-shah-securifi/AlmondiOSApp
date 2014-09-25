//
//  SFIAffiliationViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/29/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIAffiliationViewController.h"
#import "Analytics.h"

@implementation SFIAffiliationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = @"Link Almond";
    [[Analytics sharedInstance] markAlmondAffiliation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.txtAffiliationCode.hidden = NO;
    self.btnAffiliationCode.hidden = NO;
    self.lblEnterMsg.hidden = NO;

    //Invisible Affiliation Complete Elements
    self.lblHooray.hidden = TRUE;
    self.lblMessage.hidden = TRUE;
    self.lblName.hidden = TRUE;
    self.lblSSID.hidden = TRUE;
    self.lblMAC.hidden = TRUE;
    self.lblSSIDTitle.hidden = TRUE;
    self.lblMACTitle.hidden = TRUE;
    self.lblNameTitle.hidden = TRUE;
    self.imgLine1.hidden = TRUE;
    self.imgLine2.hidden = TRUE;
    self.imgLine3.hidden = TRUE;
    self.imgLine4.hidden = TRUE;
    self.imgLine5.hidden = TRUE;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAffiliationUserComplete:)
                                                 name:AFFILIATION_COMPLETE_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAlmondListResponse:)
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLogoutResponse:)
                                                 name:kSFIDidLogoutNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALMOND_LIST_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFFILIATION_COMPLETE_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSFIDidLogoutNotification
                                                  object:nil];
}

#pragma mark - Keyboard Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtAffiliationCode) {
        [textField resignFirstResponder];
        //Send Affiliation Command
        [self sendAffiliationCode:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= AFFILIATION_CODE_CHAR_COUNT;
}

#pragma mark - Class Methods

- (NSString *)convertDecimalToMAC:(NSString *)decimalString {
    //Step 1: Conversion from decimal to hexadecimal
    DLog(@"%llu", (unsigned long long) [decimalString longLongValue]);
    NSString *hexIP = [NSString stringWithFormat:@"%llX", (unsigned long long) [decimalString longLongValue]];

    NSMutableString *wifiMAC = [[NSMutableString alloc] init];
    //Step 2: Divide in pairs of 2 hex
    for (NSUInteger i = 0; i < [hexIP length]; i = i + 2) {
        NSString *ichar = [NSString stringWithFormat:@"%c%c:", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i + 1]];
        [wifiMAC appendString:ichar];
    }

    [wifiMAC deleteCharactersInRange:NSMakeRange([wifiMAC length] - 1, 1)];

    DLog(@"WifiMAC: %@", wifiMAC);
    return wifiMAC;
}

- (IBAction)cancelButtonHandler:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logoutUser {
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_LOGOUT_COMMAND;
    cloudCommand.command = nil;

    [self asyncSendCommand:cloudCommand];
}

#pragma mark - Cloud Command : Sender and Receivers

- (IBAction)sendAffiliationCode:(id)sender {
    [self.txtAffiliationCode resignFirstResponder];
    NSLog(@"Affiliation Code: %@", self.txtAffiliationCode.text);

    if (self.txtAffiliationCode.text.length == 0) {
        return;
    }

    AffiliationUserRequest *affiliationCommand = [[AffiliationUserRequest alloc] init];
    affiliationCommand.Code = self.txtAffiliationCode.text;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_AFFILIATION_CODE_REQUEST;
    cloudCommand.command = affiliationCommand;

    [self asyncSendCommand:cloudCommand];

    self.lblEnterMsg.text = @"Please wait while your Almond is being linked to cloud.";
}

- (void)onAffiliationUserComplete:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    AffiliationUserComplete *obj = (AffiliationUserComplete *) [data valueForKey:@"data"];

    BOOL isSuccessful = obj.isSuccessful;
    self.lblEnterMsg.hidden = TRUE;
    self.txtAffiliationCode.hidden = TRUE;
    self.btnAffiliationCode.hidden = TRUE;

    if (isSuccessful) {
        //Display content
        self.lblHooray.hidden = FALSE;
        self.lblMessage.hidden = FALSE;
        self.lblName.hidden = FALSE;
        self.lblSSID.hidden = FALSE;
        self.lblMAC.hidden = FALSE;
        self.lblSSIDTitle.hidden = FALSE;
        self.lblMACTitle.hidden = FALSE;
        self.lblNameTitle.hidden = FALSE;
        self.imgLine1.hidden = FALSE;
        self.imgLine2.hidden = FALSE;
        self.imgLine3.hidden = FALSE;
        self.imgLine4.hidden = FALSE;
        self.imgLine5.hidden = FALSE;

        self.lblName.text = obj.almondplusName;
        self.lblMAC.text = [self convertDecimalToMAC:obj.almondplusMAC];

        // trim and array each sid on its own line
        NSMutableArray *ssids = [NSMutableArray arrayWithArray:[obj.wifiSSID componentsSeparatedByString:@","]];
        for (uint index=0; index < ssids.count; index++) {
            NSString *sid = ssids[index];
            ssids[index] = [sid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
        }
        self.lblSSID.text = [ssids componentsJoinedByString:@"\n"];


        //Change title
        self.navigationItem.title = @"Almond Linked";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonHandler:)];
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        //Display content
        self.lblHooray.hidden = FALSE;
        self.lblMessage.hidden = FALSE;
        self.lblHooray.text = @"Oops!";

        //Handle different reason codes
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"Please try later.";
                break;
            case 2:
            case 3:
                failureReason = @"Please enter a valid code.";
                break;
            case 4:
                failureReason = @"This Almond is already linked to another user. \nContact us at support@securifi.com";
                break;
            case 5:
            case 6:
            case 7:
                //Logout
                failureReason = @"Please login again and retry.";
                self.lblMessage.text = [NSString stringWithFormat:@"Almond could not be affiliated.\n%@", failureReason];;
                [self logoutUser];
                break;

            default:
                break;
        }

        NSString *log = [NSString stringWithFormat:@"Almond could not be affiliated.\n%@", failureReason];
        self.lblMessage.text = log;
    }
}

- (void)loadAlmondList {
    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_ALMOND_LIST;
    cloudCommand.command = almondListCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onAlmondListResponse:(id)sender {
//    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = [notifier userInfo];
//
//    if (data != nil) {
//        [SNLog Log:@"%s: Received Almond List response", __PRETTY_FUNCTION__];
//
//        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
//
//        [SNLog Log:@"%s: List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];
//        //Write Almond List offline
//        [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
//    }

    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    // [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onLogoutResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        LogoutResponse *obj = (LogoutResponse *) [data valueForKey:@"data"];
        if (!obj.isSuccessful) {
            NSLog(@"Could not logout - Reason %@", obj.reason);
            NSString *alertMsg = @"Sorry. Logout was unsuccessful. Please try again.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Unsuccessful"
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}


@end
