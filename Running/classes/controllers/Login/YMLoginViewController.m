//
//  YMLoginViewController.m
//  Running
//
//  Created by 张永明 on 16/9/5.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMLoginViewController.h"
#import "YMRegisterViewController.h"
#import "YMCallPasswordViewController.h"
#import "YMStatisticViewController.h"

#import "YMConfig.h"
#import "YMUtil.h"

#import "YMUser.h"
#import "YMUserManager.h"

#import "AFHTTPSessionManager.h"

@interface YMLoginViewController () <UITextFieldDelegate>
{
    
    UIImageView *_iconImageview;
    UITextField *_accountField;
    UITextField *_passwordField;
    
    UIView *_accoutPassView;
}
@property (nonatomic, retain) UITextField *activeField;
@end

@implementation YMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.png"]];
    backImg.userInteractionEnabled = NO;
    backImg.frame = self.view.bounds;
    [self.view addSubview:backImg];

    
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logo.frame = CGRectMake(0, 100, g_screenWidth, 70);
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.backgroundColor = [UIColor clearColor];
    [self.view addSubview:logo];

    
    _accoutPassView = [self addAccountPassFieldView];
    [self addLoginBtn];
    
    [self loadNotificationCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    //统一导航样式
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)dealloc
{
    [self removeNotificationCell];
}

- (void)loadNotificationCell
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotificationCell
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

    CGFloat maxY;
    if (self.activeField==_accountField) {
        maxY = CGRectGetMaxY(self.activeField.frame)+_accoutPassView.y;
    } else if (self.activeField==_passwordField) {
         maxY = CGRectGetMaxY(self.activeField.frame)+_accoutPassView.y+50+15;
    }
    if (maxY>y-5) {
        self.view.centerY = self.view.centerY-(maxY-y+5);
    }
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    self.view.frame=self.view.bounds;
    
    [UIView commitAnimations];
}

- (UIView *)addAccountPassFieldView
{
    float uppadding = 10.f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kYMBorderMargin,g_screenHeight/2-50,g_screenWidth-2*kYMBorderMargin, 115)];
    view.backgroundColor = [UIColor clearColor];
    
    float offsetx = 0;
    float offsety = 0;
    
    UIView *accountView = [[UIView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth-2*kYMBorderMargin, 50)];
    accountView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    [accountView setCornerRadius:10];
    
    UIImageView *accountIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accountIcon"]];
    accountIcon.frame = CGRectMake(10, uppadding+4, 22, 22);
    accountIcon.contentMode = UIViewContentModeScaleToFill;
    
    offsetx = CGRectGetMaxX(accountIcon.frame);
    _accountField = [[UITextField alloc] initWithFrame:CGRectMake(offsetx+10, uppadding, accountView.frame.size.width-offsetx-20, 30)];
    _accountField.borderStyle = UITextBorderStyleNone;
    _accountField.placeholder = @"请输入用户名";
    _accountField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _accountField.autocorrectionType = UITextAutocorrectionTypeNo;
    _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField.returnKeyType = UIReturnKeyDone;
    _accountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _accountField.font = [UIFont systemFontOfSize:17];
    _accountField.textColor = [UIColor whiteColor];
    _accountField.backgroundColor = [UIColor clearColor];
    _accountField.delegate = self;
    NSString *holderText = @"请输入用户名";
    NSMutableAttributedString *accountplaceholder = [[NSMutableAttributedString alloc]initWithString:holderText];
    [accountplaceholder addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:NSMakeRange(0, holderText.length)];
    [accountplaceholder addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:17]
                       range:NSMakeRange(0, holderText.length)];
    _accountField.attributedPlaceholder = accountplaceholder;
    
    offsetx = 0;
    offsety = CGRectGetMaxY(accountView.frame);
    
    UIView *passView = [[UIView alloc] initWithFrame:CGRectMake(0,offsety+15,g_screenWidth-2*kYMBorderMargin, 50)];
    passView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    [passView setCornerRadius:10];
    
    UIImageView *passwordIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordIcon"]];
    passwordIcon.frame = CGRectMake(offsetx+10, uppadding+4, 22, 22);
    passwordIcon.contentMode = UIViewContentModeScaleToFill;
    
    offsetx = CGRectGetMaxX(passwordIcon.frame);
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(offsetx+10, uppadding, view.frame.size.width-offsetx-20, 30)];
    _passwordField.borderStyle = UITextBorderStyleNone;
    _passwordField.secureTextEntry = YES;
    _passwordField.placeholder = @"请输入密码";
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.returnKeyType = UIReturnKeyDone;
    _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.font = [UIFont systemFontOfSize:17];
    _passwordField.textColor = [UIColor whiteColor];
    _passwordField.backgroundColor = [UIColor clearColor];
    _passwordField.delegate = self;
    holderText = @"请输入密码";
    NSMutableAttributedString *passplaceholder = [[NSMutableAttributedString alloc]initWithString:holderText];
    [passplaceholder addAttribute:NSForegroundColorAttributeName
                               value:[UIColor whiteColor]
                               range:NSMakeRange(0, holderText.length)];
    [passplaceholder addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:17]
                               range:NSMakeRange(0, holderText.length)];
    _passwordField.attributedPlaceholder = passplaceholder;

    
    [accountView addSubview:accountIcon];
    [accountView addSubview:_accountField];
    [passView addSubview:passwordIcon];
    [passView addSubview:_passwordField];
    
    [view addSubview:accountView];
    [view addSubview:passView];
    
    [self.view addSubview:view];
    return view;
}

