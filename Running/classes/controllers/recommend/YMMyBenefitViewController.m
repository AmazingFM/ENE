//
//  YMMyBenefitViewController.m
//  Running
//
//  Created by 张永明 on 16/10/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMMyBenefitViewController.h"
#import "YMShowNoticeController.h"

#import "YMBenefitBoard.h"
#import "YMUserManager.h"
#import "YMUtil.h"
#import "YMMyBoy.h"

@interface YMMyBenefitViewController () <YMBenefitDelegate>
{
    NSString *_beginDate;
    NSString *_endDate;
    
    YMBenefitBoard *_benefitBoard;
    YMBenefitChart *_benefitChart;
}

@property (nonatomic, retain) YMMyProfit *myProfit;

@end

@implementation YMMyBenefitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgba(237, 237, 237, 1);;
    
//    [self addTitleBar:CGRectMake(0, 0, g_screenWidth, 40.f)];
    [self addInfoBoard:CGRectMake(0, 0.f, g_screenWidth, 150.f)];
    [self addBenifitChart:CGRectMake(0, 160, g_screenWidth,  g_screenHeight-kYMTopBarHeight-44-10-160)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startGetProfit];
}

- (YMMyProfit *)myProfit
{
    if (_myProfit==nil) {
        _myProfit = [[YMMyProfit alloc] init];
    }
    return _myProfit;
}

//- (void)addTitleBar:(CGRect)frame
//{
//    UIView *backView = [[UIView alloc] initWithFrame:frame];
//    backView.backgroundColor = [UIColor clearColor];
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,frame.size.height)];
//    titleLabel.centerX = g_screenWidth/2;
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"结算统计";
//    titleLabel.textColor = rgba(100, 100, 100, 1);
//    titleLabel.font = kYMSmallFont;
//    
//    UIButton *leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftArrow setImage:[UIImage imageNamed:@"rc-leftarrow"] forState:UIControlStateNormal];
//    leftArrow.frame = CGRectMake(10, 0, 30, frame.size.height);
//    leftArrow.tag = 1000;
//    leftArrow.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    leftArrow.backgroundColor = [UIColor yellowColor];
//    [leftArrow addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightArrow setImage:[UIImage imageNamed:@"rc-rightarrow"] forState:UIControlStateNormal];
//    rightArrow.frame = CGRectMake(frame.size.width-10-30, 0, 30, frame.size.height);
//    rightArrow.tag = 1001;
//    rightArrow.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    rightArrow.backgroundColor = [UIColor yellowColor];
//    [rightArrow addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [backView addSubview:titleLabel];
//    [backView addSubview:leftArrow];
//    [backView addSubview:rightArrow];
//    
//    [self.view addSubview:backView];
//}

- (void)addInfoBoard:(CGRect)frame
{
    _benefitBoard = [[YMBenefitBoard alloc] initWithFrame:frame];
    _benefitBoard.delegate = self;
    [self.view addSubview:_benefitBoard];
}

- (void)addBenifitChart:(CGRect)frame
{
    _benefitChart = [[YMBenefitChart alloc] initWithFrame:frame];
    [self.view addSubview:_benefitChart];
}

- (void)onClick:(UIButton *)sender
{
    if (sender.tag==1000) {
        //
    } else if (sender.tag==1001) {
        //
    }
}

- (void)showTips
{
    YMShowNoticeController *showNoticeVC = [[YMShowNoticeController alloc] init];
    showNoticeVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    if (g_nOSVersion>=8.0f) {
        showNoticeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else {
        showNoticeVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    [self presentViewController:showNoticeVC animated:YES completion:nil];
}

#pragma mark 网络请求

- (void)startGetProfit
{
//    if (![self getParameters]) {
//        return;
//    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    
    NSDate *today = [NSDate date];
    
    NSDate *beginDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*3600];
    NSString *beginTime = [YMUtil stringFromDate:beginDate withFormat:@"yyyyMMdd"];
    
    parameters[@"begin_date"] = beginTime;
    parameters[@"end_date"] = [YMUtil stringFromDate:today withFormat:@"yyyyMMdd"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserProfit"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *resp_data = respDict[kYM_RESPDATA];
                if (resp_data) {
                    self.myProfit.month_amt = resp_data[@"month_amt"];
                    self.myProfit.month_count = resp_data[@"month_count"];
                    self.myProfit.sum_amt = resp_data[@"sum_amt"];
                    self.myProfit.sum_count = resp_data[@"sum_count"];
                    
                    [self.myProfit.profit_list removeAllObjects];
                    NSArray *profitList = resp_data[@"profit_list"];
                    if (profitList.count>0) {
                        for (NSDictionary *dictItem in profitList) {
                            ProfitItem *item = [[ProfitItem alloc] init];
                            item.date = dictItem[@"date"];
                            item.occur_amt = dictItem[@"occur_amt"];
                            item.occur_count = dictItem[@"occur_count"];
                            [self.myProfit.profit_list addObject:item];
                        }
                        
                    }
                    
                    [_benefitBoard setProfit:self.myProfit];
                    [_benefitChart setProfit:self.myProfit];
                }
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        });
    }];
}

@end
