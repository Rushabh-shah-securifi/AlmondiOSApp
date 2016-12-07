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
#import "Colours.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "LocalNetworkManagement.h"
#import "AlmondManagement.h"

@interface HelpScreens()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *helpPrompt; //[showme, hide]
@property (strong, nonatomic) IBOutlet UIView *triggerHelp;
@property (strong, nonatomic) IBOutlet UIView *okGotItView;


@property (weak, nonatomic) IBOutlet UIView *centerView;
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
@property (weak, nonatomic) IBOutlet UIImageView *imgBack;
@property (weak, nonatomic) IBOutlet UIButton *BtnSkip;

//help topics

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConst;

@property (nonatomic) NSInteger prevCount;
@end

@implementation HelpScreens
- (void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"awake from nib");
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSLog(@"frame initialized");
        [[NSBundle mainBundle] loadNibNamed:@"HelpScreen" owner:self options:nil];
        self.prevCount = 0;
    }
    return self;
}


+ (HelpScreens *)initializeHelpScreen:(UIView *)navView isOnMainScreen:(BOOL)isOnMainScreen startScreen:(NSDictionary *)startScreen {
    HelpScreens *helpView = [[HelpScreens alloc]initWithFrame:CGRectMake(0, 20, navView.frame.size.width, navView.frame.size.height)];
    helpView.isOnMainScreen = isOnMainScreen;
    [helpView expandView];
    
    helpView.startScreen = startScreen;
    [helpView initailizeFirstScreen];
    
    [helpView addHelpItem:CGRectMake(0, 0, navView.frame.size.width, navView.frame.size.height-20)];
    
    return helpView;
}

+ (void)initializeGotItView:(HelpScreens *)helpView navView:(UIView *)navView{
    int helpViewHeight = 155;
    helpView.frame = CGRectMake(0, navView.frame.size.height - helpViewHeight, navView.frame.size.width, helpViewHeight);
    [helpView addGotItView:CGRectMake(0, 0, navView.frame.size.width, helpViewHeight)];
}

+ (void)initializeWifiPresence:(HelpScreens *)helpView view:(UIView *)mainView tabHt:(CGFloat)tabHeight{
    CGFloat helpHt = 120;
    helpView.frame = CGRectMake(0, mainView.frame.size.height - helpHt - tabHeight, mainView.frame.size.width, mainView.frame.size.height);
    [helpView addHelpPromptSubView:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)];
}

+ (void)addTriggerHelpPage:(HelpScreens *)helpView startScreen:(NSDictionary *)startScreen navView:(UIView*)navView{
    int triggerHeight = navView.frame.size.height - 50;
    helpView.frame = CGRectMake(0, 50, navView.frame.size.width, triggerHeight);
    
    //is on main screen is not required, as resetbottomconstraint is called here
    [helpView resetBottonConstraint];
    
    helpView.startScreen = startScreen; 
    [helpView initailizeFirstScreen];
    
    [helpView addHelpItem:CGRectMake(0, 0, navView.frame.size.width, triggerHeight)];
}

- (void)addHelpPromptSubView:(CGRect)frame{
    self.helpPrompt.frame = frame;
    [self addSubview:self.helpPrompt];
}

- (void)addHelpItem:(CGRect)frame{
    self.triggerHelp.frame = frame;
    [self addSwipeToView:self.triggerHelp];
    [self addSubview:self.triggerHelp];
}

-(void)addSwipeToView:(UIView*)view{
    [self addGestureRecognizer:view direction:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:view direction:UISwipeGestureRecognizerDirectionLeft];
}

-(void)addGestureRecognizer:(UIView*)view direction:(UISwipeGestureRecognizerDirection)direction{
     UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    recognizer.delegate = self;
    [recognizer setDirection:(direction)];
    [view addGestureRecognizer:recognizer];
}


-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)gestureRecognizer{
    NSLog(@"handle swipe from directrion: %zd", gestureRecognizer.direction);
    NSLog(@"self pagecontrol: %td", self.pageControl.currentPage);
    if((self.pageControl.currentPage == 0 && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) || (self.pageControl.currentPage == self.pageControl.numberOfPages-1 && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)){
        return;
    }
    if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        [self.pageControl setCurrentPage:self.pageControl.currentPage+1];
    }else{
        [self.pageControl setCurrentPage:self.pageControl.currentPage-1];
    }
    
    [self onPageControlValueChange:self.pageControl];
}


- (void)addGotItView:(CGRect)frame{
    self.okGotItView.frame = frame;
    [self addSubview:self.okGotItView];
}

