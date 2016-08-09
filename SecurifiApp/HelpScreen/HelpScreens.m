//
//  HelpScreens.m
//  SecurifiApp
//
//  Created by Masood on 7/15/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpScreens.h"
#import "SFIColors.h"
#import "AlmondJsonCommandKeyConstants.h"

@interface HelpScreens()
@property (strong, nonatomic) IBOutlet UIView *helpPrompt;
@property (strong, nonatomic) IBOutlet UIView *triggerHelp;
@property (strong, nonatomic) IBOutlet UIView *okGotItView;


@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *gotIt;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrow;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow3;
@property (weak, nonatomic) IBOutlet UILabel *hlpTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UITextView *desc;
@property (weak, nonatomic) IBOutlet UIButton *goToHelp;
@property (weak, nonatomic) IBOutlet UIImageView *imgCross;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConst;

@end

@implementation HelpScreens
- (void)awakeFromNib{
    NSLog(@"awake from nib");
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSLog(@"frame initialized");
        [[NSBundle mainBundle] loadNibNamed:@"HelpScreen" owner:self options:nil];
    }
    return self;
}

- (void)addHelpPromptSubView:(CGRect)frame{
    self.helpPrompt.frame = frame;
    [self addSubview:self.helpPrompt];
}

- (void)addHelpItem:(CGRect)frame{
    self.triggerHelp.frame = frame;
    [self addSubview:self.triggerHelp];
}

- (void)addGotItView:(CGRect)frame{
    self.okGotItView.frame = frame;
    [self addSubview:self.okGotItView];
}

-(void)expandView{
    self.goToHelp.hidden = YES;
    self.imgCross.hidden = YES;
    self.bottomConst.constant = -40;
}

-(void)resetBottonConstraint{
    self.imgCross.hidden = NO;
    self.goToHelp.hidden = NO;
    self.bottomConst.constant = 0;
}

-(void)initailizeFirstScreen{
    NSArray *screens = self.startScreen[SCREENS];
    NSDictionary *screen = screens.firstObject;
    
    self.hlpTitle.text = NSLocalizedString(self.startScreen[@"name"], @"");
    self.imgView.image = [UIImage imageNamed:screen[IMAGE]];
    self.subTitle.text = NSLocalizedString(screen[TITLE], @"");
    self.desc.text = NSLocalizedString(screen[DESCRIPTION], @"");
    
    self.pageControl.numberOfPages = [self.startScreen[SCREENCOUNT] intValue];
    [self.pageControl setCurrentPage:0];
    
    if(screens.count == 1){
        self.leftArrow.hidden = YES;
        self.rightArrow3.hidden = YES;
        self.gotIt.hidden = NO;
    }else{
        self.leftArrow.hidden = NO;
        self.rightArrow3.hidden = NO;
        self.gotIt.hidden = YES;
    }
}

- (IBAction)onShowMeTap:(id)sender {
    [self removeFromSuperview];
    [self.delegate onShowMeTapDelegate];
}

- (IBAction)onHideTap:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)onPageControlValueChange:(id)sender {
    UIPageControl *pageControl = sender;
    int currntPg = (int)pageControl.currentPage;
    NSArray *screens = self.startScreen[SCREENS];
    NSDictionary *screen = [screens objectAtIndex:currntPg];
    
    self.subTitle.text = NSLocalizedString(screen[TITLE], @"");
    self.desc.text = NSLocalizedString(screen[DESCRIPTION], @"");
    self.imgView.image = [UIImage imageNamed:screen[IMAGE]];
    
    NSLog(@"current count: %d, screens count: %d", pageControl.currentPage, screens.count);
    //current page starts from 0
    if(pageControl.currentPage == screens.count - 1){
        self.rightArrow3.hidden = YES;
        self.gotIt.hidden = NO;
    }else{
        self.rightArrow3.hidden = NO;
        self.gotIt.hidden = YES;
    }
}

- (IBAction)onCrossButtonTap:(id)sender {
    if(self.imgCross.hidden)
        return;
    [self resetViews];
}

- (IBAction)onSkipButtonTap:(id)sender {
    [self resetViews];
    [self.delegate onSkipTapDelegate];
}

- (IBAction)onOkGotItTap:(id)sender {
    [self resetViews];
}

- (IBAction)onHelpOkGotItTap:(id)sender {
    [self resetViews];
}

-(void)resetViews{
    //remove helpscreen, restore tabbar
    [self.delegate resetViewDelegate];
}

- (IBAction)onGoToHelpCenterTap:(id)sender {
    [self.delegate onGoToHelpCenterTapDelegate];
}


@end
