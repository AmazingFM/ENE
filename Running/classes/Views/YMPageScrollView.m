//
//  YMPageScrollView.m
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMPageScrollView.h"
#import "YMImageButton.h"

#import "YMCommon.h"
#import "YMUtil.h"

#define kYMPageControlHeight 12
#define kPageControlTag 1000

#define kLineWidth 30.f

@interface YMPageScrollView() <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    NSTimer *_autoMoveTimer; //定时滚动
    int _index;
    
    NSMutableArray *_items;
}

@end
@implementation YMPageScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //init
        _items = [NSMutableArray new];
        
        CGRect newFrame = CGRectMake(0,0,frame.size.width, frame.size.height);
        
        _scrollView = [[UIScrollView alloc] initWithFrame:newFrame];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,frame.size.height-kYMPageControlHeight, frame.size.width, kYMPageControlHeight)];
        if ([_pageControl respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)]) {
            [_pageControl setCurrentPageIndicatorTintColor:rgba(255, 255, 255, 1)];
            [_pageControl setPageIndicatorTintColor:rgba(200,200,200,1)];
        }
        
        [self addSubview:_scrollView];
        [self addSubview:_pageControl];
        
        
        
        _autoMoveTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(autoMove) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    [_items removeAllObjects];
    [_items addObjectsFromArray:items];
    NSInteger nCount = items.count;
    
//    CGFloat padding = 5;
//    CGFloat offsetx = (self.frame.size.width-nCount*kLineWidth-(nCount-1)*padding)/2;
//    
//    for (int i=0; i<nCount; i++) {
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(i*(kLineWidth+padding)+offsetx,0,kLineWidth, 3)];
//        line.backgroundColor = rgba(215, 215, 215, 1);
//    }
    
    _pageControl.numberOfPages = nCount;
    _pageControl.currentPage = _index;
    
    [_scrollView setContentSize:CGSizeMake(nCount*_scrollView.frame.size.width, _scrollView.frame.size.height)];
    
    __block CGRect pageFrame = _scrollView.bounds;
    pageFrame.origin.x = 0;
    pageFrame.origin.y = 0;
    
    [items enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YMImageButton *btn = [self buttonWithIndex:(int)idx inView:_scrollView];
        btn.frame = pageFrame;
        [btn setImageURL:obj];
        pageFrame = CGRectOffset(pageFrame, _scrollView.frame.size.width, 0);
    }];
}


- (YMImageButton *)buttonWithIndex:(int)index inView:(UIView *)view
{
    YMImageButton *imageButton = (YMImageButton*)[view viewWithTag:kPageControlTag+index];
    if (imageButton==nil) {
        imageButton = [[YMImageButton alloc] initWithFrame:CGRectZero];
        imageButton.tag = kPageControlTag+index;
        [imageButton addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:imageButton];
    }
    return imageButton;
}

- (void)autoMove
{
    if (!_scrollView.dragging) {
        if (_index<0) {
            _index = 0;
        }
        if (_index<_pageControl.numberOfPages-1) {
            _index++;
        } else {
            _index = 0;
        }
        
        [_scrollView setContentOffset:CGPointMake(_index*_scrollView.frame.size.width, 0) animated:YES];
        _pageControl.currentPage = _index;
        
//        
    }
}

- (void)itemClick:(UIView *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageControlItemClick:)]) {
        [self.delegate pageControlItemClick:sender.tag-kPageControlTag];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _pageControl.frame=CGRectMake(0,_scrollView.frame.size.height-kYMPageControlHeight,_scrollView.frame.size.width,kYMPageControlHeight);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (offset.x>=0) {
        _index = offset.x/scrollView.frame.size.width;
        _pageControl.currentPage = _index;
    }
}


-(void)dealloc{
    if(_autoMoveTimer){
        [_autoMoveTimer invalidate];
        _autoMoveTimer=nil;
    }
}
@end
