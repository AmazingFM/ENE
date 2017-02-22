//
//  YMMyBoy.m
//  Running
//
//  Created by 张永明 on 16/10/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMMyBoy.h"

@implementation YMMyBoy

@end

@implementation ProfitItem

@end

@implementation YMMyProfit

- (NSMutableArray<ProfitItem *> *)profit_list
{
    if (_profit_list==nil) {
        _profit_list = [NSMutableArray<ProfitItem *> new];
    }
    return _profit_list;
}

@end
