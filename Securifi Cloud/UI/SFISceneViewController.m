//
//  SFISceneViewController.m
//  SecurifiUI
//
//  Created by Priya Yerunkar on 09/10/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SFISceneViewController.h"
#import "SFIColors.h"
#import "SFIScene.h"
#import "SFIParser.h"
#import "AlmondPlusConstants.h"

@interface SFISceneViewController ()

@end

@implementation SFISceneViewController
@synthesize sensors;
@synthesize scenes;
@synthesize listAvailableColors, sceneSensorColors;
@synthesize sceneSensorMap;
@synthesize changeBrightness, changeHue, changeSaturation;
@synthesize baseBrightness;

static NSString *simpleTableIdentifier = @"SensorCell";

- (void)awakeFromNib
{
    
    SFIScene *sceneNight = [[SFIScene alloc]init];
    sceneNight.name = @"Night";
    sceneNight.isExpanded = FALSE;
    sceneNight.sensorCount = @"9";
    
    SFIScene *sceneMovie = [[SFIScene alloc]init];
    sceneMovie.name = @"Movie";
    sceneMovie.isExpanded = FALSE;
    sceneMovie.sensorCount = @"4";
    
    SFIScene *sceneWeekend = [[SFIScene alloc]init];
    sceneWeekend.name = @"Weekend";
    sceneWeekend.isExpanded = FALSE;
    sceneWeekend.sensorCount = @"3";
    
    SFIScene *sceneMorning = [[SFIScene alloc]init];
    sceneMorning.name = @"Morning";
    sceneMorning.isExpanded = FALSE;
    sceneMorning.sensorCount = @"3";
    
    SFIScene *sceneParty = [[SFIScene alloc]init];
    sceneParty.name = @"Party";
    sceneParty.isExpanded = FALSE;
    sceneParty.sensorCount = @"3";
    
    SFIScene *sceneStudy = [[SFIScene alloc]init];
    sceneStudy.name = @"Study";
    sceneStudy.isExpanded = FALSE;
    sceneStudy.sensorCount = @"3";
    
    SFIScene *sceneEvening = [[SFIScene alloc]init];
    sceneEvening.name = @"Evening";
    sceneEvening.isExpanded = FALSE;
    sceneEvening.sensorCount = @"3";
    
    SFIScene *sceneKids = [[SFIScene alloc]init];
    sceneKids.name = @"Kids";
    sceneKids.isExpanded = FALSE;
    sceneKids.sensorCount = @"3";
    self.scenes = [NSArray arrayWithObjects:sceneNight, sceneMovie, sceneWeekend, sceneMorning, sceneParty, sceneStudy, sceneEvening, sceneKids, nil];
    
    self.sceneSensorMap = [NSMutableDictionary dictionary];
    
    //self.scenes = [NSArray arrayWithObjects:@"Night", @"Movie",@"Weekend", nil];
    
    // self.sensors = [NSArray arrayWithObjects:@"1", @"2", nil];
    
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
    
//    self.view.autoresizingMask= UIViewAutoresizingFlexibleWidth;
//    self.view.autoresizesSubviews= YES;
    
    
    //Set title
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
   // NSString *currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];
    NSString *currentMACName  = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC_NAME];
    if(currentMACName!=nil){
        self.navigationItem.title = currentMACName;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    self.sceneSensorColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Display Drawer Gesture
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealMenu:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:showMenuSwipe];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [scenes count] + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [scenes objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 85;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 80)];
    
    if( section == [scenes count]){
        //Display Add Row
        UIImageView *imgAddScene =[[UIImageView alloc]initWithFrame:CGRectMake(110, 10, 80,80)];
        imgAddScene.userInteractionEnabled = YES;
        imgAddScene.image = [UIImage imageNamed:@"add_new.png"];
        
        UIButton *btnAddScene = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddScene.frame = imgAddScene.bounds;
        btnAddScene.backgroundColor = [UIColor clearColor];
        btnAddScene.tag = section;
        [btnAddScene addTarget:self action:@selector(onAddSceneClicked:) forControlEvents:UIControlEventTouchUpInside];
        [imgAddScene addSubview:btnAddScene];
        
        UIButton *btnAddSceneCell = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddSceneCell.frame = view.bounds;
        btnAddSceneCell.backgroundColor = [UIColor clearColor];
        btnAddSceneCell.tag = section;
        [btnAddSceneCell addTarget:self action:@selector(onAddSceneClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnAddSceneCell];
        
        [view addSubview:imgAddScene];
        return view;
    }
    
    //Display the scenes custom section
    SFIColors *currentColor;
    SFIScene *currentScene = [scenes objectAtIndex:section];
    
    if(section >= [listAvailableColors count]){
        currentColor = [listAvailableColors objectAtIndex:section % [listAvailableColors count]];
    }else{
        currentColor = [listAvailableColors objectAtIndex:section];
    }
    
    // NSLog(@"SECTION: =====> HUE %d, Brightness %d, Saturation %d", currentColor.hue, currentColor.brightness, currentColor.saturation);
    UILabel *leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,5,(self.tableView.frame.size.width/4),80)];
    leftBackgroundLabel.userInteractionEnabled = YES;
    
    leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:currentColor.hue/360.0 saturation:currentColor.saturation/100.0 brightness:currentColor.brightness/100.0 alpha:1];
    
    UIImageView *imgActivate = [[UIImageView alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width/4)/4, 20, 50,38.5)];
    imgActivate.userInteractionEnabled = YES;
    imgActivate.image = [UIImage imageNamed:@"tick_mark.png"];
    
    if(currentScene.isActivated){
        imgActivate.alpha = 1;
    }else{
        imgActivate.alpha = 0.5;
    }
    
    UIButton *btnActivate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnActivate.frame = imgActivate.bounds;
    btnActivate.backgroundColor = [UIColor clearColor];
    [btnActivate addTarget:self action:@selector(onActivateClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnActivate.tag = section;
    [imgActivate addSubview:btnActivate];
    
    UIButton *btnActivateCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnActivateCell.frame = leftBackgroundLabel.bounds;
    btnActivateCell.backgroundColor = [UIColor clearColor];
    [btnActivateCell addTarget:self action:@selector(onActivateClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnActivateCell.tag = section;
    [leftBackgroundLabel addSubview:btnActivateCell];
    
    [leftBackgroundLabel addSubview:imgActivate];
    
    UILabel *rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width/4)+11,5,(self.tableView.frame.size.width/1.5),80)];
    
    rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:currentColor.hue/360.0 saturation:currentColor.saturation/100.0 brightness:currentColor.brightness/100.0 alpha:1];
    [view addSubview:rightBackgroundLabel];
    
    UIButton *btnExpandCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExpandCell.frame = CGRectMake((self.tableView.frame.size.width/4)+11,5,self.tableView.frame.size.width - (self.tableView.frame.size.width/4) ,80);
    btnExpandCell.backgroundColor = [UIColor clearColor];
    [btnExpandCell addTarget:self action:@selector(onSceneClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnExpandCell.tag = section;
    [view addSubview:btnExpandCell];
    
    UILabel *lblSceneName = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 180, 40)];
    lblSceneName.backgroundColor = [UIColor clearColor];
    lblSceneName.textColor = [UIColor whiteColor];
    [rightBackgroundLabel addSubview:lblSceneName];
    [lblSceneName setFont:[UIFont fontWithName:@"Avenir-Light" size:32]];
    lblSceneName.text = currentScene.name;
    
    UILabel *lblSceneSensorCount = [[UILabel alloc]initWithFrame:CGRectMake(15, 45, 180, 40)];
    lblSceneSensorCount.backgroundColor = [UIColor clearColor];
    lblSceneSensorCount.textColor = [UIColor whiteColor];
    [rightBackgroundLabel addSubview:lblSceneSensorCount];
    [lblSceneSensorCount setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
    lblSceneSensorCount.text = [NSString stringWithFormat:@"%@ SENSORS",currentScene.sensorCount];
    
    UIImageView *imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 35, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;
    //NSLog(@"Name: %@ Expanded: %hhd", currentScene.name, currentScene.isExpanded);
    if(currentScene.isExpanded){
        imgSettings.alpha = 1;
    }else{
        imgSettings.alpha = 0.5;
    }
    
    
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnSettings.tag = section;
    [imgSettings addSubview:btnSettings];
    [view addSubview:imgSettings];
    
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, tableView.frame.size.width, 80)];
    //    [label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
    //    [label setTextColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0]];
    //    [view addSubview:label];
    //    [label setText:[scenes objectAtIndex:section]];
    [view addSubview:leftBackgroundLabel];
    //[view setBackgroundColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == [scenes count]){
        return 0;
    }
    SFIScene *currentScene = [scenes objectAtIndex:section];
    if(currentScene.isExpanded){
        
        return [[sceneSensorMap objectForKey:[NSString stringWithFormat:@"%d",section]] count];
    }else{
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{

       // if(indexPath.row != [sensors count]){
        NSArray *currentSensorArray = [sceneSensorMap objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
            SFISensor *currentSensor = [currentSensorArray objectAtIndex:indexPath.row];
            if(currentSensor.isExpanded){
               return 160;
           }
           return 80;
        
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    //    if(indexPath.row == [sensors count]){
    //        cell = [self createAddSymbolCell:cell];
    //        return cell;
    //    }
    
    //    if(indexPath.row == 0){
    //        self.changeBrightness = 98;
    //    }
    
    
    cell = [self createColoredListCell:cell listRow:indexPath];
    //cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Device Index: Section:: %d  Row:: %d", indexPath.section, indexPath.row);
    NSArray *currentSensorArray = [sceneSensorMap objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    SFISensor *currentSensor = [currentSensorArray objectAtIndex:indexPath.row];
    if(!currentSensor.isExpanded){
        //Expand it
        currentSensor.isExpanded = TRUE;
    }else{
        currentSensor.isExpanded = FALSE;
    }
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete row!");
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}



#pragma mark - Table View Cell Creation

-(UITableViewCell*) createAddSymbolCell: (UITableViewCell*)cell{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    
    UIImageView *imgAddDevice =[[UIImageView alloc]initWithFrame:CGRectMake(110, 10, 30,40)];
    imgAddDevice.userInteractionEnabled = YES;
    imgAddDevice.image = [UIImage imageNamed:@"add_new.png"];
    
    UIButton *btnAddDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddDevice.frame = imgAddDevice.bounds;
    btnAddDevice.backgroundColor = [UIColor clearColor];
    //[btnAddDevice addTarget:self action:@selector(onAddDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgAddDevice addSubview:btnAddDevice];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell addSubview:imgAddDevice];
    return cell;
}

-(UITableViewCell*) createColoredListCell: (UITableViewCell*)cell listRow:(NSIndexPath*)indexPath{
    
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for(UIView *currentView in cell.contentView.subviews){
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    NSArray *sensorArray = [[NSArray alloc]init];
    sensorArray = [sceneSensorMap objectForKey:[NSString stringWithFormat:@"%d", indexPath.section]];
    SFISensor *currentSensor = [sensorArray objectAtIndex:indexPath.row];
    cell.textLabel.text = currentSensor.name;
    
    
    SFIScene *currentScene = [scenes objectAtIndex:indexPath.section];
    SFIColors *currentColor = currentScene.sceneColor;
    changeHue = currentColor.hue;
    changeSaturation = currentColor.saturation;
    changeBrightness = currentColor.brightness;
    baseBrightness = currentColor.brightness;
    int positionIndex = indexPath.row % 13;
    if(positionIndex < 6) {
        changeBrightness = baseBrightness - (positionIndex * 10);
    }else{
        changeBrightness = (baseBrightness - 60) + ((positionIndex - 6) * 10);
    }
    // NSLog(@"HUE %d, Brightness %d, Saturation %d", changeHue, changeBrightness, changeSaturation);
    //  cell.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
    
    UIImageView *imgDevice;
    UILabel *lblDeviceName;
    UILabel *lblDeviceStatus;
    UIImageView *imgSettings;
    UIButton *btnDevice;
    UIButton *btnDeviceImg;
    UIButton *btnSettings;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    UILabel *leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width/4,80)];
    leftBackgroundLabel.userInteractionEnabled = YES;
    
    leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
    
    [cell addSubview:leftBackgroundLabel];
    
    imgDevice = [[UIImageView alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width/4)/3, 2, 53,70)];
    imgDevice.userInteractionEnabled = YES;
    
    btnDeviceImg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeviceImg.frame = imgDevice.bounds;
    btnDeviceImg.backgroundColor = [UIColor clearColor];
    [btnDeviceImg addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgDevice addSubview:btnDeviceImg];
    
    btnDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDevice.frame = leftBackgroundLabel.bounds;
    btnDevice.backgroundColor = [UIColor clearColor];
    [btnDevice addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:btnDevice];
    
    [cell addSubview:imgDevice];
    
    UILabel *rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width/4) + 11,1,self.tableView.frame.size.width/1.5,80)];
    
    rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
    [cell addSubview:rightBackgroundLabel];
    
    lblDeviceName = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 180, 30)];
    lblDeviceName.backgroundColor = [UIColor clearColor];
    lblDeviceName.textColor = [UIColor whiteColor];
    [lblDeviceStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    [rightBackgroundLabel addSubview:lblDeviceName];
    
    lblDeviceStatus = [[UILabel alloc]initWithFrame:CGRectMake(15, 45, 180, 30)];
    lblDeviceStatus.backgroundColor = [UIColor clearColor];
    lblDeviceStatus.textColor = [UIColor whiteColor];
    [lblDeviceStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    [rightBackgroundLabel addSubview:lblDeviceStatus];
    
    imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 60, 35, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;
    
    
    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onDeviceSettingsClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];
    
    UIButton *btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(self.tableView.frame.size.width-80, 5, 60, 80);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onDeviceSettingsClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnSettingsCell];
    
    
    lblDeviceName.text = currentSensor.name;
    
    
    //Device Type
    int currentDeviceType = currentSensor.deviceType;
    NSMutableArray *currentKnownValues = currentSensor.knownValues;
    SFIDeviceKnownValues *currentDeviceValue;
    NSString *currentValue;
    NSString *currentStateValue;
    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = [currentKnownValues objectAtIndex:0];
            currentValue = currentDeviceValue.value;
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if([currentValue isEqualToString:@"true"]){
                lblDeviceStatus.text = @"ON";
                //imgDevice.image = [UIImage imageNamed:@"bulb_on.png"];
            }else{
                // imgDevice.frame = CGRectMake(35, 25, 27,42);
                lblDeviceStatus.text = @"OFF";
                //imgDevice.image = [UIImage imageNamed:@"bulb_off.png"];
            }
            
            break;
        case 3:
            //Sensor
            //  NSLog(@"Image Name: %@", currentSensor.imageName);
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            //imgDevice.frame = CGRectMake(25, 10, 53,70);
            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            if([currentSensor.mostImpValueName isEqualToString:@"TAMPER"]){
                // imgDevice.frame = CGRectMake(25, 15, 53,60);
                lblDeviceStatus.text = @"TAMPERED";
                if([currentStateValue isEqualToString:@"false"]){
                    imgDevice.image = [UIImage imageNamed:@"door_off_tamper.png"];
                }
            }else if([currentSensor.mostImpValueName isEqualToString:@"LOW BATTERY"]){
                //imgDevice.frame = CGRectMake(25, 15, 53,60);
                lblDeviceStatus.text = @"LOW BATTERY";
                if([currentStateValue isEqualToString:@"false"]){
                    imgDevice.image = [UIImage imageNamed:@"door_off_battery.png"];
                }
            }else{
                //Check OPEN CLOSE State
                currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
                currentValue = currentDeviceValue.value;
                if([currentValue isEqualToString:@"true"]){
                    // imgDevice.frame = CGRectMake(30, 20, 40.5,60);
                    lblDeviceStatus.text = @"OPEN";
                }else{
                    //imgDevice.frame = CGRectMake(30, 15, 40.5,60);
                    lblDeviceStatus.text = @"CLOSED";
                }
            }
            
            
            break;
        default:
            //imgDevice.frame = CGRectMake(25, 20, 53,60);
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            break;
    }
    
    
    btnDevice.tag = indexPath.row;
    //btnSettings.titleLabel = [NSString stringWithFormat:@"%d", indexPath.row];
    btnDeviceImg.tag = indexPath.row;
    btnSettings.tag = indexPath.row;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(currentSensor.isExpanded){
        //Settings icon - white
        imgSettings.alpha = 1.0;
        //Show values also
        UILabel *belowBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,82,(self.tableView.frame.size.width/4)+(self.tableView.frame.size.width/1.5)+1,90)];
        belowBackgroundLabel.userInteractionEnabled = YES;
        
        belowBackgroundLabel.backgroundColor = [UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1];
        
        
        UILabel *expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10,10,299,30)];
        float baseYCordinate = -20;
        switch (currentDeviceType) {
            case 1:
                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];
                currentDeviceValue = [currentKnownValues objectAtIndex:0];
                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            case 3:
                for(int i =0; i < [currentKnownValues count]; i++){
                    expandedLblText = [[UILabel alloc]init];
                    [expandedLblText setBackgroundColor:[UIColor clearColor]];
                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
                    expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    baseYCordinate = baseYCordinate+25;
                    // NSLog(@"Y Cordinate %f", baseYCordinate);
                    expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                    [belowBackgroundLabel addSubview:expandedLblText];
                }
                
                break;
        }
        [cell addSubview:belowBackgroundLabel];
        
        
    }
    [cell addSubview:imgSettings];
    return cell;
}

