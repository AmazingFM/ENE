//
//  YMCategoryViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCategoryViewController.h"
#import "YMGoodsViewController.h"
#import "YMSearchViewController.h"
#import "YMGoodsListController.h"
#import "YMBaseNavigationController.h"
#import "YMGoodsDetailController.h"

#import "YMPageScrollView.h"
#import "YMCommon.h"
#import "YMGlobal.h"
#import "UIColor+Util.h"
#import "YMCategory.h"

#define kPageScrollViewHeight 200

@interface YMCategoryViewController () <YMGoodsItemActionDelegate, YMSearchDelegate>
{
    UIBarButtonItem *barBtnItem2;
    
    YMGoodsViewController *goodsViewController;
}

@property (nonatomic, retain) NSMutableArray *dataList;

@property (nonatomic, retain) NSMutableArray *searchList;

@end

@implementation YMCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"分类";
    
    [self addNaviBarItems];

    [self addGoodsViewController];
}

- (void)addNaviBarItems
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"icon_search_big.png"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0,0,35,35);
    [rightBtn addTarget:self action:@selector(letsSearch) forControlEvents:UIControlEventTouchUpInside];
    
    barBtnItem2 = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:nil action:nil];
    spaceItem.width=0;
    
    self.navigationItem.rightBarButtonItems=@[spaceItem,barBtnItem2];
}

- (void)letsSearch
{
    YMSearchViewController *searchViewController = [[YMSearchViewController alloc] init];
    searchViewController.delegate = self;
    YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)addGoodsViewController
{
    goodsViewController = [[YMGoodsViewController alloc] init];
    goodsViewController.delegate = self;
    goodsViewController.view.frame = CGRectMake(0,kYMTopBarHeight, g_screenWidth,g_screenHeight-kYMTopBarHeight);
    [self.view addSubview:goodsViewController.view];
    [goodsViewController viewWillAppear:YES];
}

- (void)goodsItemSelect:(YMCategory *)category
{
    YMGoodsListController *goodslistVC = [[YMGoodsListController alloc] init];
    goodslistVC.spec_id = category.category_id;
    [self.navigationController pushViewController:goodslistVC animated:YES];
}
#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchList count];
    }else{
        return [self.dataList count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *flag=@"cellFlag";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flag];
    }
    if (tableView==self.searchDisplayController.searchResultsTableView) {
        [cell.textLabel setText:self.searchList[indexPath.row]];
    }
    else{
        [cell.textLabel setText:self.dataList[indexPath.row]];
    }
    return cell;
}

#pragma mark UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"您点击了取消按钮");
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder]; // 丢弃第一使用者
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"搜索Begin");
    [searchBar setShowsCancelButton:YES animated:NO];
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    NSLog(@"搜索End");
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    // 谓词的包含语法,之前文章介绍过http://www.cnblogs.com/xiaofeixiang/
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    //过滤数据
    self.searchList= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
    //刷新表格
    return YES;
}


#pragma mark YMSearchDelegate
- (void)goodsSearchItemSelect:(YMShoppingCartItem *)goodsItem
{
    YMGoodsDetailController *detailController = [[YMGoodsDetailController alloc] init];
    detailController.goods_id = goodsItem.goods.goods_id;
    detailController.goods_subid = goodsItem.goods.sub_gid;
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
