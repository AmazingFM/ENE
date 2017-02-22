//
//  UITabBar+badge.h
//  Running
//
//  Created by 张永明 on 16/10/8.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index withValue:(NSString *)value;//显示小红点
- (void)hideBadgeOnItemIndex:(int)index;

@end
