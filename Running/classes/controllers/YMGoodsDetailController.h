//
//  YMNothingViewController.h
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

#import "YMGoods.h"

@interface YMGoodsDetailItem : NSObject

@property (nonatomic, retain) YMGoods *goods;
@property (nonatomic) int numOfRows;
@property (nonatomic) float rowHeight;

@end

@interface YMGoodsDetailController : YMBaseViewController

@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_subid;

@end
