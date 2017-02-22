//
//  YMOrder.h
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YMAddress.h"
#import "YMGoods.h"


typedef enum {
    YMOrderTypeForPay           = 0,
    YMOrderTypeForSend          = 1,
    YMOrderTypeForReceive       = 2,
    YMOrderTypeAccept           = 3,
    YMOrderTypeComment          = 4,
    YMOrderTypeCancel           = 7,
    YMOrderTypeTimeout          = 9,
} YMOrderType;

@interface YMOrderContent : NSObject

@property (nonatomic,retain) YMGoods* goods;
@property (nonatomic) int count;

@end
@interface YMOrder : NSObject

@property (nonatomic,retain) NSString *user_id;
@property (nonatomic,retain) NSString *orderId;
@property (nonatomic,retain) NSMutableArray<YMOrderContent *> *goodsItems;
@property (nonatomic,retain) NSString *fee;
@property (nonatomic,retain) NSString *totalPrice;
@property (nonatomic) YMOrderType status;
@property (nonatomic,retain) YMAddress *address;
@property (nonatomic,retain) NSString *timestamp;

@end