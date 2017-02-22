//
//  YMOrder.m
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMOrder.h"

@implementation YMOrderContent

@end

@implementation YMOrder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _goodsItems = [NSMutableArray array];
    }
    return self;
}

@end
