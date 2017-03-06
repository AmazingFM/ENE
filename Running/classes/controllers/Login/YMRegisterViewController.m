//
//  YMRegisterViewController.m
//  Running
//
//  Created by freshment on 16/9/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMRegisterViewController.h"

#import "YMDataManager.h"

#import "YMCell.h"
#import "TTTAttributedLabel.h"

#define TimeInterval 60
#define kRegisterReadMeFont [UIFont systemFontOfSize:14]

@interface YMRegisterViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, YMBaseCellDelegate, TTTAttributedLabelDelegate>
{
    UITableView *_mainTableView;
    float rowHeight;
    NSArray *dataArr;
    
    UIButton *_verifyBtn;
    NSTimer *_timer;
    int interval;
    
    NSString *_verifyCode;
    BOOL _hasRead;
}
@end

@implementation YMRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"注册账号";
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
    _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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

    YMFieldCellItem *item5=[[YMFieldCellItem alloc] init];
    item5.title = @"推荐码";
    item5.key = kYM_REMARKCODE;
    item5.actionLen = 10;
    item5.fieldType = YMFieldTypeCharacterEn;
    
    
    NSArray *section2 = @[item5];
    
    YMBaseCellItem *item6=[[YMBaseCellItem alloc] init];
    item6.title = @"开始注册";
    item6.key = @"submit";
    NSArray *section3 = @[item6];

    YMBaseCellItem *item7=[[YMBaseCellItem alloc] init];
    item7.title = @"我已阅读并接受 版权声明 和 隐私保护 条款";
    item7.key = @"readme";
    
    NSArray *section4 = @[item7];
    
    dataArr = @[section1, section2, section3, section4];
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
    if (indexPath.section==3) {
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
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"btnidentifier"] ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIButton *btn = [cell viewWithTag:1100];
            if (btn==nil) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = 1100;
                btn.frame = CGRectMake(0,0,g_screenWidth-2*kYMBorderMargin,44);
                btn.backgroundColor = rgba(255, 204, 2, 1.0);//rgba(221, 221, 221, 1)-灰色
                [btn setTitle:item.title forState:UIControlStateNormal];
                btn.titleLabel.font = kYMBigFont;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setCornerRadius:5.0f];
                [cell.contentView addSubview:btn];
            }
            [btn setTitle:item.title forState:UIControlStateNormal];
        } else if ([item.key isEqualToString:@"readme"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:0.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"readmeidentifier"] ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.backgroundView = nil;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
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

            TTTAttributedLabel *detailLabel = [cell viewWithTag:1201];
            if (detailLabel==nil) {
                detailLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(30, 0, g_screenWidth-2*kYMBorderMargin-34, 44)];
                detailLabel.delegate = self;
                detailLabel.font = kRegisterReadMeFont;
                detailLabel.textAlignment = NSTextAlignmentLeft;
                detailLabel.textColor = rgba(128, 128, 128, 1.f);
                detailLabel.backgroundColor = [UIColor clearColor];
                detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
                detailLabel.numberOfLines = 0;
                
                [detailLabel setText:item.title afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString)
                 {
                     //注销划线
                     NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"版权声明" options:NSCaseInsensitiveSearch];
                     NSRange strikeRange = [[mutableAttributedString string] rangeOfString:@"隐私保护" options:NSCaseInsensitiveSearch];
                     // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
                     UIFont *boldSystemFont = [UIFont systemFontOfSize:14];
                     
                     CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
                     if (font) {
                         //字体
                         [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
                         [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:strikeRange];
                         //                     [mutableAttributedString addAttribute:kTTTStrikeOutAttributeName value:@YES range:strikeRange];
                         //下划线
                         [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]  range:boldRange];
                         [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]  range:strikeRange];
                         //颜色
                         [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:boldRange];
                         [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strikeRange];
                         CFRelease(font);
                     }
                     return mutableAttributedString;
                 }];

                [cell.contentView addSubview:detailLabel];
            }
            
            UIFont *boldSystemFont = [UIFont systemFontOfSize:14];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            //添加点击事件
            detailLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            detailLabel.delegate = self;
            detailLabel.linkAttributes = @{(NSString *)kCTFontAttributeName:(__bridge id)font,(id)kCTForegroundColorAttributeName:[UIColor blueColor]};//NSForegroundColorAttributeName  不能改变颜色 必须用   (id)kCTForegroundColorAttributeName,此段代码必须在前设置
            NSRange range1= [detailLabel.text rangeOfString:@"版权声明"];
            NSString* path = @"authority";//[[NSBundle mainBundle] pathForResource:@"软件许可及服务协议" ofType:@"html"];
            NSURL* url = [NSURL fileURLWithPath:path];
            [detailLabel addLinkToURL:url withRange:range1];
            
            NSRange range2= [detailLabel.text rangeOfString:@"隐私保护"];
            path = @"privacy";//[[NSBundle mainBundle] pathForResource:@"会员服务协议" ofType:@"html"];
            url = [NSURL fileURLWithPath:path];
            [detailLabel addLinkToURL:url withRange:range2];
        }
    }

    return cell;
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSString *title = nil;
    NSString *msgContent = @"基金定期定额申购(以下简称“基金定投”)是指投资者委托海通证券(以下简称“我公司”)，以约定时间、约定金额、约定基金按照基金公司业务规则定期定额申购相应基金，并从投资者客户交易结算资金账户中扣取相应申购款的一种长期投资方式。\n"
    "一、 基金定投业务办理时间\n"
    "基金定投签约、解约及变更业务办理时间为上海、深圳证券交易所交易日的9:30-15:00。\n"
    "二、 基金定投业务签约\n"
    "投资者通过营业部柜台方式申请办理基金定投业务的签约。投资者应确保在我公司资金账户中已成功开立开放式基金账户，并已完成《风险承受能力测评问卷》。\n\n"
    "三、 基金定投业务的要素\n"
    "1、 定投的基金产品\n"
    "投资者申请的定投基金品种仅限于已公告我公司可开通基金定投业务的基金产品。\n"
    "2、 最低金额\n"
    "投资者选择的基金定投扣款金额应大于或等于基金定投产品日最低金额。若我公司对基金产品最低定投金额有明确规定的，以我公司为准；若我公司无明确规定的，以基金公司为准。\n"
    "3、 基金定投周期\n"
    "投资者可以选择按三个月、二个月和一个月进行基金定投。\n";
    
    
    NSString *hrefStr = url.absoluteString;
    if ([hrefStr rangeOfString:@"authority"].location!=NSNotFound) {
        title = @"版权声明";
    } else if ([hrefStr rangeOfString:@"privacy"].location!=NSNotFound) {
        title = @"隐私保护";
    }
    showDefaultAlert(title, msgContent);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
         UIButton *checkBtn = [cell viewWithTag:1200];
        if (checkBtn!=nil) {
            checkBtn.selected = !checkBtn.isSelected;
            _hasRead = checkBtn.isSelected;
        }
    }
}