-(void)expandView{
    self.goToHelp.hidden = YES;
    self.imgCross.hidden = YES;
    if(self.isOnMainScreen){
        self.imgBack.hidden = YES;
    }else{
        self.imgBack.hidden = NO;
    }
    self.bottomConst.constant = -40;
}

-(void)resetBottonConstraint{
    self.imgCross.hidden = NO;
    self.goToHelp.hidden = NO;
    self.imgBack.hidden = YES;
    self.BtnSkip.hidden = NO;
    self.bottomConst.constant = 0;
}

-(void)initailizeFirstScreen{
    NSArray *screens = self.startScreen[SCREENS];
    NSDictionary *screen = screens.firstObject;
    
    self.hlpTitle.text = NSLocalizedString(self.startScreen[@"name"], @"");
    self.imgView.image = [UIImage imageNamed:screen[IMAGE]];
    self.imgView.backgroundColor = [UIColor colorFromHexString:screen[COLOR]];
    self.subTitle.text = NSLocalizedString(screen[TITLE], @"");
    
    [self setDescText:screen];
    self.pageControl.numberOfPages = [self.startScreen[SCREENCOUNT] intValue];
    [self.pageControl setCurrentPage:0];
    
    self.leftArrow.hidden = YES;
    if(screens.count == 1){
        self.rightArrow3.hidden = YES;
        self.gotIt.hidden = NO;
    }else{
        self.rightArrow3.hidden = NO;
        self.gotIt.hidden = YES;
    }
}

-(void)setDescText:(NSDictionary *)screen{
    //json has key url
    NSString *desc = NSLocalizedString(screen[DESCRIPTION], @"");
    if(screen[S_URL] != nil){
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName: self.desc.textColor,
                                  NSFontAttributeName: self.desc.font, //has font name and size perhaps
                                  };
        
        
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:desc attributes:attribs];
        NSURL *link = ![screen[S_URL] isEqualToString:@"local"]? [NSURL URLWithString:screen[S_URL]]: [self getLocalURL];
        [attrStr addAttribute:NSLinkAttributeName value:link range:NSMakeRange(attrStr.length-5, 4)];
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(attrStr.length-5, 4)];
        self.desc.attributedText = attrStr;
    }
    else{
        self.desc.text = desc;
    }
}

-(NSURL *)getLocalURL{
    SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:[AlmondManagement currentAlmond].almondplusMAC];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", settings.host]];
}

- (IBAction)onShowMeTap:(id)sender {
    [self removeFromSuperview];
    [self.delegate onShowMeTapDelegate];
}

- (IBAction)onHideTap:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)onPageControlValueChange:(UIPageControl *)pageControl {
    NSLog(@"onPageControlValueChange");
    int currntPg = (int)pageControl.currentPage;
    if(_prevCount < currntPg)
        [self slideAnimation:YES];
    else
        [self slideAnimation:NO];
    
    NSArray *screens = self.startScreen[SCREENS];
    NSDictionary *screen = [screens objectAtIndex:currntPg];
    
    self.subTitle.text = NSLocalizedString(screen[TITLE], @"");
    [self setDescText:screen];
    [self.desc setContentOffset:CGPointZero animated:YES];

    
    self.imgView.image = [UIImage imageNamed:screen[IMAGE]];
    self.imgView.backgroundColor = [UIColor colorFromHexString:screen[COLOR]];
    
    NSLog(@"current count: %zd, screens count: %zd", pageControl.currentPage, screens.count);
    //current page starts from 0
    if(pageControl.currentPage == 0){
        self.leftArrow.hidden = YES;
        self.rightArrow3.hidden = NO;
        self.gotIt.hidden = YES;
    }
    else if(pageControl.currentPage == screens.count - 1){
        self.leftArrow.hidden = NO;
        self.rightArrow3.hidden = YES;
        self.gotIt.hidden = NO;
    }else{
        self.leftArrow.hidden = NO;
        self.rightArrow3.hidden = NO;
        self.gotIt.hidden = YES;
    }
    self.prevCount = currntPg;
}


-(void)slideAnimation:(BOOL)isLeft{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    //dont miss the keyword "From" in KCATRANSITIONFROMRIGHT
    transition.subtype = isLeft? kCATransitionFromRight: kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.centerView.layer addAnimation:transition forKey:nil];
    //    [parentView addSubview:myVC.view];
}


- (IBAction)onCrossButtonTap:(id)sender {
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
