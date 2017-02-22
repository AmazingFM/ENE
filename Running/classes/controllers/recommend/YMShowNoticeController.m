//
//  YMShowNoticeController.m
//  Running
//
//  Created by 张永明 on 16/10/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMShowNoticeController.h"

#import "UIView+Util.h"
#import "YMUtil.h"
#import "YMGlobal.h"
#import "YMCommon.h"

@interface YMShowNoticeController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *itemlist;
    CGFloat popWidth;
    CGFloat popHeight;
}

@property (nonatomic, retain) UITableView *mainTableView;

@end

@implementation YMShowNoticeController

- (void)viewDidLoad {
    [super viewDidLoad];
    popWidth=g_screenWidth-50;
    popHeight=0;
    
    itemlist = @[@"1、首先要绑定支付宝账号，因为提现的收益会转到支付宝账号。",
                 @"2、账户余额大于100元时，每周日可以申请一次兑换收益，每次兑换收益不能超过10000元(签约达人兑换收益金额不限)。",
                 @"3、申请兑换收益后会在72小时内将钱放至支付宝账户。不过遇到周末、节假日会延至工作日发放。",
                 @"4、兑换收益遇到问题可以关注”长生汇“公众号咨询。"];
    
    for (NSString *str in itemlist) {
         CGSize size = [YMUtil sizeOfString:str withWidth:popWidth-30 font:kYMBigFont];
        popHeight += size.height+10;
    }
    popHeight += 105.f;


    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, popWidth, popHeight) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = [UIColor whiteColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.bounces = NO;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,popWidth,50.f)];
    titleLabel.textColor = rgba(57, 57, 57, 1);
    titleLabel.font = kYMBigFont;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"收益规则";
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,49,popWidth,1)];
    line.backgroundColor = rgba(221, 221, 221, 1);
    [titleLabel addSubview:line];
    
    _mainTableView.tableHeaderView = titleLabel;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0,0,popWidth, 55)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = CGRectMake(kYMBorderMargin,2,popWidth-2*kYMBorderMargin,40);
    submit.backgroundColor = [YMUtil colorWithHex:0xffcc02];
    [submit setTitle:@"确定" forState:UIControlStateNormal];
    submit.titleLabel.font = kYMBigFont;
    [submit addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [submit setCornerRadius:5.0f];
    [footView addSubview:submit];

    _mainTableView.tableFooterView = footView;
    
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCellId"];

    _mainTableView.layer.cornerRadius = 10;
    _mainTableView.layer.masksToBounds = YES;
    
    _mainTableView.center = CGPointMake(g_screenWidth/2, g_screenHeight/2);
    
    [self.view addSubview:_mainTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];//[UIColor clearColor];
}

- (void)btnClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [YMUtil sizeOfString:itemlist[indexPath.row] withWidth:popWidth-30 font:kYMBigFont];
    return size.height+10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return itemlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCellId"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0,popWidth-30,height)];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = rgba(57, 57, 57, 1);
    titleLabel.font = kYMBigFont;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = itemlist[indexPath.row];
    
    [cell addSubview:titleLabel];
    return cell;
}

@end
