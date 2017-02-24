//
//  YMScrollViewController.m
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMScrollViewController.h"

@interface YMScrollViewController () <YMScrollMenuControllerDelegate, UIScrollViewDelegate>
{
    YMScrollBarMenuView*  _barMenuView;
    BOOL            _bJumpPage;
}
@end

@implementation YMScrollViewController

- (void)loadView {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super loadView];
    float pageHeight=kYMMainViewHeight-(self.hideScrollBarMenu?0:kYMScrollBarMenuHeight);
    
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,(self.hideScrollBarMenu?0:kYMScrollBarMenuHeight),g_screenWidth,pageHeight)];
    _scrollView.delegate=self;
    _scrollView.pagingEnabled=YES;
    [self.view addSubview:_scrollView];
    [_scrollView setContentSize:CGSizeMake(g_screenWidth*self.titles.count, pageHeight)];
    
    for (int i=0;i<self.controllers.count;i++) {
        UIViewController* subController=[self.controllers objectAtIndex:i];
        subController.view.frame=CGRectMake(i*g_screenWidth,0,g_screenWidth, pageHeight);
        [_scrollView addSubview:subController.view];
    }
    
    if(!self.hideScrollBarMenu){
        _barMenuView=[[YMScrollBarMenuView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kYMScrollBarMenuHeight)];
        _barMenuView.backgroundColor=[UIColor whiteColor];
        [_barMenuView setMenuItems:self.titles];
        _barMenuView.menuDelegate=self;
        [self.view addSubview:_barMenuView];
    }
    [self setRefresh];

}

-(void)setMenuTitle:(NSString*)title atIndex:(int)index{
    [_barMenuView setTitle:title atIndex:index];
}

-(void)refresh{
    YMBaseViewController* subViewController=[self.controllers objectAtIndex:self.selectedIndex];
    [subViewController refresh];
}

-(void)setRefresh
{
    for(int k=0; k<self.controllers.count; k++){
        YMBaseViewController *subViewController = [self.controllers objectAtIndex:k];
        [subViewController setRefresh:self.selectedIndex == k];
    }
}

-(void)menuControllerWillSelectIndex:(NSInteger)index{
    
}

-(void)menuControllerSelectAtIndex:(NSInteger)index{
    if(self.selectedIndex==0 && self.selectedIndex!=index){
//        [[NSNotificationCenter defaultCenter] postNotificationName:kHTHideIndexMinuteNotifier object:nil];
    }
    if(self.selectedIndex!=index){
        [self menuControllerWillSelectIndex:index];
        self.selectedIndex=index;
        [self setRefresh];
        YMBaseViewController* subViewController=[self.controllers objectAtIndex:index];
        [subViewController viewWillAppear:YES];
        [_scrollView setContentOffset:CGPointMake(index*g_screenWidth, 0) animated:YES];
        if(_barMenuView)[_barMenuView setVisibleSelectedIndex:index];
    }
}

-(NSMutableArray*)controllers{
    if(_controllers==nil){
        _controllers=[[NSMutableArray alloc] init];
    }
    return _controllers;
}

-(void)dealloc{
    if(_controllers){
        [_controllers removeAllObjects];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_barMenuView){
        CGPoint offset=scrollView.contentOffset;
        [_barMenuView setOffset:offset.x/self.controllers.count];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(!_bJumpPage){
        CGPoint point=scrollView.contentOffset;
        int pageID=point.x/g_screenWidth;
        if(self.selectedIndex==0 && self.selectedIndex!=pageID){
//            [[NSNotificationCenter defaultCenter] postNotificationName:kHTHideIndexMinuteNotifier object:nil];
        }
        if(self.selectedIndex!=pageID){
            [self menuControllerWillSelectIndex:pageID];
            self.selectedIndex=pageID;
            if(_barMenuView){
                [_barMenuView setVisibleSelectedIndex:self.selectedIndex];
            }
            [self setRefresh];
            YMBaseViewController* viewController=[self.controllers objectAtIndex:pageID];
            //            [viewController refresh];
            [viewController viewWillAppear:YES];
            if(self.scrollMenuDelegate&&[self.scrollMenuDelegate respondsToSelector:@selector(menuControllerSelectAtIndex:)]){
                [self.scrollMenuDelegate menuControllerSelectAtIndex:self.selectedIndex];
            }
        }
    }
    _bJumpPage=NO;
}

@end
