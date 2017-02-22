//
//  YMCollectionTestController.h
//  Running
//
//  Created by 张永明 on 2017/2/22.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

#import "MJRefresh.h"
#import "MJExtension.h"
#import "MJRefreshComponent.h"


@interface YMCollectionTestController : YMBaseViewController 

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL lastPage;
@property (nonatomic, retain) MJRefreshComponent *myRefreshView;

@property (nonatomic, retain) NSString *spec_id;


@end
