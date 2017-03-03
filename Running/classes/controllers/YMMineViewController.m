//
//  YMMineViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMMineViewController.h"
#import "YMOrdersViewController.h"
#import "YMSettingViewController.h"
#import "YMAddressViewController.h"
#import "YMCollectViewController.h"
#import "YMPersonChangeViewController.h"

#import "YMUserManager.h"
#import "YMToolbarView.h"
#import "YMUtil.h"

#define kPersonalBarHeight 50
#define kCutomerTel @"021-23560070"

@interface YMMineViewController () <UITableViewDelegate, UITableViewDataSource, YMToolbarDelegate, UIAlertViewDelegate>
{
    NSArray *_barImageArr;
    NSArray *_barTitleArr;
    
    NSArray *_imageArr;
    NSArray *_titleArr;
    
    UIImageView *_headView;
    UIImageView *headImgView;
    YMToolbarView *_barView;
    UITableView *_mainTableView;
    
    CGFloat kPersonalHeaderHeight;
}
@end

@implementation YMMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    kPersonalHeaderHeight = g_screenWidth*3/5;

    _barImageArr = @[@"forPay", @"forSend", @"forReceive", @"forComment", @"forOrder"];
    _barTitleArr = @[@"待付款", @"待发货", @"待收货", @"待评价", @"全部订单"];
    
    _imageArr = @[@"icon_cart", @"icon_location", @"icon_favourate", @"icon_service"];
    _titleArr = @[@"我的购物车", @"我的收货地址", @"我的收藏", @"客服电话"];
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, kPersonalHeaderHeight)];
    _headView.contentMode = UIViewContentModeScaleToFill;
    _headView.image = [UIImage imageNamed:@"person_back.png"];
    _headView.userInteractionEnabled = YES;
    
    _barView = [[YMToolbarView alloc] initWithFrame:CGRectMake(0,kPersonalHeaderHeight, g_screenWidth,kPersonalBarHeight) withTitles:_barTitleArr withIconNames:_barImageArr];
    [_barView addLine:(int)_barTitleArr.count-1];
    _barView.toolbarDelegate = self;
    _barView.backgroundColor = [UIColor whiteColor];
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,kPersonalHeaderHeight+kPersonalBarHeight, g_screenWidth, g_screenHeight-(20+kPersonalHeaderHeight-kPersonalBarHeight))];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.backgroundColor = rgba(242, 242, 242, 1);
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.scrollEnabled = NO;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor grayColor];
    _mainTableView.tableFooterView = footerView;
    
    [self.view addSubview:_headView];
    [self addHeader];
    [self.view addSubview:_barView];
    [self.view addSubview:_mainTableView];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(0,0,32,32);;//CGRectMake(g_screenWidth-10-32,20+(44.f-32)/2,32,32);
    [settingBtn setImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    settingBtn.imageView.contentMode= UIViewContentModeScaleToFill;
    [settingBtn addTarget:self action:@selector(settingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:kYMNoticeUserInfoUpdateIdentifier object:nil];
}

- (void)updateUserInfo:(NSNotification *)notice
{
//    NSDictionary *userInfo = notice.userInfo;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    NSString *headImgStr = [YMUserManager sharedInstance].user.user_icon;;
    if (headImgStr&&headImgStr.length>0) {
        NSData *_decodedImgData = [[NSData alloc] initWithBase64EncodedString:headImgStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        headImgView.image = [UIImage imageWithData:_decodedImgData];
    } else {
        headImgView.image = [UIImage imageNamed:@"defaultMe.png"];
    }
    [self requestOrdersState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)addHeader
{
    CGFloat headerW=kPersonalHeaderHeight/2;
    CGFloat headerH=headerW;
    CGFloat tmpHeight = headerW*0.6;
        //1.创建头像视图
    UIImageView *rightView=[[UIImageView alloc]initWithFrame:CGRectMake(g_screenWidth*3/10,0,g_screenWidth*7/10,tmpHeight)];
    rightView.centerY = kPersonalHeaderHeight/2;
    rightView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    rightView.userInteractionEnabled = YES;
    [self.view addSubview:rightView];
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    singleTap.cancelsTouchesInView = NO;
    [rightView addGestureRecognizer:singleTap];

    CGSize size = [YMUtil sizeWithFont:@"柯景腾新的二季" withFont:[UIFont systemFontOfSize:20]];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerW/2+15, 10, rightView.frame.size.width-headerW/2-15-45,size.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = [YMUserManager sharedInstance].user.nick_name;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = kYMBigFont;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    size = [YMUtil sizeWithFont:@"普通会员" withFont:kYMVerySmallFont];
    UIImageView *levelIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_level"]];
    levelIcon.frame = CGRectMake(nameLabel.frame.origin.x, CGRectGetMaxY(nameLabel.frame)+2, size.height, size.height);
    levelIcon.contentMode = UIViewContentModeScaleToFill;

    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(levelIcon.frame)+2, CGRectGetMaxY(nameLabel.frame)+2, size.width,size.height)];
    levelLabel.backgroundColor = [UIColor clearColor];
    levelLabel.text = @"普通会员";
    levelLabel.textColor = rgba(255, 204, 2, 1);
    levelLabel.font = kYMVerySmallFont;
    levelLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_more"]];
    arrowImg.frame = CGRectMake(0, 0, 30, 30);
    arrowImg.center = CGPointMake(rightView.width-30, tmpHeight/2);
    arrowImg.contentMode = UIViewContentModeScaleToFill;

    
    [rightView addSubview:nameLabel];
    [rightView addSubview:levelIcon];
    [rightView addSubview:levelLabel];
    [rightView addSubview:arrowImg];
    
    float headerViewWidth = headerW+10;
    UIView *headButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerViewWidth, headerViewWidth)];
    headButtonView.center = CGPointMake(g_screenWidth*3/10, kPersonalHeaderHeight/2);
    headButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    headButtonView.layer.masksToBounds = YES;
    [headButtonView.layer setCornerRadius:headerViewWidth/2]; //设置矩形四个圆角半径
    
    UITapGestureRecognizer *singleTap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [headButtonView addGestureRecognizer:singleTap1];

    headImgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, headerW, headerH)];
    headImgView.center = CGPointMake(headerViewWidth/2, headerViewWidth/2);
    headImgView.contentMode = UIViewContentModeScaleToFill;
    headImgView.userInteractionEnabled = YES;
    [headButtonView addSubview:headImgView];

    headImgView.layer.masksToBounds = YES;
    [headImgView.layer setCornerRadius:headerW/2]; //设置矩形四个圆角半径
    
    [_headView addSubview:rightView];
    [_headView addSubview:headButtonView];
}

