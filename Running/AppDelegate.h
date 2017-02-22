//
//  AppDelegate.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setRootViewControllerWithLogin;
- (void)setRootViewControllerWithRecommend;
- (void)setRootViewControllerWithMain;

@end