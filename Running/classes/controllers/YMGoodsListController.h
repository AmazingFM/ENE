//
//  YMGoodsListController.h
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

#import "MJRefresh.h"
#import "MJExtension.h"
#import "MJRefreshComponent.h"

#import "YMCellItems.h"

@class YMGoodsCollectionViewCell;

@protocol YMGoodsCollectionViewCellDelegate <NSObject>

- (void)favorateButtonSelect:(YMGoodsCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath withType:(BOOL)select;
@end

@interface YMGoodsCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) YMShoppingCartItem *item;
@property (nonatomic, weak) id<YMGoodsCollectionViewCellDelegate> delegate;

@end

@protocol YMGoodsListDelegate <NSObject>

- (void)goodsItemDidSelect:(YMShoppingCartItem *)goodsItem;

@end

@interface YMGoodsListController : YMBaseViewController <YMGoodsCollectionViewCellDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
{
    float rowHeight;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL lastPage;
@property (nonatomic, retain) MJRefreshComponent *myRefreshView;
@property (nonatomic, retain) NSString *spec_id;
@property (nonatomic, weak) id<YMGoodsListDelegate> delegate;

- (void)setItemData:(NSArray*)items;
@end
