//
//  YMOrdersViewController.m
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMOrdersViewController.h"
#import "YMPayViewController.h"

#import "YMUtil.h"
#import "YMBaseItem.h"
#import "YMUserManager.h"

#define kYMSectionHeaderHeight 40.f
#define kYMOrderTableDefaultRowHeight 40.f
#define kYMOrderTableGoodsRowHeight 100.f

#define kYMOrderTitleFont [UIFont systemFontOfSize:15]
#define kYMOrderDetailFont [UIFont systemFontOfSize:13]
#define kYMOrderPriceFont [UIFont systemFontOfSize:15]

@implementation YMOrderItem
@end


@implementation YMGoodsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
        header.backgroundColor = rgba(238, 238, 238, 1);
        header.tag = 100;

        goodImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        goodImage.contentMode = UIViewContentModeScaleToFill;
        goodImage.userInteractionEnabled = NO;
        goodImage.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = kYMOrderTitleFont;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor blackColor];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = kYMOrderDetailFont;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.textColor = [UIColor grayColor];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = kYMOrderPriceFont;
        _priceLabel.textColor = [UIColor redColor];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = kYMOrderTitleFont;
        _countLabel.textColor = [UIColor blackColor];

        [self addSubview:header];
        [header addSubview:goodImage];
        [header addSubview:_titleLabel];
        [header addSubview:_detailLabel];
        [header addSubview:_priceLabel];
        [header addSubview:_countLabel];
    }
    return self;
}

- (void)setItem:(YMOrderContent *)item
{
    _contentItem = item;
    
    UIView *header = [self viewWithTag:100];
    header.frame = CGRectMake(kYMPadding,0,g_screenWidth-2*kYMPadding,kYMOrderTableGoodsRowHeight);

    CGSize size = CGSizeMake(g_screenWidth-2*kYMPadding, kYMOrderTableGoodsRowHeight);
    
    float offsetx = 0;
    float offsety = 0;
    
    goodImage.frame = CGRectMake(offsetx+kYMPadding, offsety+kYMPadding, size.height-2*kYMPadding, size.height-2*kYMPadding);
    goodImage.backgroundColor = [UIColor yellowColor];
    [goodImage setImage:[UIImage imageNamed:@"default"]];
    
    offsetx = CGRectGetMaxX(goodImage.frame);
    
    CGSize titleSize =[YMUtil sizeWithFont:_contentItem.goods.goods_name withFont:kYMOrderTitleFont];
    _titleLabel.frame = CGRectMake(offsetx+kYMPadding, offsety+kYMPadding, size.width-offsetx-kYMPadding, titleSize.height);
    _titleLabel.text = _contentItem.goods.goods_name;
    
    offsety+=titleSize.height+kYMPadding;
    CGSize detailSize =[YMUtil sizeWithFont:_contentItem.goods.sub_gname withFont:kYMOrderDetailFont];
    _detailLabel.frame = CGRectMake(offsetx+kYMPadding, offsety+kYMPadding, size.width-offsetx-kYMPadding, detailSize.height);
    _detailLabel.text = _contentItem.goods.sub_gname;
    
    CGSize priceSize =[YMUtil sizeWithFont:[NSString stringWithFormat:@"￥%@", _contentItem.goods.price] withFont:kYMOrderPriceFont];
    _priceLabel.frame = CGRectMake(offsetx+kYMPadding, size.height-kYMPadding-priceSize.height, priceSize.width, priceSize.height);
    _priceLabel.text =[NSString stringWithFormat:@"￥%@", _contentItem.goods.price];
    
    CGSize countSize =[YMUtil sizeWithFont:[NSString stringWithFormat:@"x%d", _contentItem.count] withFont:kYMOrderTitleFont];
    _countLabel.frame = CGRectMake(size.width-countSize.width-kYMPadding, size.height-kYMPadding-countSize.height, countSize.width, countSize.height);
    _countLabel.text =[NSString stringWithFormat:@"x%d", _contentItem.count];
}

@end


@interface YMOrdersViewController () <YMScrollMenuControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    YMScrollBarMenuView*  _barMenuView;
    UITableView* _tableView;
    
    UIImageView *_noItemImg;
    UILabel *_noItemDesc;

    UIActivityIndicatorView* _loadingView;
}

