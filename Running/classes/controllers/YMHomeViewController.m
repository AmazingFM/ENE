//
//  YMHomeViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMHomeViewController.h"
#import "YMBaseNavigationController.h"
#import "YMGoodsListController.h"
#import "YMGoodsDetailController.h"
#import "YMSearchViewController.h"

#import "YMPageScrollView.h"

#import "YMCommon.h"
#import "YMGlobal.h"
#import "UIColor+Util.h"

#import "YMLocalResource.h"
//用于网络请求
#import "YMDataManager.h"
#import "YMUserManager.h"

#import "YMBaseItem.h"

#define kPageScrollViewHeight 200

@protocol YMHomeCollectionHeaderDelegate <NSObject>

@optional
- (void)pageControlItemClick:(NSInteger)index;

@end
@interface YMHomeCollectionHeader : UICollectionReusableView <YMPageScrollViewDelegate>

@property (nonatomic, retain) YMPageScrollView *pageScrollView;
@property (nonatomic, retain) id<YMHomeCollectionHeaderDelegate> delegate;
@end

@implementation YMHomeCollectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageScrollView = [[YMPageScrollView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kPageScrollViewHeight)];
        _pageScrollView.backgroundColor = [UIColor clearColor];
        _pageScrollView.delegate = self;
        [self addSubview:_pageScrollView];
    }
    return self;
}

- (void)pageControlItemClick:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageControlItemClick:)]) {
        [self.delegate pageControlItemClick:index];
    }
}

@end

@interface YMHomeViewController () <UISearchBarDelegate, YMHomeCollectionHeaderDelegate, YMGoodsCollectionViewCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *_goodsTopArr;
    NSMutableArray *_headLinkArr;
    
    float rowHeight;
    
    YMPageScrollView *_pageScrollView;//顶部的滚动栏
}

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL lastPage;
@property (nonatomic, retain) MJRefreshComponent *myRefreshView;
@property (nonatomic, copy) NSString *spec_id;


@property (nonatomic, retain) NSMutableArray *dataList;

@end

@implementation YMHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        rowHeight = 200.f;
        self.lastPage = NO;
        self.spec_id = @"";
        _goodsTopArr = [NSMutableArray new];
        _headLinkArr = [NSMutableArray new];
        
        _pageScrollView = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgba(242, 242, 242, 1);
    
    
    [self.view addSubview:self.collectionView];
    
    [self addSearchBar];
    
    NSArray *mainDataArr = [[YMLocalResource sharedResource] loadConfigFile:@"main.json"];
    [self loadMainGoodsItem:mainDataArr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self refresh];
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
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 1;
        flowLayout.headerReferenceSize = CGSizeMake(g_screenWidth, kPageScrollViewHeight+10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[YMGoodsCollectionViewCell class] forCellWithReuseIdentifier:@"goodslist"];
        [_collectionView registerClass:[YMHomeCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"homeCollectionViewHeader"];
        
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    return _collectionView;
}

- (void)loadMainGoodsItem:(NSArray *)dataArr
{
    [_goodsTopArr removeAllObjects];
    [_headLinkArr removeAllObjects];
    for (NSDictionary *goodsDict in dataArr) {
        YMGoods *goods = [[YMGoods alloc] init];
        goods.goods_id = goodsDict[@"goods_id"];
        goods.goods_image1 = goodsDict[@"image_url"];
        goods.sub_gid = goodsDict[@"sub_gid"];
        [_goodsTopArr addObject:goods];
        
        [_headLinkArr addObject:goodsDict[@"image_url"]];
    }
    
    if (_pageScrollView) {
        [_pageScrollView setItems:_headLinkArr];
    }
}

- (void)refresh
{
    [self getHeaderData];//刷新顶部数据
    
    self.myRefreshView = self.collectionView.mj_header;
    [self.collectionView.mj_footer resetNoMoreData];
    self.lastPage = NO;
    self.pageNum = 1;
    [self getGoodsList];
}

- (void)loadMoreData
{
    self.myRefreshView = self.collectionView.mj_footer;
    if (!self.lastPage) {
        self.pageNum++;
    }
    [self getGoodsList];
}


- (void)getHeaderData
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSString *uuid = [YMDataManager shared].uuid;
    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    [YMDataManager shared].reqSeq++;
    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
    
    params[kYM_APPID] = uuid;
    params[kYM_REQSEQ] = reqSeq;
    params[kYM_TIMESTAMP] = currentDate;
    
    if ([YMUserManager sharedInstance].user!=nil) {
        params[kYM_TOKEN] = [YMUserManager sharedInstance].user.token;
    }
    params[@"type_code"] = @"0005";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GetAppParam"] parameters:params success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSArray *dataArr = respDict[kYM_RESPDATA];
                
                NSData *data = [YMUtil dataFromJSON:dataArr];
                [[YMLocalResource sharedResource] saveFileToDocument:data withName:@"main.json"];
                
                [self loadMainGoodsItem:dataArr];
            } else {
                //
            }
        }
    } failure:^(NSError *error) {
//        showDefaultAlert(@"提示", @"网络不通，请检查您的网络设置");
    }];
}

#pragma mark - YMHomeCollectionHeaderDelegate
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
        reuseIdentifier = @"homeCollectionViewHeader";
    }
    
    YMHomeCollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        view.delegate = self;
        
        _pageScrollView = view.pageScrollView;
        [_pageScrollView setItems:_headLinkArr];
    }
    return view;
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
}

#pragma mark 网络请求

- (void)getGoodsList
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
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:arrayM];
                        
                        [self.collectionView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                        }
                    } else if (self.myRefreshView == self.collectionView.mj_footer) {
                        [self.itemArray addObjectsFromArray:arrayM];
                        //                        [self.mainTable reloadData];
                        [self.collectionView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                    
                }
            } else {
                [self.myRefreshView endRefreshing];
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self.myRefreshView endRefreshing];
    }];
}

@end
