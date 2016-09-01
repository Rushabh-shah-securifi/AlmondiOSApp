//
//  HistoryCell.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HistoryCell.h"
#import "UrlImgDict.h"
@interface HistoryCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgLeftConstrin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hostnameLeftConstrain;

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
-(void)setCell:(NSDictionary*)uri hideItem:(BOOL)hideItem{
    if(hideItem){
        self.imgLeftConstrin.constant = 17;
        self.hostnameLeftConstrain.constant = -25;
    }
    else {
        self.imgLeftConstrin.constant = 7;
        self.hostnameLeftConstrain.constant = 5;
    }
    self.categoryImg.hidden = hideItem;
    self.settingImg.hidden = hideItem;
    self.lastActTime.hidden = hideItem;
    UrlImgDict *imgs = [UrlImgDict sharedInstance];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if([imgs.imgDict valueForKey:uri[@"hostName"]]!= NULL){
            self.webImg.image = [imgs.imgDict objectForKey:uri[@"hostName"]];
            NSLog(@"img from img dict %@",[imgs.imgDict objectForKey:uri[@"hostName"]]);
        }else{
            self.webImg.image = uri[@"image"];
        }
        self.siteName.text = uri[@"hostName"];
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
        else{
            self.categoryImg.image = [UIImage imageNamed:@"globe"];
        }
//        self.categoryImg.image = [UIImage imageNamed:@"help-icon"];
        NSDate *dat = [NSDate getDateFromEpoch:uri[@"Epoc"]];
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