#pragma mark - Class Methods
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //self.view.autoresizesSubviews = YES;

    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    NSLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

-(void)initiliazeImages{
    int currentDeviceType;
    NSMutableArray *currentKnownValues;
    SFIDeviceKnownValues *currentDeviceValue;
    NSString *currentValue;
    NSString *currentDeviceTypeName;
    BOOL isImpFlagSet = FALSE;
    for(id key in sceneSensorMap) {
        NSArray* currentSensors = [sceneSensorMap objectForKey:key];
        for(SFISensor *currentSensor in currentSensors){
            isImpFlagSet = FALSE;
            currentDeviceType = currentSensor.deviceType;
            currentKnownValues = currentSensor.knownValues;
            switch (currentDeviceType) {
                case 1:
                    currentDeviceValue = [currentKnownValues objectAtIndex:0];
                    currentValue = currentDeviceValue.value;
                    if([currentValue isEqualToString:@"true"]){
                        currentSensor.imageName = @"switch_on.png";
                    }else{
                        currentSensor.imageName = @"switch_off.png";
                    }
                    break;
                case 3:
                    
                    for(int i = 0; i < [currentKnownValues count]; i++){
                        SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                        currentDeviceTypeName = curDeviceValues.valueName;
                        currentValue = curDeviceValues.value;
                        if([currentDeviceTypeName isEqualToString:@"TAMPER"]){
                            if([currentValue isEqualToString:@"true"]){
                                currentSensor.mostImpValueIndex = i;
                                currentSensor.mostImpValueName = currentDeviceTypeName;
                                currentSensor.imageName = @"door_on_tamper.png";
                                isImpFlagSet = TRUE;
                            }
                        }else if([currentDeviceTypeName isEqualToString:@"LOW BATTERY"]){
                            if([currentValue isEqualToString:@"1"] &&  !isImpFlagSet){
                                currentSensor.mostImpValueIndex = i;
                                currentSensor.mostImpValueName = currentDeviceTypeName;
                                currentSensor.imageName = @"door_on_battery.png";
                                isImpFlagSet = TRUE;
                            }
                        }else if([currentDeviceTypeName isEqualToString:@"STATE"]){
                            if(!isImpFlagSet){
                                currentSensor.mostImpValueIndex = i;
                                currentSensor.mostImpValueName = currentDeviceTypeName;
                                currentSensor.stateIndex = i;
                                if([currentValue isEqualToString:@"true"]){
                                    currentSensor.imageName = @"door_on.png";
                                }else{
                                    currentSensor.imageName = @"door_off.png";
                                }
                            }
                        }
                    }
                    break;
                default:
                    currentSensor.imageName = @"dimmer.png";
                    break;
            }
        }
    }
}


