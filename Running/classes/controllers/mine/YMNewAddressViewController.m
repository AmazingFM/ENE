//
//  YMNewAddressViewController.m
//  Running
//
//  Created by freshment on 16/9/29.
//  Copyright © 2016年 ming. All rights reserved.
//
#import "YMBaseNavigationController.h"
#import "YMNewAddressViewController.h"
#import "YMCitySelectViewController.h"

#import "YMCell.h"
#import "YMUserManager.h"
#import "YMCity.h"


#define kRegisterReadMeFont [UIFont systemFontOfSize:14]


@interface YMNewAddressViewController () <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, YMBaseCellDelegate, YMCitySelectDelegate>
{
    UITableView *_mainTableView;
    float rowHeight;
    NSArray *dataArr;
    NSArray *itemlist;
    
    UIButton *_verifyBtn;
    BOOL _isDefault;
    
    UIActivityIndicatorView *indicator;
    
    YMCity *_city;
}
@end

@implementation YMNewAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _isDefault = YES;
    if (self.userAddr==nil) {
        self.navigationItem.title = @"新增地址";
    } else {
        self.navigationItem.title = @"编辑地址";
    }
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    self.view.backgroundColor = rgba(247, 247, 247, 1.0);
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:indicator];
    
    rowHeight = 44.f;
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(kYMBorderMargin, kYMTopBarHeight, g_screenWidth-2*kYMBorderMargin, g_screenHeight-kYMTopBarHeight) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _mainTableView.separatorColor = [UIColor lightGrayColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.scrollEnabled = NO;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    
    _mainTableView.tableFooterView = [[UIView alloc] init];
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:_mainTableView];
    
    YMFieldCellItem *item1=[[YMFieldCellItem alloc] init];
    item1.title = @"姓名";
    item1.key = @"delivery_name";
    item1.actionLen = 20;
    item1.fieldType = YMFieldTypeCharater;
    item1.value = self.userAddr?self.userAddr.delivery_name:@"";
    
    YMFieldCellItem *item2=[[YMFieldCellItem alloc] init];
    item2.title = @"电话";
    item2.key = @"contact_no";
    item2.actionLen = 11;
    item2.fieldType = YMFieldTypeNumber;
    item2.value = self.userAddr?self.userAddr.contact_no:@"";
    
    YMBaseCellItem *item3=[[YMBaseCellItem alloc] init];
    item3.title = @"省市区";
    item3.key = @"cityArea";
    item3.value = @"";
    
    _city = self.userAddr.city;
    item3.value = _city?[NSString stringWithFormat:@"%@ %@ %@", _city.province, _city.city,_city.town]:@"";
    
    YMFieldCellItem *item4=[[YMFieldCellItem alloc] init];
    item4.title = @"详细地址";
    item4.key = @"delivery_addr";
    item4.actionLen = 50;
    item4.fieldType = YMFieldTypeCharater;
    item4.value = self.userAddr?self.userAddr.delivery_addr:@"";
    
    NSArray *section1 = @[item1, item2, item3, item4];
    
    YMBaseCellItem *item5=[[YMBaseCellItem alloc] init];
    item5.title = @"提交";
    item5.key = @"submit";
    NSArray *section2 = @[item5];
    
    YMBaseCellItem *item6=[[YMBaseCellItem alloc] init];
    item6.title = @"设为默认地址";
    item6.key = @"status";
    item6.value = self.userAddr?self.userAddr.status:@"0";
    
    NSArray *section3 = @[item6];
    
    dataArr = @[section1, section2, section3];
    itemlist = @[item1, item2, item3, item4, item5, item6];
}

- (void)viewWillAppear
{
    [self viewWillAppear];
}

