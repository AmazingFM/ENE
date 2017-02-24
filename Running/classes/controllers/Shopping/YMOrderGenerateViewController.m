//
//  YMOrderGenerateViewController.m
//  Running
//
//  Created by 张永明 on 16/9/14.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMOrderGenerateViewController.h"
#import "YMShoppingCartViewController.h"
#import "YMAddressViewController.h"
#import "YMPayViewController.h"

#import "YMAddressView.h"
#import "YMOrder.h"
#import "YMUtil.h"
#import "YMUserManager.h"
#import "YMDataBase.h"

#define kYMAddressViewHeight 80

@interface YMOrderGenerateViewController () <UITableViewDelegate, UITableViewDataSource, YMCartCellDelegate, YMAddressViewDelegate, YMAddressViewControllerDelegate>
{
    YMAddressView *_addressView;
    
    UITableView *_mainTableView;
    
    UIView *_submitView;
    UIButton *checkBtn;
    
    NSString *totalPrice;
    
    float rowHeight;
    
    YMAddress *_defaultAddress;
}

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *preBarButton;

@end

@implementation YMOrderGenerateViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        rowHeight = 100.f;
        totalPrice = @"99999.00";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"填写订单";
    self.view.backgroundColor = rgba(242, 242, 242, 1);
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    // Do any additional setup after loading the view.
    _addressView = [[YMAddressView alloc] initWithFrame:CGRectMake(0,kYMTopBarHeight,g_screenWidth,kYMAddressViewHeight)];
    _addressView.delegate = self;
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _mainTableView.frame = CGRectMake(0, kYMTopBarHeight+kYMAddressViewHeight, g_screenWidth, g_screenHeight-kYMTopBarHeight-44-kYMAddressViewHeight);
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.bounces = NO;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    _mainTableView.tableFooterView = [[UIView alloc] init];
    
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:_addressView];
    [self.view addSubview:_mainTableView];

    _submitView = [self addSubmitView];
    [self.view addSubview:_submitView];
    
//    [self finishBarView];
//    
//    [self loadNotificationCell];
    
    [self getDefaultAddress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [self removeNotificationCell];
}

- (void)finishBarView
{
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,g_screenHeight,g_screenWidth,44)];
    _toolbar.backgroundColor = [UIColor yellowColor];
    [_toolbar setBarStyle:UIBarStyleDefault];
    
    CGSize size = [YMUtil sizeWithFont:@"完成" withFont:kYMBigFont];
    UIButton *finishBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(0,0,size.width+20, 44);
    [finishBtn setBackgroundColor:[UIColor clearColor]];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    finishBtn.titleLabel.font = kYMBigFont;
    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(previousButtonIsClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.preBarButton = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];
    NSArray *barButtonItems = @[flexBarButton,self.preBarButton];
    _toolbar.items = barButtonItems;
    [self.view addSubview:_toolbar];
}

- (void) previousButtonIsClicked:(id)sender
{
    [self.view endEditing:YES];
}

- (void)loadNotificationCell
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotificationCell
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    if (self.view.hidden == YES) {
        return;
    }
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    NSArray *subviews = [self.view subviews];
    for (UIView *sub in subviews) {
        CGFloat maxY = CGRectGetMaxY(sub.frame);
        if ([sub isKindOfClass:[UITableView class]]) {
            sub.frame = CGRectMake(0,kYMAddressViewHeight,sub.frame.size.width, g_screenHeight-_toolbar.frame.size.height-rect.size.height-20-kYMNavigationBarHeight-kYMAddressViewHeight);
        }
        else if ([sub isKindOfClass:[YMAddressView class]]) {
            continue;
        }
        else {
            if (maxY > y - 2) {
                sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, sub.center.y - maxY + y-(44+20) );
            }
        }
    }
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    _toolbar.frame=CGRectMake(0, g_screenHeight, g_screenWidth, _toolbar.frame.size.height);
    _submitView.frame = CGRectMake(0, g_screenHeight-kYMNavigationBarHeight-20-44,g_screenWidth, 44);
    
    _mainTableView.frame=CGRectMake(0, kYMAddressViewHeight, g_screenWidth, g_screenHeight-kYMNavigationBarHeight-20-44-kYMAddressViewHeight);
    [UIView commitAnimations];
}

