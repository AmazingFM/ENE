//
//  YMNothingViewController.m
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMGoodsDetailController.h"

#import "YMGoodsInfoController.h"
#import "YMGoodsCommentController.h"

#import "YMPageScrollView.h"
#import "YMToolbarView.h"
#import "UIButton+Badge.h"

#import "YMUtil.h"
#import "YMUserManager.h"
#import "YMScrollBarMenuView.h"
@interface YMGoodsDetailController() <UITabBarDelegate, CAAnimationDelegate, YMScrollMenuControllerDelegate, YMGoodsInfoDelegate>
{
    CALayer     *layer;
    
    UIButton *cartButton;
    UIButton *collectButton;
    UIButton *navCollectButton;
    
    CGFloat badgeOffsetX;
}

@property (nonatomic, retain) YMGoods *goods;

@property (nonatomic, retain) UIButton *addCartButton;
@property (nonatomic,strong) UIBezierPath *path;
@property (nonatomic, retain) YMScrollBarMenuView *barMenuView;

@property (nonatomic) NSInteger selectedIndex;

@end

@implementation YMGoodsDetailController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed=YES;
        self.selectedIndex = 0;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *barImageArr = @[@"detail_home", @"detail_collect", @"detail_cart"];
    NSArray *barSelectImageArr = @[@"detail_home", @"detail_collect_select", @"detail_cart"];
    NSArray *barTitleArr = @[@"首页", @"收藏", @"购物车"];
    _addCartButton = [[UIButton alloc] initWithFrame:CGRectMake(g_screenWidth*3/5,g_screenHeight-44.f,g_screenWidth*2/5,44.f)];
    _addCartButton.tag = kYMGoodsDetailTag+2;
    [_addCartButton addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    [_addCartButton setTitle:@"加入购物车" forState:UIControlStateNormal];
    _addCartButton.backgroundColor = [UIColor redColor];
    _addCartButton.titleLabel.font = kYMBigFont;
    [_addCartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    float perWidth = g_screenWidth/5;
    
    for (int i=0; i<barTitleArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*perWidth,g_screenHeight-44.f,perWidth,44.f)];
        [btn setImage:[UIImage imageNamed:barImageArr[i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:barSelectImageArr[i]] forState:UIControlStateSelected];
        
        [btn setTitle:barTitleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIImage *image = [UIImage imageNamed:barImageArr[i]];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        CGSize size1 = [YMUtil sizeWithFont:barTitleArr[i] withFont:[UIFont systemFontOfSize:12]];
        
        btn.titleEdgeInsets =UIEdgeInsetsMake(0.5*image.size.height, -0.5*image.size.width, -0.5*image.size.height, 0.5*image.size.width);
        btn.imageEdgeInsets =UIEdgeInsetsMake(-0.5*size1.height, 0.5*size1.width, 0.5*size1.height, -0.5*size1.width);
        btn.tag = kYMGoodsDetailTag+10+i;
        
        if (i==1) {
            collectButton = btn;
        }
        
        if (i==2) {
            cartButton = btn;
            btn.shouldAnimateBadge = YES;
            btn.shouldHideBadgeAtZero=YES;
            btn.badgeValue = [YMUserManager sharedInstance].shoppingNum;
            badgeOffsetX = perWidth/2+0.5*image.size.width/2;
            btn.badgeOriginX = badgeOffsetX;
            btn.badgeOriginY = 0;
        }
        
        [btn addTarget:self action:@selector(barButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    [self.view addSubview:_addCartButton];
    
    self.path = [UIBezierPath bezierPath];
    [_path moveToPoint:_addCartButton.center];
    [_path addQuadCurveToPoint:CGPointMake(perWidth*2.5, _addCartButton.center.y) controlPoint:CGPointMake(perWidth*3, _addCartButton.centerY-200)];
    
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    self.navigationItem.rightBarButtonItem = createBarItemIcon(@"icon-service",self, @selector(service));
    
    _barMenuView=[[YMScrollBarMenuView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth/3,kYMScrollBarMenuHeight)];
    _barMenuView.backgroundColor=[UIColor clearColor];
    [_barMenuView setMenuItems:@[@"商品", @"评价"]];
    _barMenuView.menuDelegate=self;
    self.navigationItem.titleView = _barMenuView;
    
    if ([[YMDataBase sharedDatabase] isExistInIntrestCartWithId:self.goods_id andSubid:self.goods_subid]) {
        collectButton.selected = YES;
        navCollectButton.selected = YES;
    } else {
        collectButton.selected = NO;
        navCollectButton.selected = NO;
    }
    
    [self addChildViewControllers];
    
    [self addSwapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValue:) name:kYMNoticeShoppingCartIdentifier object:nil];
}

- (void)addSwapGesture
{
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    //设置轻扫的方向
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight; //默认向右
    [self.view addGestureRecognizer:swipeGestureRight];
    
    //添加轻扫手势
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    //设置轻扫的方向
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft; //默认向右
    [self.view addGestureRecognizer:swipeGestureLeft];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    UISwipeGestureRecognizerDirection direction = recognizer.direction;
    
    if (direction==UISwipeGestureRecognizerDirectionRight) {
        if (self.selectedIndex==1) {
            [self menuControllerSelectAtIndex:0];
        }
    } else if (direction==UISwipeGestureRecognizerDirectionLeft) {
        if (self.selectedIndex==0) {
            [self menuControllerSelectAtIndex:1];
        }
    }
}

- (void)addChildViewControllers
{
    CGRect viewFrame = CGRectMake(0, kYMTopBarHeight, g_screenWidth, g_screenHeight-kYMTopBarHeight-44.f);
    YMGoodsInfoController *goodsInfoVC = [[YMGoodsInfoController alloc] init];
    goodsInfoVC.goods_id = self.goods_id;
    goodsInfoVC.goods_subid = self.goods_subid;
    goodsInfoVC.delegate = self;
    [self addChildViewController:goodsInfoVC];
    [self.view addSubview:goodsInfoVC.view];
    
    YMGoodsCommentController *goodsCommentVC = [[YMGoodsCommentController alloc] init];
    [self addChildViewController:goodsCommentVC];
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = viewFrame;
    }];
}

- (void)switchController:(NSInteger)index
{
    if (index>=self.childViewControllers.count) {
        return;
    }
    
    if (index!=self.selectedIndex) {
        [self transitionFromViewController:self.childViewControllers[self.selectedIndex] toViewController:self.childViewControllers[index] duration:0 options:UIViewAnimationOptionCurveEaseInOut animations:nil completion:^(BOOL finished) {
            if (finished) {
                [self.childViewControllers[index] didMoveToParentViewController:self];
            }
            self.selectedIndex = index;
        }];
    }
}

- (void)updateBadgeValue:(NSNotification *)notice
{
    NSDictionary *userInfo = notice.userInfo;
    NSString *shoppingNum = userInfo[@"shoppingNum"];
    
    cartButton.shouldAnimateBadge = YES;
    cartButton.shouldHideBadgeAtZero=YES;
    cartButton.badgeValue = shoppingNum;
    cartButton.badgeOriginX = badgeOffsetX;
    cartButton.badgeOriginY = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    //统一导航样式
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)service
{
    
}

- (void)barButtonClick:(UIButton *)sender
{
    switch ((sender.tag-kYMGoodsDetailTag-10)) {
        case 0:
            [g_mainMenu setMenuSelectedAtIndex:0];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
        {
            [self addToCollect:sender];
        }
            break;
        case 2:
            [g_mainMenu setMenuSelectedAtIndex:1];
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        default:
            break;
    }
}

- (void)addToCart
{
    [self startAnimation];
}

- (void)addToCollect:(UIButton *)sender
{
    if (self.goods!=nil) {
        sender.selected = !sender.isSelected;
        collectButton.selected = sender.isSelected;
        navCollectButton.selected = sender.isSelected;
        
        if (sender.isSelected) {
            BOOL result = [[YMDataBase sharedDatabase] insertPdcToIntrestCartWithModel:self.goods];
            if (result) {
                [self showCustomHUDView:@"收藏成功"];
            }
        } else {
            BOOL result = [[YMDataBase sharedDatabase] deleIntrestPdcWithGoods:self.goods];
            if (result) {
                [self showCustomHUDView:@"取消收藏成功"];
            }
        }
    }
}

#pragma mark 网络请求
-(void)startAnimation
{
    if (!layer) {
        _addCartButton.enabled = NO;
        layer = [CALayer layer];
        layer.contents = (__bridge id)[UIImage imageNamed:@"defaultMenu"].CGImage;
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.bounds = CGRectMake(0, 0, 30, 30);
        [layer setCornerRadius:CGRectGetHeight([layer bounds]) / 2];
        layer.masksToBounds = YES;
        layer.position =CGPointMake(g_screenWidth/6*2.5, _addCartButton.center.y);
        [self.view.layer addSublayer:layer];
    }
    [self groupAnimation];
}
-(void)groupAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expandAnimation.duration = 0.3f;
    expandAnimation.fromValue = [NSNumber numberWithFloat:1];
    expandAnimation.toValue = [NSNumber numberWithFloat:1.2f];
    expandAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.3;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:1.2f];
    narrowAnimation.duration = 0.3f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.5f];
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,expandAnimation,narrowAnimation];
    groups.duration = 0.6f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self;
    [layer addAnimation:groups forKey:@"group"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //    [anim def];
    if (anim == [layer animationForKey:@"group"]) {
        _addCartButton.enabled = YES;
        [layer removeFromSuperlayer];
        layer = nil;

        //加入购物车
        if (self.goods!=nil) {
            if ([[YMDataBase sharedDatabase] isExistInCartWithGoods:self.goods]) {
                BOOL res = [[YMDataBase sharedDatabase] updateCountInCartByOne:self.goods.goods_id andSubid:self.goods.sub_gid];
                if (res) {
                    [self showCustomHUDView:@"加入成功"];
                    
                    int num = [[YMUserManager sharedInstance].shoppingNum intValue];
                    [YMUserManager sharedInstance].shoppingNum = [NSString stringWithFormat:@"%d", num+1];
                }
            }
            
            if ([[YMDataBase sharedDatabase] insertPdcToCartWithGoods:self.goods]) {
                [self showCustomHUDView:@"加入成功"];
                
                NSString *num = [[YMDataBase sharedDatabase] getPdcNumInCart];
                
                [YMUserManager sharedInstance].shoppingNum = num;
            } else {
                [self showCustomHUDView:@"加入失败"];
                return;
            }
        }
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.25f;

        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        shakeAnimation.duration = 0.25f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:-5];
        shakeAnimation.toValue = [NSNumber numberWithFloat:5];
        shakeAnimation.autoreverses = YES;
        
        UIView *cartBtnView = [self.view viewWithTag:112];
        [cartBtnView.layer addAnimation:shakeAnimation forKey:nil];
    }
}

#pragma mark YMGoodsInfoDelegate
- (void)setGoodsInfo:(YMGoods *)goods
{
    self.goods = goods;
}

-(void)menuControllerSelectAtIndex:(NSInteger)index{
    if(self.selectedIndex!=index){
        [self switchController:index];
        if(_barMenuView) {
            [_barMenuView setVisibleSelectedIndex:index];
            [_barMenuView setOffset:index];
        }
        
    }
}
@end
