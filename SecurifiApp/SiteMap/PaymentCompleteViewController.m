//
//  PaymentCompleteViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "PaymentCompleteViewController.h"

@interface PaymentCompleteViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSInteger prevCount;
@end

@implementation PaymentCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.prevCount = 0;
    [self addSwipeToView:self.centerView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark button tap
- (IBAction)onAccessParentalControlsTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    int currntPg = (int)pageControl.currentPage;
    if(_prevCount < currntPg)
        [self slideAnimation:YES];
    else
        [self slideAnimation:NO];
    
//    self.imageView.image = [UIImage imageNamed:currntPg == 0? @"h_scene_behave": @"h_scene_create"];
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


@end
