//
//  CollectionViewCell.m
//  GridViewTest
//
//  Created by Masood on 27/01/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import "CollectionViewCell.h"
#import "SFIColors.h"

@implementation CollectionViewCell

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
        NSLog(@"Days");
        self.dayTimeLable.text = [Days objectAtIndex:indexPath.row];
        [self setDayTimeBackGroundColor:selected];
    }
    else if(indexPath.row == 0 || indexPath.row == 8){ //hours
        self.dayTimeLable.text = @(indexPath.section - 1).stringValue;
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
    self.backgroundColor = [UIColor clearColor];
    self.dayTimeLable.text = @"";
    self.userInteractionEnabled = NO;
}

@end
