//
//  YMNothingViewController.m
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMGoodsDetailController.h"

#import "YMPageScrollView.h"
#import "YMToolbarView.h"
#import "UIButton+Badge.h"
#import "YMLabel.h"

#import "YMUtil.h"
#import "YMUserManager.h"
#import "YMScrollBarMenuView.h"


#define kYMGoodsDetailTag 100

#define kYMGoodsListTitleFont [UIFont systemFontOfSize:18]
#define kYMGoodsListTagFont [UIFont systemFontOfSize:15]
#define kYMGoodsListDetailFont [UIFont systemFontOfSize:12]
#define kYMGoodsListPriceFont [UIFont systemFontOfSize:30]


@implementation YMGoodsDetailItem

- (void)setGoods:(YMGoods *)goods
{
    _goods = goods;
    [self calcRowHeight];
    
}

- (void)calcRowHeight
{
    float offsety = 0;
    float vPadding = 8;
    
    offsety +=  g_screenHeight*2/5+vPadding;
    CGSize size = [YMUtil sizeOfString:self.goods.goods_name withWidth:g_screenWidth-2*kYMPadding font:kYMGoodsListTitleFont];
    
    offsety += size.height+vPadding;
    size = [YMUtil sizeOfString:self.goods.goods_tag withWidth:g_screenWidth-2*kYMBorderMargin font:kYMGoodsListTagFont];
    
    offsety += size.height+2*vPadding;
    size = [YMUtil sizeOfString:self.goods.price withWidth:100 font:kYMGoodsListPriceFont];
    
    offsety += size.height+2*vPadding;
    NSString *guige = self.goods.sub_gname;
    NSString *renqun = self.goods.suitable_crowd;
    NSString *baozhi = self.goods.shelf_life;
    NSString *jixing = self.goods.dosage_forms;
    NSMutableString *detailStr = [[NSMutableString alloc] initWithString:@"信息:"];
    if (guige.length!=0) {
        [detailStr appendFormat:@"     \n[包装规格] %@",guige];
    }
    if (renqun.length!=0) {
        [detailStr appendFormat:@"     \n[适用人群] %@",renqun];
    }
    if (baozhi.length!=0) {
        [detailStr appendFormat:@"     \n[保质期限] %@",baozhi];
    }
    if (jixing.length!=0) {
        [detailStr appendFormat:@"     \n[产品剂型] %@",jixing];
    }
    size = [YMUtil sizeWithFont:detailStr withFont:kYMGoodsListDetailFont];

    offsety += size.height+10;
    
    size = [YMUtil sizeWithFont:@"下拉加载更多" withFont:kYMGoodsListDetailFont];
    offsety +=30+size.height;
    
    self.rowHeight = offsety;
}
@end

@interface YMGoodsDetailController() <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, CAAnimationDelegate, YMScrollMenuControllerDelegate>
{
    UITableView *_mainTable;
    CALayer     *layer;
    
    UIButton *cartButton;
    UIButton *collectButton;
    UIButton *navCollectButton;
    
    CGFloat badgeOffsetX;
}

@property (nonatomic, retain) YMGoodsDetailItem *goodsItem;
@property (nonatomic, retain) UIButton *addCartButton;
@property (nonatomic,strong) UIBezierPath *path;
@property (nonatomic, retain) YMScrollBarMenuView *barMenuView;
@end

