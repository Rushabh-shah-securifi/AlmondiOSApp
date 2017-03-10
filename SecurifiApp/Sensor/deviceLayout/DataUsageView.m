//
//  DataUsageView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DataUsageView.h"
#import "HTTPRequest.h"
#import "CommonMethods.h"

@interface DataUsageView()<HTTPDelegate>
@property (strong, nonatomic) IBOutlet DataUsageView *view;
@property (weak, nonatomic) IBOutlet UILabel *pastWeekLbl;
@property (weak, nonatomic) IBOutlet UILabel *detailPeriodButton;
@property (weak, nonatomic) IBOutlet UILabel *UPDigit;
@property (weak, nonatomic) IBOutlet UILabel *UPLbl;
@property (weak, nonatomic) IBOutlet UILabel *DownDigit;
@property (weak, nonatomic) IBOutlet UILabel *DownLbl;


@property (nonatomic) NSString *DaysValuenew;
@property (nonatomic) NSString *Datenew;
@property (nonatomic) NSString *label;

@property (nonatomic) HTTPRequest *httpReq;
@property (nonatomic) GenericIndexValue *genericIndexValue;

@property (nonatomic) NSString *amac;
@property (nonatomic) NSString *cmac;


@end

@implementation DataUsageView

- (id)initWithFrame:(CGRect)frame genericIndexValue:(GenericIndexValue *)gval amac:(NSString *)amac cmac:(NSString *)cmac{
    self = [super initWithFrame:frame];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"DataUsageView" owner:self options:nil];
        [self addSubview:self.view];
        self.genericIndexValue = gval;
        Client *client = [Client findClientByID:@(gval.deviceID).stringValue];
        self.amac = amac;
        self.cmac = cmac;
        self.DaysValuenew = @"7";
        self.httpReq = [[HTTPRequest alloc]init];
        self.httpReq.delegate = self;
        self.Datenew = [CommonMethods getTodayDate];
        [self createRequest:@"Bandwidth" value:self.DaysValuenew date:self.Datenew];
    }
    return self;
}
- (IBAction)detailPeripdClicked:(id)sender {
    
}
-(void)responseDict:(NSDictionary *)responseDict{
    NSDictionary *dict = responseDict[@"Data"];
    // ClearBandwidth ClearHistory
    if([responseDict[@"search"] isEqualToString:@"ClearBandwidth"] || [responseDict[@"search"] isEqualToString:@"ClearHistory"]){
        [self createRequest:@"Bandwidth" value:self.DaysValuenew   date:self.Datenew];
        return;
    }
    if(dict[@"RX"] == NULL || dict[@"TX"] == NULL)
        return ;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        NSArray *downArr = [CommonMethods readableValueWithBytes:dict[@"RX"]];
        self.DownDigit.text = [downArr objectAtIndex:0];
        self.DownLbl.text = [NSString stringWithFormat:@"%@ Download",[downArr objectAtIndex:1]];
        
        NSArray *upArr = [CommonMethods readableValueWithBytes:dict[@"TX"]];
        self.UPDigit.text = [upArr objectAtIndex:0];
        self.UPLbl.text = [NSString stringWithFormat:@"%@ Upload",[upArr objectAtIndex:1]];
    });
}
-(void)createRequest:(NSString *)search value:(NSString*)value date:(NSString *)date{
    NSString *req ;
    req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&AMAC=%@&CMAC=%@",search,value,date,_amac,_cmac];
//    [self showHudWithTimeoutMsg:@"Loading..." withDelay:1];// call delegate merhod for hud
    [self.httpReq sendHttpRequest:req];
}
@end
