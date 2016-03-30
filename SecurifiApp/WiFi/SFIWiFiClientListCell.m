//
//  SFIWiFiClientListCell.m
//  Wifi
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIWiFiClientListCell.h"
#import "SKSTableViewCellIndicator.h"
#import "SFIColors.h"
#import "UIColor+Securifi.h"

#define kIndicatorViewTag -1

@interface SFIWiFiClientListCell() {

    IBOutlet UIView *cellBGView;
    IBOutlet UILabel *lblMAC;
    IBOutlet UILabel *lblStatus;
    IBOutlet UIImageView *imgIcon;
}

@end

@implementation SFIWiFiClientListCell


- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"SFIWiFiClientListCell awakeFromNib ");
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.expandable = YES;
        self.expanded = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isExpanded) {
        
        if (![self containsIndicatorView])
            [self addIndicatorView];
        else {
            [self removeIndicatorView];
            [self addIndicatorView];
        }
    }
}

static UIImage *_image = nil;
- (UIView *)expandableView
{
    if (!_image) {
        _image = [UIImage imageNamed:@"icoSettings"];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, _image.size.width, _image.size.height);
    button.frame = frame;
    
    [button setBackgroundImage:_image forState:UIControlStateNormal];
    
    return button;
}

- (void)setExpandable:(BOOL)isExpandable
{
    if (isExpandable)
        [self setAccessoryView:[self expandableView]];
    
    _expandable = isExpandable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)addIndicatorView
{
    CGPoint point = self.accessoryView.center;
    CGRect bounds = self.accessoryView.bounds;
    
    CGRect frame = CGRectMake((point.x - CGRectGetWidth(bounds) * 1.5), point.y * 1.4, CGRectGetWidth(bounds) * 3.0, CGRectGetHeight(self.bounds) - point.y * 1.4);
    SKSTableViewCellIndicator *indicatorView = [[SKSTableViewCellIndicator alloc] initWithFrame:frame];
    indicatorView.tag = kIndicatorViewTag;
    [self.contentView addSubview:indicatorView];
}

- (void)removeIndicatorView
{
    id indicatorView = [self.contentView viewWithTag:kIndicatorViewTag];
    if (indicatorView)
    {
        [indicatorView removeFromSuperview];
        indicatorView = nil;
    }
}

- (BOOL)containsIndicatorView
{
    return [self.contentView viewWithTag:kIndicatorViewTag] ? YES : NO;
}

- (void)accessoryViewAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isExpanded) {
            
            self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
            
        } else {
            self.accessoryView.transform = CGAffineTransformMakeRotation(0);
        }
    } completion:^(BOOL finished) {
        
        if (!self.isExpanded)
            [self removeIndicatorView];
        
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    lblMAC.text = @"";
    lblStatus.text = @"";
}


- (void)createClientCell:(ClientDevice*)connectedDevice{
    NSLog(@"createClientCell ");
    self.connectedDevice = connectedDevice;
    lblMAC.text = connectedDevice.name;
    if(connectedDevice.deviceAllowedType == DeviceAllowed_Blocked){
        lblStatus.text = @"Blocked";
        cellBGView.backgroundColor = [SFIColors ruleGraycolor];
    }else{
        if (connectedDevice.isActive) {
            lblStatus.text = NSLocalizedString(@"wifi.Active",@"ACTIVE");
            cellBGView.backgroundColor = [UIColor securifiRouterTileGreenColor];
        }else{
            lblStatus.text = NSLocalizedString(@"wifi.Inactive",@"INACTIVE");
            cellBGView.backgroundColor = [UIColor lightGrayColor];
        }
    }
    UIImage* image = [UIImage imageNamed:[connectedDevice iconName]];
    imgIcon.image = image;
    CGRect fr = imgIcon.frame;
    fr.size = image.size;
    fr.origin.x = (90-fr.size.width)/2;
    fr.origin.y = (80-fr.size.height)/2;
    imgIcon.frame = fr;
}

- (IBAction)btnSettingTap:(id)sender {
    NSLog(@"btnSettingTap ");
    NSDictionary *connectedDevice =  @{@"Name" : @"smartDevice",
                                       @"Type" : @"Tablate",
                                       @"Manufacture" : @"freedom",
                                       @"MAC Address" : @"10.21.45.53.58",
                                       @"Last Known IP" : @"10.21.1.100",
                                       @"Signal Strength" : @"-33 dBm",
                                       @"Connection" : @"wireLess",
                                       @"Allow On network" : @"Always",
                                       @"use as pesence sensor" : @"true",
                                       @"inActiveTimeOut" : @"32"
                                       };
    
     NSArray *IndexArray = [[NSArray alloc]initWithObjects:@"1",@"2",nil];
    self.connectedDevice = [[ClientDevice alloc]init];
    self.connectedDevice.name = @"smartPhone";
    self.connectedDevice.deviceID = @"12";
    self.connectedDevice.deviceIP = @"10.21.21.100";
    self.connectedDevice.deviceType = @"SmartPhone";
    self.connectedDevice.timeout = 24;
    self.connectedDevice.deviceLastActiveTime = @"25";
    self.connectedDevice.manufacturer = @"freedom";
    self.connectedDevice.isActive = YES;
    self.connectedDevice.deviceUseAsPresence = YES;
    [self.delegate btnSettingTapped:connectedDevice index:IndexArray];
//    [self.delegate btnSettingTapped:self Info:self.connectedDevice];

}

@end
