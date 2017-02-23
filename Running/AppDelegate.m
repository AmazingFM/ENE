//
//  AppDelegate.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "AppDelegate.h"
#import "YMGlobal.h"
#import "UIColor+Util.h"
#import "UIView+Util.h"
#import "MBProgressHUD.h"

#import "YMDefaultViewController.h"
#import "YMRootViewController.h"
#import "YMLoginViewController.h"
#import "YMStatisticViewController.h"
#import "YMFirstGuideViewController.h"
#import "YMBaseNavigationController.h"
#import "YMPayResultViewController.h"

#import <AlipaySDK/AlipaySDK.h>

#import "LBLaunchImageAdView.h"
#import "YMUserManager.h"
#import "YMDataManager.h"
#import "YMVersionManager.h"

float g_nOSVersion;
NSString *g_strVersion;

float g_screenWidth;
float g_screenHeight;
AppDelegate *g_appDelegate;
UIWindow *g_mainWindow;

@interface AppDelegate ()
{
    YMDefaultViewController *defaultVC;
    YMRootViewController *mainController;
    YMLoginViewController *login;
    YMStatisticViewController *recommendVC;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /************ 控件外观设置 **************/
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setTintColor:rgba(255, 204, 2, 1.0)];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:rgba(255, 204, 2, 1.0)} forState:UIControlStateSelected];

    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setCornerRadius:5.0];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAlpha:0.6];
    [UIBarButtonItem appearance].tintColor=[UIColor whiteColor];

    [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = [UIColor cyanColor];

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    if(g_nOSVersion>=7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }

    initialize();
    
    g_appDelegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    defaultVC = [[YMDefaultViewController alloc] init];
    self.window.rootViewController = defaultVC;
    
    g_mainWindow = self.window;
    [self.window makeKeyAndVisible];
    
    LBLaunchImageAdView * adView = [[LBLaunchImageAdView alloc]initWithWindow:self.window adType:LogoAdType];
    
    //回调
    adView.clickBlock = ^(BOOL isLogin){
        if (isLogin) {
            if ([[YMUserManager sharedInstance].user.user_type intValue]==0) { //普通用户
                [g_appDelegate setRootViewControllerWithMain];
            } else if ([[YMUserManager sharedInstance].user.user_type intValue]==1 ||
                       [[YMUserManager sharedInstance].user.user_type intValue]==2) {
                [self setRootViewControllerWithRecommend];
            }
        } else {
            [self setRootViewControllerWithLogin];
        }
    };
    return YES;
}

- (void)setRootViewControllerWithRecommend
{
    if (recommendVC==nil) {
        recommendVC = [[YMStatisticViewController alloc] init];
    }
    YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:recommendVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}


- (void)setRootViewControllerWithLogin
{
    if (login==nil) {
        login = [[YMLoginViewController alloc] init];
    }
    YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:login];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void)setRootViewControllerWithMain
{
    if (mainController==nil) {
        mainController = [[YMRootViewController alloc] init];
    }
    self.window.rootViewController=mainController;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[YMDataBase sharedDatabase] closeDatabase];
    [[YMDataManager shared] writeSeqToDefaults];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[YMDataBase sharedDatabase] openDatabase];
    [[YMDataManager shared] readSeqFromDefaults];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[YMVersionManager sharedManager] getVersionInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            
            if (resultDic!=nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMNoticePayResultIdentifier object:nil userInfo:resultDic];
            }
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            
            if (resultDic!=nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMNoticePayResultIdentifier object:nil userInfo:resultDic];
            }
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    return YES;
}
@end