@property(nonatomic,retain)NSArray*         titles;
@property(nonatomic,retain)NSDictionary*         statusTitles;
@property(nonatomic,retain)NSMutableArray<YMOrderItem *>*  itemArr;

@end

@implementation YMOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titles = @[@"全部", @"待付款", @"待发货", @"待收货", @"已收货"];
    self.statusTitles = @{@"0":@"待支付", @"1":@"已支付", @"2":@"已发货", @"3":@"已收货", @"4":@"已评价", @"7":@"已取消", @"9":@"超时"};
    self.navigationItem.title = self.titles[self.selectedIndex];
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    self.view.backgroundColor = rgba(238, 238, 238, 1);
    
    _barMenuView=[[YMScrollBarMenuView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,kYMScrollBarMenuHeight)];
    _barMenuView.selectedIndex = self.selectedIndex;
    _barMenuView.backgroundColor=[UIColor whiteColor];
    [_barMenuView setMenuItems:self.titles];
    _barMenuView.menuDelegate=self;
    [self.view addSubview:_barMenuView];
    

    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,kYMScrollBarMenuHeight,g_screenWidth, g_screenHeight-20-kYMNavigationBarHeight-kYMScrollBarMenuHeight) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = rgba(210, 210, 210, 1);
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CGFLOAT_MIN)];
    headview.backgroundColor = [UIColor redColor];
    _tableView.tableHeaderView = headview;
    
    _tableView.tableFooterView = [[UIView alloc] init];
    
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }

    _noItemDesc = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, 50)];
    _noItemDesc.center = self.view.center;
    _noItemDesc.text = @"暂无此类订单，快去选购商品吧!";
    _noItemDesc.textAlignment = NSTextAlignmentCenter;
    _noItemDesc.textColor = rgba(183, 183, 183, 1);
    _noItemDesc.font = kYMBigFont;
    
    _noItemImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_order"]];
    _noItemImg.frame = CGRectMake(0, 0, g_screenWidth/4, g_screenWidth/4);
    _noItemImg.center = CGPointMake(_noItemDesc.centerX, _noItemDesc.centerY-50);
    _noItemImg.hidden = YES;
    _noItemDesc.hidden = YES;
    
    [self.view addSubview:_noItemDesc];
    [self.view addSubview:_noItemImg];

    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refresh];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh
{
    self.myRefreshView = _tableView.mj_header;
    
    if (self.lastPage) {
        [_tableView.mj_footer resetNoMoreData];
    }
    self.lastPage = NO;
    self.pageNum = 1;
    [self requestOrders];
}

- (void)loadMoreData
{
    self.myRefreshView = _tableView.mj_footer;
    
    if (!self.lastPage) {
        self.pageNum++;
    }
    [self requestOrders];
    
}


-(void)startLoading{
    [_loadingView startAnimating];
}

-(void)endLoading{
    [_loadingView stopAnimating];
}

-(void)menuControllerWillSelectIndex:(int)index{
    
}

-(void)menuControllerSelectAtIndex:(int)index{
    if(self.selectedIndex!=index){
        self.selectedIndex=index;
        
        self.navigationItem.title = self.titles[self.selectedIndex];
        
        [self requestOrders];
        if(_barMenuView) {
           [_barMenuView setVisibleSelectedIndex:index];
            [_barMenuView setOffset:index];
        }
        
    }
}

- (NSMutableArray *)itemArr
{
    if (_itemArr==nil) {
        _itemArr = [NSMutableArray array];
    }
    return _itemArr;
}

#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kYMSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    YMOrderItem *item = self.itemArr[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, g_screenWidth, kYMSectionHeaderHeight)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10.f, g_screenWidth, kYMSectionHeaderHeight-10.f)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kYMPadding, 0, headerView.width-2*kYMPadding-50, headerView.height*3/5)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = [NSString stringWithFormat:@"订单号:%@", item.order.orderId];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kYMPadding, CGRectGetMaxY(titleLabel.frame), headerView.width-2*kYMPadding-50, headerView.height*2/5)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textColor = [UIColor grayColor];
    
    NSString *timeStr = [YMUtil dateStringTransform:item.order.timestamp fromFormat:@"yyyyMMddHHmmss" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    timeLabel.text = [NSString stringWithFormat:@"下单时间:%@", timeStr];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.width-15-50, 0, 50, headerView.height)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textAlignment = NSTextAlignmentRight;
    statusLabel.font = kYMNormalFont;
    statusLabel.textColor = [UIColor redColor];
    statusLabel.text = self.statusTitles[[NSString stringWithFormat:@"%d", item.order.status]];
    
    [headerView addSubview:titleLabel];
    [headerView addSubview:timeLabel];
    
    [headerView addSubview:statusLabel];
    
    [view addSubview:headerView];
    return view;
}

