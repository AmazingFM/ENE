//
//  YMSearchViewController.m
//  Running
//
//  Created by freshment on 16/9/25.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMSearchViewController.h"

@interface YMSearchViewController () <UISearchBarDelegate>

@end

@implementation YMSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSearchBar];
}

- (void)addSearchBar
{
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.backgroundColor=[UIColor clearColor];
    searchBar.tintColor = [UIColor redColor];
    searchBar.showsCancelButton = YES;
    searchBar.translucent =YES;
    [searchBar sizeToFit];
    searchBar.autocapitalizationType =UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType =UITextAutocorrectionTypeNo;
    searchBar.placeholder = @"请输入商品代码/名称";
    searchBar.delegate = self;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    [searchBar becomeFirstResponder];
    self.navigationItem.titleView = searchBar;
}

#pragma mark - 协议UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //@ 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
    if (searchText.length>1) {
        [self beginSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [searchBar setShowsCancelButton:NO animated:NO];    // 取消按钮回收
//    [searchBar resignFirstResponder];                                // 取消第一响应值,键盘回收,搜索结束
}

#pragma mark 网络请求

- (void)beginSearch
{
    //
}


@end
