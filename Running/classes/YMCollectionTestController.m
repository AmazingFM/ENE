//
//  YMCollectionTestController.m
//  Running
//
//  Created by 张永明 on 2017/2/22.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMCollectionTestController.h"
#import "YMGoodsViewController.h"

#import "YMBaseNavigationController.h"
#import "YMGoodsListController.h"
#import "YMGoodsDetailController.h"
#import "YMSearchViewController.h"

#import "MXNavigationBarManager.h"

#import "YMPageScrollView.h"
#import "YMBaseItem.h"
#import "YMCommon.h"
#import "YMGlobal.h"
#import "UIColor+Util.h"

#import "YMLocalResource.h"
//用于网络请求
#import "YMDataManager.h"
#import "YMUserManager.h"

#define kPageScrollViewHeight 200
//
@interface YMCollectionHeaderView : UICollectionReusableView
@property (nonatomic, retain) YMPageScrollView *pageScrollView;
@end

@implementation YMCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageScrollView = [[YMPageScrollView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kPageScrollViewHeight)];
        _pageScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageScrollView];
    }
    
    return self;
}

@end

@interface YMCollectionTestController () <UISearchBarDelegate, YMPageScrollViewDelegate, YMGoodsCollectionViewCellDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *_goodsTopArr;
    
    float rowHeight;
    
    NSMutableArray *linksArr;
}

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UIView *naviNew;

@end

@implementation YMCollectionTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgba(242, 242, 242, 1);
    
    rowHeight = 200.f;
    
    self.lastPage = NO;
    self.spec_id = @"";

    
    _goodsTopArr = [[NSMutableArray alloc] init];
    linksArr =[[NSMutableArray alloc] init];
    