@implementation YMGoodsDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed=YES;
}
    return self;  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth, g_screenHeight-44.f) style:UITableViewStylePlain];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainTable];
    
    NSArray *barImageArr = @[@"detail_home", @"detail_collect", @"detail_cart"];
    NSArray *barSelectImageArr = @[@"detail_home", @"detail_collect_select", @"detail_cart"];
    NSArray *barTitleArr = @[@"首页", @"收藏", @"购物车"];
    _addCartButton = [[UIButton alloc] initWithFrame:CGRectMake(g_screenWidth*3/5,CGRectGetMaxY(_mainTable.frame),g_screenWidth*2/5,44.f)];
    _addCartButton.tag = kYMGoodsDetailTag+2;
    [_addCartButton addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    [_addCartButton setTitle:@"加入购物车" forState:UIControlStateNormal];
    _addCartButton.backgroundColor = [UIColor redColor];
    _addCartButton.titleLabel.font = kYMBigFont;
    [_addCartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    float perWidth = g_screenWidth/5;
    
    for (int i=0; i<barTitleArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*perWidth,CGRectGetMaxY(_mainTable.frame),perWidth,44.f)];
        [btn setImage:[UIImage imageNamed:barImageArr[i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:barSelectImageArr[i]] forState:UIControlStateSelected];
        
        [btn setTitle:barTitleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIImage *image = [UIImage imageNamed:barImageArr[i]];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        CGSize size1 = [YMUtil sizeWithFont:barTitleArr[i] withFont:[UIFont systemFontOfSize:12]];
        
        btn.titleEdgeInsets =UIEdgeInsetsMake(0.5*image.size.height, -0.5*image.size.width, -0.5*image.size.height, 0.5*image.size.width);
        btn.imageEdgeInsets =UIEdgeInsetsMake(-0.5*size1.height, 0.5*size1.width, 0.5*size1.height, -0.5*size1.width);
        btn.tag = kYMGoodsDetailTag+10+i;
        
        if (i==1) {
            collectButton = btn;
        }
        
        if (i==2) {
            cartButton = btn;
            btn.shouldAnimateBadge = YES;
            btn.shouldHideBadgeAtZero=YES;
            btn.badgeValue = [YMUserManager sharedInstance].shoppingNum;
            badgeOffsetX = perWidth/2+0.5*image.size.width/2;
            btn.badgeOriginX = badgeOffsetX;
            btn.badgeOriginY = 0;
        }
        
        [btn addTarget:self action:@selector(barButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    [self.view addSubview:_addCartButton];
    
    self.path = [UIBezierPath bezierPath];
    [_path moveToPoint:_addCartButton.center];
    [_path addQuadCurveToPoint:CGPointMake(perWidth*2.5, _addCartButton.center.y) controlPoint:CGPointMake(perWidth*3, _addCartButton.centerY-200)];
    
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    self.navigationItem.rightBarButtonItem = createBarItemIcon(@"icon-service",self, @selector(service));
    
    _barMenuView=[[YMScrollBarMenuView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth/2,kYMScrollBarMenuHeight)];
    _barMenuView.backgroundColor=[UIColor clearColor];
    [_barMenuView setMenuItems:@[@"商品", @"评价"]];
    _barMenuView.menuDelegate=self;
    self.navigationItem.titleView = _barMenuView;
    
    if ([[YMDataBase sharedDatabase] isExistInIntrestCartWithId:self.goods_id andSubid:self.goods_subid]) {
        collectButton.selected = YES;
        navCollectButton.selected = YES;
    } else {
        collectButton.selected = NO;
        navCollectButton.selected = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValue:) name:kYMNoticeShoppingCartIdentifier object:nil];
}

- (void)updateBadgeValue:(NSNotification *)notice
{
    NSDictionary *userInfo = notice.userInfo;
    NSString *shoppingNum = userInfo[@"shoppingNum"];
    
    cartButton.shouldAnimateBadge = YES;
    cartButton.shouldHideBadgeAtZero=YES;
    cartButton.badgeValue = shoppingNum;
    cartButton.badgeOriginX = badgeOffsetX;
    cartButton.badgeOriginY = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    //统一导航样式
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self startGetGoodsInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (YMGoodsDetailItem *)goodsItem
{
    if (_goodsItem==nil) {
        _goodsItem = [[YMGoodsDetailItem alloc] init];
        _goodsItem.numOfRows = 0;
    }
    return _goodsItem;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)service
{
    
}

- (void)barButtonClick:(UIButton *)sender
{
    switch ((sender.tag-kYMGoodsDetailTag-10)) {
        case 0:
            [g_mainMenu setMenuSelectedAtIndex:0];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
        {
            [self addToCollect:sender];
        }
            break;
        case 2:
            [g_mainMenu setMenuSelectedAtIndex:1];
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        default:
            break;
    }
}

- (void)addToCart
{
    [self startAnimation];
}

- (void)addToCollect:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    collectButton.selected = sender.isSelected;
    navCollectButton.selected = sender.isSelected;
    
    if (self.goodsItem.goods!=nil) {
        if (sender.isSelected) {
            BOOL result = [[YMDataBase sharedDatabase] insertPdcToIntrestCartWithModel:self.goodsItem.goods];
            if (result) {
                [self showCustomHUDView:@"收藏成功"];
            }
        } else {
            BOOL result = [[YMDataBase sharedDatabase] deleIntrestPdcWithGoods:self.goodsItem.goods];
            if (result) {
                [self showCustomHUDView:@"取消收藏成功"];
            }
        }
        
    }
}
#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.goodsItem.numOfRows+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return self.goodsItem.rowHeight;
    } else if(indexPath.row==1) {
        return 400;
    }
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"defaultCellId";
    if (indexPath.row==1) {
        cellIdentifier = @"webviewId";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.row==0)
    {
        float offsetx = 0;
        float offsety = 0;
        float vPadding = 8;
        
        YMPageScrollView *pageScroll = [cell viewWithTag:100];
        if (pageScroll==nil) {
            pageScroll = [[YMPageScrollView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, g_screenHeight*2/5)];
            pageScroll.backgroundColor = [UIColor clearColor];
            [cell addSubview:pageScroll];
        }
        
        NSMutableArray *iconArr = [NSMutableArray new];
        if (self.goodsItem.goods) {
            if (self.goodsItem.goods.goods_image1.length!=0) {
                [iconArr addObject:self.goodsItem.goods.goods_image1];
            }
            if (self.goodsItem.goods.goods_image2.length!=0) {
                [iconArr addObject:self.goodsItem.goods.goods_image2];
            }
            if (self.goodsItem.goods.goods_image3.length!=0) {
                [iconArr addObject:self.goodsItem.goods.goods_image3];
            }
            if (self.goodsItem.goods.goods_image4.length!=0) {
                [iconArr addObject:self.goodsItem.goods.goods_image4];
            }
            [pageScroll setItems:iconArr];
        }
        
        offsety += pageScroll.height+vPadding;
        
        CGSize size = [YMUtil sizeOfString:self.goodsItem.goods.goods_name withWidth:g_screenWidth-2*kYMPadding font:kYMGoodsListTitleFont];
        
        YMLabel *titleLabel = [cell viewWithTag:101];
        if (titleLabel==nil) {
            titleLabel = [[YMLabel alloc] initWithFrame:CGRectZero];
            titleLabel.numberOfLines = 0;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kYMGoodsListTitleFont;
            titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.tag = 101;
            titleLabel.verticalAlignment = VerticalAlignmentTop;
            [cell addSubview:titleLabel];
        }
        titleLabel.text = self.goodsItem.goods.goods_name;
        titleLabel.frame = CGRectMake(kYMBorderMargin,offsety,g_screenWidth-2*kYMBorderMargin, size.height);
        
        offsety += titleLabel.height+vPadding;
        
        size = [YMUtil sizeOfString:self.goodsItem.goods.goods_tag withWidth:g_screenWidth-2*kYMBorderMargin font:kYMGoodsListTagFont];
        UILabel *tagLabel = [cell viewWithTag:1011];
        if (tagLabel==nil) {
            tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            tagLabel.backgroundColor = [UIColor clearColor];
            tagLabel.font = kYMGoodsListTagFont;
            tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            tagLabel.textColor = rgba(135, 135, 135, 1);
            tagLabel.tag = 1011;
            [cell addSubview:tagLabel];
        }
        tagLabel.text = [NSString stringWithFormat:@"%@",self.goodsItem.goods.goods_tag];
        tagLabel.frame = CGRectMake(kYMBorderMargin,offsety,g_screenWidth-2*kYMBorderMargin, size.height);
        
        offsety += tagLabel.height+2*vPadding;
        size = [YMUtil sizeOfString:self.goodsItem.goods.price withWidth:100 font:kYMGoodsListPriceFont];
        UILabel *priceLabel = [cell viewWithTag:102];
        if (priceLabel==nil) {
            priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            priceLabel.backgroundColor = [UIColor clearColor];
            priceLabel.font = kYMGoodsListPriceFont;
            priceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            priceLabel.textColor = [UIColor redColor];
            priceLabel.tag = 102;
            [cell addSubview:priceLabel];
        }
        priceLabel.text = [NSString stringWithFormat:@"￥:%@",self.goodsItem.goods.price];
        priceLabel.frame = CGRectMake(kYMBorderMargin,offsety,150, size.height);
        
        offsetx += 100;
        
        UILabel *soldLabel = [cell viewWithTag:103];
        if (soldLabel==nil) {
            soldLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            soldLabel.backgroundColor = [UIColor clearColor];
            soldLabel.font = kYMGoodsListTitleFont;
            soldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            soldLabel.textColor = rgba(135, 135, 135, 1);
            soldLabel.tag = 103;
            soldLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:soldLabel];
        }
        soldLabel.text = [NSString stringWithFormat:@"销量:%@", self.goodsItem.goods.sale_count];
        soldLabel.frame = CGRectMake(g_screenWidth-kYMBorderMargin-100-100,offsety,100, size.height);
        
        offsetx += 100;
        
        UILabel *remainLabel = [cell viewWithTag:104];
        if (remainLabel==nil) {
            remainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            remainLabel.backgroundColor = [UIColor clearColor];
            remainLabel.font = kYMGoodsListTitleFont;
            remainLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            remainLabel.textColor = rgba(135, 135, 135, 1);
            remainLabel.tag = 104;
            remainLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:remainLabel];
        }
        
        int sale = [self.goodsItem.goods.sale_count intValue];
        int store = [self.goodsItem.goods.store_count intValue];
        
        remainLabel.text = [NSString stringWithFormat:@"剩余:%d", store-sale];
        remainLabel.frame = CGRectMake(g_screenWidth-kYMBorderMargin-100,offsety,100, size.height);
        
        offsetx = 0;
        offsety += priceLabel.height+2*vPadding;
        
        UIView *detailBack = [cell viewWithTag:105];
        if (detailBack==nil) {
            detailBack = [[UIView alloc] initWithFrame:CGRectZero];
            detailBack.tag = 105;
            detailBack.backgroundColor = rgba(244, 244, 244, 1);
            [cell addSubview:detailBack];
        }
        NSString *guige = self.goodsItem.goods.sub_gname;
        NSString *renqun = self.goodsItem.goods.suitable_crowd;
        NSString *baozhi = self.goodsItem.goods.shelf_life;
        NSString *jixing = self.goodsItem.goods.dosage_forms;
        
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
        
        detailLabel.text = detailStr;
        detailLabel.frame = CGRectMake(kYMBorderMargin,5,detailBack.frame.size.width-2*kYMBorderMargin, size.height);
        
        offsetx = 0;
        offsety += detailBack.height;
        
        UILabel *line = [cell viewWithTag:107];
        if (line==nil) {
            line = [[UILabel alloc] initWithFrame:CGRectZero];
            line.backgroundColor = rgba(186, 186, 186, 1);
            line.tag = 107;
            [cell addSubview:line];
        }
        line.frame = CGRectMake(kYMBorderMargin,offsety+30,g_screenWidth-2*kYMBorderMargin, 1);
        
        UILabel *descLabel = [cell viewWithTag:106];
        if (descLabel==nil) {
            descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            descLabel.backgroundColor = [UIColor whiteColor];
            descLabel.font = kYMGoodsListDetailFont;
            descLabel.textAlignment = NSTextAlignmentCenter;
            descLabel.textColor = rgba(186, 186, 186, 1);
            descLabel.tag = 106;
            [cell addSubview:descLabel];
        }
        
        size = [YMUtil sizeWithFont:@"下拉加载更多" withFont:kYMGoodsListDetailFont];
        size.width += 40;
        descLabel.text = [NSString stringWithFormat:@"上拉加载更多"];
        descLabel.frame = CGRectMake(0,0,size.width, size.height);
        descLabel.center = CGPointMake(g_screenWidth/2, offsety+30);
        
    } else if (indexPath.row==1) {
        cell.backgroundColor = [UIColor whiteColor];
        UIWebView  *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth,400)];
        webview.backgroundColor = [UIColor whiteColor];
        
