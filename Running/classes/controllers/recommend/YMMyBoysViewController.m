//
//  YMMyBoysViewController.m
//  Running
//
//  Created by 张永明 on 16/10/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMMyBoysViewController.h"

#import "MJRefresh.h"
#import "MJExtension.h"
#import "MJRefreshComponent.h"

#import "YMUserManager.h"
#import "YMBaseItem.h"
#import "YMMyBoy.h"
#import "Config.h"

#define kYMStatisticHeaderViewHeight 44.f
#define kYMStatisticRowHeight 80.f

@interface YMMyBoysViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    UIImageView *_headView;
    UISearchBar *_searchBar;
    UITableView *_mainTableView;
    
    NSMutableArray *_itemlist;
}
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL lastPage;
@property (nonatomic, retain) MJRefreshComponent *myRefreshView;

@end

@implementation YMMyBoysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _itemlist = [NSMutableArray array];
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, g_screenWidth*2/5)];
    _headView.contentMode = UIViewContentModeScaleToFill;
    _headView.image = [UIImage imageNamed:@"person_back.png"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    CGRect headFrame = CGRectMake(0,0,_headView.frame.size.width, _headView.frame.size.height);
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quitBtn.backgroundColor = [UIColor clearColor];
    [quitBtn setTitle:@"退出" forState:UIControlStateNormal];
    quitBtn.titleLabel.font = kYMNormalFont;
    quitBtn.frame = CGRectMake(headFrame.size.width-60,5,50,30);
    quitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBtn addTarget:self action:@selector(loginOut:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *nameStr = [NSString stringWithFormat:@"你好，%@", [YMUserManager sharedInstance].user.nick_name];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:nameStr];
    NSRange range1 = [nameStr rangeOfString:@"你好，"];
    NSRange range2 = NSMakeRange(range1.length, nameStr.length-range1.length);
    [attributedStr addAttribute:NSFontAttributeName value:kYMSmallFont range:range1];
    [attributedStr addAttribute:NSFontAttributeName value:kYMBigFont range:range2];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headFrame.size.width,30)];
    nameLabel.center = CGPointMake(headFrame.size.width/2, headFrame.size.height/2);
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.attributedText = attributedStr;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *levelInfo = @"省级代理";
    NSString *remarkCode = @"132433";
    NSString *userInfo = [NSString stringWithFormat:@"%@，推荐吗：%@", levelInfo, remarkCode];
    
    
    CGSize size = [YMUtil sizeWithFont:userInfo withFont:kYMVerySmallFont];
    UIImageView *levelIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rc-level"]];
    levelIcon.frame = CGRectMake(headFrame.size.width-size.width-size.height-7,headFrame.size.height-size.height-2, size.height, size.height);
    levelIcon.contentMode = UIViewContentModeScaleToFill;
    
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(headFrame.size.width-size.width-5, headFrame.size.height-size.height-2, size.width,size.height)];
    levelLabel.backgroundColor = [UIColor clearColor];
    levelLabel.text = userInfo;
    levelLabel.textColor = [UIColor lightGrayColor];
    levelLabel.font = kYMVerySmallFont;
    levelLabel.textAlignment = NSTextAlignmentLeft;
    
    [_headView addSubview:quitBtn];
    [_headView addSubview:nameLabel];
    [_headView addSubview:levelIcon];
    [_headView addSubview:levelLabel];
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _mainTableView.frame = CGRectMake(0, g_screenWidth*2/5, g_screenWidth, g_screenHeight*3/5-44);
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.bounces = YES;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    
    _mainTableView.tableFooterView = [[UIView alloc] init];
    
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    _mainTableView.tableHeaderView = [self addTableHeaderView];
    
    _mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    
//    _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [self.view addSubview:_mainTableView];
    
    [_mainTableView.mj_header beginRefreshing];
}

- (void)loginOut:(UIButton *)sender
{
    [Config deleteOwnAccount];
    
    [g_appDelegate setRootViewControllerWithLogin];
}


- (void)refresh
{
    self.myRefreshView = _mainTableView.mj_header;
    
    if (self.lastPage) {
        [_mainTableView.mj_footer resetNoMoreData];
    }
    self.lastPage = NO;
    self.pageNum = 1;
    [self startGetBoys];
}

- (void)loadMoreData
{
    self.myRefreshView = _mainTableView.mj_footer;
    
    if (!self.lastPage) {
        self.pageNum++;
    }
    [self startGetBoys];
    
}


