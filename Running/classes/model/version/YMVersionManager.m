//
//  YMVersionManager.m
//  Running
//
//  Created by 张永明 on 2017/1/17.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMVersionManager.h"

#import "YMDataManager.h"
#import "YMUserManager.h"
#import "YMUtil.h"
#import "YMGlobal.h"
#import "PPNetworkHelper.h"

@interface YMVersionManager() <UIAlertViewDelegate>

@end

@implementation YMVersionManager
+ (instancetype)sharedManager
{
    static YMVersionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMVersionManager alloc] init];
    });
    return instance;
}

#define kUpdateVersionKey @"kUpdateVersionKey"

- (void)getVersionInfo
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSString *uuid = [YMDataManager shared].uuid;
    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    [YMDataManager shared].reqSeq++;
    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
    
    params[kYM_APPID] = uuid;
    params[kYM_REQSEQ] = reqSeq;
    params[kYM_TIMESTAMP] = currentDate;
    
    if ([YMUserManager sharedInstance].user!=nil) {
        params[kYM_TOKEN] = [YMUserManager sharedInstance].user.token;
    }
    params[@"type_code"] = @"0004";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GetAppParam"] parameters:params success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *versionInfoDict = respDict[kYM_RESPDATA];
                //保存版本更新信息
                [YMUtil saveKey:kUpdateVersionKey value:versionInfoDict];
                
                [self dealWithServerInfo:versionInfoDict];
                
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        NSDictionary *versionInfoDict = [YMUtil loadKey:kUpdateVersionKey];
        [self dealWithServerInfo:versionInfoDict];
    }];
}

- (void)dealWithServerInfo:(NSDictionary *)versionInfoDict
{
    self.newestVersion = versionInfoDict[@"version_code"];
    self.downloadUrl = versionInfoDict[@"download_url"];
    self.updateLog = versionInfoDict[@"update_log"];
    self.forced = ![versionInfoDict[@"forces"] boolValue];
    
    if ([self needUpgradeVesion:g_strVersion newVersion:self.newestVersion]) {
        UIAlertView *alertView = nil;
        if (self.forced) {
            alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:self.updateLog delegate:self cancelButtonTitle:@"更新" otherButtonTitles:nil];
            alertView.tag = 0;
        } else {
            alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:self.updateLog delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
            alertView.tag = 1;
        }
        
        [alertView show];
    }
}

- (BOOL)needUpgradeVesion:(NSString *)version newVersion:(NSString *)newVersion
{
    NSArray *vers = [version componentsSeparatedByString:@"."];
    NSArray *newVers = [newVersion componentsSeparatedByString:@"."];
    
    if ([newVers[0] intValue]>[vers[0] intValue]) {
        return YES;
    } else {
        if([newVers[1] intValue]>[vers[1] intValue]) {
            return YES;
        } else {
            if([newVers[2] intValue]>[vers[2] intValue]) {
                return YES;
            }
        }
    }
    return NO;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
    } else {
        if(buttonIndex==1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
        }
    }
}

@end
