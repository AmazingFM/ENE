//
//  YMAddressViewController.m
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMAddressViewController.h"
#import "YMNewAddressViewController.h"

#import "YMAddressCell.h"
#import "YMUserManager.h"
#import "YMCellItems.h"

#define kYMSectionHeaderHeight 10.f
#define kYMAddressTableDefaultRowHeight 80.f
#define kYMOrderTableGoodsRowHeight 100.f

@interface YMAddressViewController () <UITableViewDelegate, UITableViewDataSource, YMAddressCellDelegate, UIAlertViewDelegate>
{
    UITableView* _tableView;
    
    UIImageView *_noItemImg;
    UILabel *_noItemDesc;
    
    UIButton *_addAddressBtn;
    
    UIActivityIndicatorView* indicator;
    
    YMAddressItem *_currentItem;
    
    YMAddressAction actionType;
}

@property (nonatomic, retain) NSMutableArray<YMAddressItem *> *addrList;

@end

@implementation YMAddressViewController

- (NSMutableArray<YMAddressItem *> *)addrList
{
    if (_addrList==nil) {
        _addrList = [NSMutableArray<YMAddressItem *> new];
    }
    return _addrList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的地址";
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));

    self.view.backgroundColor = rgba(238, 238, 238, 1);
    
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,kYMTopBarHeight,g_screenWidth, g_screenHeight-kYMTopBarHeight-kYMNavigationBarHeight) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=[UIColor clearColor];

    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CGFLOAT_MIN)];
    _tableView.tableHeaderView = headview;
    
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
    
    _noItemDesc = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, 50)];
    _noItemDesc.center = self.view.center;
    _noItemDesc.text = @"暂无地址，赶紧添加一个吧";
    _noItemDesc.textAlignment = NSTextAlignmentCenter;
    _noItemDesc.textColor = rgba(183, 183, 183, 1);
    _noItemDesc.font = kYMBigFont;
    
    _noItemImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_order"]];
    _noItemImg.frame = CGRectMake(0, 0, g_screenWidth/4, g_screenWidth/4);
    _noItemImg.center = CGPointMake(_noItemDesc.centerX, _noItemDesc.centerY-50);
    _noItemImg.hidden = YES;
    _noItemDesc.hidden = YES;
    
    UIView *btnBack = [[UIView alloc] initWithFrame:CGRectMake(0, g_screenHeight-kYMNavigationBarHeight, g_screenWidth, kYMNavigationBarHeight)];
    btnBack.backgroundColor = [UIColor whiteColor];
    
    _addAddressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addAddressBtn.frame = CGRectMake(0,0,g_screenWidth-2*40,34);
    _addAddressBtn.backgroundColor = [YMUtil colorWithHex:0xffcc02];
    [_addAddressBtn setTitle:@"+ 新增收货地址" forState:UIControlStateNormal];
    [_addAddressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _addAddressBtn.titleLabel.font = kYMBigFont;
    [_addAddressBtn addTarget:self action:@selector(addAdress) forControlEvents:UIControlEventTouchUpInside];
    [_addAddressBtn setCornerRadius:5.0f];
    _addAddressBtn.center = CGPointMake(g_screenWidth/2, kYMNavigationBarHeight/2);
    
    [btnBack addSubview:_addAddressBtn];
    
    [self.view addSubview:_noItemDesc];
    [self.view addSubview:_noItemImg];
    
    [self.view addSubview:_tableView];
    [self.view addSubview:btnBack];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.addrList removeAllObjects];
    [self getAddrList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.addrList[indexPath.section].size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return kYMSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, g_screenWidth, kYMSectionHeaderHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.addrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellId";
    
    YMAddressItem *addItem = self.addrList[indexPath.section];
    addItem.indexPath = indexPath;
    
    YMAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[YMAddressCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    cell.addressItem = addItem;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMAddressItem *addItem = self.addrList[indexPath.section];
    if ([self.delegate respondsToSelector:@selector(didSelectAddress:)]) {
        [self.delegate didSelectAddress:addItem.address];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addAdress
{
    YMNewAddressViewController *newAddressVC = [[YMNewAddressViewController alloc] init];
    [self.navigationController pushViewController:newAddressVC animated:YES];
}

- (void)modifyAddress:(YMAddressItem *)addressItem withType:(YMAddressAction)type
{
    _currentItem = addressItem;
    actionType = type;
    switch (type) {
        case YMAddressActionDefault:
        {
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
            
            YMAddress *address = addressItem.address;
            parameters[@"usraddr_id"] = address.addressId;
            parameters[@"delivery_name"] = address.delivery_name;
            parameters[@"delivery_addr"] = address.delivery_addr;
            parameters[@"contact_no"] = address.contact_no;
            parameters[@"status"] = @"0";//设置为默认
            
            YMCity *city = address.city;
            [parameters addEntriesFromDictionary:[city keyValues]];
            
            [self startModifyAddress:parameters];
        }
            break;
        case YMAddressActionEdit:
        {
            YMNewAddressViewController *newAddressVC = [[YMNewAddressViewController alloc] init];
            newAddressVC.userAddr = _currentItem.address;
            [self.navigationController pushViewController:newAddressVC animated:YES];

        }
            break;
        case YMAddressActionDelete:
        {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"你准备删除该地址？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        //删除地址
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
        
        YMAddress *address = _currentItem.address;
        parameters[@"usraddr_id"] = address.addressId;
        parameters[@"delivery_name"] = address.delivery_name;
        parameters[@"delivery_addr"] = address.delivery_addr;
        parameters[@"contact_no"] = address.contact_no;
        parameters[@"status"] = @"2";//删除地址
        
        YMCity *city = address.city;
        [parameters addEntriesFromDictionary:[city keyValues]];
        
        [self startModifyAddress:parameters];
    }
}

#pragma mark 网络请求
//- (BOOL)getParameters
//{
////    [super getParameters];
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    
//    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
//    return YES;
//}

- (void)startModifyAddress:(NSDictionary *)parameters
{
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserAddrModify"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                if (actionType == YMAddressActionDelete) {
                    //删除
                    [self.addrList removeObject:_currentItem];
                    
                    if (self.addrList.count==0) {
                        _noItemImg.hidden = NO;
                        _noItemDesc.hidden = NO;
                        _tableView.hidden = YES;
                    } else {
                        _noItemImg.hidden = YES;
                        _noItemDesc.hidden = YES;
                        _tableView.hidden = NO;
                        [_tableView reloadData];
                    }
                } else if (actionType == YMAddressActionDefault) {
                    //设置默认
                    for (YMAddressItem *item in self.addrList) {
                        if (item==_currentItem) {
                            item.address.status=@"0";
                        } else {
                            item.address.status=@"1";
                        }
                    }
                    [_tableView reloadData];
                }
            } else {
                //错误
                showDefaultAlert(resp_id, respDict[kYM_RESPDESC]);
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

- (void)getAddrList
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;

    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserAddrList"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                
                if (dataDict) {
                    if ([dataDict[@"usraddr_list"] isKindOfClass:[NSArray class]]) {
                        NSArray *addrlist = dataDict[@"usraddr_list"];
                        if ([addrlist count]==0) {
                            _noItemImg.hidden = NO;
                            _noItemDesc.hidden = NO;
                            _tableView.hidden = YES;
                        } else {
                            for (NSDictionary *addDict in dataDict[@"usraddr_list"]) {
                                YMAddress *address = [[YMAddress alloc] init];
                                address.addressId = addDict[@"id"];
                                address.delivery_name = addDict[@"delivery_name"];
                                address.contact_no = addDict[@"contact_no"];
                                address.delivery_addr = addDict[@"delivery_addr"];
                                address.status = addDict[@"status"];
                                
                                YMCity *city = [YMCity objectWithKeyValues:addDict];
                                address.city = city;
                                
                                YMAddressItem *addItem = [[YMAddressItem alloc] init];
                                addItem.address = address;
                                [self.addrList addObject:addItem];
                                _noItemImg.hidden = YES;
                                _noItemDesc.hidden = YES;
                                _tableView.hidden = NO;
                            }
                            [_tableView reloadData];
                        }
                    }
                    else {
                        _noItemImg.hidden = NO;
                        _noItemDesc.hidden = NO;
                        _tableView.hidden = YES;
                    }
                } else {
                    _noItemImg.hidden = NO;
                    _noItemDesc.hidden = NO;
                    _tableView.hidden = YES;
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
