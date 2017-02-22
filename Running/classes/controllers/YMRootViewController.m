//
//  YMRootViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMRootViewController.h"
#import "YMMainViewController.h"

#import "YMGlobal.h"

YMMainViewController *g_mainMenu;

@interface YMRootViewController()
{
    UIView *_baseView;//目前是_baseView
    UIView *_currentView;//其实就是rootViewController.view
    
    YMMainViewController *_mainViewController;
}
@end

@implementation YMRootViewController

- (id)init
{
    self = [super init];
    if (self) {
        _mainViewController = [[YMMainViewController alloc] init];
        self.rootViewController = _mainViewController;
        g_mainMenu = _mainViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _baseView = self.view;
    [_baseView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.rootViewController) {
        NSAssert(false, @"you must set rootViewController!!");
    }
    if (_currentView!=_rootViewController.view) {
        [_currentView removeFromSuperview];
        _currentView=_rootViewController.view;
        [_baseView addSubview:_currentView];
        _currentView.frame=_baseView.bounds;
    }
}

- (void)setRootViewController:(UIViewController *)rootViewController{
    if (_rootViewController!=rootViewController) {
        if (_rootViewController) {
            [_rootViewController removeFromParentViewController];
        }
        _rootViewController=rootViewController;
        if (_rootViewController) {
            [self addChildViewController:_rootViewController];
        }
    }
}
@end
