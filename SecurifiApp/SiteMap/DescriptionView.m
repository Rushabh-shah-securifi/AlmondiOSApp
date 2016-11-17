//
//  DescriptionView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 16/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DescriptionView.h"
@interface DescriptionView()
@property (strong, nonatomic) IBOutlet DescriptionView *viewMain;

@end
@implementation DescriptionView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.viewMain.frame = frame;
    if(self){
//        NSLog(@"frame initialized");
//         [[NSBundle mainBundle] loadNibNamed:@"DescriptionView" owner:self options:nil];
//        self.viewMain.frame = frame;
//        [self addSubview:self.viewMain];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
   self = [super initWithCoder:aDecoder];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"DescriptionView" owner:self options:nil];
        self.viewMain.frame = self.frame;
        [self addSubview:self.viewMain];
    }
return self;
}
@end
