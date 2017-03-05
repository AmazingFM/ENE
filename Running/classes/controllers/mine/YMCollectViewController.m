//
//  YMCollectViewController.m
//  Running
//
//  Created by 张永明 on 16/9/26.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCollectViewController.h"
#import "YMShoppingCartViewController.h"
#import "YMGoodsDetailController.h" 

#import "YMUserManager.h"
#import "YMDataBase.h"

@interface YMCollectViewController () <UITableViewDelegate, UITableViewDataSource, YMCartCellDelegate>
{
    UITableView *_mainTableView;
    
    float rowHeight;
    NSMutableArray *dataArr; //
    
    
    UIImageView *_noItemImg;
    UILabel *_noItemDesc;
}

@end

@implementation YMCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rowHeight = 100.f;
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的收藏";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    UIView *nothing = [[UIView alloc] init];
    [self.view addSubview:nothing];
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _mainTableView.frame = CGRectMake(0, kYMTopBarHeight, g_screenWidth, g_screenHeight-kYMTopBarHeight-49.f);
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.bounces = NO;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    _mainTableView.tableFooterView = [[UIView alloc] init];
    
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:_mainTableView];

    _noItemDesc = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, 50)];
    _noItemDesc.center = self.view.center;
    _noItemDesc.text = @"暂无收藏，快去收藏一下吧!";
    _noItemDesc.textAlignment = NSTextAlignmentCenter;
    _noItemDesc.textColor = rgba(183, 183, 183, 1);
    _noItemDesc.font = kYMBigFont;
    
    _noItemImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_cart"]];
    _noItemImg.frame = CGRectMake(0, 0, g_screenWidth/4, g_screenWidth/4);
    _noItemImg.center = CGPointMake(_noItemDesc.centerX, _noItemDesc.centerY-50);
    _noItemImg.hidden = YES;
    _noItemDesc.hidden = YES;
    
    [self.view addSubview:_noItemDesc];
    [self.view addSubview:_noItemImg];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self initItems];
}

- (void)initItems
{
    dataArr = [NSMutableArray arrayWithArray:[[YMDataBase sharedDatabase] getAllpdcInIntrestCart]];
    
    if (dataArr!=nil && dataArr.count>0) {
        for (YMShoppingCartItem *item in dataArr) {
            if (item.goods.price.length==0) {
                item.goods.price = @"0.00";
            }
            CGSize size = CGSizeMake(g_screenWidth, rowHeight);
            item.size = size;
        }
        _noItemImg.hidden = YES;
        _noItemDesc.hidden = YES;
        _mainTableView.hidden = NO;
        [self startGetGoodsInfoList];
    } else {
        _mainTableView.hidden = YES;
        _noItemImg.hidden = NO;
        _noItemDesc.hidden = NO;
    }
}

#pragma mark YMCartCellDelegate
- (void)cellDeleteGoods:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = dataArr[indexPath.row];
    
    if ([[YMDataBase sharedDatabase] deleIntrestPdcWithGoods:item.goods]) {
        [self showTextHUDView:@"取消收藏成功"];
        [dataArr removeObject:item];
        
        if (dataArr.count==0) {
            _mainTableView.hidden = YES;
            _noItemImg.hidden = NO;
            _noItemDesc.hidden = NO;
        } else {
            [_mainTableView reloadData];
        }
    }
}

- (void)cellAddToCart:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath forType:(BOOL)type
{
    YMShoppingCartItem *item = dataArr[indexPath.row];
    
    if (!type) {
        if ([[YMDataBase sharedDatabase] deletePdcInCartByGoods:item.goods]) {
            item.isInCart = NO;
            [self showCustomHUDView:@"移出购物车"];
        }
    } else {
        //加入购物车
        if (item.goods!=nil) {
            if ([[YMDataBase sharedDatabase] insertPdcToCartWithGoods:item.goods]) {
                item.isInCart = YES;
                [self showCustomHUDView:@"加入购物车"];
                
                NSString *num = [[YMDataBase sharedDatabase] getPdcNumInCart];
                
                [YMUserManager sharedInstance].shoppingNum = num;
                return;
            } else {
                [self showCustomHUDView:@"加入失败,请重新添加"];
                return;
            }
        }
    }
}


#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
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
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = dataArr[indexPath.row];
    item.indexPath = indexPath;
    static NSString *cellIdentifier = @"cellId";
    YMCartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[YMCartCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.type = 3;
        cell.delegate = self;
    }
    
    cell.item = item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    YMShoppingCartItem *item = dataArr[indexPath.row];
        
    YMGoodsDetailController *detailController = [[YMGoodsDetailController alloc] init];
    detailController.goods_id = item.goods.goods_id;
    detailController.goods_subid = item.goods.sub_gid;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark 网络请求
//- (BOOL)getParameters
//{
////    [super getParameters];
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    
//    NSMutableArray *paramsArr = [NSMutableArray array];
//    for (YMShoppingCartItem *item in dataArr) {
//        NSDictionary *dict = @{@"goods_id":[NSNumber numberWithInteger:[item.goods.goods_id integerValue]],@"sub_gid":[NSNumber numberWithInteger:[item.goods.sub_gid integerValue]]};
//        [paramsArr addObject:dict];
//    }
//    
//    NSString *str = [YMUtil stringFromJSON:paramsArr];
//    parameters[kYM_GOODSARRAY] = str;
//    
//    return YES;
//}

- (void)startGetGoodsInfoList
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    NSMutableArray *paramsArr = [NSMutableArray array];
    for (YMShoppingCartItem *item in dataArr) {
        NSDictionary *dict = @{@"goods_id":[NSNumber numberWithInteger:[item.goods.goods_id integerValue]],@"sub_gid":[NSNumber numberWithInteger:[item.goods.sub_gid integerValue]]};
        [paramsArr addObject:dict];
    }
    
    NSString *str = [YMUtil stringFromJSON:paramsArr];
    parameters[kYM_GOODSARRAY] = str;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsArrayQuery"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                if ([respDict[kYM_RESPDATA] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict = respDict[kYM_RESPDATA];
                    if ([dataDict[@"goods_array"] isKindOfClass:[NSArray class]]) {
                        NSArray *goodsArr = dataDict[@"goods_array"];
                        for (int i=0; i<goodsArr.count; i++) {
                            YMShoppingCartItem *item = dataArr[i];
                            
                            NSDictionary *goodsDict = goodsArr[i];
                            item.goods.goods_id = goodsDict[@"goods_id"];
                            item.goods.goods_image1 = goodsDict[@"goods_image1"];
                            item.goods.goods_image1_mid = goodsDict[@"goods_image1_mid"];
                            item.goods.goods_tag = goodsDict[@"goods_tag"];
                            item.goods.price = goodsDict[@"price"];
                            item.goods.sale_count = goodsDict[@"sale_count"];
                            item.goods.status = goodsDict[@"status"];
                            item.goods.store_count = goodsDict[@"store_count"];
                            item.goods.sub_gid = goodsDict[@"sub_gid"];
                        }
                    }
                }
                [_mainTableView reloadData];//重新刷新
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
