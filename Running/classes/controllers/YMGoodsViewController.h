//
//  YMGoodsViewController.h
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

@class YMGoodModel;
@class YMSubCategoryModel;

@class YMCategory;

#define kCellIdentifier_Left @"LeftTableViewCell"
#define kCellIdentifier_Right @"RightTableViewCell"

#define kCellIdentifier_CollectionView @"CollectionViewCell"

@interface LeftTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *name;

@end

@interface YMCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) YMCategory *model;

@end

@interface YMCollectionViewHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *title;

@end

@protocol YMGoodsItemActionDelegate <NSObject>

- (void)goodsItemSelect:(YMCategory *)category;

@end

@interface YMGoodsViewController : YMBaseViewController

@property (nonatomic, weak) id<YMGoodsItemActionDelegate> delegate;

@end