-(void)onAddSceneClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"Add Sensor  Index Clicked: %ld", (long)btn.tag);
}

-(void)onDeviceClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"Device  Index Clicked: %ld", (long)btn.tag);
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSLog(@"Section %d Row %d", indexPath.section, indexPath.row);
        NSArray *currentSensorArray = [sceneSensorMap objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
        SFISensor *currentSensor =[currentSensorArray objectAtIndex:btn.tag];
        int currentDeviceType = currentSensor.deviceType;
        NSMutableArray *currentKnownValues = currentSensor.knownValues;
        SFIDeviceKnownValues *currentDeviceValue;
        NSString *currentValue;
        NSString * mostImpIndexName;
        switch (currentDeviceType) {
            case 1:
                //Switch
                //Only one value
                currentDeviceValue = [currentKnownValues objectAtIndex:0];
                currentValue = currentDeviceValue.value;
                if([currentValue isEqualToString:@"true"]){
                    NSLog(@"Change to OFF");
                    currentDeviceValue.value = @"false";
                    currentSensor.imageName = @"switch_off.png";
                }else{
                    NSLog(@"Change to ON");
                    currentDeviceValue.value = @"true";
                    currentSensor.imageName = @"switch_on.png";
                }
                [self.tableView reloadData];
                break;
            case 3:
                //Sensor
                mostImpIndexName = currentSensor.mostImpValueName;
                if([mostImpIndexName isEqualToString:@"TAMPER"]){
                    currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
                    currentDeviceValue.value = @"false";
                    [self initiliazeImages];
                    [self.tableView reloadData];
                }
                break;
                
        }
        
    }
}

