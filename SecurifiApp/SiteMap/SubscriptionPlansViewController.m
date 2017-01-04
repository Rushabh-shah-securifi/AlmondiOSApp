//
//  SubscriptionPlansViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/2/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SubscriptionPlansViewController.h"
#import "Colours.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonMethods.h"
#import "SFIColors.h"
#import "SelectedPlanViewController.h"
#import "AlmondPlan.h"
#import "AlmondManagement.h"
#import "UIViewController+Securifi.h"

#define TOP_LABEL @"toplabel"
#define MID_LABEL @"midlabel"
#define BOTTOM_LABEL @"bottomlabel"
#define PLAN_TYPE @"plantype"

@interface SubscriptionPlansViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic) NSInteger prevCount;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *planDesc;
@property (weak, nonatomic) IBOutlet UILabel *slideImgLbl;

@property (nonatomic)AlmondPlan *almondPlan;
@property (nonatomic)PlanType newSelectedPlan;
@end

@implementation SubscriptionPlansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.prevCount = 0;
    self.almondPlan = [AlmondPlan getAlmondPlan:self.currentMAC];
    self.planDesc.text = @"Please select a plan from the plans listed above.";
    self.newSelectedPlan = PlanTypeNone;
    
    self.imgView.image = [UIImage imageNamed:@"iot-security-device-scan"];
    self.slideImgLbl.text = NSLocalizedString(@"h_initiateScan", @"");
    
    [self addSwipeToView:self.centerView];
    [self setupScrollView];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark action methods
- (IBAction)onCrossBtnTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark swipe methods
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

