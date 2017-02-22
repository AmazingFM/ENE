//
//  YMGoods.m
//  Running
//
//  Created by freshment on 16/9/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMGoods.h"

@implementation YMGoods

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.goods_id=@"";
        self.goods_name=@"";
        self.goods_tag=@"";
        self.goods_image1=@"";
        self.goods_image1_mid=@"";
        self.price=@"";
        self.sub_gid=@"";
        self.sub_gname=@"";
        
        //detail info
        self.goods_desc=@"";
        self.goods_image2=@"";
        self.goods_image2_mid=@"";
        self.goods_image3=@"";
        self.goods_image3_mid=@"";
        self.goods_image4=@"";
        self.goods_image4_mid=@"";
        self.sale_count=@"";
        self.spec_id=@"";
        self.status=@"";
        self.store_count=@"";
        self.brand_id = @"";
        self.suitable_crowd = @"";
        self.dosage_forms = @"";
        self.shelf_life = @"";
        self.manufacturer = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    YMGoods *result = [[[self class] allocWithZone:zone] init];
    return result;
}


@end
