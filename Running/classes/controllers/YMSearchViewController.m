//
//  YMSearchViewController.m
//  Running
//
//  Created by freshment on 16/9/25.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMSearchViewController.h"
#import "YMGoodsListController.h"

#import "YMBaseItem.h"

@interface YMSearchViewController () <UISearchBarDelegate , YMGoodsListDelegate>
{
    YMGoodsListController *goodslistVC;
    float rowHeight;
}

@end

@implementation YMSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rowHeight = 200.f;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSearchBar];
    
    goodslistVC = [[YMGoodsListController alloc] init];
    goodslistVC.delegate = self;
    [self.view addSubview:goodslistVC.view];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    goodslistVC.view.frame = self.view.bounds;
}

- (void)addSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth-60, 44)];;
    searchBar.backgroundColor=[UIColor clearColor];
    searchBar.tintColor = [UIColor redColor];
    searchBar.showsCancelButton = NO;
    searchBar.translucent =YES;
    [searchBar sizeToFit];
    searchBar.autocapitalizationType =UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType =UITextAutocorrectionTypeNo;
    searchBar.placeholder = @"请输入商品代码/名称";
    searchBar.delegate = self;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.returnKeyType = UIReturnKeyDone;
    [searchBar becomeFirstResponder];
    self.navigationItem.titleView = searchBar;
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 协议UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //@ 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
    if (searchText.length>1) {
        [self beginSearch:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark YMGoodsListDelegate
- (void)goodsItemDidSelect:(YMShoppingCartItem *)goodsItem
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsSearchItemSelect:)]) {
        [self.delegate goodsSearchItemSelect:goodsItem];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 网络请求
- (void)beginSearch:(NSString *)searchText
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[kYM_KEYWORDS] = searchText;
    
    parameters[kYM_PAGENO] = @"1";
    parameters[kYM_PAGESIZE] = @"30";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsList"] parameters:parameters success:^(id responseObject) {
        
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
                    
                    [goodslistVC setItemData:arrayM];
                } else {
                    [goodslistVC setItemData:nil];
                }
            } else {
                [goodslistVC setItemData:nil];
            }
        }
    } failure:^(NSError *error) {
        [goodslistVC setItemData:nil];
    }];
}
@end
