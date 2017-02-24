//
//  YMPayViewController.m
//  Running
//
//  Created by freshment on 16/10/5.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMPayViewController.h"

#import "YMPayResultViewController.h"

#import "YMLabel.h"
#import "YMUserManager.h"
#import <AlipaySDK/AlipaySDK.h>

#define kYMPayTableHeaderViewHeight 50.f
@interface YMPayViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_mainTableView;
    
    UIView *_submitView;
    NSString *totalPrice;
    
    NSString *_orderStr;
    
    int payChannel;//0-alipay, 1-weixin
}

@end

@implementation YMPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    payChannel = -1;
    
    self.navigationItem.title = @"确认订单";
    self.view.backgroundColor = rgba(242, 242, 242, 1);
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _mainTableView.frame = CGRectMake(0, 0, g_screenWidth, g_screenHeight-kYMNavigationBarHeight-20-44);
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.bounces = NO;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    
    _mainTableView.tableHeaderView = [self addTableHeaderView];
    _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth,CGFLOAT_MIN)];
    
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:_mainTableView];
    
    _submitView = [self addSubmitView];
    [self.view addSubview:_submitView];
    
    [self getSignedPay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payResult:) name:kYMNoticePayResultIdentifier object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)addTableHeaderView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kYMPayTableHeaderViewHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *okImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-pay-ok"]];
    float okWidth = 30.f;
    okImageV.frame = CGRectMake(0,0, okWidth, okWidth);
    okImageV.center = CGPointMake(15+okWidth/2, kYMPayTableHeaderViewHeight/2);
    okImageV.backgroundColor = [UIColor clearColor];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(okImageV.frame)+10, 0, g_screenWidth, kYMPayTableHeaderViewHeight)];
    descLabel.text = @"下单成功，请在当日内完成支付\n否则订单将自动超时关闭";
    descLabel.numberOfLines = 2;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.font = kYMNormalFont;
    descLabel.textColor = rgba(102, 102, 102, 1);
    descLabel.textAlignment = NSTextAlignmentLeft;
    
    [backView addSubview:okImageV];
    [backView addSubview:descLabel];
    
    return backView;
}