-(void)onDeviceSettingsClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"Device Settings Index Clicked: %ld", (long)btn.tag);
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSLog(@"Section %d Row %d", indexPath.section, indexPath.row);
        NSArray *currentSensorArray = [sceneSensorMap objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
        SFISensor *currentSensor = [currentSensorArray objectAtIndex:btn.tag];
        if(!currentSensor.isExpanded){
            //Expand it
            currentSensor.isExpanded = TRUE;
        }else{
            currentSensor.isExpanded = FALSE;
        }
        [self.tableView reloadData];
    }
}

-(void)onSceneClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    // NSLog(@"Scene  Index Clicked: %ld", (long)btn.tag);
    SFIScene *currentScene = [scenes objectAtIndex:btn.tag];
    // NSLog(@"Current Scene name: %@", currentScene.name);
    if(currentScene.isExpanded){
        //self.sensors = nil;
        currentScene.isExpanded = FALSE;
    }else{
        //Load sensors for that scene
        NSArray *sensorArray;
        SFIColors *currentColor;
        switch(btn.tag){
            case 0:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene1sensor"];
                [sceneSensorMap setObject:sensorArray forKey:@"0"];
                break;
            case 1:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene2sensor"];
                [sceneSensorMap setObject:sensorArray forKey:@"1"];
                break;
            case 2:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene3sensor"];
                [sceneSensorMap setObject:sensorArray forKey:@"2"];
                break;
            default:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene3sensor"];
                [sceneSensorMap setObject:sensorArray forKey:[NSString stringWithFormat:@"%ld", (long)btn.tag]];
                break;
        }
        
        if(currentScene.sceneColor==nil){
            
            currentColor = [[SFIColors alloc]init];
            //self.sensors = [NSArray arrayWithObjects:@"1", @"2", nil];
            if(btn.tag >= [self.sceneSensorColors count]){
                currentColor = [self.sceneSensorColors objectAtIndex:btn.tag % [self.sceneSensorColors count]];
            }else{
                currentColor = [self.sceneSensorColors objectAtIndex:btn.tag];
            }
            
            
            //currentColor = [self.sceneSensorColors objectAtIndex:btn.tag];
            currentColor.brightness = currentColor.brightness-10;
            currentScene.sceneColor = currentColor;
        }
        currentScene.isExpanded = TRUE;
        
        [self initiliazeImages];
    }
    [self.tableView reloadData];
}

