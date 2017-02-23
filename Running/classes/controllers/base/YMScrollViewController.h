//
//  YMScrollViewController.h
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"
#import "YMScrollBarMenuView.h"


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