- (UIView *)addSubmitView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, g_screenHeight-44.f, g_screenWidth, 44.f)];
    backView.backgroundColor = [UIColor whiteColor];
    
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth-120, backView.frame.size.height)];
    totalPrice = [self calcTotalPrice];
    totalLabel.attributedText = [self priceString];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.tag = 101;
    
    checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(g_screenWidth-100,0,100,backView.frame.size.height)];
    checkBtn.tag = 100;
    [checkBtn addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
    [checkBtn setTitle:@"提交订单" forState:UIControlStateNormal];
    checkBtn.backgroundColor = [UIColor redColor];
    checkBtn.titleLabel.font = kYMBigFont;
    [checkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [backView addSubview:totalLabel];
    [backView addSubview:checkBtn];
    
    return backView;
}

- (NSAttributedString *)priceString
{
    NSString *totalPriceStr = [NSString stringWithFormat:@"实际付款:%@", totalPrice];
    //富文本对象
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:totalPriceStr];
    
    NSRange range1 = [totalPriceStr rangeOfString:@"实际付款:"];
    
    NSRange range = NSMakeRange(range1.length,totalPriceStr.length-range1.length);
    //富文本样式
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    [aAttributedString addAttribute:NSFontAttributeName value:kYMBigFont range:range];
    [aAttributedString addAttribute:NSFontAttributeName value:kYMSmallFont range:range1];
    return aAttributedString;
}

- (void)btnClick:(UIButton *)sender
{
    //
    showAlert(@"您准备提交订单");
}

- (NSString *)calcTotalPrice
{
    NSString *sum = @"0";
    
    NSMutableArray *operands = [NSMutableArray new];
    for (YMShoppingCartItem *item in self.itemlist) {
        if (item.selected) {
            [operands addObject: [YMUtil decimalMutiply:item.count with:item.goods.price]];
        }
    }
    sum = [YMUtil decimalAdd:operands];
    return sum;
}



#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = self.itemlist[indexPath.row];
    item.indexPath = indexPath;
    static NSString *cellIdentifier = @"cellId";
    YMCartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[YMCartCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.type = 1;
        cell.delegate = self;
    }
    
    cell.item = item;
    
    return cell;
}

#pragma mark YMCartCellDelegate
- (void)cellCount:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath forType:(int)type
{
    YMShoppingCartItem *item = self.itemlist[indexPath.row];
    
    NSInteger count = [item.count integerValue];
    
    if (type==0) {
        count++;
    } else {
        count--;
    }
    
    item.count = [NSString stringWithFormat:@"%ld", count];
    
    [self updatePrice];
}

- (void)updatePrice
{
    totalPrice = [self calcTotalPrice];
    UILabel *totalPriceLabel = [_submitView viewWithTag:101];
    totalPriceLabel.attributedText = [self priceString];
}

#pragma mark YMAddressViewDelegate
- (void)didClick
{
    YMAddressViewController *addressViewVC = [[YMAddressViewController alloc] init];
    addressViewVC.delegate = self;
    [self.navigationController pushViewController:addressViewVC animated:YES];
}

#pragma mark YMAddressViewControllerDelegate
- (void)didSelectAddress:(YMAddress *)address;
{
    _defaultAddress = address;
    _addressView.address = address;
}


#pragma mark 网络请求
//- (BOOL)getParameters
//{
////    [super getParameters];
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    
//    parameters[@"user_id"] = [YMUserManager sharedInstance].user.user_id;
//    parameters[@"amt"] = [self calcTotalPrice];
//    
//    if (_defaultAddress==nil) {
//        showDefaultAlert(@"提示", @"请选择地址");
//        return NO;
//    }
//    parameters[@"delivery_name"] = _defaultAddress.delivery_name;
//    parameters[@"contact_no"] = _defaultAddress.contact_no;
//    parameters[@"delivery_addr"] = _defaultAddress.delivery_addr;
//    
//    YMCity *city = _defaultAddress.city;
//    [parameters addEntriesFromDictionary:[city keyValues]];
//    
//    NSMutableArray *paramsArr = [NSMutableArray array];
//    for (YMShoppingCartItem *item in self.itemlist) {
//        NSDictionary *dict =
//                @{@"goods_id":[NSNumber numberWithInteger:[item.goods.goods_id  integerValue]],
//                  @"sub_gid":[NSNumber numberWithInteger:[item.goods.sub_gid integerValue]],
//                  @"price":item.goods.price,
//                  @"qty":item.count,
//                  @"amt":[YMUtil decimalMutiply:item.count with:item.goods.price]};
//        [paramsArr addObject:dict];
//    }
//    
//    NSString *str = [YMUtil stringFromJSON:paramsArr];
//    parameters[@"order_detail_arr"] = str;
//    return YES;
//}