- (void)btnClick:(UIButton *)sender
{
    //
    if (sender.tag==1100) { //submit
        //
        [self startRegister];
        
    } else if (sender.tag==1200) {
        //
        [sender setSelected:!sender.isSelected];
        _hasRead = sender.isSelected;
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
    NSArray *arr = dataArr[indexPath.section];
    YMFieldCellItem *item = arr[indexPath.row];
    item.fieldText = fieldText;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

#pragma mark 网络请求

//- (BOOL)getParameters
//{
////    [super getParameters];
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    
//    NSMutableDictionary *keyValueDict = [NSMutableDictionary new];
//    for (NSArray *arr in dataArr) {
//        for (YMBaseCellItem *item in arr) {
//            keyValueDict[item.key] = (NSString *)item.value;
//        }
//    }
//    
//    NSString *userName = keyValueDict[kYM_USERNAME];
//    NSString *userPass = keyValueDict[kYM_PASSWORD];
//    NSString *userPassConfirm = keyValueDict[@"codeconfirm"];
//    NSString *remarkCode = keyValueDict[kYM_REMARKCODE];
//    NSString *verifyCode = keyValueDict[@"verifycode"];
//    
//    if (!_hasRead) {
//        showAlert(@"请阅读并接受相关服务条款");
//        return NO;
//    }
//    if (userName.length==0 ||
//        userPass.length==0 ||
//        remarkCode.length==0) {
//        showAlert(@"用户名、密码、推荐码不能为空");
//        return NO;
//    }
//    
//    if (![userPass isEqualToString:userPassConfirm]) {
//        showAlert(@"密码不一致");
//        return NO;
//    }
//    
//    if (![verifyCode isEqualToString:_verifyCode]) {
//        showAlert(@"验证码不正确，请重新获取");
//        return NO;
//    }
//    
//    parameters[kYM_USERNAME] = userName;
//    parameters[kYM_PASSWORD] = [YMUtil md5HexDigest:userPass];//123456
//    parameters[kYM_REMARKCODE] = remarkCode;
//    
//    return YES;
//}

- (void)startRegister
{
    
    //    [g_appDelegate setRootViewControllerWithMain];
    //    return;
    //http://139.196.237.165/ene/AppServ/index.php?a=UserLogin&app_id=1&req_seq=2&time_stamp=20160907110800&sign=47839274&user_name=13777777777&user_pass=8765&remark_code=9999
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    NSMutableDictionary *keyValueDict = [NSMutableDictionary new];
    for (NSArray *arr in dataArr) {
        for (YMBaseCellItem *item in arr) {
            keyValueDict[item.key] = (NSString *)item.value;
        }
    }
    
    NSString *userName = keyValueDict[kYM_USERNAME];
    NSString *userPass = keyValueDict[kYM_PASSWORD];
    NSString *userPassConfirm = keyValueDict[@"codeconfirm"];
    NSString *remarkCode = keyValueDict[kYM_REMARKCODE];
    NSString *verifyCode = keyValueDict[@"verifycode"];
    
    if (!_hasRead) {
        showAlert(@"请阅读并接受相关服务条款");
        return ;
    }
    if (userName.length==0 ||
        userPass.length==0 ||
        remarkCode.length==0) {
        showAlert(@"用户名、密码、推荐码不能为空");
        return ;
    }
    
    if (![userPass isEqualToString:userPassConfirm]) {
        showAlert(@"密码不一致");
        return ;
    }
    
    if (![verifyCode isEqualToString:_verifyCode]) {
        showAlert(@"验证码不正确，请重新获取");
        return ;
    }
    
    parameters[kYM_USERNAME] = userName;
    parameters[kYM_PASSWORD] = [YMUtil md5HexDigest:userPass];//123456
    parameters[kYM_REMARKCODE] = remarkCode;
    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=Register"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            
//            __weak NSDictionary *params = self.params;
            
            if ([resp_id integerValue]==0) {
//                [g_appDelegate backgroundLogin:@[params[kYM_USERNAME], params[kYM_PASSWORD], params[kYM_REMARKCODE]]];
                
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
    for (NSArray *arr in dataArr) {
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
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
//    NSString *uuid = [YMDataManager shared].uuid;
//    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
//    [YMDataManager shared].reqSeq++;
//    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
//    
//    paramDict[kYM_APPID] = uuid;
//    paramDict[kYM_REQSEQ] = reqSeq;
//    paramDict[kYM_TIMESTAMP] = currentDate;
    parameters[@"mobile"] = userName;
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=SmsSend"] parameters:parameters success:^(id responseObject) {
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
