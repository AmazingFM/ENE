//
//  YMUser.m
//  Running
//
//  Created by freshment on 16/9/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMUser.h"

@implementation YMUser

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"user_id": @"id" };
}

- (id)copyWithZone:(NSZone *)zone
{
    YMUser *result = [[[self class] allocWithZone:zone] init];
    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _user_id = @"";
        _user_icon = @"";
        _nick_name = @"";
        _sexual = @"0";
        _token = @"";
        _user_type = @"0";//普通
        _user_name = @"";
        _true_name = @"";
        _contact_eml = @"";
        _birthday = @"";
        _remark_code = @"";
    }
    return self;
}
@end