#pragma mark page control
- (IBAction)onPageControlValueChange:(UIPageControl *)pageControl {
    NSLog(@"onPageControlValueChange");
    int currntPg = (int)pageControl.currentPage;
    if(_prevCount < currntPg)
        [self slideAnimation:YES];
    else
        [self slideAnimation:NO];
    
    switch (currntPg) {
        case 0:
            self.imgView.image = [UIImage imageNamed:@"iot-security-device-scan"];
            self.slideImgLbl.text = NSLocalizedString(@"h_initiateScan", @"");
            break;
        case 1:
            self.imgView.image = [UIImage imageNamed:@"iot-security-devices-active"];
            self.slideImgLbl.text = NSLocalizedString(@"h_flagDevices", @"");
            break;
        case 2:
            self.imgView.image = [UIImage imageNamed:@"iot-security-web-history"];
            self.slideImgLbl.text = NSLocalizedString(@"h_monitorSites", @"");
            break;
        default:
            break;
    }
//    self.imgView.image = [UIImage imageNamed:currntPg == 0? @"h_scene_behave": @"h_scene_create"];
//    self.centerView.backgroundColor = currntPg == 0? [UIColor lightGrayColor]: [UIColor orangeColor];
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

#pragma mark bottom view
- (void)setupScrollView{
    //    scrollView.backgroundColor = [UIColor lightGrayColor];
    CGFloat xOffset = 2;
    int counter = 0;
    NSArray *plans = [self getPlans];
    UIButton *planBtn;
    for(NSDictionary *plan in plans){
        PlanType planType = [plan[PLAN_TYPE] integerValue];
        if(planType == PlanTypeCancel){
            planBtn = [self makeCancelButton:xOffset selector:@selector(onPlanBtnTap:) plan:plan];
        }else{
            planBtn = [self makePlanButton:xOffset selector:@selector(onPlanBtnTap:) plan:plan];
        }
        planBtn.tag = planType;
        if(planType == PlanTypeFreeExpired){
            planBtn.alpha = 0.6;
            planBtn.enabled = NO;
        }
        [self.scrollView addSubview:planBtn];
        //        label.backgroundColor = [UIColor yellowColor];
        xOffset += 120;
        counter++;
    }

    [self setHorizantalScrolling:self.scrollView];
}

- (NSArray *)getPlans{
    NSMutableArray *plans = [NSMutableArray new];
    
    //if(self.almondPlan.planType != PlanTypeNone)
      //  [plans addObject:[self getPlanDict:@"" midLabel:@"Cancel Subscription" btmLabel:@"" planType:PlanTypeCancel]];
    
    NSString *text1 = self.almondPlan.planType != PlanTypeNone? @"EXPIRED": @"TRIAL";
    PlanType freePlanType = self.almondPlan.planType != PlanTypeNone? PlanTypeFreeExpired: PlanTypeFree;
    [plans addObject:[self getPlanDict:@"1 Month" midLabel:@"Free" btmLabel:text1 planType:freePlanType]];

//    [plans addObject:[self getPlanDict:@"1 Day" midLabel:@"Test" btmLabel:@"PLAN" planType:PlanTypeOneDay]];
    
    [plans addObject:[self getPlanDict:@"1 Month" midLabel:@"$9.99" btmLabel:@"$3.99" planType:PlanTypeOneMonth]];
    
//    [plans addObject:[self getPlanDict:@"3 Months" midLabel:@"$12" btmLabel:@"PLAN" planType:PlanTypeThreeMonths]];
    
//    [plans addObject:[self getPlanDict:@"6 Months" midLabel:@"$20" btmLabel:@"PLAN" planType:PlanTypeSixMonths]];
    
    [plans addObject:[self getPlanDict:@"1 Year" midLabel:@"$48" btmLabel:@"$39.99" planType:PlanTypeOneYear]];
    
    return plans;
}

- (NSDictionary *)getPlanDict:(NSString *)topLabel midLabel:(NSString *)midLabel btmLabel:(NSString *)btmLabel planType:(PlanType)planType{
    NSMutableDictionary *muDict = [NSMutableDictionary new];
    [muDict setObject:topLabel forKey:TOP_LABEL];
    [muDict setObject:midLabel forKey:MID_LABEL];
    [muDict setObject:btmLabel forKey:BOTTOM_LABEL];
    [muDict setObject:[NSNumber numberWithInt:planType] forKey:PLAN_TYPE];
    
    return muDict;
}

- (UIButton *)makePlanButton:(CGFloat)xOffset selector:(SEL)selector plan:(NSDictionary *)plan{
    UIButton *planBtn = [[UIButton alloc]initWithFrame:CGRectMake(xOffset, 20, 100, 100)];
    [planBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
//    planBtn.backgroundColor = [UIColor colorFromHexString:@"02a8f3"];
    
    [self addLables:planBtn plan:plan];
    [self setBorder:planBtn];
    return planBtn;
}

- (UIButton *)makeCancelButton:(CGFloat)xOffset selector:(SEL)selector plan:(NSDictionary *)plan{
    UIButton *planBtn = [[UIButton alloc]initWithFrame:CGRectMake(xOffset, 20, 100, 100)];
    [planBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    //    planBtn.backgroundColor = [UIColor colorFromHexString:@"02a8f3"];
    
    [self addCancelLable:planBtn plan:plan];
    [self setBorder:planBtn];
    return planBtn;
}

- (void)addCancelLable:(UIButton *)btn plan:(NSDictionary *)plan{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, CGRectGetWidth(btn.frame), 60)];
    label.center = CGPointMake(CGRectGetMidX(btn.bounds), CGRectGetMidY(btn.bounds));
    [self addLable:plan[MID_LABEL] btn:btn label:label fntName:@"Avenir-Roman" fntSze:14];
}

- (void)addLables:(UIButton *)btn plan:(NSDictionary *)plan{
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, CGRectGetWidth(btn.frame), 20)];
    [self addLable:plan[TOP_LABEL] btn:btn label:label1 fntName:@"Avenir-Roman" fntSze:16];
    
    //label2
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, CGRectGetWidth(btn.frame), 20)];
    label2.center = CGPointMake(CGRectGetMidX(btn.bounds), CGRectGetMidY(btn.bounds));
    [self addLable:plan[MID_LABEL] btn:btn label:label2 fntName:@"Avenir-Roman" fntSze:16];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:plan[MID_LABEL]];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributeString length])];
    if(![[plan[MID_LABEL] lowercaseString] isEqualToString:@"free"])
        label2.attributedText = attributeString;
    
    //label3
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(btn.frame)-30, CGRectGetWidth(btn.frame), 20)];
    [self addLable:plan[BOTTOM_LABEL] btn:btn label:label3 fntName:@"Avenir-Heavy" fntSze:18];
}

-(void)addLable:(NSString *)title btn:(UIButton *)btn label:(UILabel*)label fntName:(NSString *)fntName fntSze:(int)fntSze{
    [CommonMethods setLableProperties:label text:title textColor:label.textColor = [SFIColors paymentColor] fontName:fntName fontSize:fntSze alignment:NSTextAlignmentCenter];
    [btn addSubview:label];
}

