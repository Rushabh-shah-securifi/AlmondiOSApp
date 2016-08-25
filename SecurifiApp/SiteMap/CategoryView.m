//
//  CategoryView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CategoryView.h"
@interface CategoryView()
@property (strong, nonatomic) IBOutlet UIView *cat_view;
@end
@implementation CategoryView
- (id)init{
    self = [super init];
    if(self){
        NSLog(@"frame initialized");
        [[NSBundle mainBundle] loadNibNamed:@"categoryTab" owner:self options:nil];
        [self addSubview:self.cat_view];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)categoryChanged:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self.delegate didChangeCategoryWithTag:button.tag];
   
}

@end
