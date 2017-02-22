//
//  YMScrollViewController.m
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMScrollViewController.h"

#import "YMGlobal.h"
#define kLABarMenuItemTag       1000

#define kYMScrollBarItemHighlightColor rgba(255, 204, 2, 1.0)

@interface YMScrollBarMenuView(){
    int _menuMaxCount;
    UIScrollView* _scrollView;
    UIView* _highlightView;
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
    int itemCount=[items count];
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
    
    _highlightView.frame=CGRectMake(perWidth*_selectedIndex,self.frame.size.height-2,perWidth,2);
    
//    _selectedIndex=0;
    UIButton* defaultBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+_selectedIndex];
    [defaultBtn setTitleColor:kYMScrollBarItemHighlightColor forState:UIControlStateNormal];
//    [defaultBtn setBackgroundColor:kHTScrollBarItemHighlightColor];
    [self addSubview:_scrollView];
}

-(void)setVisibleSelectedIndex:(int)selectedIndex{
    UIButton* selectedBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+_selectedIndex];
    [selectedBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _selectedIndex=selectedIndex;
    UIButton* currentBtn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+selectedIndex];
    [currentBtn setTitleColor:kYMScrollBarItemHighlightColor forState:UIControlStateNormal];
    
    
}

-(void)menuItemSelected:(UIButton*)btn{
    int index=btn.tag-kLABarMenuItemTag;
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

-(void)setTitle:(NSString*)title atIndex:(int)index{
    UIButton* btn=(UIButton*)[_scrollView viewWithTag:kLABarMenuItemTag+index];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted];
}

-(void)setOffset:(int)index{
    float itemWidth=g_screenWidth/_menuMaxCount;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    _highlightView.frame=CGRectMake(index*itemWidth, self.frame.size.height-2, itemWidth, 2);
    [UIView commitAnimations];

    
}
@end


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

-(void)menuControllerWillSelectIndex:(int)index{
    
}

-(void)menuControllerSelectAtIndex:(int)index{
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