- (void)setBorder:(UIButton *)planBtn{
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [SFIColors paymentColor].CGColor;
    border.fillColor = nil;
    border.lineDashPattern = @[@4, @2];
    
    border.path = [UIBezierPath bezierPathWithRect:planBtn.bounds].CGPath;
    border.frame = planBtn.bounds;
    
    [planBtn.layer addSublayer:border];
}

- (void)setHorizantalScrolling:(UIScrollView *)scrollView{
    CGRect contentRect = CGRectZero;
    for (UIView *view in scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    scrollView.contentSize = contentRect.size;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width+2,scrollView.frame.size.height);
}

-(void)onPlanBtnTap:(UIButton *)currentBtn{
    NSLog(@"onPlanBtnTap tag: %d", currentBtn.tag);
    if(currentBtn.selected)
        return;
    
    for(UIButton *button in [self.scrollView subviews]){
        if([button isKindOfClass:[UIImageView class]]){
            continue;
        }
        if(button.tag == currentBtn.tag){
            currentBtn.selected = YES;
            [self plainBtn:currentBtn];
        }
        
        else{
            if(button.selected)//optimisation
                [self dottenBtn:button];
            button.selected = NO;
        }
    }
    //write a methods, pass it text to make bold and the entire text, it should return you the attributed string.
    NSString *text1 = @"You have selected ";
    NSString *text2 = [NSString stringWithFormat:@"for Internet Security on %@", [AlmondManagement cloudAlmond:self.currentMAC].almondplusName];
    switch (currentBtn.tag) {
        case PlanTypeFree:
            self.planDesc.attributedText = [CommonMethods getAttributedString:text1 subText:@"1 Month Free Trial " text:text2 fontSize:self.planDesc.font.pointSize];
            break;
        case PlanTypeOneDay:
            self.planDesc.attributedText = [CommonMethods getAttributedString:text1 subText:@"1 Day Test Plan " text:text2 fontSize:self.planDesc.font.pointSize];
            break;
        case PlanTypeOneMonth:
            self.planDesc.attributedText = [CommonMethods getAttributedString:text1 subText:@"1 Month $3.99 Plan " text:text2 fontSize:self.planDesc.font.pointSize];
            break;
        case PlanTypeThreeMonths:
            self.planDesc.attributedText = [CommonMethods getAttributedString:text1 subText:@"3 Months $12 Plan " text:text2 fontSize:self.planDesc.font.pointSize];
            break;
        case PlanTypeSixMonths:
            self.planDesc.attributedText = [CommonMethods getAttributedString:text1 subText:@"6 Months $20 Plan " text:text2 fontSize:self.planDesc.font.pointSize];
            break;
        case PlanTypeOneYear:
            self.planDesc.attributedText = [CommonMethods getAttributedString:text1 subText:@"1 Year $39.99 Plan " text:text2 fontSize:self.planDesc.font.pointSize];
            break;
        default:
            break;
    }
    self.newSelectedPlan = currentBtn.tag;
}


- (void)dottenBtn:(UIButton *)btn{
    NSLog(@"dottenBtn");
    [self toggleSubLayersVisibiity:NO layers:btn.layer.sublayers];
    btn.backgroundColor = [UIColor whiteColor];
    for(UILabel *label in [btn subviews]){
        label.textColor = [SFIColors paymentColor];
    }
}

- (void)plainBtn:(UIButton *)btn{
    NSLog(@"plainBtn");
    [self toggleSubLayersVisibiity:YES layers:btn.layer.sublayers];
    btn.backgroundColor = [SFIColors paymentColor];
    for(UILabel *label in [btn subviews]){
        label.textColor = [UIColor whiteColor];
    }
}

- (void)toggleSubLayersVisibiity:(BOOL)hide layers:(NSArray*)subLayers{
    for(CALayer *layer in subLayers){
        if([layer isKindOfClass:[CAShapeLayer class]])
            layer.hidden = hide;
    }
}

#pragma action events
- (IBAction)onContinueTap:(id)sender {
    NSLog(@"onContinueTap");
    if(self.newSelectedPlan == PlanTypeNone){
        [self showToast:@"Please select a plan."];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    SelectedPlanViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectedPlanViewController"];
    viewController.selectedPlan = self.newSelectedPlan;
    viewController.currentMAC = self.currentMAC;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
