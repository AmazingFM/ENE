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
    item7.title = @"我已阅读并接受 版权声明和隐私保护 条款";
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
                     NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"版权声明和" options:NSCaseInsensitiveSearch];
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
//            NSRange range1= [detailLabel.text rangeOfString:@"版权声明"];
            NSRange range1= [detailLabel.text rangeOfString:@"版权声明和隐私保护"];
            NSString* path = @"authority";//[[NSBundle mainBundle] pathForResource:@"软件许可及服务协议" ofType:@"html"];
            NSURL* url = [NSURL fileURLWithPath:path];
            [detailLabel addLinkToURL:url withRange:range1];
            
//            NSRange range2= [detailLabel.text rangeOfString:@"隐私保护"];
//            path = @"privacy";//[[NSBundle mainBundle] pathForResource:@"会员服务协议" ofType:@"html"];
//            url = [NSURL fileURLWithPath:path];
//            [detailLabel addLinkToURL:url withRange:range2];
        }
    }

    return cell;
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSString *title = nil;
    NSString *msgContent = @"重要须知：上海铂登实业有限公司电商平台“长生汇”一贯重视用户的个人信息及隐私的保护，在您使用长生汇的服务和/或在长生汇购物的时候，长生汇有可能会收集和使用您的个人信息及隐私。为此，长生汇通过本《长生汇用户个人信息及隐私保护政策》（以下简称“本《隐私政策》”）向您说明您在使用长生汇的服务和/或在长生汇购物时，长生汇是如何收集、存储、使用和分享这些信息的，以及长生汇向您提供的访问、更新、控制和保护这些信息的方式。\n"
    "本《隐私政策》与您使用长生汇的服务、在长生汇购物息息相关，请您务必仔细阅读、充分理解（未成年人应当在其监护人的陪同下阅读），包括但不限于免除或者限制长生汇责任的条款。\n"
    "您如果使用或者继续使用长生汇的服务和/或在长生汇购物，即视为您充分理解并完全接受本《隐私政策》；您如果对本《隐私政策》有任何疑问、异议或者不能完全接受本《隐私政策》，请联系长生汇客户服务部，客户服务电话：021-23560070。\n"
    "第一条    本《隐私政策》所述的个人信息，是指个人姓名、住址、出生日期、身份证号码、银行账号、移动电话号码等单独或与其他信息对照可以设别特定的个人的信息，包括但不限于您在注册长生汇用户账号时填写并提供给长生汇的姓名、性别、生日、移动电话号码、送货地址、身高、体重。\n"
    "第二条    您承诺并保证：您主动填写或者提供给长生汇的个人信息是真实的、准确的、完整的。而且，填写或者提供给长生汇后，如果发生了变更的，您会在第一时间内，通过原有的渠道或者长生汇提供的新的渠道进行更新，以确保长生汇所获得的您的这些个人信息是最新的、真实的、准确的和完整的；否则，长生汇无须承担由此给您造成的任何损失。\n"
    "第三条    您应当重视您的个人信息的保护，您如果发现您的个人信息已经被泄露或者存在被泄露的可能，且有可能会危及您注册获得的长生汇账户安全，或者给您造成其他的损失的，您务必在第一时间通知长生汇，以便长生汇采取相应的措施确保您的长生汇账户安全，防止损失的发生或者进一步扩大；否则，长生汇无须承担由此给您造成的任何损失（及扩大的损失）。\n"
    "第四条    您充分理解并完全接受：您在使用长生汇的服务和/或在长生汇购物时，长生汇有可能会收集您的如下信息（以下统称“用户信息”）：\n"
    "（一） 第一条所述的您的个人信息；\n"
    "（二） 您提供给第三方或者向第三方披露的个人信息及隐私；\n"
    "（三） 您登录和使用长生汇网站、App的时间、时长、支付账号、购物记录、系统日志信息以及行为数据（包括但不限于订单下达及取消数据、退货退款申请数据、手机钱包账户余额、交易纠纷数据等）；\n"
    "（四） 您所使用的台式计算机、移动设备的品牌、型号、IP地址以及软件版本信息\n"
    "（五） 为了实现前述目的，通过cookie或者其他方式自动采集到的您的其他个人信息或者隐私。\n"
    "您通过具有定位功能的移动设备登录、使用长生汇的App时，长生汇有可能会通过GPS或者Wifi收集您的地理位置信息；您如果不同意收集，您在您的移动设备上关闭此项功能。\n"
    "第五条    您充分理解并完全接受：保护用户信息是长生汇一贯的政策，长生汇将会使用各种安全技术和程序存储、保护用户信息，防止其被未经授权的访问、使用、复制和泄露。长生汇不向任何第三方透漏用户信息，但存在下列任何一项情形或者为第七条所述的目的而披露给第三方的除外：\n"
    "（一） 基于国家法律法规的规定而对外披露；\n"
    "（二） 应国家司法机关及其他有法律权限的政府机关基于法定程序的要求而披露；\n"
    "（三） 为保护长生汇或您的合法权益而披露；\n"
    "（四） 在紧急情况下，为保护其他用户或者第三方人身安全而披露；\n"
    "（五） 用户本人或其监护人授权披露；\n"
    "（六） 应用户的监护人的合法要求而向其披露。\n"
    "长生汇即便是按照前款约定将用户信息披露给第三方，亦会要求接收上述用户信息的第三方严格按照国家法律法规使用和保护用户信息。\n"
    "第六条    您充分理解并完全接受：即便是长生汇采取各种安全技术和程序存储、保护用户信息，防止其被未经授权的访问、使用、复制和泄露，但用户信息仍然有可能发生被黑客攻击、窃取，因不可抗力或者其他非长生汇的自身原因而被泄露的情形。对此，只要是长生汇采取了必要的措施防止上述情形之发生，并在上述情形发生之后采取必要的措施防止其损失进一步扩大，长生汇则无须赔偿由此给您造成的任何损失。\n"
    "第七条    您充分理解并完全接受：长生汇有可能将用户信息用于下列某一个或者某几个目的：\n"
    "（一）在您登录长生汇网站或者App时，用于验证您的身份、供您支付货款、为您提供送货服务、售后服务以及其他客户服务；\n"
    "（二）帮助长生汇分析、了解用户需求，设计新的商业模式，向您及其他用户推荐新的商品，或者将其用于长生汇所开展的新业务当中；\n"
    "（三）评估和改进长生汇服务中的广告和其他促销及推广活动。\n";
    
    NSString *hrefStr = url.absoluteString;
    if ([hrefStr rangeOfString:@"authority"].location!=NSNotFound) {
        title = @"版权声明和隐私保护";//@"版权声明";
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
