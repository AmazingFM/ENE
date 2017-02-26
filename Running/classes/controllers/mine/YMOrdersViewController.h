//
//  YMOrdersViewController.h
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"
#import "YMScrollViewController.h"

#import "YMOrder.h"

#import "MJRefresh.h"
#import "MJExtension.h"
#import "MJRefreshComponent.h"


@interface YMOrderItem : NSObject

@property (nonatomic,retain) YMOrder *order;

@end

@interface YMGoodsCell : UITableViewCell
{
    UIImageView *goodImage;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_priceLabel;
    UILabel *_countLabel;
}

@property (nonatomic, retain) YMOrderContent *contentItem;

@end

@interface YMOrdersViewController : YMBaseViewController

@property(nonatomic)NSInteger selectedIndex;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL lastPage;
@property (nonatomic, retain) MJRefreshComponent *myRefreshView;

@end
