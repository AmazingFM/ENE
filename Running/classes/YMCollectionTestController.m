//
//  YMCollectionTestController.m
//  Running
//
//  Created by 张永明 on 2017/2/22.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMCollectionTestController.h"

@interface YMCollectionTestController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) NSMutableArray *topItemArr;
@end

@implementation YMCollectionTestController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (NSMutableArray *)topItemArr
{
    if (_topItemArr==nil) {
        _topItemArr = [NSMutableArray new];
    }
    return _topItemArr;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemArray.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodslist" forIndexPath:indexPath];
    cell.delegate = self;
    YMShoppingCartItem *item = self.itemArray[indexPath.row];
    item.indexPath = indexPath;
    cell.item = item;
    return cell;
}
@end
