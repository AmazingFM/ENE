//
//  YMSearchViewController.h
//  Running
//
//  Created by freshment on 16/9/25.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

@protocol YMSearchDelegate <NSObject>

- (void)goodsSearchItemSelect:(YMShoppingCartItem *)goodsItem;

@end

@interface YMSearchViewController : YMBaseViewController
@property (nonatomic, weak) id<YMSearchDelegate> delegate;
@end
