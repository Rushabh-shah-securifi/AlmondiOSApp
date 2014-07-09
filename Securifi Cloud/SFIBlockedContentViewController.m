//
//  SFIBlockedContentViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 18/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIBlockedContentViewController.h"
#import "SNLog.h"
#import "AlmondPlusConstants.h"
#import "SFIGenericRouterCommand.h"
#import "SFIParser.h"

@implementation SFIBlockedContentViewController
@synthesize blockedContentArray, mobileInternalIndex, addBlockedContentArray, setBlockedContentArray;
@synthesize txtBlockedText, actionType;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.tableView.separatorColor = [UIColor clearColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(setBlockedContentHandler:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.addBlockedContentArray = [[NSMutableArray alloc]init];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.title = @"Blocked Content";
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    NSString *xml = @"<root><AlmondBlockedContent><BlockedText>abcd</BlockedText><BlockedText>xyz123</BlockedText></AlmondBlockedContent>";
    //    SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:xml];
    //    NSLog(@"Command Type %d", genericRouterCommand.commandType);
    //    SFIDevicesList *routerSettings = (SFIDevicesList*)genericRouterCommand.command;
    //    self.blockedContentArray = [routerSettings.deviceList mutableCopy];
    
    [self sendGenericCommandRequest:GET_BLOCKED_CONTENT_COMMAND];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(GenericResponseCallback:)
                   name:GENERIC_COMMAND_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];

    self.actionType = @"";
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GENERIC_COMMAND_NOTIFIER
                                                  object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    //NSLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [blockedContentArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    header.backgroundColor = [UIColor clearColor];// [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,40)];
    //backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    [header addSubview:backgroundLabel];
    
    txtBlockedText = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, self.tableView.frame.size.width-100,35)] ;
    txtBlockedText.placeholder = @"Enter keyword, url to block";
    txtBlockedText.textColor = [UIColor blackColor];
    //[field setBorderStyle:UITextBorderStyleBezel];
    [header addSubview:txtBlockedText];
    
    UIButton *btnAdd = [[UIButton alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width-75,7,65,30)];
//    btnAdd.backgroundColor = [UIColor whiteColor];
    [btnAdd setTitleColor:[UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1] forState:UIControlStateNormal ];
    [btnAdd setTitle:@"Add" forState:UIControlStateNormal];
    [btnAdd setTitle:@"Add" forState:UIControlStateHighlighted];
    [btnAdd setTitle:@"Add" forState:UIControlStateDisabled];
    [btnAdd setTitle:@"Add" forState:UIControlStateSelected];
    [btnAdd addTarget:self action:@selector(btnAddClicked:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnAdd];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    
    SFIBlockedContent *currentBlockedValue = [blockedContentArray objectAtIndex:indexPath.row];
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,tableView.frame.size.width-20,40)];
    backgroundLabel.userInteractionEnabled = YES;
    
    if(currentBlockedValue.isSelected){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //backgroundLabel.backgroundColor = [UIColor grayColor];
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        //backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
        //backgroundLabel.backgroundColor = [UIColor clearColor];
    }
    
    UILabel *lblOption = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 20)];
    lblOption.backgroundColor = [UIColor clearColor];
    [lblOption setFont:[UIFont fontWithName:@"Avenir-Roman" size:14]];
    lblOption.text = currentBlockedValue.blockedText;
    lblOption.textColor = [UIColor blackColor];
    [backgroundLabel addSubview:lblOption];
    [cell addSubview:backgroundLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //cell.textLabel.text = currentBlockedValue.blockedText;
    
    
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.addBlockedContentArray = blockedContentArray;
    SFIBlockedContent *currentUIContent = [blockedContentArray objectAtIndex:indexPath.row];
    //SFIBlockedContent *currentXMLContent = [setBlockedContentArray objectAtIndex:indexPath.row];
    
    if(currentUIContent.isSelected){
        currentUIContent.isSelected = FALSE;
        // [self.setBlockedContentArray addObject:currentXMLContent];
    }else{
        currentUIContent.isSelected = TRUE;
        // [self.setBlockedContentArray removeObject:currentXMLContent];
    }
    NSLog(@"Row Clicked %d - Option %@", indexPath.row, currentUIContent.blockedText);
    actionType = @"set";
    [self.tableView reloadData];
}


-(void)btnAddClicked:(id)sender{
    NSLog(@"Add button clicked: %@", txtBlockedText.text);
    SFIBlockedContent *newContent = [[SFIBlockedContent alloc]init];
    newContent.blockedText = txtBlockedText.text;
    if(![self.actionType isEqualToString:@"set"]){
        self.actionType = @"add";
        [self.addBlockedContentArray addObject:newContent];
    }
    
    [self.blockedContentArray addObject:newContent];
    [self.tableView reloadData];
}