//        NSString * jsStr = [NSString stringWithFormat:@"<html> \n"
//                            "<head> \n"
//                            "<style type=\"text/css\"> \n"
//                            "body {font-size: %f; font-family: \"%@\"; color: %@; text-align: %@;}\n"
//                            "h1 {font-size: %f; font-family: \"%@\"; color: %@; text-align: %@;}\n"
//                            "h2 {font-size: %f; font-family: \"%@\"; color: %@; text-align: %@;}\n"
//                            "</style> \n"
//                            "</head> \n"
//                            "<body bgcolor=\"%@\"> \n"
//                            "<h1>%@ \n"
//                            "<h2>%@ \n"
//                            "</h2> \n"
//                            "</h1> \n"
//                            "%@ \n"
//                            "</body> \n"
//                            "</html>", fontSize, @"", self.webBodyColor, @"left",
//                            (float)fontSize +1, @"", self.webMainTitleColor, @"center",
//                            (float)fontSize-2, @"", self.webSubTitleColor, @"center",self.webBackgroundColor,self.newsTitle,[NSString stringWithFormat:@"［%@］ %@", self.newsSource, self.newsDate],self.newsContent];
        
        NSString * jsStr = self.goodsItem.goods.goods_desc;
        [webview loadHTMLString:jsStr baseURL:nil];
        [cell addSubview:webview];
    }
    
    return cell;
}

