//
//  MyNavigationViewController.m
//  自定义导航
//
//  Created by yons on 15/11/6.
//  Copyright (c) 2015年 蒋玉顺. All rights reserved.
//

#import "MyNavigationViewController.h"
#import "MyNavbar.h"
#define DEF_RGB_COLOR(_red, _green, _blue) [UIColor colorWithRed:(_red)/255.0f green:(_green)/255.0f blue:(_blue)/255.0f alpha:1]

@interface MyNavigationViewController ()

@end

@implementation MyNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MyNavbar *navBar = [[MyNavbar alloc] initWithFrame:CGRectMake(0, 20, 375, 44)];
    [self setValue:navBar forKey:@"navigationBar"];
    
}

+ (void)initialize
{
    //arning 一般设置导航条背景，不会在导航控制器的子控制器里设置
    // 1.设置导航条的背题图片 --- 设置全局
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    navBar.barTintColor = DEF_RGB_COLOR(38, 122,242);
    
    // 3.设置导航条标题的字体和颜色
    NSDictionary *titleAttr = @{
                                NSForegroundColorAttributeName:[UIColor whiteColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:22]
                                };
    [navBar setTitleTextAttributes:titleAttr];
    
    //设置返回按钮的样式
    //tintColor是用于导航条的所有Item
    navBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *navItem = [UIBarButtonItem appearanceWhenContainedIn:self, nil];
    
    //设置Item的字体大小
    [navItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} forState:UIControlStateNormal];
    
    
}

@end