-(void)onActivateClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"Activate  Index Clicked: %ld", (long)btn.tag);
    SFIScene *currentScene = [scenes objectAtIndex:btn.tag];
    if(currentScene.isActivated){
        currentScene.isActivated = FALSE;
    }else{
        currentScene.isActivated = TRUE;
    }
    [self.tableView reloadData];
}

-(void)onSettingClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"Settings Index Clicked: %ld", (long)btn.tag);
    SFIScene *currentScene = [scenes objectAtIndex:btn.tag];
    if(currentScene.isExpanded){
        //self.sensors = nil;
        currentScene.isExpanded = FALSE;
    }else{
        //TODO: Load sensors for that scene
        NSArray *sensorArray;
        SFIColors *currentColor;
        switch(btn.tag){
            case 0:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene1sensor"];
                [sceneSensorMap setObject:sensorArray forKey:@"0"];
                break;
            case 1:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene2sensor"];
                [sceneSensorMap setObject:sensorArray forKey:@"1"];
                break;
            case 2:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene2sensor"];
                [sceneSensorMap setObject:sensorArray forKey:@"2"];
                break;
            default:
                sensorArray = [[NSArray alloc]init];
                sensorArray = [[SFIParser alloc] loadDataFromXML:@"scene2sensor"];
                [sceneSensorMap setObject:sensorArray forKey:[NSString stringWithFormat:@"%ld", (long)btn.tag]];
                break;
        }
        
        if(currentScene.sceneColor==nil){
            currentColor = [[SFIColors alloc]init];
            //self.sensors = [NSArray arrayWithObjects:@"1", @"2", nil];
            if(btn.tag >= [self.sceneSensorColors count]){
                currentColor = [self.sceneSensorColors objectAtIndex:btn.tag % [self.sceneSensorColors count]];
            }else{
                currentColor = [self.sceneSensorColors objectAtIndex:btn.tag];
            }
            
            
            //currentColor = [self.sceneSensorColors objectAtIndex:btn.tag];
            currentColor.brightness = currentColor.brightness-10;
            currentScene.sceneColor = currentColor;
        }
        currentScene.isExpanded = TRUE;
        
        [self initiliazeImages];
    }
    [self.tableView reloadData];
    
}

- (void)swipeDetected:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"Delete Detected");
//    [UIView animateWithDuration:0.4 animations:^{
//        [self setTransform:CGAffineTransformMakeTranslation(0.0f, -(self.tableView frame.origin.y + self.frame.size.height))];
//    } completion:^(BOOL finished) {
//        [self setAlpha:0.0f];
//        NSIndexPath *indexPath = [(UICollectionView *)self.superview indexPathForCell:self];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteSwipedCellNotification" object:indexPath];
//    }];
}

@end