- (UIView *)addSubmitView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, g_screenHeight-44.f, g_screenWidth, 44.f)];
    backView.backgroundColor = [UIColor whiteColor];
    
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth-120, backView.frame.size.height)];
    totalPrice = self.order.totalPrice;
    totalLabel.attributedText = [self priceString];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.tag = 101;
    
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(g_screenWidth-100,0,100,backView.frame.size.height)];
    checkBtn.tag = 100;
    [checkBtn addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
    [checkBtn setTitle:@"去付款" forState:UIControlStateNormal];
    checkBtn.backgroundColor = [UIColor redColor];
    checkBtn.titleLabel.font = kYMBigFont;
    [checkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [backView addSubview:totalLabel];
    [backView addSubview:checkBtn];
    
    return backView;
}

- (NSAttributedString *)priceString
{
    NSString *totalPriceStr = [NSString stringWithFormat:@"实际付款:%@", totalPrice];
    //富文本对象
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:totalPriceStr];
    
    NSRange range1 = [totalPriceStr rangeOfString:@"实际付款:"];
    
    NSRange range = NSMakeRange(range1.length,totalPriceStr.length-range1.length);
    //富文本样式
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    [aAttributedString addAttribute:NSFontAttributeName value:kYMBigFont range:range];
    [aAttributedString addAttribute:NSFontAttributeName value:kYMSmallFont range:range1];
    return aAttributedString;
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize titleSize = [YMUtil sizeWithFont:@"订单状态" withFont:kYMNormalFont];
    CGSize detailSize = [YMUtil sizeWithFont:@"下单时间" withFont:kYMdetailFont];
    if (indexPath.section==0&&indexPath.row==0) {
        return titleSize.height+20+(detailSize.height+10)*2;
    } else if (indexPath.section==0&&indexPath.row==1) {
        return titleSize.height+20+detailSize.height*2+2;
    }
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] init];
    sectionView.backgroundColor = [UIColor clearColor];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"defaultCellId";
    if (indexPath.section==0&&indexPath.row==0) {
        cellId = @"orderCellId";
    } else if (indexPath.section==0&&indexPath.row==1) {
        cellId = @"addressCellId";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        if (indexPath.section==1) {
            UIImageView *selectImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30, 30)];
            selectImageV.image = [UIImage imageNamed:@"icon-checkoff-round"];
            selectImageV.backgroundColor = [UIColor clearColor];
            selectImageV.contentMode = UIViewContentModeCenter;
            cell.accessoryView = selectImageV;
        }
    }
    
    float kPadding = 15.f;
    float kVerticalPadding = 10.f;
    CGSize titleSize = [YMUtil sizeWithFont:@"订单状态" withFont:kYMNormalFont];
    CGSize detailSize = [YMUtil sizeWithFont:@"下单时间" withFont:kYMdetailFont];

    float offsety = kVerticalPadding;
    if (indexPath.section==0 && indexPath.row==0) {
        UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, offsety, g_screenWidth-2*kPadding, titleSize.height)];
        orderLabel.text = @"订单状态：待付款";
        orderLabel.backgroundColor = [UIColor clearColor];
        orderLabel.font = kYMNormalFont;
        orderLabel.textColor = [UIColor blackColor];
        orderLabel.textAlignment = NSTextAlignmentLeft;
        
        offsety += titleSize.height+kVerticalPadding;
        UILabel *orderNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, offsety, g_screenWidth-2*kPadding, detailSize.height)];
        orderNoLabel.text = [NSString stringWithFormat:@"订单号：%@", self.order.orderId];
        orderNoLabel.backgroundColor = [UIColor clearColor];
        orderNoLabel.font = kYMdetailFont;
        orderNoLabel.textColor = rgba(102, 102, 102, 1);
        orderNoLabel.textAlignment = NSTextAlignmentLeft;
        
        offsety += detailSize.height+kVerticalPadding;
        UILabel *orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, offsety, g_screenWidth-2*kPadding, detailSize.height)];
        NSString *timeStr = [YMUtil dateStringTransform:self.order.timestamp fromFormat:@"yyyyMMddHHmmss" toFormat:@"yyyy-MM-dd HH:mm"];
        orderTimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",timeStr];
        orderTimeLabel.backgroundColor = [UIColor clearColor];
        orderTimeLabel.font = kYMdetailFont;
        orderTimeLabel.textColor = rgba(102, 102, 102, 1);
        orderTimeLabel.textAlignment = NSTextAlignmentLeft;
        
        [cell addSubview:orderLabel];
        [cell addSubview:orderNoLabel];
        [cell addSubview:orderTimeLabel];
    } else if (indexPath.section==0 && indexPath.row==1) {
        UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, offsety, 150, titleSize.height)];
        orderLabel.text = [NSString stringWithFormat:@"收货人：%@", self.order.address.delivery_name];
        orderLabel.backgroundColor = [UIColor clearColor];
        orderLabel.font = kYMNormalFont;
        orderLabel.textColor = [UIColor blackColor];
        orderLabel.textAlignment = NSTextAlignmentLeft;
        
        UILabel *teleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orderLabel.frame), offsety, 150, titleSize.height)];
        teleLabel.text = self.order.address.contact_no;
        teleLabel.backgroundColor = [UIColor clearColor];
        teleLabel.font = kYMNormalFont;
        teleLabel.textColor = [UIColor blackColor];
        teleLabel.textAlignment = NSTextAlignmentLeft;

        offsety += titleSize.height+kVerticalPadding;
        YMLabel *orderNoLabel = [[YMLabel alloc] initWithFrame:CGRectMake(kPadding, offsety, g_screenWidth-2*kPadding, detailSize.height*2)];
        orderNoLabel.numberOfLines = 2;
        YMCity *city = self.order.address.city;
        orderNoLabel.text = [NSString stringWithFormat:@"%@%@%@%@", city.province,city.city,city.town,self.order.address.delivery_addr];
        orderNoLabel.backgroundColor = [UIColor clearColor];
        orderNoLabel.font = kYMdetailFont;
        orderNoLabel.textColor = rgba(102, 102, 102, 1);
        orderNoLabel.textAlignment = NSTextAlignmentLeft;
        [orderNoLabel setVerticalAlignment:VerticalAlignmentTop];
        [cell addSubview:orderLabel];
        [cell addSubview:teleLabel];
        [cell addSubview:orderNoLabel];
    } else if (indexPath.section==1) {
        if (indexPath.row==0) {
            [cell.imageView setImage:[UIImage imageNamed:@"icon-pay-ali"]];
            cell.textLabel.text = @"支付宝支付";
            cell.textLabel.font = [UIFont systemFontOfSize:18.f];
        } else if (indexPath.row==1) {
            [cell.imageView setImage:[UIImage imageNamed:@"icon-pay-weixin"]];
            cell.textLabel.text = @"微信支付";
            cell.textLabel.font = [UIFont systemFontOfSize:18.f];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *selectImageV = (UIImageView *)cell.accessoryView;
        if (selectImageV) {
            payChannel = (int)indexPath.row;
            selectImageV.image = [UIImage imageNamed:@"icon-checkon-round"];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *selectImageV = (UIImageView *)cell.accessoryView;
        if (selectImageV) {
            selectImageV.image = [UIImage imageNamed:@"icon-checkoff-round"];
        }
    }
}

#pragma mark 网络请求
- (void)getSignedPay
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    parameters[@"order_id"] = self.order.orderId;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=OrderAlipay"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *respData = respDict[kYM_RESPDATA];
                _orderStr = respData[@"order_str"];//支付串
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

- (void)submitOrder
{
    if (payChannel==-1) {
        showDefaultAlert(@"提示", @"请选择一种支付方式");
    }
    if (payChannel==0) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"CSHAlisdk";
        
        if (_orderStr) {
            [[AlipaySDK defaultService] payOrder:_orderStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
                
                if (resultDic!=nil) {
                    [self jumpToResult:resultDic];
                }
            }];
        }
    } else if (payChannel==1) {
        showDefaultAlert(@"提示", @"暂不支持微信支付");
    }
}

- (void)payResult:(NSNotification *)notice
{
    NSDictionary *userInfo = notice.userInfo;
    [self jumpToResult:userInfo];
}

- (void)jumpToResult:(NSDictionary *)resultDic{
    YMPayResultViewController *payResult = [[YMPayResultViewController alloc] init];
    payResult.resultDict = resultDic;
    payResult.order = self.order;
    
    [self.navigationController pushViewController:payResult animated:YES];
}
@end
