//
//  YMMainViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMMainViewController.h"
#import "YMHomeViewController.h"
#import "YMCategoryViewController.h"
#import "YMShoppingCartViewController.h"
#import "YMMineViewController.h"
#import "YMAdviceViewController.h"
#import "YMBaseNavigationController.h"

#import "YMCollectionTestController.h"

#import "UIColor+Util.h"
#import "UITabBar+badge.h"
#import "YMUserManager.h"
#import "YMCommon.h"

#define kYMMainMenuBarItemTag 3000

@interface YMMainViewController ()<UITabBarControllerDelegate>

@end

@implementation YMMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadNaviBarItems];
    [self loadMenuBar];
    self.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValue:) name:kYMNoticeShoppingCartIdentifier object:nil];
}

- (void)updateBadgeValue:(NSNotification *)notice
{
    NSDictionary *userInfo = notice.userInfo;
    NSString *shoppingNum = userInfo[@"shoppingNum"];
    
    [self.tabBar showBadgeOnItemIndex:1 withValue:shoppingNum];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    if (self.navigationController.viewControllers.count >1) {
//        self.tabBarController.tabBar.hidden =YES;
//    }else {
//        self.tabBarController.tabBar.hidden =NO;
//    }
//}

- (void)loadNaviBarItems
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationItem.title = @"Running";
}

/**
 tab image大小，2x,3x, 50px, 75px
 */
- (void)loadMenuBar
{
//    YMCollectionTestController *home = [[YMCollectionTestController alloc] init];
    YMHomeViewController *home = [[YMHomeViewController alloc] init];
    YMBaseNavigationController *homeNav = [[YMBaseNavigationController alloc] initWithRootViewController:home];
    
    YMCategoryViewController *category = [[YMCategoryViewController alloc] init];
    YMBaseNavigationController *categoryNav = [[YMBaseNavigationController alloc] initWithRootViewController:category];

    YMShoppingCartViewController *shopping = [[YMShoppingCartViewController alloc] init];
    YMBaseNavigationController *shoppingNav = [[YMBaseNavigationController alloc] initWithRootViewController:shopping];

    YMMineViewController *mine = [[YMMineViewController alloc] init];
    YMBaseNavigationController *mineNav = [[YMBaseNavigationController alloc] initWithRootViewController:mine];

    YMAdviceViewController *advice = [[YMAdviceViewController alloc] init];
    YMBaseNavigationController *adviceNav = [[YMBaseNavigationController alloc] initWithRootViewController:advice];
    
    self.viewControllers = @[homeNav, shoppingNav, categoryNav, mineNav, adviceNav];
    NSArray *titles = @[@"首页", @"购物车", @"分类", @"我的", @"客服咨询"];
    NSArray *images = @[@"tabbar-home", @"tabbar-shopping", @"tabbar-category", @"tabbar-mine", @"tabbar-advice"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        item.tag = kYMMainMenuBarItemTag+idx;
        [item setTitle:titles[idx]];
        [item setImage:[UIImage imageNamed:images[idx]]];
        [item setSelectedImage:[UIImage imageNamed:[images[idx] stringByAppendingString:@"-selected"]]];
    }];
    
    [self.tabBar showBadgeOnItemIndex:1 withValue:[YMUserManager sharedInstance].shoppingNum];
    
    [self setSelectedIndex:0];
}

-(int)getMenuSelectedIndex{
    return self.selectedIndex;
}

-(void)setMenuSelectedAtIndex:(int)index
{
//    YMBaseNavigationController *currentNavController=(YMBaseNavigationController *)[self.viewControllers objectAtIndex:self.selectedIndex];
//    [currentNavController popToRootViewControllerAnimated:YES];
    
    [self setSelectedIndex:index];
    
//    YMBaseNavigationController *newNavController=(YMBaseNavigationController *)[self.viewControllers objectAtIndex:index];
//    [newNavController popToRootViewControllerAnimated:YES];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
//    NSInteger selectedIndex=item.tag-kYMMainMenuBarItemTag;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    if ([viewController isKindOfClass:[UINavigationController class]]) {
//        [(UINavigationController *)viewController popToRootViewControllerAnimated:YES];
//    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
