//
//  YMGoodsInfoController.m
//  Running
//
//  Created by 张永明 on 2017/2/25.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMGoodsInfoController.h"
#import "YMPageScrollView.h"
#import "YMLabel.h"
#import "YMGoods.h"

@interface YMGoodsInfoController () <UIWebViewDelegate>
{
    UIWebView  *webview;
    UIScrollView *bigScroll;
    
    CGFloat webViewHeight;
}

@property (nonatomic, retain) YMGoods *goods;
@end

@implementation YMGoodsInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    webViewHeight = 700;

    [self setupView];
    
    [self startGetGoodsInfo];
}

- (void)updateUI
{
    float offsetx = 0;
    float offsety = 0;
    float vPadding = 8;
    
    YMPageScrollView *pageScroll = [bigScroll viewWithTag:100];
    NSMutableArray *iconArr = [NSMutableArray new];
    if (self.goods) {
        if (self.goods.goods_image1.length!=0) {
            [iconArr addObject:self.goods.goods_image1];
        }
        if (self.goods.goods_image2.length!=0) {
            [iconArr addObject:self.goods.goods_image2];
        }
        if (self.goods.goods_image3.length!=0) {
            [iconArr addObject:self.goods.goods_image3];
        }
        if (self.goods.goods_image4.length!=0) {
            [iconArr addObject:self.goods.goods_image4];
        }
        [pageScroll setItems:iconArr];
    }
    
    offsety += pageScroll.height+vPadding;
    CGSize size = [YMUtil sizeOfString:self.goods.goods_name withWidth:g_screenWidth-2*kYMPadding font:kYMGoodsListTitleFont];
    YMLabel *titleLabel = [bigScroll viewWithTag:101];
    titleLabel.text = self.goods.goods_name;
    titleLabel.frame = CGRectMake(kYMBorderMargin,offsety,g_screenWidth-2*kYMBorderMargin, size.height);
    
    offsety += titleLabel.height+vPadding;
    size = [YMUtil sizeOfString:self.goods.goods_tag withWidth:g_screenWidth-2*kYMBorderMargin font:kYMGoodsListTagFont];
    UILabel *tagLabel = [bigScroll viewWithTag:1011];
    tagLabel.text = [NSString stringWithFormat:@"%@",self.goods.goods_tag];
    tagLabel.frame = CGRectMake(kYMBorderMargin,offsety,g_screenWidth-2*kYMBorderMargin, size.height);
    
    offsety += tagLabel.height+2*vPadding;
    size = [YMUtil sizeOfString:self.goods.price withWidth:100 font:kYMGoodsListPriceFont];
    UILabel *priceLabel = [bigScroll viewWithTag:102];
    priceLabel.text = [NSString stringWithFormat:@"￥:%@",self.goods.price];
    priceLabel.frame = CGRectMake(kYMBorderMargin,offsety,150, size.height);
    
    offsetx += 100;
    UILabel *soldLabel = [bigScroll viewWithTag:103];
    soldLabel.text = [NSString stringWithFormat:@"销量:%@", self.goods.sale_count];
    soldLabel.frame = CGRectMake(g_screenWidth-kYMBorderMargin-100-100,offsety,100, size.height);
    
    offsetx += 100;
    UILabel *remainLabel = [bigScroll viewWithTag:104];
    int sale = [self.goods.sale_count intValue];
    int store = [self.goods.store_count intValue];
    remainLabel.text = [NSString stringWithFormat:@"剩余:%d", store-sale];
    remainLabel.frame = CGRectMake(g_screenWidth-kYMBorderMargin-100,offsety,100, size.height);
    
    offsetx = 0;
    offsety += priceLabel.height+2*vPadding;
    UIView *detailBack = [bigScroll viewWithTag:105];
    NSString *guige = self.goods.sub_gname;
    NSString *renqun = self.goods.suitable_crowd;
    NSString *baozhi = self.goods.shelf_life;
    NSString *jixing = self.goods.dosage_forms;
    
    NSMutableString *detailStr = [[NSMutableString alloc] initWithString:@"信息:"];
    if (guige.length!=0) {
        [detailStr appendFormat:@"\n     [包装规格] %@",guige];
    }
    if (renqun.length!=0) {
        [detailStr appendFormat:@"\n     [适用人群] %@",renqun];
    }
    if (baozhi.length!=0) {
        [detailStr appendFormat:@"\n     [保质期限] %@",baozhi];
    }
    if (jixing.length!=0) {
        [detailStr appendFormat:@"\n     [产品剂型] %@",jixing];
    }
    size = [YMUtil sizeWithFont:detailStr withFont:kYMGoodsListDetailFont];
    detailBack.frame = CGRectMake(kYMBorderMargin,offsety,g_screenWidth-2*kYMBorderMargin, size.height+10);
    
    UILabel *detailLabel = [detailBack viewWithTag:1051];
    
    detailLabel.text = detailStr;
    detailLabel.frame = CGRectMake(kYMBorderMargin,5,detailBack.frame.size.width-2*kYMBorderMargin, size.height);
    
    offsetx = 0;
    offsety += detailBack.height;
    UILabel *line = [bigScroll viewWithTag:107];
    line.frame = CGRectMake(kYMBorderMargin,offsety+30,g_screenWidth-2*kYMBorderMargin, 1);
    
    UILabel *descLabel = [bigScroll viewWithTag:106];
    size = [YMUtil sizeWithFont:@"下拉加载更多" withFont:kYMGoodsListDetailFont];
    size.width += 40;
    descLabel.text = [NSString stringWithFormat:@"上拉加载更多"];
    descLabel.frame = CGRectMake(0,0,size.width, size.height);
    descLabel.center = CGPointMake(g_screenWidth/2, offsety+30);
    
    offsetx = 0;
    offsety = descLabel.y + descLabel.height;
    
    webview = [bigScroll viewWithTag:2000];
    webview.frame = CGRectMake(0, offsety, g_screenWidth,webViewHeight);
    NSString * jsStr = self.goods.goods_desc;
    [webview loadHTMLString:jsStr baseURL:nil];
    bigScroll.contentSize = CGSizeMake(g_screenWidth, offsety+webViewHeight);
}