- (void)settingBtnClick:(UIButton *)sender
{
    YMSettingViewController *settingController = [[YMSettingViewController alloc] init];
    [self.navigationController pushViewController:settingController animated:YES];
}

#pragma mark YMToolbarDelegate
-(void)toolbarSelectAtIndex:(int)selectIndex
{
    int index = 0;
    switch (selectIndex) {
        case 0:
        case 1:
        case 2:
        case 3:
            index = selectIndex+1;
            break;
        case 4:
        {
            index=0;
        }
            break;
    }
    YMOrdersViewController *orderController = [[YMOrdersViewController alloc] init];
    orderController.selectedIndex = index;
    [orderController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:orderController animated:YES];
}

#pragma mark UITableViewDelegagte, UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    sectionHeaderView.backgroundColor = rgba(242, 242, 242, 1);
    return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell.imageView setImage:[UIImage imageNamed:_imageArr[indexPath.section]]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = kYMNormalFont;
    cell.textLabel.text = _titleArr[indexPath.section];
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.detailTextLabel.font = kYMNormalFont;
    if (indexPath.section==3) {
        cell.detailTextLabel.text = kCutomerTel;
    } else {
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            //
            [g_mainMenu setMenuSelectedAtIndex:1];
            break;
        case 1:
        {
            YMAddressViewController *addressVC = [[YMAddressViewController alloc] init];
            addressVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addressVC animated:YES];
        }
            break;
        case 2:
        {
            YMCollectViewController *collectVC = [[YMCollectViewController alloc] init];
            [self.navigationController pushViewController:collectVC animated:YES];
        }
            break;
        case 3:
            [self showAlertView:[NSString stringWithFormat:@"是否准备拨打%@", kCutomerTel]];
            break;
        default:
            break;
    }
}

- (void)showAlertView:(NSString *)alertMsg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alertMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", kCutomerTel]]];
    }
}
#pragma mark UIGestureRecognizerDelegate
- (void)handleTap:(UIGestureRecognizer*)gesture
{
    //
    YMPersonChangeViewController *changeInfoVC = [[YMPersonChangeViewController alloc] init];
    changeInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:changeInfoVC animated:YES];
    
}

#pragma mark 网络请求
- (void)requestOrdersState
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserOrderStat"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                
                NSArray *resp_data = respDict[kYM_RESPDATA];
                
                if (resp_data && [resp_data isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dict in resp_data) {
                        NSString *count = dict[@"count"];
                        NSString *status = dict[@"status"];
                        
                        int index = [status intValue];
                        if (index>=0 && index<=3) {
                            [_barView showBadgeOnItemIndex:index withValue:count];
                        }
                    }
                }
            }
        }
    } failure:^(NSError *error) {
    }];
}

@end
