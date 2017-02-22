//
//  YMStatisticViewController.m
//  Running
//
//  Created by 张永明 on 16/10/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMStatisticViewController.h"
#import "YMMyBenefitViewController.h"
#import "YMMyBoysViewController.h"

#import "YMGlobal.h"
#import "YMUserManager.h"
#import "Config.h"

@interface YMStatisticViewController ()

@property (nonatomic, retain) YMMyBoysViewController *myBoysVC;
@property (nonatomic, retain) YMMyBenefitViewController *myBenefitVC;
@property (nonatomic, retain) UIViewController *currentVC;

@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, retain) UIView *contentView;

@end

@implementation YMStatisticViewController

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgba(237, 237, 237, 1);
    
//    [self addNaviBarItems];
    
    [self addBottomView];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0, g_screenWidth, g_screenHeight-64-44-10)];
    [self.view addSubview:_contentView];
    
    [self addSubControllers];
}

- (void)addNaviBarItems
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"rc-more.png"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0,0,20,20);
    [rightBtn addTarget:self action:@selector(myAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:nil action:nil];
    spaceItem.width=0;
    
    self.navigationItem.rightBarButtonItems=@[spaceItem,barBtnItem];
}

- (void)myAction:(UIButton *)sender
{
    [Config deleteOwnAccount];
    
    [g_appDelegate setRootViewControllerWithLogin];

    
}

- (void)addSubControllers
{
    _myBoysVC = [[YMMyBoysViewController alloc] init];
    [self addChildViewController:_myBoysVC];
    
    _myBenefitVC = [[YMMyBenefitViewController alloc] init];
    [self addChildViewController:_myBenefitVC];
    
    [self fitFrameForChildViewController:_myBoysVC];
    [self.contentView addSubview:_myBoysVC.view];
    self.navigationItem.title = @"客户列表";
    self.currentVC = _myBoysVC;
}

- (void)fitFrameForChildViewController:(UIViewController *)childViewController{
    CGRect frame = self.contentView.frame;
    frame.origin.y = 0;
    childViewController.view.frame = frame;
}

- (void)addBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,g_screenHeight-44-64, g_screenWidth, 44)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    NSArray *titles = @[@"客户列表", @"结算信息"];
    CGFloat perWidth = g_screenWidth/2;
    for(int i=0; i<titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*perWidth, 0, perWidth, 44);
        [button setTitle:titles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:button];
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,30)];
    line.backgroundColor = rgba(224, 224, 224, 1);
    line.center = CGPointMake(g_screenWidth/2, 22.f);
    [_bottomView addSubview:line];
    [self.view addSubview:_bottomView];
}

- (void)buttonClick:(UIButton *)sender
{
    if (([sender.titleLabel.text isEqualToString:@"客户列表"]&&_currentVC==_myBoysVC) ||
        ([sender.titleLabel.text isEqualToString:@"结算信息"]&&_currentVC==_myBenefitVC)) {
        return;
    }
    
    if ([sender.titleLabel.text isEqualToString:@"客户列表"]) {
        [self fitFrameForChildViewController:_myBoysVC];
        self.navigationItem.title = @"客户列表";
        [self transitionFromViewController:_currentVC toViewController:_myBoysVC duration:0.f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
            if (finished) {
                [_myBoysVC didMoveToParentViewController:self];
                _currentVC = _myBoysVC;
            }
        }];
    }
    
    if ([sender.titleLabel.text isEqualToString:@"结算信息"]) {
        [self fitFrameForChildViewController:_myBenefitVC];
        self.navigationItem.title = @"结算信息";
        [self transitionFromViewController:_currentVC toViewController:_myBenefitVC duration:0.f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
            if (finished) {
                [_myBenefitVC didMoveToParentViewController:self];
                _currentVC = _myBenefitVC;
            }
        }];
    }
}

@end
