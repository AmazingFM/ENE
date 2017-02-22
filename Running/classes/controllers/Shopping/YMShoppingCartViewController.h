//
//  YMShoppingCartViewController.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

#import "YMGoods.h"

#import "YMCellItems.h"

@class YMCartCell;
@protocol YMCartCellDelegate <NSObject>

@optional
- (void)cellButtonSelect:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath;
- (void)cellCount:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath forType:(int)type;
- (void)cellCount:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath withNewValue:(NSString *)value;

- (void)cellDeleteGoods:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath;
- (void)cellAddToCart:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath forType:(BOOL)type;

@end
@interface YMCartCell : UITableViewCell

@property (nonatomic) int type;
@property (nonatomic, retain) YMShoppingCartItem *item;
@property(nonatomic,assign)NSInteger choosedCount;
@property (nonatomic, weak) id<YMCartCellDelegate> delegate;

@end


@interface YMShoppingCartViewController : YMBaseViewController

@end
