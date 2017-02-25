//
//  YMGoodsInfoController.h
//  Running
//
//  Created by 张永明 on 2017/2/25.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMBaseViewController.h"




#define kYMGoodsDetailTag 100

#define kYMGoodsListTitleFont [UIFont systemFontOfSize:18]
#define kYMGoodsListTagFont [UIFont systemFontOfSize:15]
#define kYMGoodsListDetailFont [UIFont systemFontOfSize:12]
#define kYMGoodsListPriceFont [UIFont systemFontOfSize:30]

@protocol YMGoodsInfoDelegate <NSObject>

- (void)setGoodsInfo:(YMGoods *)goods;

@end

@interface YMGoodsInfoController : YMBaseViewController

@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_subid;
@property (nonatomic, weak) id<YMGoodsInfoDelegate> delegate;

@end