- (void)addLoginBtn
{
    float offsety = CGRectGetMaxY(_accoutPassView.frame);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kYMBorderMargin,offsety+50,g_screenWidth-2*kYMBorderMargin, 100)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(0,0,g_screenWidth-2*kYMBorderMargin, 40);
    [loginBtn setCornerRadius:5.f];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
    
    loginBtn.backgroundColor = [UIColor lightGrayColor];
    [loginBtn setTitle:@"登     陆" forState:UIControlStateNormal];
    [loginBtn setTitleColor:rgba(90, 95, 97, 1) forState:UIControlStateNormal];
    loginBtn.titleLabel.font = kYMBigFont;
    [loginBtn addTarget:self action:@selector(startLogin) forControlEvents:UIControlEventTouchUpInside];

    offsety = CGRectGetMaxY(loginBtn.frame);
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.tag = 1001;
    registerBtn.frame = CGRectMake(0,offsety+15,100, 30);
    registerBtn.backgroundColor = [UIColor clearColor];
    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [registerBtn setTitle:@"用户注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerBtn.titleLabel.font = kYMSmallFont;
    [registerBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getPassBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getPassBtn.tag = 1002;
    getPassBtn.frame = CGRectMake(g_screenWidth-2*kYMBorderMargin-100,offsety+15,100, 30);
    getPassBtn.backgroundColor = [UIColor clearColor];
    getPassBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [getPassBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [getPassBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    getPassBtn.titleLabel.font = kYMNormalFont;
    [getPassBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:loginBtn];
    [view addSubview:registerBtn];
    [view addSubview:getPassBtn];
    
    [self.view addSubview:view];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_accountField==textField) {
        [_accountField resignFirstResponder];
    } else if (_passwordField==textField) {
        [_passwordField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)textEntered
{
    unichar c = [textEntered characterAtIndex:[textEntered length]-1];
    if(c==0||c=='\n'){
        return YES;
    }
    
    int actionLen = 20;
    if(actionLen>0){
        if([textField.text length]+[textEntered length]>actionLen){
            return NO;
        }
    }

    NSCharacterSet *cs  = nil;
    BOOL isMatch=NO;
    if (textField==_accountField) {
        cs=[[NSCharacterSet characterSetWithCharactersInString:@"_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    } else if (textField==_passwordField) {
        cs=[[NSCharacterSet characterSetWithCharactersInString:@"_!*&%0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    }

//    if(fieldItem.fieldType==HTEntrustFieldTypeAmount){
//        isMatch=YES;
//        cs=[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
//    }else if(fieldItem.fieldType==HTEntrustFieldTypeNumber){
//        cs=[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
//    }else if(fieldItem.fieldType==HTEntrustFieldTypeCharater){
//        cs=[[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
//    }
    NSString *filtered = [[textEntered componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [textEntered isEqualToString:filtered];
    //数字校验
    
    if(isMatch){
        NSString *temp;
        //        NSString *regex=@"^\\d*(\\d+)?$";
        NSString *regex=@"^\\d*(\\d+\\.\\d*)?$";
        temp = [textField.text stringByReplacingCharactersInRange:range withString:textEntered];
        NSPredicate *filter=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        isMatch=[filter evaluateWithObject:temp];
        //数字校验
        return (basicTest && isMatch);
    }else {
        return basicTest;
    }

    return YES;
}

//
- (void)btnClick:(UIButton *)sender
{
    if (sender.tag==1001) {
        YMRegisterViewController *registerController = [[YMRegisterViewController alloc] init];
        [self.navigationController pushViewController:registerController animated:YES];
    }
    if (sender.tag == 1002) {
        YMCallPasswordViewController *callPassVC = [[YMCallPasswordViewController alloc] init];
        [self.navigationController pushViewController:callPassVC animated:YES];
    }
}

#pragma mark 网络请求
//- (BOOL)getParameters
//{
////    [super getParameters];
//    
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    NSString *username = _accountField.text;
//    NSString *password = _passwordField.text;
//    
//    if (username.length==0 || password.length==0) {
//        showAlert(@"用户名、密码不能为空");
//        return NO;
//    }
//    parameters[kYM_USERNAME] = username;
//    parameters[kYM_PASSWORD] = [YMUtil md5HexDigest:password];
//    parameters[kYM_REMARKCODE]= @"9999";
//    return YES;
//}

- (void)startLogin
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    NSString *username = _accountField.text;
    NSString *password = _passwordField.text;
    
    if (username.length==0 || password.length==0) {
        showAlert(@"用户名、密码不能为空");
        return ;
    }
    parameters[kYM_USERNAME] = username;
    parameters[kYM_PASSWORD] = [YMUtil md5HexDigest:password];
    parameters[kYM_REMARKCODE]= @"9999";
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在登陆..";
    hud.label.font = kYMNormalFont;
    hud.label.textColor =  [UIColor grayColor]; //
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserLogin"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        __weak NSDictionary *params = parameters;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                [YMConfig saveOwnAccount:params[kYM_USERNAME] andPassword:params[kYM_PASSWORD] andRemarkCode:params[kYM_REMARKCODE]];
                
                YMUser *model = [YMUser objectWithKeyValues:respDict[kYM_RESPDATA]];
                [YMUserManager sharedInstance].user = model;
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMNoticeLoginInIdentifier object:nil userInfo:@{kYM_USERID:model.user_id}];
                
                if ([model.user_type intValue]==0) { //普通用户
                    [g_appDelegate setRootViewControllerWithMain];
                } else if ([model.user_type intValue]==1 ||
                           [model.user_type intValue]==2) {
                    [g_appDelegate setRootViewControllerWithRecommend];
                }
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    }];
}

@end
