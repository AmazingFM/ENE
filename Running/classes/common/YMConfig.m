//
//  YMConfig.m
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMConfig.h"
#import "YMUtil.h"

#import <SSKeychain.h>

NSString *const kService = @"Running";
NSString *const kAccount = @"account";
NSString *const kRemarkCode = @"remarkCode";
NSString *kUserID = @"userID";
NSString *const kUserName = @"name";

@implementation YMConfig

+ (void)load
{
    //加载初始化信息，城市信息
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (instancetype)sharedInstance
{
    static YMConfig *sharedInstance = nil;
    
    if (sharedInstance==nil) {
        sharedInstance = [[YMConfig alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)applicationWillEnterForeground
{
    [self readSeqFromDefaults];
}

- (void)applicationWillEnterBackground
{
    [self writeSeqToDefaults];
}

- (NSString *)uuid
{
    if (!_uuid) {
        _uuid = [YMUtil getUUID];
    }
    return _uuid;
}

- (NSString *)currentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)newReqSeqStr
{
    NSString *reqStr = [NSString stringWithFormat:@"%06d", ++_reqSeq];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSString *today = [formatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@%@", today, reqStr];
}

- (NSString *)reqSeqStr
{
    NSString *reqStr = [NSString stringWithFormat:@"%6d", _reqSeq];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSString *today = [formatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@%@", today, reqStr];
}

- (void)readSeqFromDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *rq = [userDefaults stringForKey:@"reqSeq"];
    NSString *today = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMdd"];
    if (rq!=nil && rq.length>0) {
        NSString * rqDate = [rq substringToIndex:8];
        if ([rqDate isEqualToString:today]) {
            NSString *rqNum = [rq substringWithRange:NSMakeRange(8, 6)];
            _reqSeq = [rqNum intValue];
        } else {
            _reqSeq = 0;
        }
    } else {
        _reqSeq = 0;
    }
}

- (void)writeSeqToDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *reqSeq = [self reqSeqStr];
    [userDefaults setObject:reqSeq forKey:@"reqSeq"];
    [userDefaults synchronize];
}

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password andRemarkCode:(NSString *)remarkCode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account ?: @"" forKey:kAccount];
    [userDefaults setObject:remarkCode ?: @"" forKey:kRemarkCode];
    [userDefaults synchronize];
    
    [SSKeychain setPassword:password ?: @"" forService:kService account:account];
}

+ (void)changePassword:(NSString *)account andPassword:(NSString *)password
{
    [SSKeychain setPassword:password ?: @"" forService:kService account:account];
}

+ (NSArray *)getOwnAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kAccount] ?:@"";
    NSString *remarkCode = [userDefaults objectForKey:kRemarkCode] ?: @"";
    NSString *password = [SSKeychain passwordForService:kService account:account] ?: @"";
    
    if (account!=nil && account.length!=0) {return @[account, password, remarkCode];}
    return nil;
}

+ (BOOL)deleteOwnAccount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kAccount];
    if (account || account.length==0) {
        [userDefaults removeObjectForKey:kAccount];
        return [SSKeychain deletePasswordForService:kService account:account];
    }
    return YES;
}

@end