- (UIView *)footerView:(int)section
{
    float sectionfooterHeight = 40.f;
    
    YMOrderItem *item = self.itemArr[section];
    YMOrderType status = item.order.status;
    NSMutableArray *title = [NSMutableArray array];
    switch (status) {
        case YMOrderTypeForPay:
            [title addObjectsFromArray:@[@"取消订单", @"去付款"]];
            break;
        case YMOrderTypeForSend:
//            [title addObjectsFromArray:@[@"更改地址",@"去付款"]];
            break;
        case YMOrderTypeForReceive:
            [title addObjectsFromArray:@[@"确认收货"]];
            break;
        case YMOrderTypeAccept:
        case YMOrderTypeComment:
        case YMOrderTypeTimeout:
        case YMOrderTypeCancel:
            [title addObjectsFromArray:@[@"删除订单"]];
            break;
        default:
            break;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, g_screenWidth, sectionfooterHeight)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    CGSize buttonSize = [YMUtil sizeWithFont:@"更改地址" withFont:kYMNormalFont];
    float perwith = buttonSize.width+10;
    float height = (buttonSize.height+10)<sectionfooterHeight?(buttonSize.height+10):sectionfooterHeight;
    
    float padding = 15.f;

    if (title.count>0) {
        float offsetx = g_screenWidth-title.count*(padding+perwith);
        for (int i=0; i<title.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(offsetx, (sectionfooterHeight-height)/2, perwith, height);

            [button setTitle:title[i] forState:UIControlStateNormal];
            button.titleLabel.font = kYMNormalFont;
            UIColor *textColor;
            if ([title[i] isEqualToString:@"去付款"]) {
                textColor = [UIColor whiteColor];
                button.backgroundColor = [UIColor redColor];
            } else {
                button.backgroundColor = [UIColor clearColor];
                textColor = [UIColor blackColor];
            }
            [button setTitleColor:textColor forState:UIControlStateNormal];
            button.layer.cornerRadius = 4;
            button.layer.borderWidth = 0.5f;
            button.layer.borderColor = [UIColor lightGrayColor].CGColor;
            button.layer.masksToBounds = YES;
            button.tag = 100*section+i;
            
            [button addTarget:self action:@selector(modifyOrderAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [footerView addSubview:button];
            offsetx += padding+perwith;
        }
    }
    
    return footerView;
}

- (void)modifyOrderAction:(UIButton *)sender
{
    YMOrderItem *item = self.itemArr[sender.tag/100];
    
    if ([sender.titleLabel.text isEqualToString:@"去付款"]) {
        YMPayViewController *payVC = [[YMPayViewController alloc] init];
        payVC.order = item.order;
        [self.navigationController pushViewController:payVC animated:YES];
    } else if([sender.titleLabel.text isEqualToString:@"取消订单"]) {
        [self cancleOrder:item.order];
    } else if([sender.titleLabel.text isEqualToString:@"删除订单"]) {
        [self deleteOrder:item.order];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.itemArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YMOrderItem *item = self.itemArr[section];
    NSMutableArray<YMOrderContent *> *goodsItems = item.order.goodsItems;
    
    if (goodsItems.count>0) {
        return goodsItems.count+3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray<YMOrderContent *> *goodsItems = self.itemArr[indexPath.section].order.goodsItems;
    
    if (indexPath.row==goodsItems.count+2) {
        return 40.f;
    } else if(indexPath.row==goodsItems.count||
              indexPath.row==goodsItems.count+1) {
        return kYMOrderTableDefaultRowHeight;
    } else {
        return kYMOrderTableGoodsRowHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMOrder *order =  self.itemArr[indexPath.section].order;
    NSMutableArray<YMOrderContent *> *goodsItems = order.goodsItems;
    
    NSString *cellIdentifier = nil;
    
    if (indexPath.row==goodsItems.count+2) {
        cellIdentifier = @"footerCellId";
    } else if (indexPath.row>=goodsItems.count) {
        cellIdentifier = @"defaultCellId";
    } else if (indexPath.row<goodsItems.count){
        cellIdentifier = @"goodsCellId";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        if ([cellIdentifier containsString:@"goods"]) {
            cell = [[YMGoodsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
    }
    
    if ([cell isKindOfClass:[YMGoodsCell class]]){
        YMGoodsCell *goodCell = (YMGoodsCell *)cell;
        [goodCell setItem:goodsItems[indexPath.row]];
    } else if ([cell isKindOfClass:[UITableViewCell class]]) {
        if ((indexPath.row-goodsItems.count)==0) {
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth-50, kYMOrderTableDefaultRowHeight)];
            priceLabel.font = kYMOrderDetailFont;
            priceLabel.attributedText = [self priceString:order];
            priceLabel.textAlignment = NSTextAlignmentRight;
            cell.accessoryView = priceLabel;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }  else if ((indexPath.row-goodsItems.count)==1) {
            UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth-50, kYMOrderTableDefaultRowHeight)];
            YMAddress *address = order.address;
            addressLabel.text = [NSString stringWithFormat:@"收货信息 %@(%@，%@%@%@%@)", address.delivery_name, address.contact_no, address.city.province, address.city.city, address.city.town, address.delivery_addr];//@"收货信息";
            addressLabel.font = kYMOrderDetailFont;
            addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            addressLabel.numberOfLines = 2;
            addressLabel.textAlignment = NSTextAlignmentRight;
            cell.accessoryView = addressLabel;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ((indexPath.row-goodsItems.count)==2) {
            for (UIView *sub in cell.subviews) {
                [sub removeFromSuperview];
            }
            [cell addSubview:[self footerView:(int)indexPath.section]];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y<=kYMSectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=kYMSectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-kYMSectionHeaderHeight, 0, 0, 0);
    }
}

- (NSAttributedString *)priceString:(YMOrder *)order
{
    int i=0;
    for (YMOrderContent *content in order.goodsItems) {
        i+=content.count;
    }
    
    if (order.fee==nil||[order.fee isEqualToString:@"(null)"]||order.fee.length==0||[order.fee intValue]==0) {
        order.fee = @"0.00";
    }
    NSString *totalPriceStr = [NSString stringWithFormat:@"共%d件商品  合计:￥%@ (含运费:￥%@)", i,order.totalPrice, order.fee];
    //富文本对象
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:totalPriceStr];
    
    NSRange tmpRange0 = [totalPriceStr rangeOfString:@"共"];
    NSRange tmpRange1 = [totalPriceStr rangeOfString:@"件"];
    NSRange range1 = NSMakeRange(tmpRange0.length, tmpRange1.location-tmpRange0.length);
    
    tmpRange0 = [totalPriceStr rangeOfString:@"合计:"];
    tmpRange1 = [totalPriceStr rangeOfString:@"(含"];
    NSRange range2 = NSMakeRange(tmpRange0.location+tmpRange0.length, tmpRange1.location-tmpRange0.location-tmpRange0.length);
    
    tmpRange0 = [totalPriceStr rangeOfString:@"合计:￥"];
    tmpRange1 = [totalPriceStr rangeOfString:@"."];
    NSRange range21 = NSMakeRange(tmpRange0.location+tmpRange0.length, tmpRange1.location-tmpRange0.location-tmpRange0.length);

//    int start = tmpRange1.location;
//    NSString *substr = [totalPriceStr substringFromIndex:tmpRange1.location];
    tmpRange0 = [totalPriceStr rangeOfString:@"运费:"];
    tmpRange1 = [totalPriceStr rangeOfString:@")"];
    NSRange range3 = NSMakeRange(tmpRange0.location+tmpRange0.length, tmpRange1.location-tmpRange0.location-tmpRange0.length);

    //富文本样式
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range1];
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range2];
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range3];
    
    [aAttributedString addAttribute:NSFontAttributeName value:kYMOrderPriceFont range:range21];
    return aAttributedString;
}


#pragma mark 网络请求
- (void)requestOrders
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    self.params[kYM_ORDERSTATUS] = self.selectedIndex==0?@"":[NSString stringWithFormat:@"%d", (self.selectedIndex-1)];
    
    self.params[kYM_PAGENO] = [NSString stringWithFormat:@"%d", self.pageNum];
    self.params[kYM_PAGESIZE] = @"20";

    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    [self startLoading];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=OrderList"] parameters:self.params success:^(id responseObject) {
        [self endLoading];
        
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *resp_data = respDict[kYM_RESPDATA];
                
                if (resp_data) {
                    NSMutableDictionary *pageNav = resp_data[@"page_nav"];
                    
                    PageItem *pageItem = [[PageItem alloc] init];
                    pageItem.current_page = [pageNav[@"current_page"] intValue];
                    pageItem.page_size = [pageNav[@"page_size"] intValue];
                    pageItem.total_num = [pageNav[@"total_num"] intValue];
                    pageItem.total_page = [pageNav[@"total_page"] intValue];
                    
                    if (pageItem.current_page==pageItem.total_page) {
                        self.lastPage = YES;
                    }
                    
                    
                    NSMutableArray *ordersList = [NSMutableArray array];
                    if ([resp_data[@"order_list"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *dict in resp_data[@"order_list"]) {
                            YMOrder *order = [[YMOrder alloc] init];
                            
                            order.user_id = dict[@"user_id"];
                            order.orderId = dict[@"order_id"];
                            order.timestamp = dict[@"add_time"];
                            order.totalPrice = dict[@"amt"];
                            order.status = [dict[@"status"] intValue];
                            
                            YMAddress *address = [[YMAddress alloc] init];
                            address.delivery_name = dict[@"delivery_name"];
                            address.delivery_addr = dict[@"delivery_addr"];
                            address.contact_no = dict[@"contact_no"];
                            address.delivery_name = dict[@"delivery_name"];
                            
                            YMCity *city = [YMCity objectWithKeyValues:dict];
                            address.city = city;
                            order.address = address;

                            if ([ dict[@"order_detail"] isKindOfClass:[NSArray class]]) {
                                NSArray *goodsArr = dict[@"order_detail"];
                                for (NSDictionary *dict1 in goodsArr) {
                                    YMOrderContent *detailContent = [[YMOrderContent alloc] init];
                                    detailContent.count = [dict1[@"qty"] intValue];
                                    
                                    YMGoods *goods = [YMGoods objectWithKeyValues:dict1];
                                    detailContent.goods = goods;
                                    
                                    [order.goodsItems addObject:detailContent];
                                }
                            }
                            
                            [ordersList addObject:order];
                        }
                    }
                    
                    NSMutableArray *arrayM = [NSMutableArray array];
                    for (int i=0; i<ordersList.count; i++)
                    {
                        YMOrderItem *orderItem = [[YMOrderItem alloc] init];
                        orderItem.order = ordersList[i];
                        [arrayM addObject:orderItem];
                    }
                    
                    //..下拉刷新
                    if (self.myRefreshView == _tableView.mj_header) {
                        [self.itemArr removeAllObjects];
                        [self.itemArr addObjectsFromArray:arrayM];
                        _tableView.mj_footer.hidden = self.lastPage;
                        [_tableView reloadData];
                        [self.myRefreshView endRefreshing];
                        
                    } else if (self.myRefreshView == _tableView.mj_footer) {
                        [self.itemArr addObjectsFromArray:arrayM];
                        [_tableView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [_tableView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                    _tableView.hidden = NO;
                    _noItemImg.hidden = YES;
                    _noItemDesc.hidden = YES;
                } else {
                    _tableView.hidden = YES;
                    _noItemImg.hidden = NO;
                    _noItemDesc.hidden = NO;
                }
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self endLoading];
    }];
}

- (void)cancleOrder:(YMOrder *)order
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[@"order_id"] = order.orderId;
    self.params[@"status"] = @"7"; //取消订单
    
    [self startLoading];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=OrderModify"] parameters:self.params success:^(id responseObject) {
        [self endLoading];
        
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                //重新刷新订单
                [self showTextHUDView:@"成功取消订单"];
                [self refresh];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self endLoading];
    }];
}

- (void)deleteOrder:(YMOrder *)order
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[@"order_id"] = order.orderId;
    self.params[@"status"] = @"99"; //取消订单
    
    [self startLoading];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=OrderStatusModify"] parameters:self.params success:^(id responseObject) {
        [self endLoading];
        
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                //重新刷新订单
                [self showTextHUDView:@"成功删除订单"];
                [self refresh];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self endLoading];
    }];
}

@end