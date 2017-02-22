//
//  MyNavbar.m
//  自定义导航
//
//  Created by yons on 15/11/6.
//  Copyright (c) 2015年 蒋玉顺. All rights reserved.
//

#import "MyNavbar.h"

@implementation MyNavbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
                self.bgView = view;
            }
        }
    }
    return self;
}

/**
 *   显示导航条背景颜色
 */
- (void)show
{
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.hidden = NO;
    }];
}
/**
 *   隐藏
 */
- (void)hidden
{
        self.bgView.hidden = YES;
}
@end