#pragma mark 网络请求
- (BOOL)getParameters
{
    [super getParameters];
    
    self.params[kYM_GOODSID] = self.goods_id;
    self.params[kYM_SUBGID] = self.goods_subid;
    return YES;
}

- (void)startGetGoodsInfo
{
    if (![self getParameters]) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsInfo"] parameters:self.params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                self.goodsItem.goods = [YMGoods objectWithKeyValues:respDict[kYM_RESPDATA]];
                self.goodsItem.numOfRows = 1;
                [_mainTable reloadData];
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

-(void)startAnimation
{
    if (!layer) {
        _addCartButton.enabled = NO;
        layer = [CALayer layer];
        layer.contents = (__bridge id)[UIImage imageNamed:@"defaultMenu"].CGImage;
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.bounds = CGRectMake(0, 0, 30, 30);
        [layer setCornerRadius:CGRectGetHeight([layer bounds]) / 2];
        layer.masksToBounds = YES;
        layer.position =CGPointMake(g_screenWidth/6*2.5, _addCartButton.center.y);
        [self.view.layer addSublayer:layer];
    }
    [self groupAnimation];
}
-(void)groupAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expandAnimation.duration = 0.3f;
    expandAnimation.fromValue = [NSNumber numberWithFloat:1];
    expandAnimation.toValue = [NSNumber numberWithFloat:1.2f];
    expandAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.3;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:1.2f];
    narrowAnimation.duration = 0.3f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.5f];
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,expandAnimation,narrowAnimation];
    groups.duration = 0.6f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self;
    [layer addAnimation:groups forKey:@"group"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //    [anim def];
    if (anim == [layer animationForKey:@"group"]) {
        _addCartButton.enabled = YES;
        [layer removeFromSuperlayer];
        layer = nil;

        //加入购物车
        if (self.goodsItem.goods!=nil) {
            if ([[YMDataBase sharedDatabase] isExistInCartWithGoods:self.goodsItem.goods]) {
                BOOL res = [[YMDataBase sharedDatabase] updateCountInCartByOne:self.goodsItem.goods.goods_id andSubid:self.goodsItem.goods.sub_gid];
                if (res) {
                    [self showCustomHUDView:@"加入成功"];
                    
                    int num = [[YMUserManager sharedInstance].shoppingNum intValue];
                    [YMUserManager sharedInstance].shoppingNum = [NSString stringWithFormat:@"%d", num+1];
                }
            }
            
            if ([[YMDataBase sharedDatabase] insertPdcToCartWithGoods:self.goodsItem.goods]) {
                [self showCustomHUDView:@"加入成功"];
                
                NSString *num = [[YMDataBase sharedDatabase] getPdcNumInCart];
                
                [YMUserManager sharedInstance].shoppingNum = num;
            } else {
                [self showCustomHUDView:@"加入失败"];
                return;
            }
        }
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.25f;

        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        shakeAnimation.duration = 0.25f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:-5];
        shakeAnimation.toValue = [NSNumber numberWithFloat:5];
        shakeAnimation.autoreverses = YES;
        
        UIView *cartBtnView = [self.view viewWithTag:112];
        [cartBtnView.layer addAnimation:shakeAnimation forKey:nil];
    }
}

@end
