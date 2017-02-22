//
//  MyNavbar.h
//  自定义导航
//
//  Created by yons on 15/11/6.
//  Copyright (c) 2015年 蒋玉顺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNavbar : UINavigationBar
@property (nonatomic,strong)UIView *bgView;
/**
 *   显示导航条背景颜色
 */
- (void)show;
/**
 *   隐藏
 */
- (void)hidden;
@end
