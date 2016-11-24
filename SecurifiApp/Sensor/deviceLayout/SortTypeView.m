//
//  SortTypeView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SortTypeView.h"

@implementation SortTypeView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self imageButtonViews];
    }
    return self;
}
-(void)imageButtonViews{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:button];
    button.backgroundColor = [UIColor greenColor];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 60, 60)];
//    imageView.center = self.center;
    imageView.center = CGPointMake(CGRectGetMidX(self.bounds), imageView.center.y);
    imageView.image = [UIImage imageNamed:@"filter_list_black"];
    [self addSubview:imageView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
    label.backgroundColor = [UIColor redColor];
    [self addSubview:label];
}
@end