- (UIView *)addTableHeaderView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kYMStatisticHeaderViewHeight)];
    backView.backgroundColor = rgba(237, 237, 237, 1);
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 2, g_screenWidth-40, 34)];
    searchBar.showsCancelButton = NO;
    searchBar.translucent =YES;
    [searchBar sizeToFit];
    searchBar.autocapitalizationType =UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType =UITextAutocorrectionTypeNo;
    searchBar.placeholder = @"姓名、地址";
    searchBar.delegate = self;
    searchBar.contentMode = UIViewContentModeLeft;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ([searchBar respondsToSelector:@selector(barTintColor)]) {
        float iosversion7_1 = 7.1;
        if (version >= iosversion7_1) {
            [[[[searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
            [searchBar setBackgroundColor:[UIColor clearColor]];
        }
        else {            //iOS7.0
            [searchBar setBarTintColor:[UIColor clearColor]];
            [searchBar setBackgroundColor:[UIColor clearColor]];
        }
    }
    else {
        //iOS7.0以下
        [[searchBar.subviews objectAtIndex:0] removeFromSuperview];
        [searchBar setBackgroundColor:[UIColor clearColor]];
    }
    
    [backView addSubview:searchBar];
    return backView;
}

#pragma mark - 协议UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:NO];
    //    YMSearchViewController *searchVC = [[YMSearchViewController alloc] init];
    //    YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:searchVC];
    //
    //    [self presentViewController:nav animated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //@ 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];    // 取消按钮回收
    [searchBar resignFirstResponder];                                // 取消第一响应值,键盘回收,搜索结束
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemlist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kYMStatisticRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMMyBoy *boy = _itemlist[indexPath.row];
    
    NSString *cellId = @"defaultCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.tintColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UIImageView *headImageV = (UIImageView *)[cell viewWithTag:1000];
    
    if (headImageV==nil) {
        headImageV = [[UIImageView alloc] initWithFrame:CGRectMake(kYMBorderMargin, 10, kYMStatisticRowHeight-20, kYMStatisticRowHeight-20)];
        headImageV.tag = 1000;
        headImageV.layer.cornerRadius = 5.f;
        headImageV.layer.masksToBounds = YES;
        headImageV.contentMode = UIViewContentModeScaleToFill;
        [cell addSubview:headImageV];
    }
    if (boy.user_icon.length==0) {
        headImageV.image = [UIImage imageNamed:@"defaultMe.png"];
    } else {
        NSData *_decodedImgData = [[NSData alloc] initWithBase64EncodedString:boy.user_icon options:NSDataBase64DecodingIgnoreUnknownCharacters];
        headImageV.image = [UIImage imageWithData:_decodedImgData];
    }

    CGFloat offsetx = CGRectGetMaxX(headImageV.frame)+kYMBorderMargin;
    CGFloat offsety = 10.f;
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1001];
    if (titleLabel==nil) {
        CGSize size = [YMUtil sizeWithFont:@"赵三" withFont:kYMNormalFont];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, offsety, 100, size.height)];
        titleLabel.tag = 1001;
        titleLabel.font = kYMNormalFont;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:titleLabel];
    }
    if (boy.true_name.length>0) {
        titleLabel.text = boy.true_name;
    } else {
        titleLabel.text = boy.nick_name;
    }
    
    UILabel *monthLabel = (UILabel *)[cell viewWithTag:1002];
    if (monthLabel==nil) {
        CGSize size = [YMUtil sizeWithFont:@"赵三" withFont:kYMSmallFont];
        monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, offsety, 100, size.height)];
        monthLabel.centerY = kYMStatisticRowHeight/2;
        monthLabel.tag = 1002;
        monthLabel.font = kYMSmallFont;
        monthLabel.textColor = [UIColor lightGrayColor];
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:monthLabel];
    }
    NSString *monthStr = [NSString stringWithFormat:@"本月交易:%@笔", boy.month_count];
    monthLabel.text = monthStr;
    
    UIButton *teleButton = (UIButton *)[cell viewWithTag:1003];
    if (teleButton==nil) {
        CGSize size = [YMUtil sizeWithFont:@"赵三" withFont:[UIFont systemFontOfSize:12]];
        size.height += 4;
        teleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        teleButton.tag = 1003;
        [teleButton setImage:[UIImage imageNamed:@"rc-tele"] forState:UIControlStateNormal];
        teleButton.frame = CGRectMake(offsetx, kYMStatisticRowHeight-10-size.height, 100, size.height);
        
        teleButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [teleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        teleButton.backgroundColor = [UIColor clearColor];
        teleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        teleButton.titleEdgeInsets = UIEdgeInsetsMake(0,5,0,0);
        [cell addSubview:teleButton];
    }
    [teleButton setTitle:boy.user_name forState:UIControlStateNormal];

    UILabel *summaryLabel = (UILabel *)[cell viewWithTag:1004];
    if (summaryLabel==nil) {
        CGSize size = [YMUtil sizeWithFont:@"已交易:10000笔" withFont:kYMNormalFont];
        summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(g_screenWidth-size.width-30, 0, size.width, size.height)];
        summaryLabel.centerY = kYMStatisticRowHeight/2;
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.tag = 1004;
        summaryLabel.font = kYMNormalFont;
        summaryLabel.textColor = [UIColor lightGrayColor];
        summaryLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:summaryLabel];
    }

    NSString *sumStr = [NSString stringWithFormat:@"已交易:%@笔", boy.sum_count];
    //富文本对象
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:sumStr];
    
    NSRange range1 = [sumStr rangeOfString:@"已交易:"];
    
    NSRange range = NSMakeRange(range1.length,sumStr.length-range1.length-1);
    //富文本样式
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    summaryLabel.attributedText =aAttributedString;

    return cell;
}

#pragma mark 网络请求
- (void)startGetBoys
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    self.params[kYM_PAGENO] = [NSString stringWithFormat:@"%d", self.pageNum];
    self.params[kYM_PAGESIZE] = @"30";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=CustList"] parameters:self.params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *resp_data = respDict[kYM_RESPDATA];
                if (resp_data) {
                    NSArray *boyList;
                    
                    if ([resp_data[@"cust_list"] isKindOfClass:[NSArray class]]) {
                        boyList = [YMMyBoy objectArrayWithKeyValuesArray:resp_data[@"cust_list"]];
                    }
                    
                    //..下拉刷新
                    if (self.myRefreshView == _mainTableView.mj_header) {
                        [_itemlist removeAllObjects];
                        [_itemlist addObjectsFromArray:boyList];
                        
                        _mainTableView.mj_footer.hidden = self.lastPage;
                        [_mainTableView reloadData];
                        [self.myRefreshView endRefreshing];
                        
                    } else if (self.myRefreshView == _mainTableView.mj_footer) {
                        [_itemlist addObjectsFromArray:boyList];
                        [_mainTableView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [_mainTableView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                }
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        });
    }];
}

@end
