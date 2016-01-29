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

- (void)awakeFromNib {
    NSLog(@"awakeFromNib");
    [self changeBackgroundColor:[UIColor whiteColor]];
//    [self setSelectedColor:[SFIColors lightGreenColor]];
}

-(void)changeBackgroundColor:(UIColor*)color{
    NSLog(@"changeBackgroundColor");
    UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView = bgView;
    self.backgroundView.backgroundColor = color;
}

-(void)setSelectedColor:(UIColor*)color{
    NSLog(@"setSelectedColor");
    UIView *selectedView = [[UIView alloc]initWithFrame:self.bounds];
    self.selectedBackgroundView = selectedView;
    self.selectedBackgroundView.backgroundColor = color;
}

-(void)setSelected:(BOOL)selected{
    NSLog(@"set selected: %d", selected);
    [super setSelected:selected];
    if(selected)
        [self changeBackgroundColor:[SFIColors lightGreenColor]];
    else
        [self changeBackgroundColor:[UIColor whiteColor]];
}

-(void)addDayTimeLable:(NSIndexPath *)indexPath{
    NSLog(@"cell - indexpath: %@", indexPath);
    NSArray *Days = @[@"", @"Su", @"Mo", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @""];
    if(indexPath.section == 0 || indexPath.section == 25){
        self.dayTimeLable.text = [Days objectAtIndex:indexPath.row];
        [self setTextLableProperties];
    }
    else if(indexPath.row == 0 || indexPath.row == 8){
//        self.dayTimeLable.text = [NSString stringWithFormat:@"%ld-%ld",indexPath.section-1, (long)indexPath.section];
        self.dayTimeLable.text = @(indexPath.section - 1).stringValue;
        [self setTextLableProperties];
    }
}

-(void)setTextLableProperties{
    self.userInteractionEnabled = NO;
    [self changeBackgroundColor:[UIColor clearColor]];
}

-(void)setBlockedVal:(NSString*)blockedVal{
    if([blockedVal isEqualToString:@"1"])
//        [self setSelectedColor:[SFIColors lightGreenColor]];
//    [self changeBackgroundColor:[SFIColors lightGreenColor]];
//    [self setSelected:YES];
        [self setSelected:YES];
}

@end
