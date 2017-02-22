//
//  YMCategoryModel.m
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCategoryModel.h"

#import "YMCommon.h"

@implementation YMCategoryModel

+ (NSDictionary *)objectClassInArray
{
    return @{@"spus":@"YMGoodModel"};
}
@end

@implementation YMGoodModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"foodId": @"id" };
}

@end

@implementation YMCollectionCategoryModel

+ (NSDictionary *)objectClassInArray
{
    return @{ @"subcategories": @"YMSubCategoryModel"};
}
@end

@implementation YMSubCategoryModel

@end

