//
//  YMBaseNavigationController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseNavigationController.h"

#import "YMCommon.h"

@interface YMBaseNavigationController ()

@end

@implementation YMBaseNavigationController

//@synthesize alphaView;
//-(id)initWithRootViewController:(UIViewController *)rootViewController{
//    self = [super initWithRootViewController:rootViewController];
//    if (self) {
//        CGRect frame = self.navigationBar.frame;
//        alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height+20)];
//        alphaView.backgroundColor = rgba(38,38,38,1);
//        [self.view insertSubview:alphaView belowSubview:self.navigationBar];
//        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"bigShadow.png"] forBarMetrics:UIBarMetricsCompact];
//        self.navigationBar.layer.masksToBounds = YES;
//    }
//    return self;
//}

//-(void)setAlph:(BOOL)flag{
//    if (flag) {
//        [UIView animateWithDuration:0.5 animations:^{
//            alphaView.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            _changing = NO;
//        }];
//
//    } else {
//        [UIView animateWithDuration:0.5 animations:^{
//            alphaView.alpha = 1.0;
//        } completion:^(BOOL finished) {
//            _changing = NO;
//            
//        }];
//    }
//}

//- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;
//{
//    [super setNavigationBarHidden:navigationBarHidden animated:animated];
//    if (navigationBarHidden) {
//        alphaView.alpha = 0.f;
//    } else {
//        alphaView.alpha = 1.f;
//    }
//}
@end
