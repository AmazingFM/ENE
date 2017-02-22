//
//  YMCallPasswordViewController.m
//  Running
//
//  Created by freshment on 16/9/26.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCallPasswordViewController.h"
#import "YMDataManager.h"

#import "YMCell.h"

#define TimeInterval 60

@interface YMCallPasswordViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, YMBaseCellDelegate>
{
    UITableView *_mainTableView;
    float rowHeight;
    
    UIButton *_verifyBtn;
    NSTimer *_timer;
    int interval;
    
    NSString *_verifyCode;
}

@end

@implementation YMCallPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"找回密码";
    self.view.backgroundColor = rgba(247, 247, 247, 1.0);
    
    rowHeight = 44.f;
    _verifyCode = @"526108";
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(kYMBorderMargin, 0, g_screenWidth-2*kYMBorderMargin, g_screenHeight-kYMNavigationBarHeight) style:UITableViewStylePlain];
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
    item1.title = @"手机号";
    item1.key = kYM_USERNAME;
    item1.actionLen = 11;
    item1.fieldType = YMFieldTypeNumber;
    
    YMFieldCellItem *item2=[[YMFieldCellItem alloc] init];
    item2.title = @"验证码";
    item2.key = @"verifycode";
    item2.actionLen = 6;
    item2.fieldType = YMFieldTypeNumber;
    
    YMFieldCellItem *item3=[[YMFieldCellItem alloc] init];
    item3.title = @"密码";
    item3.key = kYM_PASSWORD;
    item3.secureTextEntry = YES;
    item3.actionLen = 8;
    item3.fieldType = YMFieldTypePassword;
    
    YMFieldCellItem *item4=[[YMFieldCellItem alloc] init];
    item4.title = @"密码确认";
    item4.key = @"codeconfirm";
    item4.secureTextEntry = YES;
    item4.actionLen = 8;
    item4.fieldType = YMFieldTypePassword;
    
    NSArray *section1 = @[item1, item2, item3, item4];
    
    YMBaseCellItem *item6=[[YMBaseCellItem alloc] init];
    item6.title = @"重置密码";
    item6.key = @"submit";
    NSArray *section3 = @[item6];
    
    [self.dataArr addObjectsFromArray:@[section1, section3]];
}

- (NSMutableArray *)dataArr
{
    if (_dataArr==nil) {
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
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
    if (indexPath.section==1) {
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
    NSArray *arr = self.dataArr[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataArr[indexPath.section];
    YMBaseCellItem *item = arr[indexPath.row];
    item.indexPath = indexPath;
    
    YMRoundCornerCell *cell;
    if ([item isKindOfClass:[YMFieldCellItem class]]) {
        cell = [YMRCFieldCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"defaultCellId"] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = kYMNormalFont;
        
        cell.textLabel.text = item.title;
        [cell setItem:item];
        
        
        
        if ([item.key isEqualToString:@"verifycode"]) {
            _verifyBtn = [cell viewWithTag:1000];
            if (_verifyBtn==nil) {
                _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _verifyBtn.tag=1000;
                _verifyBtn.backgroundColor = rgba(255, 204, 2, 1.0);
                [_verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                CGSize size = [YMUtil sizeWithFont:@"获取验证码" withFont:kYMNormalFont];
                _verifyBtn.frame = CGRectMake(0,5,size.width+10,34);
                _verifyBtn.titleLabel.font = kYMNormalFont;
                [_verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_verifyBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_verifyBtn setCornerRadius:5.0f];
                cell.accessoryView=_verifyBtn;
            }
        }
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
                
                if (item.backColor==nil) {
                    btn.backgroundColor = rgba(221, 221, 221, 1);
                } else {
                    btn.backgroundColor = item.backColor;
                }
                
                [btn setTitle:item.title forState:UIControlStateNormal];
                btn.titleLabel.font = kYMBigFont;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setCornerRadius:5.0f];
                [cell.contentView addSubview:btn];
            }
            [btn setTitle:item.title forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

- (void)btnClick:(UIButton *)sender
{
    //
    if (sender.tag==1100) { //submit
        //
        [self callPassword];
        
    } else if (sender.tag==1000) {
        //
        [self sendSMS];
    }
}

-(void)refreshBtn
{
    interval--;
    if (interval<=0) {
        [self stopTimer];
        return;
    }
    [_verifyBtn setTitle:[NSString stringWithFormat:@"%ds后重发", interval] forState:UIControlStateNormal];
    
}

-(void)startTimer
{
    _timer= [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshBtn) userInfo:nil repeats:YES];
    [_verifyBtn setEnabled:NO];
}
-(void)stopTimer
{
    if(_timer==nil) return;
    
    [_timer invalidate];
    _timer = nil;
    [_verifyBtn setTitle:@"再次发送" forState:UIControlStateNormal];
    _verifyBtn.enabled = YES;
}

-(void)viewValueChanged:(NSString *)fieldText withIndexPath:(NSIndexPath*)indexPath
{
    NSArray *arr = self.dataArr[indexPath.section];
    YMFieldCellItem *item = arr[indexPath.row];
    item.fieldText = fieldText;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

#pragma mark 网络请求

- (BOOL)getParameters
{
    [super getParameters];
    
    NSMutableDictionary *keyValueDict = [NSMutableDictionary new];
    for (NSArray *arr in self.dataArr) {
        for (YMBaseCellItem *item in arr) {
            keyValueDict[item.key] = (NSString *)item.value;
        }
    }
    
    NSString *userName = keyValueDict[kYM_USERNAME];
    NSString *userPass = keyValueDict[kYM_PASSWORD];
    NSString *userPassConfirm = keyValueDict[@"codeconfirm"];
    NSString *verifyCode = keyValueDict[@"verifycode"];

    if (userName.length==0 || userPass.length==0 ) {
        showAlert(@"用户名、密码不能为空");
        return NO;
    }
    
    if (![userPass isEqualToString:userPassConfirm]) {
        showAlert(@"密码不一致");
        return NO;
    }
    
    if (![verifyCode isEqualToString:_verifyCode]) {
        showAlert(@"验证码不正确，请重新获取");
        return NO;
    }

    
    self.params[kYM_USERNAME] = userName;
    self.params[@"new_pass"] = [YMUtil md5HexDigest:userPass];
    
    return YES;
}

- (void)callPassword
{
    if (![self getParameters]) {
        return;
    }
    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserPassReset"] parameters:self.params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                [self showTextHUDView:@"重置密码成功，请登录"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    }];
}

-(void)sendSMS
{
    NSMutableDictionary *keyValueDict = [NSMutableDictionary new];
    for (NSArray *arr in self.dataArr) {
        for (YMBaseCellItem *item in arr) {
            keyValueDict[item.key] = (NSString *)item.value;
        }
    }
    NSString *userName = keyValueDict[kYM_USERNAME];
    
    interval = TimeInterval;
    if (userName.length!=11) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请输入手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    NSString *uuid = [YMDataManager shared].uuid;
    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    [YMDataManager shared].reqSeq++;
    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
    
    paramDict[kYM_APPID] = uuid;
    paramDict[kYM_REQSEQ] = reqSeq;
    paramDict[kYM_TIMESTAMP] = currentDate;
    paramDict[@"mobile"] = userName;
    paramDict[@"send_type"] = @"1";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=SmsSend"] parameters:paramDict success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                _verifyCode = dataDict[@"verify_code"];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        showDefaultAlert(@"提示", @"发送失败");
    }];
    
    
    [self startTimer];
}

@end