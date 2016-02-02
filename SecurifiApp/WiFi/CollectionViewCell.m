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

//-(void)awakeFromNib{
//    self.backgroundColor = [UIColor whiteColor];
//}

//-(void)changeBackgroundColor:(UIColor*)color{
    //    NSLog(@"changeBackgroundColor");
    //    UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
    //    self.backgroundView = bgView;
    //    self.backgroundView.backgroundColor = color;
//}


-(void)setSelected:(BOOL)selected{
    NSLog(@"set selected: %d", selected);
    [super setSelected:selected];
    if(selected)
        self.backgroundColor = [SFIColors lightGreenColor];
    else
        self.backgroundColor = [UIColor whiteColor];
}

-(void)addDayTimeLable:(NSIndexPath *)indexPath{
    NSLog(@"cell - indexpath: %@", indexPath);
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

-(void)setBlockedVal:(NSString*)blockedVal{
    if([blockedVal isEqualToString:@"1"]){
        self.selected = YES;
//        [self setSelected:YES];
//        self.userInteractionEnabled = YES;
    }
    
}

@end
