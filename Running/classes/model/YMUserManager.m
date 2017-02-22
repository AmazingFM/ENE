//
//  YMDataManager.m
//  Running
//
//  Created by freshment on 16/9/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMUserManager.h"
#import "YMDataBase.h"

#import "YMCommon.h"

@implementation YMUserManager

+ (instancetype)sharedInstance
{
    static YMUserManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _user = [[YMUser alloc] init];
        _shoppingNum = nil;
    }
    return self;
}

- (void)setUser:(YMUser *)user
{
    _user.user_id = user.user_id;
    _user.user_icon = user.user_icon;
    _user.nick_name = user.nick_name;
    _user.sexual = user.sexual;
    _user.token = user.token;
    _user.user_type = user.user_type;
    _user.user_name = user.user_name;
    
    [self loadData];
}

- (void)loadData
{
    self.shoppingNum = [[YMDataBase sharedDatabase] getPdcNumInCart];
}

- (void)setShoppingNum:(NSString *)shoppingNum
{
    _shoppingNum = shoppingNum;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kYMNoticeShoppingCartIdentifier object:nil userInfo:@{@"shoppingNum":shoppingNum}];
}

@end
