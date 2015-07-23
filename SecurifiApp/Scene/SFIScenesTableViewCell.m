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
    lblName.text = info[@"SceneName"];
    //TEST
    if ([info[@"SceneEntryList"] isKindOfClass:[NSArray class]]) {
        self.deviceIndexes = info[@"SceneEntryList"];
    }else{
        NSString * strSceneEntryList = info[@"SceneEntryList"];
        strSceneEntryList = [strSceneEntryList stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSData * data = [strSceneEntryList dataUsingEncoding:NSUTF8StringEncoding] ;
        self.deviceIndexes = [data objectFromJSONData];
    }
    if ([[info valueForKey:@"IsActive"] boolValue]) {
        [btnActivate setImage:[UIImage imageNamed:@"iconSceneChekmark"] forState:UIControlStateNormal];
    }else{
        [btnActivate setImage:[UIImage imageNamed:@"iconSceneCircle"] forState:UIControlStateNormal];
    }
    if (self.deviceIndexes.count>1) {
        lblInfo.text = [NSString stringWithFormat:@"%ld SENSORS",(long)self.deviceIndexes.count];
    }else{
        lblInfo.text = [NSString stringWithFormat:@"%ld SENSOR",(long)self.deviceIndexes.count];
    }
    
}
- (IBAction)btnActivateTap:(id)sender {
    [self.delegate activateScene:self Info:self.cellInfo];
}
@end
