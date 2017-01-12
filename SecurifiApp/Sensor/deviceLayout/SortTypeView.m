//
//  SortTypeView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SortTypeView.h"
#import "CommonMethods.h"
#import "Colours.h"
#import "UIFont+Securifi.h"

@implementation SortTypeView

-(id)initWithFrame:(CGRect)frame sortType:(NSDictionary *)sortTypeDict buttonTag:(NSInteger)buttonTag {
    self = [super initWithFrame:frame];
    if(self){
        self.sortTypeDict = sortTypeDict;
        [self imageButtonViews:buttonTag];
    }
    return self;
}
-(void)imageButtonViews:(NSInteger )buttonTag{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    button.tag = buttonTag;
    [button addTarget:self action:@selector(onButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 45, 45)];
//    imageView.center = self.center;
    imageView.center = CGPointMake(CGRectGetMidX(self.bounds), imageView.center.y);
    NSLog(@"self.sortTypeDict %@",self.sortTypeDict);
    imageView.image = [CommonMethods imageNamed:[self.sortTypeDict valueForKey:@"image"] withColor:[UIColor colorFromHexString:@"929292"]];
    
    [self addSubview:imageView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
    label.textColor = [UIColor colorFromHexString:@"929292"];
    label.text = [self.sortTypeDict valueForKey:@"name"];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont securifiFont:14];
    [self addSubview:label];
}
-(void)onButtonTap:(id)sender{
    [self.delegate onTypeSelection:sender];
}
@end