- (void)submitOrder
{
//    if (![self getParameters]) {
//        return;
//    }
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[@"user_id"] = [YMUserManager sharedInstance].user.user_id;
    parameters[@"amt"] = [self calcTotalPrice];
    
    if (_defaultAddress==nil) {
        showDefaultAlert(@"提示", @"请选择地址");
        return;
    }
    parameters[@"delivery_name"] = _defaultAddress.delivery_name;
    parameters[@"contact_no"] = _defaultAddress.contact_no;
    parameters[@"delivery_addr"] = _defaultAddress.delivery_addr;
    
    YMCity *city = _defaultAddress.city;
    [parameters addEntriesFromDictionary:[city keyValues]];
    
    NSMutableArray *paramsArr = [NSMutableArray array];
    for (YMShoppingCartItem *item in self.itemlist) {
        NSDictionary *dict =
        @{@"goods_id":[NSNumber numberWithInteger:[item.goods.goods_id  integerValue]],
          @"sub_gid":[NSNumber numberWithInteger:[item.goods.sub_gid integerValue]],
          @"price":item.goods.price,
          @"qty":item.count,
          @"amt":[YMUtil decimalMutiply:item.count with:item.goods.price]};
        [paramsArr addObject:dict];
    }
    
    NSString *str = [YMUtil stringFromJSON:paramsArr];
    parameters[@"order_detail_arr"] = str;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=OrderAdd"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *respData = respDict[kYM_RESPDATA];
                
                [self showCustomHUDView:[NSString stringWithFormat:@"%@", respDict[kYM_RESPDESC]]];
                YMOrder *order = [[YMOrder alloc] init];
                order.timestamp = respData[@"add_time"];
                order.orderId = respData[@"order_id"];
                order.totalPrice = totalPrice;
                order.address = _defaultAddress;
                
                YMPayViewController *payVC = [[YMPayViewController alloc] init];
                payVC.order = order;
                [self.navigationController pushViewController:payVC animated:YES];
                
                //删除购物车中对于goods
                NSMutableArray<YMGoods *> *goodsList = [NSMutableArray<YMGoods *> new];
                for (YMShoppingCartItem *item in self.itemlist) {
                    [goodsList addObject:item.goods];
                }
                [[YMDataBase sharedDatabase] deletePdcInCartWithList:goodsList];
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

- (void)getDefaultAddress
{
//    [self.params removeAllObjects];
//    [super getParameters];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    parameters[@"status"] = @"0";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserAddrList"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                if (dataDict) {
                    if ([dataDict[@"usraddr_list"] isKindOfClass:[NSArray class]]) {
                        NSArray *addrlist = dataDict[@"usraddr_list"];
                        if (addrlist.count>0) {
//                            if (checkBtn!=nil) {
//                                checkBtn.enabled = YES;
//                                checkBtn.backgroundColor = [UIColor redColor];
//                            }
                            
                            NSDictionary *addrDict = addrlist[0];
                            YMAddress *defaultAddr = [[YMAddress alloc] init];
                            defaultAddr.addressId = addrDict[@"id"];
                            defaultAddr.delivery_name = addrDict[@"delivery_name"];
                            defaultAddr.contact_no = addrDict[@"contact_no"];
                            defaultAddr.delivery_addr = addrDict[@"delivery_addr"];
                            defaultAddr.status = addrDict[@"status"];
                            
                            YMCity *city = [YMCity objectWithKeyValues:addrDict];
                            defaultAddr.city = city;
                            
                            _defaultAddress = defaultAddr;
                            _addressView.address = defaultAddr;
                        }
                    }
                } else {
                    //没有地址
//                    if (checkBtn!=nil) {
//                        checkBtn.enabled = NO;
//                        checkBtn.backgroundColor = rgba(221, 221, 221, 1);
//                    }
                    _addressView.address = nil;
                }
            } else {
                //错误
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

@end
