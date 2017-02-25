//
//  YMScrollBarMenuView.h
//  Running
//
//  Created by 张永明 on 2017/2/23.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMScrollMenuControllerDelegate <NSObject>

-(void)menuControllerWillSelectIndex:(NSInteger)index;
-(void)menuControllerSelectAtIndex:(NSInteger)index;

@end

@interface YMScrollBarMenuView : UIView
@property(nonatomic,assign)id<YMScrollMenuControllerDelegate> menuDelegate;
@property(nonatomic,assign)NSInteger selectedIndex;
-(void)setMenuItems:(NSArray*)items;
-(void)setMenuFont:(float)fontSize;
-(void)setTitle:(NSString*)title atIndex:(NSInteger)index;
-(void)setVisibleSelectedIndex:(NSInteger)selectedIndex;
-(void)setOffset:(NSInteger)index;
@end
