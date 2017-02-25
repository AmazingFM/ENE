//
//  YMPayResultViewController.m
//  Running
//
//  Created by 张永明 on 16/10/11.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMPayResultViewController.h"

#import "YMLabel.h"
#import "YMGlobal.h"
#import "YMUtil.h"

@interface YMPayResultViewController ()

@end

@implementation YMPayResultViewController

/**
 resultStatus，状态码，SDK里没对应信息，第一个文档里有提到：
 9000 订单支付成功
 8000 正在处理中
 4000 订单支付失败
 6001 用户中途取消
 6002 网络连接出错
 result = {
 memo = "";
 result = "{\"alipay_trade_app_pay_response\":{\"code\":\"10000\",\"msg\":\"Success\",\"app_id\":\"2016100402037159\",\"auth_app_id\":\"2016100402037159\",\"charset\":\"utf-8\",\"timestamp\":\"2016-10-11 20:46:06\",\"total_amount\":\"0.01\",\"trade_no\":\"2016101121001004600247606949\",\"seller_id\":\"2088421870836153\",\"out_trade_no\":\"201610081521354091\"},\"sign\":\"Z0YfSi+xPwG1E3PrkZRKU0MAc1IhQWNfj5/6rdz6stIPz3RKDuSH4E+Z46t1c762RQAhPmspkjcNc8kDfnob2gowABNEZs6TAKivavf+XdN5QUN18C0Lesr2kpow95OnWddsEFz4vRtZPsTWAkHwp7TsblpyKYBznPNmPihqVRo=\",\"sign_type\":\"RSA\"}";
 resultStatus = 9000;
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int result = [self.resultDict[@"resultStatus"] intValue];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *resultView = [[UIView alloc] initWithFrame:CGRectMake(0,kYMTopBarHeight,g_screenWidth,g_screenHeight/4)];
    resultView.backgroundColor = [UIColor clearColor];
    
    CGSize size = [YMUtil sizeWithFont:@"支付成功" withFont:kYMBigFont];
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, size.height)];
    resultLabel.backgroundColor = [UIColor clearColor];
    NSString *resultStr;

    if (result==9000) {
        resultStr = @"支付成功，我们会尽快发货";
    } else {
        resultStr = @"支付失败";
    }
    resultLabel.font = kYMBigFont;
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.textColor = rgba(80, 179, 78, 1);
    resultLabel.centerY = resultView.height/2;
    resultLabel.text = resultStr;
    
    UIImageView *resultIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,resultLabel.origin.y-55,40,40)];
    
    if (result==9000) {
        resultIcon.image = [UIImage imageNamed:@"icon-pay-success"];
    } else {
        resultIcon.image = [UIImage imageNamed:@"icon-pay-fail"];
    }
    resultIcon.contentMode = UIViewContentModeScaleToFill;
    resultIcon.backgroundColor = [UIColor clearColor];
    resultIcon.centerX = g_screenWidth/2;
    
    size = [YMUtil sizeWithFont:@"支付成功" withFont:[UIFont systemFontOfSize:30]];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, size.height)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.font = [UIFont boldSystemFontOfSize:30];
    priceLabel.textColor = [UIColor blackColor];
    priceLabel.y = CGRectGetMaxY(resultLabel.frame)+20;
    NSString *priceStr = self.order.totalPrice;
    priceLabel.text = priceStr;

    [resultView addSubview:resultLabel];
    [resultView addSubview:resultIcon];
    [resultView addSubview:priceLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kYMBorderMargin, CGRectGetMaxY(resultView.frame), g_screenWidth-2*kYMBorderMargin, 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];//rgba(130, 130, 102, 1);
    
    UIView *orderView = [[UIView alloc] initWithFrame:CGRectMake(0,g_screenHeight/3,g_screenWidth,g_screenHeight*2/3)];
    orderView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:resultView];
    [self.view addSubview:line];
    
    size = [YMUtil sizeWithFont:@"收货地址：" withFont:kYMNormalFont];
    size.width += 0;
    
    YMCity *city = self.order.address.city;
    NSString *addrStr = [NSString stringWithFormat:@"%@%@%@%@", city.province,city.city,city.town,self.order.address.delivery_addr];
    CGSize addrSize = [YMUtil sizeOfString:addrStr withWidth:g_screenWidth-2*kYMBorderMargin-size.width font:kYMNormalFont];
    
    
    CGFloat offsetx = kYMBorderMargin;
    CGFloat offsety = 30+line.y;
    
    NSString *resultDetailStr = self.resultDict[@"result"];
    NSDictionary *resultDetail = (NSDictionary *)[YMUtil JSONFromString:resultDetailStr];
    NSString *timestamp;
    NSString *total_amount;
    NSString *trade_no;
    
    NSArray *titles;
    NSArray *values;
    
    if (result==9000) {
        NSDictionary *alipayResp = resultDetail[@"alipay_trade_app_pay_response"];
        
        timestamp = alipayResp[@"timestamp"];
        total_amount = alipayResp[@"total_amount"];
        trade_no = alipayResp[@"trade_no"];
        
        titles = @[@"收货人：", @"收货地址：", @"订单号：", @"下单时间：", @"支付时间：", @"交易流水："];
        values = @[[NSString stringWithFormat:@"%@ %@", self.order.address.delivery_name, self.order.address.contact_no],
                   addrStr,
                   self.order.orderId,
                   [YMUtil dateStringTransform:self.order.timestamp fromFormat:@"yyyyMMddHHmmss" toFormat:@"yyyy-MM-dd HH:mm:ss"],
                   timestamp,trade_no];
    } else {
        titles = @[@"收货人：", @"收货地址：", @"订单号：", @"下单时间："];
        values = @[[NSString stringWithFormat:@"%@ %@", self.order.address.delivery_name, self.order.address.contact_no],
                   addrStr,
                   self.order.orderId,
                   [YMUtil dateStringTransform:self.order.timestamp fromFormat:@"yyyyMMddHHmmss" toFormat:@"yyyy-MM-dd HH:mm:ss"]];
    }
    
    for (int i=0; i<titles.count; i++) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx,offsety,size.width, size.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = kYMNormalFont;
        titleLabel.textColor = rgba(102, 102, 102, 1);
        titleLabel.text = titles[i];

        offsetx += size.width;
        
        YMLabel *valueLabel = [[YMLabel alloc] initWithFrame:CGRectZero];
        if (i==1) {
            valueLabel.frame = CGRectMake(offsetx,offsety,g_screenWidth-kYMBorderMargin-offsetx, addrSize.height);
        } else {
            valueLabel.frame = CGRectMake(offsetx,offsety,g_screenWidth-kYMBorderMargin-offsetx, size.height);
        }

        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.textAlignment = NSTextAlignmentLeft;
        valueLabel.font = kYMNormalFont;
        valueLabel.textColor = rgba(102, 102, 102, 1);
        valueLabel.text = values[i];
        valueLabel.numberOfLines = 0;
        valueLabel.text = values[i];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        
        offsetx = kYMBorderMargin;
        
        offsety += valueLabel.height+20;
        
        [self.view addSubview:titleLabel];
        [self.view addSubview:valueLabel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