- (IBAction)setBlockedContentHandler:(id)sender{
    NSLog(@"Send data to cloud");
    //TODO: Create xml
    //    <root>
    //    <AlmondBlockedContent action="set|add" count=”2”>
    //    <BlockedText index=”1”>quickbrownfox</BlockedText>
    //    <BlockedText index=”2”>lazydog</BlockedText>
    //    </AlmondBlockedContent>
    //    </root>
    NSMutableArray *xmlArray = [[NSMutableArray alloc]init];
    if([actionType isEqualToString:@"set"]){
        for(SFIBlockedContent *currentContent in self.blockedContentArray){
            if(!currentContent.isSelected){
                [xmlArray addObject:currentContent];
            }
        }
    }else{
        xmlArray = self.addBlockedContentArray;
    }
    
    NSString *payload = [NSString stringWithFormat:@"<root><AlmondBlockedContent action=\"%@\" count=\"%lu\">",self.actionType, (unsigned long)[xmlArray count]];
    int i = 1;
    for(SFIBlockedContent *currentContent in xmlArray){
        NSString *newString = [NSString stringWithFormat:@"<BlockedText index=\"%d\">%@</BlockedText>",i, currentContent.blockedText];
        payload = [payload stringByAppendingString:newString];
        i++;
    }
    payload = [payload stringByAppendingString:@"</AlmondBlockedContent></root>"];
    NSLog(@"Payload: %@", payload);
    [self sendGenericCommandRequest:payload];
}

#pragma mark - Cloud command handlers

- (void)sendGenericCommandRequest:(NSString *)data {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    self.mobileInternalIndex = (arc4random() % 1000) + 1;

    NSString *currentMAC = [[SecurifiToolkit sharedInstance] currentAlmondName];

    GenericCommandRequest *setWirelessSettingGenericCommand = [[GenericCommandRequest alloc] init];
    setWirelessSettingGenericCommand.almondMAC = currentMAC;
    setWirelessSettingGenericCommand.applicationID = APPLICATION_ID;
    setWirelessSettingGenericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d", self.mobileInternalIndex];
    setWirelessSettingGenericCommand.data = data;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = GENERIC_COMMAND_REQUEST;
    cloudCommand.command = setWirelessSettingGenericCommand;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

-(void)GenericResponseCallback:(id)sender
{
    [SNLog Log:@"Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received GenericCommandResponse",__PRETTY_FUNCTION__];
        
        GenericCommandResponse *obj = (GenericCommandResponse *)[data valueForKey:@"data"];
        
        BOOL isSuccessful = obj.isSuccessful;
        if(isSuccessful){
            NSMutableData *genericData = [[NSMutableData alloc] init];
            int expectedGenericDataLength, command;
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData* data =  [obj.decodedData mutableCopy];  //[obj.genericData dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"Data: %@", data);
            
            [genericData appendData:data];
            
            [genericData getBytes:&expectedGenericDataLength range:NSMakeRange(0, 4)];
            [SNLog Log:@"Method Name: %s Expected Length: %d", __PRETTY_FUNCTION__,expectedGenericDataLength];
            [genericData getBytes:&command range:NSMakeRange(4,4)];
            [SNLog Log:@"Method Name: %s Command: %d", __PRETTY_FUNCTION__,command];
            
            //Remove 8 bytes from received command
            [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
            
            NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
            SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
            NSLog(@"Command Type %d", genericRouterCommand.commandType);
            if(genericRouterCommand.commandType == 5){
                SFIDevicesList *routerSettings = (SFIDevicesList*)genericRouterCommand.command;
                self.blockedContentArray = [routerSettings.deviceList mutableCopy];
                [self.addBlockedContentArray removeAllObjects];
                self.setBlockedContentArray = [self.blockedContentArray mutableCopy];
                [self.tableView reloadData];
            }
        }else{
            NSLog(@"Reason: %@", obj.reason);
        }
    }
}

- (void)onAlmondListDidChange:(id)sender {

}

- (void)_onAlmondListDidChange:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
        if (obj.isSuccessful) {
            [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];

            SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
            SFIAlmondPlus *plus = [toolkit currentAlmond];

            SFIAlmondPlus *deletedAlmond = [obj.almondPlusMACList objectAtIndex:0];
            if ([plus.almondplusMAC isEqualToString:deletedAlmond.almondplusMAC]) {
                [SNLog Log:@"Method Name: %s Remove this view", __PRETTY_FUNCTION__];
                NSArray *almondList = [toolkit almondList];

                if ([almondList count] != 0) {
                    SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
                    [toolkit setCurrentAlmond:currentAlmond colorCodeIndex:0];
                    self.navigationItem.title = currentAlmond.almondplusName;
                }
                else {
                    self.navigationItem.title = @"Get Started";
                    [toolkit removeCurrentAlmond];
                }

                [self.navigationController popToRootViewControllerAnimated:YES];
            }

        }

    }
}



@end
