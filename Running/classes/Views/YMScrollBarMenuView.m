//
//  YMScrollBarMenuView.m
//  Running
//
//  Created by 张永明 on 2017/2/23.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMScrollBarMenuView.h"
#import "YMGlobal.h"
#import "YMCommon.h"
#import "YMUtil.h"

#define kLABarMenuItemTag       1000

#define kYMScrollBarItemHighlightColor rgba(255, 204, 2, 1.0)

@interface YMScrollBarMenuView(){
    NSInteger _menuMaxCount;
    UIScrollView* _scrollView;
    UIView* _highlightView;
    
    float titleWidth;
}
@end

@implementation YMScrollBarMenuView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _highlightView=[[UIView alloc] init];
        _highlightView.backgroundColor=kYMScrollBarItemHighlightColor;
        [self addSubview:_highlightView];
    }
    return self;
}

-(void)setMenuFont:(float)fontSize
{
    
}

-(void)setMenuItems:(NSArray*)items{
    _scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
    //    _scrollView.pagingEnabled=YES;
    _scrollView.showsHorizontalScrollIndicator=NO;
    NSInteger itemCount=[items count];
    _menuMaxCount=itemCount;
    
    [_scrollView setContentSize:CGSizeMake(g_screenWidth*[items count]/itemCount, self.bounds.size.height)];
    float perWidth=self.frame.size.width/itemCount;
    for (int i=0;i<[items count]; i++) {
        UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_scrollView addSubview:btn];
        btn.frame=CGRectMake(perWidth*i+2,5,perWidth-4, self.bounds.size.height-10);
        btn.titleLabel.font=[UIFont boldSystemFontOfSize:14];
        [btn setTitle:[items objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitle:[items objectAtIndex:i] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(menuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=kLABarMenuItemTag+i;
        btn.layer.borderColor=[UIColor clearColor].CGColor;
        btn.layer.borderWidth=3;
        btn.layer.cornerRadius=5.0f;
    }
    
    titleWidth = 0;
    NSString *title = [items objectAtIndex:0];
    for (int i=0; i<items.count; i++) {
        float width = [YMUtil sizeWithFont:items[i] withFont:[UIFont boldSystemFontOfSize:14]].width;
        titleWidth = (titleWidth>width)?:width;
    }
    
    _highlightView.frame=CGRectMake(perWidth*_selectedIndex+(perWidth-titleWidth)/2,self.frame.size.height-2,titleWidth,2);
    
    //    _selectedIndex=0;
    UIButton* defaultBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+_selectedIndex];
    [defaultBtn setTitleColor:kYMScrollBarItemHighlightColor forState:UIControlStateNormal];
    //    [defaultBtn setBackgroundColor:kHTScrollBarItemHighlightColor];
    [self addSubview:_scrollView];
}

-(void)setVisibleSelectedIndex:(NSInteger)selectedIndex{
    UIButton* selectedBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+_selectedIndex];
    [selectedBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _selectedIndex=selectedIndex;
    UIButton* currentBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+selectedIndex];
    [currentBtn setTitleColor:kYMScrollBarItemHighlightColor forState:UIControlStateNormal];
    
    
}

-(void)menuItemSelected:(UIButton*)btn{
    NSInteger index=btn.tag-kLABarMenuItemTag;
    UIButton* selectedBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+_selectedIndex];
    [selectedBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    if(self.menuDelegate&&[self.menuDelegate respondsToSelector:@selector(menuControllerWillSelectIndex:)]){
        [self.menuDelegate menuControllerWillSelectIndex:index];
    }
    _selectedIndex=index;
    [btn setTitleColor:kYMScrollBarItemHighlightColor forState:UIControlStateNormal];
    if(self.menuDelegate){
        [self.menuDelegate menuControllerSelectAtIndex:index];
    }
}

-(void)setTitle:(NSString*)title atIndex:(NSInteger)index{
    UIButton* btn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+index];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted];
}

-(void)setOffset:(NSInteger)index{
    float itemWidth=self.bounds.size.width/_menuMaxCount;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    _highlightView.frame=CGRectMake(itemWidth*_selectedIndex+(itemWidth-titleWidth)/2,self.frame.size.height-2,titleWidth,2);
    [UIView commitAnimations];
}
@end

