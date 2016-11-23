//
//  HelpCenterTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 7/20/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpCenterTableViewCell.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "CommonMethods.h"
#import "SFIColors.h"

//This class is linked with multiple cells
@interface HelpCenterTableViewCell()
//help center cell
@property (weak, nonatomic) IBOutlet UIImageView *leftImg;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;

//help center items cell
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImg;


//support
@property (weak, nonatomic) IBOutlet UIImageView *flagImgView;
@property (weak, nonatomic) IBOutlet UIImageView *flagImg2;
@property (weak, nonatomic) IBOutlet UILabel *numberLbl;
@property (weak, nonatomic) IBOutlet UILabel *countryCode;

@end

@implementation HelpCenterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setUpHelpCell:(NSDictionary *)helpItem{
    NSLog(@"name :%@, image: %@", helpItem[@"name"], helpItem[S_ICON]);
    self.helpLabel.text = NSLocalizedString(helpItem[@"name"], @"");
    self.leftImg.image = [UIImage imageNamed:helpItem[S_ICON]];
    self.backgroundColor = [SFIColors getHelpCenterColor:helpItem[COLOR]];
}

- (void)setUpHelpItemCell:(NSDictionary*)helpItem row:(NSInteger)row{
    self.itemLabel.text = NSLocalizedString([[helpItem[ITEMS] objectAtIndex:row] valueForKey:@"name"], @"");
    self.itemImg.image = [CommonMethods imageNamed:helpItem[S_ICON] withColor:[UIColor grayColor]];
}

- (void)setUpSupportCell:(NSArray*)countryNumber row:(NSInteger)row{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if(row == 0){
        self.flagImgView.hidden = NO;
        self.flagImgView.image = [UIImage imageNamed:@"us"];
        self.countryCode.text = @"(US,CA)";
    }else{
        self.flagImgView.hidden = YES;
        self.countryCode.text = [NSString stringWithFormat:@"(%@)", countryNumber[1]];
    }
    self.flagImg2.image = [UIImage imageNamed:countryNumber[0]];
    self.numberLbl.text = countryNumber[2];
}

@end