//
//  YMResetPwdViewController.m
//  Running
//
//  Created by 张永明 on 16/10/9.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMResetPwdViewController.h"

#import "YMUserManager.h"
#import "YMDataManager.h"

#import "Config.h"

@implementation YMResetPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:indicator];
    
    self.navigationItem.title = @"修改密码";
    
    YMFieldCellItem *item1=[[YMFieldCellItem alloc] init];
    item1.title = @"原密码";
    item1.key = kYM_PASSWORD;
    item1.placeholder = @"请输入原密码";
    item1.secureTextEntry = YES;
    item1.actionLen = 8;
    item1.fieldType = YMFieldTypePassword;
    
    YMFieldCellItem *item2=[[YMFieldCellItem alloc] init];
    item2.title = @"新密码";
    item2.placeholder = @"请输入新密码";
    item2.key = @"new_pass";
    item2.secureTextEntry = YES;
    item2.actionLen = 8;
    item2.fieldType = YMFieldTypePassword;

    YMFieldCellItem *item3=[[YMFieldCellItem alloc] init];
    item3.title = @"密码确认";
    item3.placeholder = @"请确认密码";
    item3.key = @"codeconfirm";
    item3.secureTextEntry = YES;
    item3.actionLen = 8;
    item3.fieldType = YMFieldTypePassword;
    
    
    NSArray *section1 = @[item1, item2, item3];
    
    YMBaseCellItem *item4=[[YMBaseCellItem alloc] init];
    item4.title = @"修改密码";
    item4.key = @"submit";
    item4.backColor = [YMUtil colorWithHex:0xffcc02];
    
    NSArray *section2 = @[item4];
    
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:@[section1, section2]];
}

- (BOOL)getParameters
{
    [self.params removeAllObjects];
    
    NSString *uuid = [YMDataManager shared].uuid;
    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    [YMDataManager shared].reqSeq++;
    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
    
    self.params[kYM_APPID] = uuid;
    self.params[kYM_REQSEQ] = reqSeq;
    self.params[kYM_TIMESTAMP] = currentDate;
    
    if ([YMUserManager sharedInstance].user!=nil) {
        self.params[kYM_TOKEN] = [YMUserManager sharedInstance].user.token;
    }
    
    NSMutableDictionary *keyValueDict = [NSMutableDictionary new];
    for (NSArray *arr in self.dataArr) {
        for (YMBaseCellItem *item in arr) {
            keyValueDict[item.key] = (NSString *)item.value;
        }
    }
    
    NSString *oldPass = keyValueDict[kYM_PASSWORD];
    NSString *newPass = keyValueDict[@"new_pass"];
    NSString *newPassConfirm = keyValueDict[@"codeconfirm"];
    
    if (oldPass.length==0) {
        [self showTextHUDView:@"原密码不能为空"];
        return NO;
    }
    
    if (![newPass isEqualToString:newPassConfirm]) {
        [self showTextHUDView:@"密码不一致"];
        return NO;
    }
    
    self.params[kYM_PASSWORD] = [YMUtil md5HexDigest:oldPass];
    self.params[@"new_pass"] = [YMUtil md5HexDigest:newPass];
    
    return YES;
}

- (void)callPassword
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    [indicator startAnimating];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserModify"] parameters:self.params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                [Config changePassword:[YMUserManager sharedInstance].user.user_name andPassword:self.params[@"new_pass"]];
                [self showTextHUDView:@"密码修改成功"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
    }];
}

@end
