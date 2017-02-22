//
//  Config.m
//  Running
//
//  Created by 张永明 on 16/9/5.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "Config.h"

#import <SSKeychain.h>

NSString *const kService = @"Running";
NSString *const kAccount = @"account";
NSString *const kRemarkCode = @"remarkCode";
NSString *kUserID = @"userID";
NSString * const kUserName = @"name";

@implementation Config

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
