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
        self.backgroundColor = [SFIColors lightGreenColor];
    else
        self.backgroundColor = [UIColor whiteColor];
}

-(void)addDayTimeLable:(NSIndexPath *)indexPath{
    NSArray *Days = @[@"", @"Su", @"Mo", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @""];
    if(indexPath.section == 0 || indexPath.section == 25){
        self.dayTimeLable.text = [Days objectAtIndex:indexPath.row];
        [self setTextLableProperties];
    }
    else if(indexPath.row == 0 || indexPath.row == 8){
        self.dayTimeLable.text = @(indexPath.section - 1).stringValue;
        [self setTextLableProperties];
    }
}

-(void)setTextLableProperties{
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
}


@end