#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==2) {
        if([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,cell.bounds.size.width)];
        }
        if([cell respondsToSelector:@selector(setLayoutMargins:)]){
            [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,cell.bounds.size.width)];
        }
        return;
    }
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = dataArr[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = dataArr[indexPath.section];
    YMBaseCellItem *item = arr[indexPath.row];
    item.indexPath = indexPath;
    
    YMRoundCornerCell *cell;
    if ([item isKindOfClass:[YMFieldCellItem class]]) {
        cell = [YMRCFieldCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"defaultCellId"] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = kYMNormalFont;
        
        cell.textLabel.text = item.title;
        [cell setItem:item];
        
    }
    else {
        if ([item.key isEqualToString:@"submit"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:1.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"btnidentifier"] ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIButton *btn = [cell viewWithTag:1100];
            if (btn==nil) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = 1100;
                btn.frame = CGRectMake(0,0,g_screenWidth-2*kYMBorderMargin,44);
                btn.backgroundColor = [YMUtil colorWithHex:0xffcc02];
                [btn setTitle:item.title forState:UIControlStateNormal];
                btn.titleLabel.font = kYMBigFont;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setCornerRadius:5.0f];
                [cell.contentView addSubview:btn];
            }
            [btn setTitle:item.title forState:UIControlStateNormal];
        } else if ([item.key isEqualToString:@"status"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:0.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"statusidentifier"] ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundView = nil;
            cell.backgroundColor = [UIColor clearColor];
            
            UIButton *checkBtn = [cell viewWithTag:1200];
            if (checkBtn==nil) {
                checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                checkBtn.tag = 1200;
                checkBtn.frame = CGRectMake(5,12,20,20);
                [checkBtn setContentMode:UIViewContentModeScaleAspectFit];
                [checkBtn setImage:[UIImage imageNamed:@"icon_box_nonselect.png"] forState:UIControlStateNormal];
                [checkBtn setImage:[UIImage imageNamed:@"icon_box_select.png"] forState:UIControlStateSelected];
                
                [checkBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:checkBtn];
            }
            
            if ([item.value intValue]==0) {
                checkBtn.selected = YES;
                _isDefault = YES;
            } else {
                checkBtn.selected = NO;
                _isDefault = NO;
            }
            
            UILabel *detailLabel = [cell viewWithTag:1201];
            if (detailLabel==nil) {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, g_screenWidth-2*kYMBorderMargin-34, 44)];
                detailLabel.tag = 1201;
                detailLabel.font = kRegisterReadMeFont;
                detailLabel.textAlignment = NSTextAlignmentLeft;
                detailLabel.textColor = rgba(128, 128, 128, 1.f);
                detailLabel.backgroundColor = [UIColor clearColor];
                detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
                detailLabel.numberOfLines = 0;
                
                [cell.contentView addSubview:detailLabel];
            }
            detailLabel.text = item.title;
        } else if ([item.key isEqualToString:@"cityArea"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:0.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"statusidentifier"] ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.font = kYMNormalFont;
            cell.textLabel.text = item.title;

            UILabel *detailLabel = [cell viewWithTag:1201];
            if (detailLabel==nil) {
                CGSize size = [YMUtil sizeWithFont:@"确认密码" withFont:kYMNormalFont];
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width+30, 0, g_screenWidth-2*kYMBorderMargin-30-size.width-kYMBorderMargin, 44)];
                detailLabel.tag = 1201;
                detailLabel.font = kRegisterReadMeFont;
                detailLabel.textAlignment = NSTextAlignmentLeft;
                detailLabel.textColor = rgba(128, 128, 128, 1.f);
                detailLabel.backgroundColor = [UIColor clearColor];
                detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
                detailLabel.numberOfLines = 0;
                
                [cell.contentView addSubview:detailLabel];
            }
            
            NSString *strUrl = [item.value stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (strUrl.length==0) {
                detailLabel.text = @"请选择省市区";
            } else
            {
                detailLabel.text = item.value;
            }
           
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *checkBtn = [cell viewWithTag:1200];
        if (checkBtn!=nil) {
            checkBtn.selected = !checkBtn.isSelected;
            _isDefault = checkBtn.isSelected;
        }
    } else if (indexPath.section==0 && indexPath.row==2) {
        //选择城市页面
        YMCitySelectViewController *citySelectVC = [[YMCitySelectViewController alloc] init];
        citySelectVC.delegate = self;
        YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:citySelectVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)btnClick:(UIButton *)sender
{
    //
    if (sender.tag==1100) { //submit
        //
        if (self.userAddr==nil) {
            [self startAddUserAddr];
        } else {
            [self startModifyAddress];
        }
    } else if (sender.tag==1200) {
        //
        [sender setSelected:!sender.isSelected];
        _isDefault = sender.isSelected;
    } else if (sender.tag==1000) {
        //
        
    }
}

