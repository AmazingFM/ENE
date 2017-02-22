//
//  YMScrollViewController.h
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

@protocol YMScrollMenuControllerDelegate <NSObject>

-(void)menuControllerWillSelectIndex:(int)index;
-(void)menuControllerSelectAtIndex:(int)index;

@end

@interface YMScrollBarMenuView : UIView
@property(nonatomic,assign)id<YMScrollMenuControllerDelegate> menuDelegate;
@property(nonatomic,assign)int selectedIndex;
-(void)setMenuItems:(NSArray*)items;
-(void)setMenuFont:(float)fontSize;
-(void)setTitle:(NSString*)title atIndex:(int)index;
-(void)setVisibleSelectedIndex:(int)selectedIndex;
-(void)setOffset:(int)index;
@end

@interface YMScrollViewController : YMBaseViewController
@property(nonatomic,strong)UIScrollView*    scrollView;
@property(nonatomic,strong)NSArray*         titles;
@property(nonatomic,strong)NSMutableArray*  controllers;
@property(nonatomic)int                     selectedIndex;
@property(nonatomic)BOOL                    hideScrollBarMenu;
@property(nonatomic)id<YMScrollMenuControllerDelegate> scrollMenuDelegate;
-(void)menuControllerSelectAtIndex:(int)index;
-(void)setMenuTitle:(NSString*)title atIndex:(int)index;
@end