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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webImgYConstrain;

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
    //NSLog(@"uri dict %@",uri);
    
        if(isCategory){
            self.catImgXConstrain.constant = -6;
            self.webImg.hidden = YES;
            self.siteNameXconstrain.constant = 5;
            NSLog(@"image uri %@",uri[@"image"]);
            self.categoryImg.image = uri[@"image"];
        }
        else{
            if(hideItem){
                self.webImgXConstrain.constant = 17;
                self.siteNameXconstrain.constant = -29;
                self.webImgYConstrain.constant = 13;
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
            NSArray* domainValues = [uri[@"hostName"] componentsSeparatedByString:@"."];
            if([domainValues[0] isEqualToString:@"google"]){
                [self.webImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.com/favicon.ico"]]placeholderImage:[UIImage imageNamed:@"globe"]];
            }else{
                [self.webImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/s2/favicons?domain=%@", uri[@"hostName"]]]
                               placeholderImage:[UIImage imageNamed:@"globe"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          if(error!=nil){
                                              [self.webImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/favicon.ico", uri[@"hostName"]]]placeholderImage:[UIImage imageNamed:@"globe"]];
                                          }else
                                          {}
                                      }];
            }
        }
        else{
            self.webImg.image = uri[@"image"];
        }
    
    
        self.siteName.text = [NSString stringWithFormat:@"%@",uri[@"hostName"]];
        if([[uri[@"categoryObj"]valueForKey:@"categoty"] isEqualToString:@"NC-17"]){
            self.categoryImg.image = [UIImage imageNamed:@"Adults_Only"];
            
        }
        else if ([[uri[@"categoryObj"]valueForKey:@"categoty"] isEqualToString:@"U"]){
            self.categoryImg.image = [UIImage imageNamed:@"unknown_category"];
            
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
