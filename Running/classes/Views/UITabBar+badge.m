//
//  UITabBar+badge.m
//  Running
//
//  Created by 张永明 on 16/10/8.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "UITabBar+badge.h"

#define TabbarItemNums 5

@implementation UITabBar (badge)

//显示小红点
- (void)showBadgeOnItemIndex:(int)index withValue:(NSString *)value{
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    float radius=5;
    UILabel *badgeView = [[UILabel alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = radius;//圆形
    badgeView.backgroundColor = [UIColor redColor];//颜色：红色
    badgeView.font=[UIFont systemFontOfSize:8];
    badgeView.layer.masksToBounds=YES;
    badgeView.textColor=[UIColor whiteColor];
    badgeView.textAlignment=NSTextAlignmentCenter;
    badgeView.adjustsFontSizeToFitWidth=YES;

    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    float percentX = (index +0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
//    badgeView.frame = CGRectMake(x, y, 10, 10);//圆形大小为10
    [self addSubview:badgeView];
    [self bringSubviewToFront:badgeView];
    
    int bardge = [value intValue];
    if(bardge>0){
        if(bardge<10){
            badgeView.text=[NSString stringWithFormat:@"%i",bardge];
            badgeView.frame=CGRectMake(x,y,radius*2,radius*2);
        }else if(bardge<99){
            badgeView.text=[NSString stringWithFormat:@"%i",bardge];
            badgeView.frame=CGRectMake(x,y,radius*3,radius*2);
        }else {
            badgeView.text=[NSString stringWithFormat:@"%i",bardge];
            badgeView.frame=CGRectMake(x,y,radius*3,radius*2);
        }
    } else {
        badgeView.hidden = YES;
    }
}

//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeBadgeOnItemIndex:(int)index{
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

@end