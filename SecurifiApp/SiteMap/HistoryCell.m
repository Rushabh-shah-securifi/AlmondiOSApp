//
//  HistoryCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HistoryCell.h"
#import "UrlImgDict.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface HistoryCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webImgXConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *siteNameXconstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *catImgXConstrain;

@end

@implementation HistoryCell

- (void)awakeFromNib {
//    self.webImg.image = [UIImage imageNamed:@"favicon.ico"];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCell:(NSDictionary*)uri hideItem:(BOOL)hideItem isCategory:(BOOL)isCategory showTime :(BOOL)showTime count:(NSInteger)count{
    
    dispatch_async(dispatch_get_main_queue(), ^() {
    
        if(isCategory){
            self.catImgXConstrain.constant = -6;
            self.webImg.hidden = YES;
            self.siteNameXconstrain.constant = 5;
            self.categoryImg.image = uri[@"image"];
        }
        else{
            if(hideItem){
                self.webImgXConstrain.constant = 17;
                self.siteNameXconstrain.constant = -27;
            }
            else {
                self.webImgXConstrain.constant = 7;
                self.siteNameXconstrain.constant = 5;
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            self.categoryImg.hidden = hideItem;
            self.settingImg.hidden = hideItem;
        }
        self.lastActTime.hidden = !showTime;
        if(showTime){
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    
        [self.webImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/favicon.ico", uri[@"hostName"]]]
                       placeholderImage:[UIImage imageNamed:@"globe"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  if(error!=nil){
                                      NSLog(@"encountered error %@ for %@",[error localizedDescription],uri[@"hostName"]);
                                      [self.webImg setImage:[UIImage imageNamed:@"globe"]];
                                  }else
                                      NSLog(@"completed loading %@",uri[@"hostName"]);
                              }];
        
        self.siteName.text = [NSString stringWithFormat:@"%ld,%@",(long)count,uri[@"hostName"]];
        if([[uri[@"categoryObj"]valueForKey:@"categoty"] isEqualToString:@"NC-17"]){
            self.categoryImg.image = [UIImage imageNamed:@"Adults_Only"];
            
        }
        else if ([[uri[@"categoryObj"]valueForKey:@"categoty"] isEqualToString:@"R"]){
            self.categoryImg.image = [UIImage imageNamed:@"Restricted"];
            
        }
        else if ([[uri[@"categoryObj"]valueForKey:@"categoty"]isEqualToString:@"PG-13"]){
            self.categoryImg.image = [UIImage imageNamed:@"Parents_Strongly_Cautioned"];
            
        }
        else if ([[uri[@"categoryObj"]valueForKey:@"categoty"] isEqualToString:@"PG"]){
            self.categoryImg.image = [UIImage imageNamed:@"Parental_Guidance"];
            
        }
        else if ([[uri[@"categoryObj"]valueForKey:@"categoty"] isEqualToString:@"G"]){
            self.categoryImg.image = [UIImage imageNamed:@"General_Audiences"];
        }
//        else{
//            self.categoryImg.image = [UIImage imageNamed:@"globe"];
//        }
//        self.categoryImg.image = [UIImage imageNamed:@"help-icon"];
        NSDate *dat = [NSDate dateWithTimeIntervalSince1970:[uri[@"Epoc"] intValue]];
        self.lastActTime.text = [dat stringFromDate];
        
    });
}
-(void)setName:(URIData *)uri{
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.siteName.text = uri.hostName;
    });
}

-(NSString*)getCounttext:(int)count{
    NSLog(@"count uri = %d",count);
    if(count >= 0 && count <= 999)
        return @(count).stringValue;
    else{
        count /= 1000;
        return [NSString stringWithFormat:@"%dK", count];
    }
    return @"";
}

@end
