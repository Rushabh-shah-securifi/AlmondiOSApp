//
//  MoreCellTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 8/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MoreCellTableViewCell.h"
@interface MoreCellTableViewCell()
//morecell1
@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *name;

//morecell2
@property (weak, nonatomic) IBOutlet UILabel *featureName;
@property (weak, nonatomic) IBOutlet UIImageView *featureIcon;

//morecell3
@property (weak, nonatomic) IBOutlet UILabel *version;

@end

@implementation MoreCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpMoreCell1:(NSString *)name{
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    UIImage * image = [self loadImageWithFileName:PROFILE_PIC ofType:@"jpg" inDirectory:documentsDirectory];
    
    NSLog(@"cell image: %@", image);
    self.imgView.clipsToBounds = YES;
    self.imgView.image = image;
    self.name.text = name;
}

-(UIImage *)loadImageWithFileName:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, [extension lowercaseString]]];
    
    return result;
}

-(void)setUpMoreCell2:(NSDictionary*)moreFeature{
    self.featureIcon.image =[UIImage imageNamed:moreFeature.allKeys.firstObject];
    self.featureName.text = moreFeature.allValues.firstObject;
}

-(void)setUpMoreCell3{
    self.version.text = [self getVersion];
}

-(NSString *)getVersion{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *shortVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [bundle objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
    NSString *version = [NSString stringWithFormat:@"%@ (%@)", shortVersion, buildNumber];
    return version;
}

- (IBAction)onLogoutTap:(id)sender {
    //disabled button touch in storyboard
    //moved code to did select row
//    [self.delegate onLogoutTapDelegate];
}

- (IBAction)onImageButtonTap:(UIButton *)button {
    [self.delegate onImageTapDelegate:button];
}
- (IBAction)onLogoutAllTap:(id)sender {
    [self.delegate onLogoutAllTapDelegate];
}

@end