-(void)viewValueChanged:(NSString *)fieldText withIndexPath:(NSIndexPath*)indexPath
{
    NSArray *arr = dataArr[indexPath.section];
    YMFieldCellItem *item = arr[indexPath.row];
    item.fieldText = fieldText;
}

#pragma mark 城市选择delegate
- (void)didSelectCity:(YMCity *)city
{
    _city = city;
    YMBaseCellItem *cellItem = itemlist[2];
    cellItem.value = [NSString stringWithFormat:@"%@ %@ %@", _city.province, _city.city, _city.town];
    
    [_mainTableView reloadRowsAtIndexPaths:@[cellItem.indexPath] withRowAnimation:UITableViewRowAnimationNone];

}

#pragma mark 网络请求
//- (BOOL)getParameters
//{
//    [super getParameters];
//    self.params[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
//    return YES;
//}

- (void)startAddUserAddr
{
//    [self getParameters];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    
    for (YMBaseCellItem *cellItem in itemlist) {
        if ([cellItem.key isEqualToString:@"delivery_name"] ||
            [cellItem.key isEqualToString:@"contact_no"] ||
            [cellItem.key isEqualToString:@"delivery_addr"]) {
            
            if (cellItem.value.length==0) {
                showDefaultAlert(@"提示", [NSString stringWithFormat:@"请输入%@", cellItem.title]);
                return;
            } else {
                parameters[cellItem.key] = cellItem.value;
            }
        } else if ([cellItem.key isEqualToString:@"cityArea"]) {
            NSString *strUrl = [cellItem.value stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (strUrl.length==0) {
                showDefaultAlert(@"提示", [NSString stringWithFormat:@"请选择%@", cellItem.title]);
                return;
            }
        }
    }
    
    parameters[@"status"] = [NSString stringWithFormat:@"%d", !_isDefault];
    
    
    NSDictionary *cityDict = [_city keyValues];
    [parameters addEntriesFromDictionary:cityDict];
    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    [indicator startAnimating];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserAddrAdd"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                [self showTextHUDView:respDict[kYM_RESPDESC]];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
    }];
}

- (void)startModifyAddress
{
//    [self getParameters];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    
    for (YMBaseCellItem *cellItem in itemlist) {
        if ([cellItem.key isEqualToString:@"delivery_name"] ||
            [cellItem.key isEqualToString:@"contact_no"] ||
            [cellItem.key isEqualToString:@"delivery_addr"]) {
            
            if (cellItem.value.length==0) {
                showDefaultAlert(@"提示", [NSString stringWithFormat:@"请输入%@", cellItem.title]);
                return;
            } else {
                parameters[cellItem.key] = cellItem.value;
            }
        } else if ([cellItem.key isEqualToString:@"cityArea"]) {
            NSString *strUrl = [cellItem.value stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (strUrl.length==0) {
                showDefaultAlert(@"提示", [NSString stringWithFormat:@"请选择%@", cellItem.title]);
                return;
            }
        }
    }
    
    parameters[@"status"] = [NSString stringWithFormat:@"%d", !_isDefault];

    if (self.userAddr!=nil) {
        parameters[@"usraddr_id"] = self.userAddr.addressId;
    }
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserAddrModify"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                [self showTextHUDView:respDict[kYM_RESPDESC]];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                //错误
                showDefaultAlert(resp_id, respDict[kYM_RESPDESC]);
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

@end
