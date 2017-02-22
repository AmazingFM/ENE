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

#import "YMSegment.h"
#import "YMLocalResource.h"
//用于网络请求
#import "YMDataManager.h"
#import "YMUserManager.h"

#define kPageScrollViewHeight 200

@interface YMHomeViewController () <UISearchBarDelegate, YMPageScrollViewDelegate>
{
    YMPageScrollView *_pageScrollView;
    NSMutableArray *_goodsTopArr;
}

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) YMSegment *ymSegment;
@property (nonatomic, weak) UIScrollView *bigScroll;

@end

@implementation YMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgba(242, 242, 242, 1);
    
    _goodsTopArr = [[NSMutableArray alloc] init];
    
    _pageScrollView = [[YMPageScrollView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kPageScrollViewHeight)];
    _pageScrollView.backgroundColor = [UIColor clearColor];
    _pageScrollView.delegate = self;

    [self.view addSubview:_pageScrollView];
    
    YMGoodsListController *vc1 = [[YMGoodsListController alloc]init];
    vc1.spec_id = @"";
    [self addChildViewController:vc1];

    vc1.view.frame = CGRectMake(0, CGRectGetMaxY(_pageScrollView.frame), g_screenWidth, g_screenHeight-kPageScrollViewHeight);
    vc1.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:vc1.view];
    
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

- (void)loadMainGoodsItem:(NSArray *)dataArr
{
    [_goodsTopArr removeAllObjects];
    NSMutableArray *linksArr = [NSMutableArray new];
    for (NSDictionary *goodsDict in dataArr) {
        YMGoods *goods = [[YMGoods alloc] init];
        goods.goods_id = goodsDict[@"goods_id"];
        goods.goods_image1 = goodsDict[@"image_url"];
        goods.sub_gid = goodsDict[@"sub_gid"];
        [_goodsTopArr addObject:goods];
        
        [linksArr addObject:goodsDict[@"image_url"]];
    }
    [_pageScrollView setItems:linksArr];
}

- (void)refresh
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
@end
