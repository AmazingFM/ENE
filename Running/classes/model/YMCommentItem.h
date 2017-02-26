//
//  YMCommentItem.h
//  Running
//
//  Created by 张永明 on 2017/2/26.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YMCommentItem : NSObject

@property (nonatomic, copy) NSString *goods_id;             //商品id
@property (nonatomic, copy) NSString *sub_gid;              //子商品id
@property (nonatomic, copy) NSString *order_id;             //订单id
@property (nonatomic, copy) NSString *user_id;              //用户id
@property (nonatomic, copy) NSString *user_name;            //待定
@property (nonatomic, copy) NSString *evaluate_level;       //评价星级 1-5星
@property (nonatomic, copy) NSString *evaluate_desc;        //评价内容
@property (nonatomic, copy) NSString *date;        //评价时间

@property (nonatomic, copy) NSString *image_1;              //晒图1url,图片上传单独提供接口
@property (nonatomic, copy) NSString *image_2;              //晒图2url
@property (nonatomic, copy) NSString *image_3;              //晒图3url

@end
