//
//  YMNothingViewController.h
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

//商品页面，包括商品基本信息、评价页面
@interface YMGoodsDetailController : YMBaseViewController

@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_subid;

@end
