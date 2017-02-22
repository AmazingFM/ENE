//
//  YMGoods.h
//  Running
//
//  Created by freshment on 16/9/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMGoods : NSObject<NSCopying>
@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_name;
@property (nonatomic, copy) NSString *goods_tag;
@property (nonatomic, copy) NSString *goods_image1;
@property (nonatomic, copy) NSString *goods_image1_mid;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *sub_gid;
@property (nonatomic, copy) NSString *sub_gname;

//detail info
@property (nonatomic, copy) NSString *goods_desc;
@property (nonatomic, copy) NSString *goods_image2;
@property (nonatomic, copy) NSString *goods_image2_mid;
@property (nonatomic, copy) NSString *goods_image3;
@property (nonatomic, copy) NSString *goods_image3_mid;
@property (nonatomic, copy) NSString *goods_image4;
@property (nonatomic, copy) NSString *goods_image4_mid;
@property (nonatomic, copy) NSString *sale_count;
@property (nonatomic, copy) NSString *spec_id;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *store_count;
@property (nonatomic, copy) NSString *brand_id;
@property (nonatomic, copy) NSString *suitable_crowd;
@property (nonatomic, copy) NSString *dosage_forms;
@property (nonatomic, copy) NSString *shelf_life;
@property (nonatomic, copy) NSString *manufacturer;
@end