//    _pageScrollView = [[YMPageScrollView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kPageScrollViewHeight)];
//    _pageScrollView.backgroundColor = [UIColor clearColor];
//    _pageScrollView.delegate = self;
//    
//    [self.view addSubview:_pageScrollView];
    
  [self.view addSubview:self.collectionView];
    
    [self addSearchBar];
    
    NSArray *mainDataArr = [[YMLocalResource sharedResource] loadConfigFile:@"main.json"];
    [self loadMainGoodsItem:mainDataArr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [MXNavigationBarManager managerWithController:self];
//    [MXNavigationBarManager setBarColor:[UIColor clearColor]];
    
    //optional
//    [MXNavigationBarManager setTintColor:[UIColor blackColor]];
//    [MXNavigationBarManager setStatusBarStyle:UIStatusBarStyleDefault];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
//    self.naviNew = [[UIView alloc]initWithFrame:CGRectMake(0, -20, self.navigationController.navigationBar.bounds.size.width,self.navigationController.navigationBar.bounds.size.height+20)];
//    self.naviNew.backgroundColor = [UIColor colorWithHex:0xff5179 alpha:0];
//    [self.navigationController.navigationBar insertSubview:self.naviNew atIndex:0];
    
    [self refresh];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //统一导航样式
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
    [self.naviNew removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    if (point.y < 0) {
        //不能向上拉的逻辑
        self.collectionView.contentOffset = CGPointMake(0.0, 0.0);
        self.collectionView.userInteractionEnabled = YES;
    }
    NSLog(@"point %@",NSStringFromCGPoint(point));
    
    //变色的逻辑
    if (point.y>=136&&point.y<=200) {
        CGFloat ap = (point.y-136)/64;
        self.naviNew.backgroundColor = [UIColor colorWithHex:0xff5179 alpha:ap];
    }else if (point.y>200){
        self.naviNew.backgroundColor = [UIColor colorWithHex:0xff5179 alpha:1];
    }else{
        self.naviNew.backgroundColor = [UIColor colorWithHex:0xff5179 alpha:0];
    }
    
}

- (NSMutableArray *)itemArray
{
    if (_itemArray==nil) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        //设置滚动方向
        [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //item间距
        flowlayout.minimumInteritemSpacing = 1;
        //上下间距
        flowlayout.minimumLineSpacing = 10;
        flowlayout.headerReferenceSize = CGSizeMake(g_screenWidth, kPageScrollViewHeight+10);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;

        //注册cell
        [_collectionView registerClass:[YMGoodsCollectionViewCell class] forCellWithReuseIdentifier:@"goodslist"];
        [_collectionView registerClass:[YMCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectHeaderViewId"];
        
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)loadMainGoodsItem:(NSArray *)dataArr
{
    [_goodsTopArr removeAllObjects];
    [linksArr removeAllObjects];
    for (NSDictionary *goodsDict in dataArr) {
        YMGoods *goods = [[YMGoods alloc] init];
        goods.goods_id = goodsDict[@"goods_id"];
        goods.goods_image1 = goodsDict[@"image_url"];
        goods.sub_gid = goodsDict[@"sub_gid"];
        [_goodsTopArr addObject:goods];
        
        [linksArr addObject:goodsDict[@"image_url"]];
    }
//    [_pageScrollView setItems:linksArr];
}

- (void)refresh
{
    self.myRefreshView = self.collectionView.mj_header;
    
    if (self.lastPage) {
        [self.collectionView.mj_footer resetNoMoreData];
    }
    self.lastPage = NO;
    self.pageNum = 1;
    [self startRequest];
}

- (void)loadMoreData
{
    self.myRefreshView = self.collectionView.mj_footer;
    
    if (!self.lastPage) {
        self.pageNum++;
    }
    [self startRequest];
    
}

//- (void)refresh
//{
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    
//    NSString *uuid = [YMDataManager shared].uuid;
//    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
//    [YMDataManager shared].reqSeq++;
//    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
//    
//    params[kYM_APPID] = uuid;
//    params[kYM_REQSEQ] = reqSeq;
//    params[kYM_TIMESTAMP] = currentDate;
//    
//    if ([YMUserManager sharedInstance].user!=nil) {
//        params[kYM_TOKEN] = [YMUserManager sharedInstance].user.token;
//    }
//    params[@"type_code"] = @"0005";
//    
//    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GetAppParam"] parameters:params success:^(id responseObject) {
//        NSDictionary *respDict = responseObject;
//        if (respDict) {
//            NSString *resp_id = respDict[kYM_RESPID];
//            if ([resp_id integerValue]==0) {
//                NSArray *dataArr = respDict[kYM_RESPDATA];
//                
//                NSData *data = [YMUtil dataFromJSON:dataArr];
//                [[YMLocalResource sharedResource] saveFileToDocument:data withName:@"main.json"];
//                
//                [self loadMainGoodsItem:dataArr];
//            } else {
//                //
//            }
//        }
//    } failure:^(NSError *error) {
//        //        showDefaultAlert(@"提示", @"网络不通，请检查您的网络设置");
//    }];
//}

#pragma mark
- (void)pageControlItemClick:(NSInteger)index
{
    YMGoods *goods = _goodsTopArr[index];
    YMGoodsDetailController *detailController = [[YMGoodsDetailController alloc] init];
    detailController.goods_id = goods.goods_id;
    detailController.goods_subid = goods.sub_gid;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)addSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 20, g_screenWidth-40, 34)];
    searchBar.showsCancelButton = NO;
    searchBar.translucent =YES;
    [searchBar sizeToFit];
    searchBar.autocapitalizationType =UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType =UITextAutocorrectionTypeNo;
    searchBar.placeholder = @"请输入商品代码/名称";
    searchBar.delegate = self;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    //第一种方法
    /**
     
     if (version == 7.0) {
     searchBar.backgroundColor = [UIColor clearColor];
     searchBar.barTintColor = [UIColor clearColor];
     }else{
     for(int i =  0 ;i < searchBar.subviews.count;i++){
     
     UIView * backView = searchBar.subviews[i];
     
     if ([backView isKindOfClass:NSClassFromString(@"UISearchBarBackground")] == YES) {
     
     
     [backView removeFromSuperview];
     [searchBar setBackgroundColor:[UIColor clearColor]];
     break;
     
     }else{
     NSArray * arr = searchBar.subviews[i].subviews;
     for(int j = 0;j<arr.count;j++   ){
     UIView * barView = arr[i];
     if ([barView isKindOfClass:NSClassFromString(@"UISearchBarBackground")] == YES) {
     [barView removeFromSuperview];
     [searchBar setBackgroundColor:[UIColor clearColor]];
     break;
     }
     }
     }
     }
     }
     */
    //第二种方法
    //    version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ([searchBar respondsToSelector:@selector(barTintColor)]) {
        float iosversion7_1 = 7.1;
        if (version >= iosversion7_1) {
            [[[[searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
            [searchBar setBackgroundColor:[UIColor clearColor]];
        }
        else {            //iOS7.0
            [searchBar setBarTintColor:[UIColor clearColor]];
            [searchBar setBackgroundColor:[UIColor clearColor]];
        }
    }
    else {
        //iOS7.0以下
        [[searchBar.subviews objectAtIndex:0] removeFromSuperview];
        [searchBar setBackgroundColor:[UIColor clearColor]];
    }
    [self.view addSubview:searchBar];
    
}

#pragma mark - 协议UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:NO];
    //    YMSearchViewController *searchVC = [[YMSearchViewController alloc] init];
    //    YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:searchVC];
    //
    //    [self presentViewController:nav animated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //@ 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];    // 取消按钮回收
    [searchBar resignFirstResponder];                                // 取消第一响应值,键盘回收,搜索结束
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodslist" forIndexPath:indexPath];
    cell.delegate = self;
    YMShoppingCartItem *item = self.itemArray[indexPath.row];
    item.indexPath = indexPath;
    cell.item = item;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return CGSizeMake((g_screenWidth-10-10)/2, 200.f );
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = (YMShoppingCartItem *)self.itemArray[indexPath.row];
    YMGoodsDetailController *detailController = [[YMGoodsDetailController alloc] init];
    detailController.goods_id = item.goods.goods_id;
    detailController.goods_subid = item.goods.sub_gid;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reuseIdentifier = @"collectHeaderViewId";
    }
    
    YMCollectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        [view.pageScrollView setItems:linksArr];
//        view.title.text = @"sdsdfs";
    }
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView

{
    
    return 1;
    
}

#pragma mark YMGoodsListCellDelegate

- (void)favorateButtonSelect:(YMGoodsCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath withType:(BOOL)select
{
    YMShoppingCartItem *item = self.itemArray[indexPath.row];
    item.isFavorate = select;
    
    BOOL ret;
    if (select) {
        ret = [[YMDataBase sharedDatabase] insertPdcToIntrestCartWithModel:item.goods];
        if (ret) {
            [self showCustomHUDView:@"收藏成功"];
        } else {
            [self showCustomHUDView:@"收藏失败"];
        }
    } else {
        ret = [[YMDataBase sharedDatabase] deleIntrestPdcWithGoods:item.goods];
        if (ret) {
            [self showCustomHUDView:@"取消收藏成功"];
        } else {
            [self showCustomHUDView:@"取消收藏失败"];
        }
    }
    //    showAlert([NSString stringWithFormat:@"更新收藏状态%@:%@", ret?@"成功":@"失败",select?@"选择":@"取消"]);
}

#pragma mark 网络请求

- (void)startRequest
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[kYM_SPECID] = self.spec_id;
    
    self.params[kYM_PAGENO] = [NSString stringWithFormat:@"%d", self.pageNum];
    self.params[kYM_PAGESIZE] = @"30";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsList"] parameters:self.params success:^(id responseObject) {
        [self.myRefreshView endRefreshing];
        
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *resp_data = respDict[kYM_RESPDATA];
                
                if (resp_data) {
                    NSMutableDictionary *pageNav = resp_data[@"page_nav"];
                    
                    PageItem *pageItem = [[PageItem alloc] init];
                    pageItem.current_page = [pageNav[@"current_page"] intValue];
                    pageItem.page_size = [pageNav[@"page_size"] intValue];
                    pageItem.total_num = [pageNav[@"total_num"] intValue];
                    pageItem.total_page = [pageNav[@"total_page"] intValue];
                    
                    if (pageItem.current_page==pageItem.total_page) {
                        self.lastPage = YES;
                    }
                    
                    NSArray *goodsList;
                    if ([resp_data[@"goods_list"] isKindOfClass:[NSArray class]]) {
                        goodsList = [YMGoods objectArrayWithKeyValuesArray:resp_data[@"goods_list"]];
                    }
                    
                    NSMutableArray *arrayM = [NSMutableArray array];
                    if (goodsList!=nil) {
                        for (int i=0; i<goodsList.count; i++)
                        {
                            YMShoppingCartItem *goodsItem = [[YMShoppingCartItem alloc] init];
                            goodsItem.isFavorate = [[YMDataBase sharedDatabase] isExistInIntrestCart:goodsList[i]];
                            goodsItem.size = CGSizeMake(g_screenWidth, rowHeight);
                            goodsItem.goods = goodsList[i];
                            [arrayM addObject:goodsItem];
                        }
                    }
                    
                    //..下拉刷新
                    if (self.myRefreshView == self.collectionView.mj_header) {
                        self.itemArray = arrayM;
                        self.collectionView.mj_footer.hidden = self.lastPage;
                        [self.collectionView reloadData];
                        [self.myRefreshView endRefreshing];
                        
                    } else if (self.myRefreshView == self.collectionView.mj_footer) {
                        [self.itemArray addObjectsFromArray:arrayM];
                        //                        [self.mainTable reloadData];
                        [self.collectionView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                    self.collectionView.hidden = NO;
//                    _noItemImg.hidden = YES;
//                    _noItemDesc.hidden = YES;
                    
                } else {
                    self.collectionView.hidden = YES;
//                    _noItemImg.hidden = NO;
//                    _noItemDesc.hidden = NO;
                }
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self.myRefreshView endRefreshing];
    }];
}

@end
