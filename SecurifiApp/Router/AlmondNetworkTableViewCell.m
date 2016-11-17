//
//  AlmondNetworkTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 7/26/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondNetworkTableViewCell.h"
#import "UIFont+Securifi.h"
#import "UIColor+Securifi.h"
#import "CommonMethods.h"
#import "UIFont+Securifi.h"

@interface AlmondNetworkTableViewCell()
@property (nonatomic) UIView *almondView;
@property (nonatomic) CGFloat yCoordinate;
@property (nonatomic) NSArray *summary;
@end
@implementation AlmondNetworkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSLog(@"almond n/w cell init");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super layoutSubviews];

        CGRect rect = self.bounds;
        rect = CGRectInset(rect, 10, 0);
        self.almondView.frame = rect;
        self.almondView.backgroundColor = [UIColor securifiRouterTileGreenColor];
    
        [self createAlmondNetworkView];
        [self.contentView addSubview:self.almondView];
    });
}

- (void)markReuse {
    UIView *oldView = self.almondView;
    UIView *newView = [[UIView alloc] initWithFrame:self.frame];
    dispatch_async(dispatch_get_main_queue(), ^{
        [oldView removeFromSuperview];
        self.almondView = newView;
    });
}

- (void)setHeading:(NSString*)heading titles:(NSArray *)titles almCount:(NSInteger)almCount{
    self.heading = heading;
    self.titles = titles;
    NSString *almText = almCount == 1? @"Almond": @"Almonds";
    self.msgs = @[[NSString stringWithFormat:@"You currently have %ld %@.", (long)almCount, almText],
                  @"Add more to increase Wi-Fi Coverage."];
}

-(void)createAlmondNetworkView{
    self.yCoordinate = 10;
    [self.almondView addSubview:[self makeTitleLabel:self.heading]];
    
    //add almond views (almond + bottomTitle)
    [self.almondView addSubview:[self makeAddAlmondView:self.titles]];
    
    //add summary
    [self.almondView addSubview:[self makeMsgLabel]];
}


- (UILabel *)makeMsgLabel{
    NSArray *msgs = self.msgs;
    NSString *msg;
    if (msgs) {
        msg = [msgs componentsJoinedByString:@"\n"];
    }
    else {
        msg = @"";
    }
    UILabel *label = [self makeMultiLineLabel:msg font:[UIFont securifiBoldFont:14] alignment:NSTextAlignmentLeft numberOfLines:2];
//    label.backgroundColor = [UIColor orangeColor];
    return label;
}

- (UIView *)makeAddAlmondView:(NSArray*)titles{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, self.yCoordinate, CGRectGetWidth(self.almondView.frame)-10, 115)];
//    scrollView.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat xOffset = 0;
    int almondCount = 0;
    for(NSString *title in titles){
        UIButton *almond = [self makeAlmondButton:@"almond_icon" xOffset:xOffset selector:@selector(onAlmondTap:)];
        almond.tag = almondCount;
        [scrollView addSubview:almond];
        
        [self addLable:title view:scrollView offset:xOffset];
//        label.backgroundColor = [UIColor yellowColor];
        xOffset += 80;
        almondCount++;
    }
    self.yCoordinate += CGRectGetHeight(scrollView.frame);
    UIButton *addAlmond = [self makeAlmondButton:@"add_almond" xOffset:xOffset selector:@selector(onAddAlmondTap:)];
    [scrollView addSubview:addAlmond];
    [self addLable:@"Add Almond" view:scrollView offset:xOffset];
    [self setHorizantalScrolling:scrollView];
    return scrollView;
}

-(void)addLable:(NSString *)title view:(UIScrollView *)scrlView offset:(CGFloat)xOffset{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xOffset, 70, 60, 40)];
    [CommonMethods setLableProperties:label text:title textColor:[UIColor whiteColor] fontName:@"Avenir-Heavy" fontSize:14 alignment:NSTextAlignmentCenter];
    [scrlView addSubview:label];
}

- (void)setHorizantalScrolling:(UIScrollView *)scrollView{
    CGRect contentRect = CGRectZero;
    for (UIView *view in scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    scrollView.contentSize = contentRect.size;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + 10,scrollView.frame.size.height);
}

- (UIButton *)makeAlmondButton:(NSString *)imageName xOffset:(CGFloat)xOffset selector:(SEL)selector{
    UIButton *almond = [[UIButton alloc]initWithFrame:CGRectMake(xOffset, 0, 60, 60)];
    [almond setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [almond addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return almond;
}


- (UILabel *)makeTitleLabel:(NSString *)title {
    UILabel *label =  [self makeMultiLineLabel:title font:[UIFont standardHeadingBoldFont] alignment:NSTextAlignmentLeft numberOfLines:1];
//    label.backgroundColor = [UIColor yellowColor];
    self.yCoordinate += CGRectGetHeight(label.frame);
    return label;
}

- (UILabel *)makeMultiLineLabel:(NSString *)title font:(UIFont*)textFont alignment:(enum NSTextAlignment)alignment numberOfLines:(int)lineCount{
    // offsets leaves room for the "edit" icon on the right side of the card or other rules
    CGFloat offset = 30;
    
    CGFloat width = CGRectGetWidth(self.frame) - offset;
    CGFloat height = textFont.pointSize * lineCount;
    height += textFont.pointSize; // padding
    CGRect frame = CGRectMake(10, self.yCoordinate, width, height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    NSLog(@"point size: %f", textFont.pointSize);
    [CommonMethods setLableProperties:label text:title textColor:[UIColor whiteColor] fontName:textFont.fontName fontSize:textFont.pointSize alignment:alignment];
    label.numberOfLines = lineCount;
    
    return label;
}

#pragma mark button tap methods
-(void)onAlmondTap:(UIButton *)almondBtn{
    NSLog(@"onAlmondTap");
    [self.delegate onAlmondTapDelegate:almondBtn.tag];
}

-(void)onAddAlmondTap:(UIButton *)addAlmondBtn{
    NSLog(@"onAddAlmondTap");
    [self.delegate onAddAlmondTapDelegate];
}

@end
