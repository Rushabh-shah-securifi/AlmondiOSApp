////
////  SensorTableViewCell.h
////  SecurifiApp
////
////  Created by Securifi-Mac2 on 19/02/16.
////  Copyright © 2016 Securifi Ltd. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//
//
//@interface SensorTableViewCell : UITableViewCell
//@property(nonatomic) SFIDevice *device;
//@property(nonatomic) SFIDeviceValue *deviceValue;
//@property(nonatomic) UIColor *cellColor;
//@property(nonatomic) UIImageView *deviceImageView;
//@property(nonatomic) UIImageView *deviceImageViewSecondary;
//@property(nonatomic) UILabel *deviceStatusLabel;
//@property(nonatomic, readonly) UILabel *deviceNameLabel;
//@property (strong, nonatomic) IBOutlet UIView *deviceField;
//
//- (void)layoutTileFrame;
//-(void)layoutDeviceTileFrame;
//
//@property (weak, nonatomic) IBOutlet UIButton *deviceImageButton;
//
//
//@end



/*
 //
 //  SensorTableViewCell.m
 //  SecurifiApp
 //
 //  Created by Securifi-Mac2 on 19/02/16.
 //  Copyright © 2016 Securifi Ltd. All rights reserved.
 //
 
 #import "SensorTableViewCell.h"
 #import "SFIConstants.h"
 #import "UIFont+Securifi.h"
 @implementation SensorTableViewCell
 
 - (void)awakeFromNib {
 // Initialization code
 NSLog(@" awake from nib called");
 
 
 }
 
 - (void)setSelected:(BOOL)selected animated:(BOOL)animated {
 [super setSelected:selected animated:animated];
 
 // Configure the view for the selected state
 }
 
 -(void)layoutDeviceTileFrame{
 NSLog(@" self.frame size %f,%f",self.contentView.frame.size.width,self.contentView.frame.size.height);
 self.deviceField = [[UIView alloc]initWithFrame:CGRectMake(5, 5, self.contentView.frame.size.width -10 , self.contentView.frame.size.height +35 )];
 self.deviceField.backgroundColor = [UIColor orangeColor];
 [self.contentView addSubview:self.deviceField];
 NSLog(@" self.deviceField.frame size %f,%f,%f,%f",self.deviceField.frame.origin.x,self.deviceField.frame.origin.y,self.deviceField.frame.size.width,self.deviceField.frame.size.height);
 //deviceImageButton
 UIButton *deviceImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 79, self.deviceField.frame.size.height)];
 deviceImageButton.backgroundColor = [UIColor orangeColor];
 deviceImageButton.imageView.image = [UIImage imageNamed:DEVICE_UNKNOWN_IMAGE];
 [deviceImageButton setImage:[UIImage imageNamed:DEVICE_UNKNOWN_IMAGE] forState:UIControlStateNormal];
 deviceImageButton.imageEdgeInsets = UIEdgeInsetsMake(10, 13, 10, 13);
 [self.deviceField addSubview:deviceImageButton];
 //device name label
 UILabel *deviceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, self.deviceField.frame.size.width - 80 -60, 30)];
 deviceNameLabel.text = @"1234";
 [self.deviceField addSubview:deviceNameLabel];
 
 
 //device status label
 UILabel *deviceStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 45, self.deviceField.frame.size.width - 80 -60, 20)];
 deviceStatusLabel.text = @"status";
 
 deviceStatusLabel.textColor = [UIColor whiteColor];
 [self.deviceField addSubview:deviceStatusLabel];
 
 //device setting button
 UIButton *deviceSettingButton = [[UIButton alloc]initWithFrame:CGRectMake(self.deviceField.frame.size.width - 60, 0, 60, 79)];
 deviceSettingButton.backgroundColor = [UIColor clearColor];
 deviceSettingButton.imageView.image = [UIImage imageNamed:@"icon_config.png"];
 deviceSettingButton.imageEdgeInsets = UIEdgeInsetsMake(28, 23, 28, 23);
 [deviceSettingButton setImage:[UIImage imageNamed:@"icon_config.png"] forState:UIControlStateNormal];
 [self.deviceField addSubview:deviceSettingButton];
 
 }
 - (void)layoutTileFrame {
 self.deviceValue = [SFIDeviceValue new]; // ensure no null pointers; layout code assumes there exists a Device Value that returns answers
 
 
 const SFIDevice *currentSensor = self.device;
 const CGRect cell_frame = self.frame;
 const NSInteger row_index = self.tag;
 
 UIColor *const cell_color = self.cellColor;
 UIColor *const clear_color = [UIColor greenColor];
 UIColor *const white_color = [UIColor yellowColor];
 
 UIView *leftBackgroundLabel = [[UIView alloc] initWithFrame:CGRectMake(10, 5, LEFT_LABEL_WIDTH, SENSOR_ROW_HEIGHT - 10)];
 leftBackgroundLabel.tag = 111;
 leftBackgroundLabel.userInteractionEnabled = YES;
 leftBackgroundLabel.backgroundColor = [UIColor clearColor];
 [self.contentView addSubview:leftBackgroundLabel];
 
 UIButton *deviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
 deviceButton.tag = row_index;
 deviceButton.frame = leftBackgroundLabel.bounds;
 deviceButton.backgroundColor = [UIColor greenColor];
 [deviceButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
 [leftBackgroundLabel addSubview:deviceButton];
 
 UIView *rightBackgroundLabel = [[UIView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH , 5, cell_frame.size.width , SENSOR_ROW_HEIGHT - 10)];
 rightBackgroundLabel.backgroundColor = cell_color;
 UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDeviceNameLabelTapped:)];
 [rightBackgroundLabel addGestureRecognizer:recognizer];
 [self.contentView addSubview:rightBackgroundLabel];
 
 UILabel *deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, (cell_frame.size.width - LEFT_LABEL_WIDTH - 40), 30)];
 deviceNameLabel.backgroundColor = clear_color;
 deviceNameLabel.textColor = white_color;
 deviceNameLabel.text = self.device.deviceName;
 deviceNameLabel.font = [deviceNameLabel.font fontWithSize:16];
 [rightBackgroundLabel addSubview:deviceNameLabel];
 _deviceNameLabel = deviceNameLabel;
 
 UILabel *deviceStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 180, 60)];
 deviceStatusLabel.backgroundColor = clear_color;
 deviceStatusLabel.textColor = white_color;
 deviceStatusLabel.numberOfLines = 2;
 deviceStatusLabel.font = [UIFont standardUILabelFont];
 [rightBackgroundLabel addSubview:deviceStatusLabel];
 self.deviceStatusLabel = deviceStatusLabel;
 
 //todo seems like the button could take place of image view
 
 UIImageView *settingsImage = [[UIImageView alloc] initWithFrame:CGRectMake(cell_frame.size.width - 50, 37, 23, 23)];
 settingsImage.image = [UIImage imageNamed:@"icon_config.png"];
 // settingsImage.alpha = (CGFloat) (self.isExpandedView ? 1.0 : 0.5); // change color of image when expanded
 settingsImage.userInteractionEnabled = YES;
 settingsImage.backgroundColor = [UIColor greenColor];
 [self.contentView addSubview:settingsImage];
 
 UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
 settingsButton.tag = row_index;
 settingsButton.frame = settingsImage.bounds;
 settingsButton.backgroundColor = clear_color;
 [settingsButton addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
 //    [settingsImage addSubview:settingsButton];
 
 //    UIButton *settingsButtonCell = [UIButton buttonWithType:UIButtonTypeCustom];
 //    settingsButtonCell.tag = row_index;
 //    settingsButtonCell.frame = CGRectMake(cell_frame.size.width - 20, 9, 60, 76);
 //    settingsButtonCell.backgroundColor = white_color;
 //    [settingsButtonCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
 //    [self.contentView addSubview:settingsButtonCell];
 [self layoutDeviceImageCell];
 }
 
 - (void)layoutDeviceImageCell {
 UIColor *clear_color = [UIColor clearColor];
 
 UIButton *deviceImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
 deviceImageButton.tag = self.tag;
 deviceImageButton.backgroundColor = clear_color;
 deviceImageButton.imageView.image = [UIImage imageNamed:DEVICE_UNKNOWN_IMAGE];
 [deviceImageButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
 
 //    if ([self needsTemperatureView]) {
 //        self.deviceTemperatureView = [[TemperatureView alloc] initWithFrame:CGRectMake(0, 0, LEFT_LABEL_WIDTH, 100)];
 //        [self.contentView addSubview:self.deviceTemperatureView];
 //    }
 
 CGRect imageView_frame = CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70);
 //
 self.deviceImageView = [[UIImageView alloc] initWithFrame:imageView_frame];
 self.deviceImageView.userInteractionEnabled = YES;
 self.deviceImageView.backgroundColor = [UIColor whiteColor];
 //
 [self.deviceImageView addSubview:deviceImageButton];
 deviceImageButton.frame = self.deviceImageView.bounds;
 [self.contentView addSubview:self.deviceImageView];
 
 NSLog(@" self.deviceImageView frame %f,%f,%f,%f",self.deviceImageView.frame.origin.x,self.deviceImageView.frame.origin.y,self.deviceImageView.frame.size.width,self.deviceImageView.frame.size.height);
 //
 self.deviceImageViewSecondary = [[UIImageView alloc] initWithFrame:imageView_frame];
 [self.contentView addSubview:self.deviceImageViewSecondary];
 
 [self configureSensorImageName:DEVICE_UNKNOWN_IMAGE statusMesssage:@"home"];
 }
 - (void)configureSensorImageName:(NSString *)imageName statusMesssage:(NSString *)message {
 self.deviceImageViewSecondary.image = [UIImage imageNamed:imageName];
 self.deviceStatusLabel.text = message;
 NSMutableArray *status = [NSMutableArray array];
 if (message) {
 [status addObject:message];
 }
 //    self.iconImageName = imageName;
 //    self.statusTextArray = status;
 }
 
 - (void)tearDown {
 for (UIView *currentView in self.contentView.subviews) {
 [currentView removeFromSuperview];
 }
 self.deviceImageView = nil;
 self.deviceStatusLabel = nil;
 }
 
 
 #pragma mark - Device Values
 
 //todo deprecate and get rid of;
 - (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceState {
 return [self.deviceValue knownValuesForProperty:self.device.statePropertyType];
 }
 
 //todo deprecate and get rid of;
 - (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceMutableState {
 return [self.deviceValue knownValuesForProperty:self.device.mutableStatePropertyType];
 }
 @end

 */