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
#import "NSDate+Convenience.h"
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
@property (nonatomic) CategoryView *cat_view_more;

@property (nonatomic) NSString *catTag;
@property (weak, nonatomic) IBOutlet UILabel *clientName;




@end

@implementation ChangeCategoryViewController

- (void)viewDidLoad {
     self.clientName.text = self.client.name;
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
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.uriDict[@"Epoc"] integerValue]];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];//Accessed on matt's iPhone on Wed 29 June 11:00.
    [dateformate setDateFormat:@"EEEE dd MMMM HH:mm"]; // Date formater
    NSString *str = [dateformate stringFromDate:date];
    self.LblClientLastVicited.text = [NSString stringWithFormat:@"Accessed on %@ on %@",self.client.name,str];
    NSLog(@"LblClientLastVicited %@",[NSString stringWithFormat:@"Accessed on %@ on %@",self.client.name,str]);
    self.cat_view = [[CategoryView alloc]init];
    self.cat_view_more = [[CategoryView alloc]initMoreClickView];
    self.cat_view_more.delegate = self;
    self.cat_view.delegate = self;
    NSLog(@"uri dict = %@ ",self.uriDict);
    [self categoryMap:self.uriDict[@"categoryObj"]];
    
    
}
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)categoryMap:(NSDictionary *)uriDict{
    NSString *urlStr = self.uriDict[@"hostName"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:urlStr attributes:nil];
    NSRange linkRange = NSMakeRange(0, urlStr.length); // for the word "link" in the string above
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
    [attributedString setAttributes:linkAttributes range:linkRange];
   
    self.LblUri.userInteractionEnabled = YES;
    [self.LblUri addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    // Assign attributedText to UILabel
    self.LblUri.attributedText = attributedString;
//    self.LblUri.text = self.uriDict[@"hostName"];
    if([[uriDict valueForKey:@"categoty"] isEqualToString:@"NC-17"]){
        
        self.globalColor = [UIColor colorFromHexString:@"000000"];
        self.catogeryTag.text =@"Adults Only";
        self.catogeryFuncLbl.text = @"No One 17 and Under Admitted. Clearly adult. Children are not admitted.";
       
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"R"]){
        self.globalColor = [UIColor colorFromHexString:@"f44336"];
        self.catogeryTag.text =@"Restricted";
        self.catogeryFuncLbl.text = @"Under 17 requires accompanying parent or adult guardian. Contains some adult material. Parents are urged to learn more about the film before taking their young children with them.";
     
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"PG-13"]){
        self.globalColor = [UIColor colorFromHexString:@"ff9800"];
        self.catogeryTag.text =@"Parents Strongly Cautioned";
        self.catogeryFuncLbl.text = @"Some material may be inappropriate for children under 13. Parents are urged to be cautious. Some material may be inappropriate for pre teenagers.";
      
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"PG"]){
        self.globalColor = [UIColor colorFromHexString:@"ffc107"];
        self.catogeryTag.text =@"Parential Guidence Suggested";
        self.catogeryFuncLbl.text = @"Some material may not be suitable for children. Parents urged to give  parental guidance. May contain some material parents might not like for their young children.";
        
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"G"]){
        self.globalColor = [UIColor colorFromHexString:@"4caf50"];
        self.catogeryTag.text =@"General Audiences";
        self.catogeryFuncLbl.text = @"All ages admitted. Nothing that would offend parents for viewing by children.";
        
    }
    
//    [self.catogeryTag setTextColor:self.globalColor];
    self.bottomView.backgroundColor = self.globalColor;
    _LblCatogeryTag.backgroundColor = self.globalColor;
//    self.catogeryTag.text =[uriDict valueForKey:@"categoty"];
    
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
    [self.cat_view_more removeFromSuperview];
    self.backGroundButton.hidden = YES;
}

-(void )didChangeCategoryWithTag:(NSInteger)tag{
//    NSDictionary *updatedUriDict;
//    switch (tag) {
//        case 1:
//            [self showToast:@"updating category Adults Only"];
//            
//            break;
//        case 2:
//            [self showToast:@"updating category Rrstricted"];
//            
//            break;
//        case 3:
//            [self showToast:@"Parents Strongly Cautioned"];
//           
//            break;
//        case 4:
//            [self showToast:@"Parential Guidence Suggested"];
//           
//            break;
//        case 5:
//            [self showToast:@"General Audiences"];
//            
//            break;
//        default:
//            
//            break;
//        
//    }
    [self showToast:@"Thank you! Your suggestion has been recorded"];
    [self.cat_view removeFromSuperview];
    self.backGroundButton.hidden = YES;
}
-(void)handleTapOnLabel:(id)sender{
    NSLog(@"hyper link pressed");NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.uriDict[@"hostName"]]];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)moreOnCategoryClicked:(id)sender {
    NSLog(@"moreOnCategoryClicked");
    self.cat_view_more.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 320);
    [self.view addSubview:self.cat_view_more];
    self.backGroundButton.hidden = NO;
}
-(void)showmsg{
    self.cat_view_more.frame = CGRectMake(0, self.view.frame.size.height - 110, self.view.frame.size.width, 300);
    [self.view addSubview:self.cat_view_more];
}
-(void)closeMoreView{
    [self.cat_view removeFromSuperview];
    [self.cat_view_more removeFromSuperview];
    self.backGroundButton.hidden = YES;
}
@end
