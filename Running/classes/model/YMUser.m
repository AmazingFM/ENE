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

@end