- (void)setupView
{
    bigScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth, g_screenHeight-kYMTopBarHeight-44)];
    bigScroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bigScroll];
    
    YMPageScrollView *pageScroll = [bigScroll viewWithTag:100];
    if (pageScroll==nil) {
        pageScroll = [[YMPageScrollView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, g_screenHeight*2/5)];
        pageScroll.backgroundColor = [UIColor clearColor];
        pageScroll.tag = 100;
        [bigScroll addSubview:pageScroll];
    }
    
    YMLabel *titleLabel = [bigScroll viewWithTag:101];
    if (titleLabel==nil) {
        titleLabel = [[YMLabel alloc] initWithFrame:CGRectZero];
        titleLabel.numberOfLines = 0;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = kYMGoodsListTitleFont;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.tag = 101;
        titleLabel.verticalAlignment = VerticalAlignmentTop;
        [bigScroll addSubview:titleLabel];
    }
    
    UILabel *tagLabel = [bigScroll viewWithTag:1011];
    if (tagLabel==nil) {
        tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tagLabel.backgroundColor = [UIColor clearColor];
        tagLabel.font = kYMGoodsListTagFont;
        tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tagLabel.textColor = rgba(135, 135, 135, 1);
        tagLabel.tag = 1011;
        [bigScroll addSubview:tagLabel];
    }
    
    UILabel *priceLabel = [bigScroll viewWithTag:102];
    if (priceLabel==nil) {
        priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = kYMGoodsListPriceFont;
        priceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        priceLabel.textColor = [UIColor redColor];
        priceLabel.tag = 102;
        [bigScroll addSubview:priceLabel];
    }
    
    UILabel *soldLabel = [bigScroll viewWithTag:103];
    if (soldLabel==nil) {
        soldLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        soldLabel.backgroundColor = [UIColor clearColor];
        soldLabel.font = kYMGoodsListTitleFont;
        soldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        soldLabel.textColor = rgba(135, 135, 135, 1);
        soldLabel.tag = 103;
        soldLabel.textAlignment = NSTextAlignmentRight;
        [bigScroll addSubview:soldLabel];
    }
    
    UILabel *remainLabel = [bigScroll viewWithTag:104];
    if (remainLabel==nil) {
        remainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        remainLabel.backgroundColor = [UIColor clearColor];
        remainLabel.font = kYMGoodsListTitleFont;
        remainLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        remainLabel.textColor = rgba(135, 135, 135, 1);
        remainLabel.tag = 104;
        remainLabel.textAlignment = NSTextAlignmentRight;
        [bigScroll addSubview:remainLabel];
    }
    
    UIView *detailBack = [bigScroll viewWithTag:105];
    if (detailBack==nil) {
        detailBack = [[UIView alloc] initWithFrame:CGRectZero];
        detailBack.tag = 105;
        detailBack.backgroundColor = rgba(244, 244, 244, 1);
        [bigScroll addSubview:detailBack];
    }
    
    UILabel *detailLabel = [detailBack viewWithTag:1051];
    if (detailLabel==nil) {
        detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.font = kYMGoodsListDetailFont;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.numberOfLines = 0;
        detailLabel.textAlignment = NSTextAlignmentLeft;
        detailLabel.textColor = rgba(186, 186, 186, 1);
        detailLabel.tag = 1051;
        [detailBack addSubview:detailLabel];
    }
    
    UILabel *line = [bigScroll viewWithTag:107];
    if (line==nil) {
        line = [[UILabel alloc] initWithFrame:CGRectZero];
        line.backgroundColor = rgba(186, 186, 186, 1);
        line.tag = 107;
        [bigScroll addSubview:line];
    }
    
    UILabel *descLabel = [bigScroll viewWithTag:106];
    if (descLabel==nil) {
        descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descLabel.backgroundColor = [UIColor whiteColor];
        descLabel.font = kYMGoodsListDetailFont;
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.textColor = rgba(186, 186, 186, 1);
        descLabel.tag = 106;
        [bigScroll addSubview:descLabel];
    }
    
    webview = [bigScroll viewWithTag:2000];
    if (webview==nil) {
        webview = [[UIWebView alloc] initWithFrame:CGRectZero];
        webview.backgroundColor = [UIColor whiteColor];
        webview.delegate = self;
        
        webview.tag=2000;
        [bigScroll addSubview:webview];
    }
}

- (void)startGetGoodsInfo
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_GOODSID] = self.goods_id;
    parameters[kYM_SUBGID] = self.goods_subid;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsInfo"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                self.goods = [YMGoods objectWithKeyValues:respDict[kYM_RESPDATA]];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(setGoodsInfo:)]) {
                    [self.delegate setGoodsInfo:self.goods];
                }
                
                [self updateUI];
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

#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat scrollHeight = [[webview stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGFloat newWebHeight = scrollHeight;
    
    CGRect frame = webView.frame;
    frame.size = CGSizeMake(g_screenWidth, newWebHeight);
    webView.frame = frame;
    
    CGFloat offset = newWebHeight-webViewHeight;
    CGSize scrollContentSize = bigScroll.contentSize;
    bigScroll.contentSize = CGSizeMake(g_screenWidth, scrollContentSize.height+offset);
    
    webViewHeight= newWebHeight;
}

@end
