//
//  YMMainViewController.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface YMMainViewController : UITabBarController

@property (nonatomic, readonly, getter=getMenuSelectedIndex) int menuSelectedIndex;

//- (void)setSelectedIndex:(NSUInteger)selectedIndex;
-(void)setMenuSelectedAtIndex:(int)index;

@end
