//
//  CollectionViewCell.m
//  GridViewTest
//
//  Created by Masood on 27/01/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import "CollectionViewCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"

@implementation CollectionViewCell
-(void)awakeFromNib{
    NSLog(@"awakeFromNib");
//    self.dayLabel
}

-(void)layoutSubviews{
    NSLog(@"layoutSubviews");
}

-(void)layoutIfNeeded{
    NSLog(@"layoutIfNeeded");
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if(selected)
        self.backgroundColor = [SFIColors gridBlockColor];
    else
        self.backgroundColor = [UIColor whiteColor];
}

-(void)addDayTimeLable:(NSIndexPath *)indexPath isSelected:(NSString*)selected{
    NSArray *Days = @[@"", @"Su", @"Mo", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @""];
    if(indexPath.section == 0 || indexPath.section == 25){ //days
        NSLog(@"indexpath.row: %ld", indexPath.row);
        self.dayLabel.text = [Days objectAtIndex:indexPath.row];
        [self setDayTimeBackGroundColor:selected];
    }
    else if(indexPath.row == 0 || indexPath.row == 8){ //hours
        self.dayLabel.text = @(indexPath.section - 1).stringValue;
        [self setDayTimeBackGroundColor:selected];
    }
}

-(void)setDayTimeBackGroundColor:(NSString*)selected{
    if([selected isEqualToString:@"1"]){
        self.backgroundColor = [SFIColors gridBlockColor];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}
-(void)handleCornerCells{
//    self.dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    self.dayLabel.text = @"";
//    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}
-(void)setlabel{
    NSLog(@"setlabel");
    if(self.dayLabel == nil)
        self.dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.dayLabel.text = @"";
    self.dayLabel.font = [UIFont securifiLightFont:12];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.dayLabel];
}
@end
