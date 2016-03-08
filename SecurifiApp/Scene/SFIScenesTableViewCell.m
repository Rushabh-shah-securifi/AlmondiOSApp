//
//  SFIScenesTableViewCell.m
//  Scenes
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIScenesTableViewCell.h"
#import "MDJSON.h"

@interface SFIScenesTableViewCell () {
    __weak IBOutlet UIView *viewGridIcon;
    __weak IBOutlet UIImageView *imgIcon;
    __weak IBOutlet UIView *viewLine;
    __weak IBOutlet UIView *viewGridLabels;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblInfo;
    IBOutlet UIButton *btnActivate;
    IBOutlet UIImageView *alexaImg;
}

@end

@implementation SFIScenesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    viewGridIcon.backgroundColor = [UIColor clearColor];
    imgIcon.image = nil;
    viewGridLabels.backgroundColor = [UIColor clearColor];
    lblName.text = @"";
    lblInfo.text = @"";
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    imgIcon.image = [UIImage imageNamed:@"iconSceneChekmark"];
    [imgIcon sizeToFit];
    imgIcon.center = CGPointMake(viewGridIcon.frame.size.width/2, viewGridIcon.frame.size.height/2);
    
    viewGridLabels.backgroundColor = viewGridIcon.backgroundColor;
    
}

- (void)createScenesCell:(id)info {
    self.cellInfo = info;
    viewGridIcon.backgroundColor = self.cellColor;
    lblName.text = info[@"Name"];

    if ([info[@"SceneEntryList"] isKindOfClass:[NSArray class]]) {
        self.deviceIndexes = info[@"SceneEntryList"];
    }else{
        NSString * strSceneEntryList = info[@"SceneEntryList"];
        strSceneEntryList = [strSceneEntryList stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSData * data = [strSceneEntryList dataUsingEncoding:NSUTF8StringEncoding] ;
        self.deviceIndexes = [data objectFromJSONData];
    }
    if ([[info valueForKey:@"Active"] boolValue]) {
        [btnActivate setImage:[UIImage imageNamed:@"iconSceneChekmark"] forState:UIControlStateNormal];
    }else{
        [btnActivate setImage:[UIImage imageNamed:@"iconSceneCircle"] forState:UIControlStateNormal];
    }
    BOOL isCompatible = [self isSceneNameCompatibleWithAlexa];
    if (isCompatible){//
        alexaImg.image = [UIImage imageNamed:@"amazon-echo"];
    }else{
        alexaImg.image = nil;
    }
    if (self.deviceIndexes.count>1) {
        lblInfo.text = [NSString stringWithFormat:NSLocalizedString(@"sensor.text.%ld SENSORS", "SENSORS"),(long)self.deviceIndexes.count];
    }else{
        lblInfo.text = [NSString stringWithFormat:NSLocalizedString(@"sensor.text.%ld SENSOR", "SENSOR"),(long)self.deviceIndexes.count];
    }
    
}
- (IBAction)btnActivateTap:(id)sender {
    [self.delegate activateScene:self Info:self.cellInfo];
}

- (BOOL)isSceneNameCompatibleWithAlexa{
    NSArray *sceneNameList;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scene_names" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    sceneNameList = [content componentsSeparatedByString:@","];
    NSString *lowerCaseSceneName = lblName.text.lowercaseString;
    BOOL isCompatible = NO;
    for(NSString *name in sceneNameList){
        if([name.lowercaseString isEqualToString:lowerCaseSceneName]){
            isCompatible = YES;
            break;
        }
    }
    return isCompatible;
}


@end
