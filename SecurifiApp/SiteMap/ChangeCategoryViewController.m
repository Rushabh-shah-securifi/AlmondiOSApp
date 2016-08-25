//
//  ChangeCategoryViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ChangeCategoryViewController.h"
#import "UIViewController+Securifi.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "CategoryView.h"

@interface ChangeCategoryViewController ()<CategoryViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *catogeryTag;
@property (weak, nonatomic) IBOutlet UILabel *catogeryFuncLbl;
@property (weak, nonatomic) IBOutlet UILabel *CatogeryStatusLbl;

@property (weak, nonatomic) IBOutlet UILabel *LblCatogeryTag;
@property (weak, nonatomic) IBOutlet UILabel *LblUri;
@property (weak, nonatomic) IBOutlet UIButton *backGroundButton;
@property (weak, nonatomic) IBOutlet UILabel *LblCatogeryType;
@property (weak, nonatomic) IBOutlet UILabel *LblClientLastVicited;
@property (nonatomic) UIColor *globalColor;
@property (nonatomic) CategoryView *cat_view;
@property (nonatomic) NSString *catTag;




@end

@implementation ChangeCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
-(void)updateNavi:(UIColor *)backGroundColor title:(NSString *)title tintColor:(UIColor *)tintColor tintBarColor:(UIColor *)tintBarColor{
    self.navigationController.view.backgroundColor =  backGroundColor;
    self.navigationController.navigationBar.topItem.title = title;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.barTintColor = tintBarColor;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    self.cat_view = [[CategoryView alloc]init];
    self.cat_view.delegate = self;
    NSLog(@"uri dict = %@ ",self.uriDict);
    [self categoryMap:self.uriDict[@"categoryObj"]];
    
    
}
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)categoryMap:(NSDictionary *)uriDict{
    self.LblUri.text = self.uriDict[@"hostName"];
    if([[uriDict valueForKey:@"categoty"] isEqualToString:@"NC-17"]){
        
        self.globalColor = [UIColor colorFromHexString:@"000000"];
        self.catogeryFuncLbl.text = @"Adults Only";
       
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"R"]){
        self.globalColor = [UIColor colorFromHexString:@"f44336"];
        self.catogeryFuncLbl.text = @"Restricted";
     
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"PG-13"]){
        self.globalColor = [UIColor colorFromHexString:@"ff9800"];
        self.catogeryFuncLbl.text = @"Parents Strongly Cautioned";
      
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"PG"]){
        self.globalColor = [UIColor colorFromHexString:@"ffc107"];
        self.catogeryFuncLbl.text = @"Parential Guidence Suggested";
        
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"G"]){
        self.globalColor = [UIColor colorFromHexString:@"4caf50"];
        self.catogeryFuncLbl.text = @"General Audiences";
        
    }
    
    [self.catogeryTag setTextColor:self.globalColor];
    self.bottomView.backgroundColor = self.globalColor;
    _LblCatogeryTag.backgroundColor = self.globalColor;
    self.catogeryTag.text =[uriDict valueForKey:@"categoty"];
    
    self.LblCatogeryTag.text =[uriDict valueForKey:@"categoty"];
   
    self.LblCatogeryType.text = [uriDict valueForKey:@"subCategory"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changedCatogeryButtonPrssed:(id)sender {
    NSLog(@"changedCatogeryButtonPrssed");
    

        self.cat_view.frame = CGRectMake(0, self.view.frame.size.height - 230, self.view.frame.size.width, 230);
        [self.view addSubview:self.cat_view];
    
    
    self.backGroundButton.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)dismissCategoryTag:(id)sender {
    [self.cat_view removeFromSuperview];
    self.backGroundButton.hidden = YES;
}

-(void )didChangeCategoryWithTag:(NSInteger)tag{
//    NSDictionary *updatedUriDict;
    switch (tag) {
        case 1:
            [self showToast:@"updating category Adults Only"];
            
            break;
        case 2:
            [self showToast:@"updating category Rrstricted"];
            
            break;
        case 3:
            [self showToast:@"Parents Strongly Cautioned"];
           
            break;
        case 4:
            [self showToast:@"Parential Guidence Suggested"];
           
            break;
        case 5:
            [self showToast:@"General Audiences"];
            
            break;
        default:
            
            break;
        
    }
    [self.cat_view removeFromSuperview];
    self.backGroundButton.hidden = YES;
}
@end
