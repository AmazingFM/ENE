//
//  YMGoodsListController.m
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMGoodsListController.h"
#import "YMGoodsDetailController.h"
#import "YMCollectionViewFlowLayout.h"

#import "YMUtil.h"

#import "YMGoods.h"
#import "YMBaseItem.h"

#import "YMDatabase.h"

#define kYMGoodsListButtonViewTag 100
#define kYMGoodsListTitleFont [UIFont systemFontOfSize:14]
#define kYMGoodsListDetailFont [UIFont systemFontOfSize:11]
#define kYMGoodsListPriceFont [UIFont systemFontOfSize:16]

@interface YMGoodsCollectionViewCell()
{
    UIButton *_favoriteBtn;
    UIImageView *goodImage;
    UILabel *_titleLabel;
    UILabel *_subgnameLabel;
    UILabel *_detailLabel;
    UILabel *_priceLabel;
    CGSize frameSize;
}
@end

@implementation YMGoodsCollectionViewCell

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frameSize = frame.size;
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor whiteColor];
        self.backgroundView = backView;
        
        float offsetx = 5;
        float defaultH = 0;
        
        CGSize size = [YMUtil sizeWithFont:@"￥:00.00" withFont:kYMGoodsListPriceFont];
        size.height += 10;
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, frameSize.height-size.height, frameSize.width-50, size.height)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = kYMGoodsListPriceFont;
        _priceLabel.textColor = [UIColor redColor];
        
        _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(frameSize.width-10-(size.height-10), frameSize.height-size.height+5, size.height-10, size.height-10)];
        
        _favoriteBtn.tag = kYMGoodsListButtonViewTag;
        _favoriteBtn.backgroundColor = [UIColor clearColor];
        [_favoriteBtn setImage:[UIImage imageNamed:@"icon-collect.png"] forState:UIControlStateNormal];
        [_favoriteBtn setImage:[UIImage imageNamed:@"icon-collect-selected.png"] forState:UIControlStateSelected];
        [_favoriteBtn.imageView setContentMode:UIViewContentModeScaleToFill];
        [_favoriteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        defaultH = size.height;
        defaultH += 1;
        size = [YMUtil sizeWithFont:@"此商品暂无规格说明" withFont:kYMGoodsListDetailFont];
        size.height += 4;

        _subgnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, frameSize.height-size.height-defaultH, frameSize.width, size.height)];
        _subgnameLabel.backgroundColor = [UIColor clearColor];
        _subgnameLabel.font = kYMGoodsListDetailFont;
        _subgnameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _subgnameLabel.textColor = [UIColor grayColor];
        
        defaultH += size.height;
        size = [YMUtil sizeWithFont:@"此商品暂无说明" withFont:kYMGoodsListDetailFont];
        size.height += 4;
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, frameSize.height-size.height-defaultH, frameSize.width, size.height)];
//        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = kYMGoodsListDetailFont;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.textColor = [UIColor grayColor];
        
        defaultH += size.height;
        size = [YMUtil sizeWithFont:@"大还丹" withFont:kYMGoodsListTitleFont];
        size.height += 4;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, frameSize.height-size.height-defaultH, frameSize.width, size.height)];
//        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = kYMGoodsListTitleFont;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor blackColor];
        
        defaultH += size.height;
        float imageHeight = frameSize.height-defaultH;
        goodImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, imageHeight)];
        goodImage.contentMode = UIViewContentModeScaleToFill;
        goodImage.userInteractionEnabled = NO;
        goodImage.backgroundColor = [UIColor clearColor];
        

        [self addSubview:goodImage];
        [self addSubview:_favoriteBtn];
        [self addSubview:_titleLabel];
        [self addSubview:_detailLabel];
        [self addSubview:_priceLabel];
        [self addSubview:_subgnameLabel];
    }
    return self;
}

- (void)setItem:(YMShoppingCartItem *)item
{
    _item = item;
    
    float offsetx = 5;
    float defaultH = 0;
    
    NSString *priceStr = [NSString stringWithFormat:@"￥:%@", item.goods.price];
    CGSize size = [YMUtil sizeWithFont:priceStr withFont:kYMGoodsListPriceFont];
    size.height += 10;
    _priceLabel.text = priceStr;
    
    _favoriteBtn.selected = item.isFavorate;
    
    defaultH = size.height;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(offsetx, frameSize.height-defaultH, frameSize.width-2*offsetx, 1)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line1];
    
    defaultH += 1;
    size = [YMUtil sizeWithFont:item.goods.sub_gname.length!=0?item.goods.sub_gname:@"此商品暂无规格说明" withFont:kYMGoodsListDetailFont];
    size.height += 4;
    
    _subgnameLabel.text = item.goods.sub_gname.length!=0?item.goods.sub_gname:@"此商品暂无规格说明";
    
    defaultH += size.height;
    size = [YMUtil sizeWithFont:item.goods.goods_tag?:@"此商品暂无说明" withFont:kYMGoodsListDetailFont];
    size.height += 4;
    
    _detailLabel.text = item.goods.goods_tag.length!=0?item.goods.goods_tag:@"此商品暂无说明";
    
    defaultH += size.height;
    size = [YMUtil sizeWithFont:item.goods.goods_name withFont:kYMGoodsListTitleFont];
    size.height += 4;
    
    _titleLabel.text = item.goods.goods_name;
    
    defaultH += size.height;
    NSString *imageUrl = item.goods.goods_image1;
    [goodImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default"]];
}

- (void)btnClick:(UIButton *)sender
{
    _item.selected = !sender.isSelected;
    [sender setSelected:_item.selected];
    if ([self.delegate respondsToSelector:@selector(favorateButtonSelect:withIndexPath:withType:)]) {
        [self.delegate favorateButtonSelect:self withIndexPath:_item.indexPath withType:_item.selected];
    }
}

@end

@interface YMGoodsListController()
{
    UIImageView *_noItemImg;
    UILabel *_noItemDesc;
}

@end

@implementation YMGoodsListController

- (void)loadView
{
    [super loadView];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"产品列表";
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    rowHeight = 200.f;
    
    self.lastPage = NO;
    
    _noItemDesc = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, 50)];
    _noItemDesc.center = self.view.center;
    _noItemDesc.text = @"暂时没有相关商品!";
    _noItemDesc.textAlignment = NSTextAlignmentCenter;
    _noItemDesc.textColor = rgba(183, 183, 183, 1);
    _noItemDesc.font = kYMBigFont;
    
    _noItemImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_order"]];
    _noItemImg.frame = CGRectMake(0, 0, g_screenWidth/4, g_screenWidth/4);
    _noItemImg.center = CGPointMake(_noItemDesc.centerX, _noItemDesc.centerY-50);
    _noItemImg.hidden = YES;
    _noItemDesc.hidden = YES;
    
    [self.view addSubview:_noItemDesc];
    [self.view addSubview:_noItemImg];
    
    [self.view addSubview:self.collectionView];
}

- (NSMutableArray *)itemArray
{
    if (_itemArray==nil) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, kYMTopBarHeight, self.view.bounds.size.width, self.view.bounds.size.height-kYMTopBarHeight);//;self.view.bounds;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        YMCollectionViewFlowLayout *flowlayout = [[YMCollectionViewFlowLayout alloc] init];
        //设置滚动方向
        [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //item间距
        flowlayout.minimumInteritemSpacing = 1;
        //上下间距
        flowlayout.minimumLineSpacing = 10;
        flowlayout.sectionInset = UIEdgeInsetsMake(5,5,0,5);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor yellowColor];
        //注册cell
        [_collectionView registerClass:[YMGoodsCollectionViewCell class] forCellWithReuseIdentifier:@"goodslist"];
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)refresh
{
    self.myRefreshView = self.collectionView.mj_header;
    [self.collectionView.mj_footer resetNoMoreData];
    self.lastPage = NO;
    self.pageNum = 1;
    [self startRequest];
}

- (void)loadMoreData
{
    self.myRefreshView = self.collectionView.mj_footer;
    
    if (!self.lastPage) {
        self.pageNum++;
        [self startRequest];
    }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemArray.count;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return CGSizeMake((g_screenWidth-10-10)/2, 200.f );
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = (YMShoppingCartItem *)self.itemArray[indexPath.row];
    YMGoodsDetailController *detailController = [[YMGoodsDetailController alloc] init];
    detailController.goods_id = item.goods.goods_id;
    detailController.goods_subid = item.goods.sub_gid;
    [self.navigationController pushViewController:detailController animated:YES];
}



#pragma mark YMGoodsListCellDelegate

- (void)favorateButtonSelect:(YMGoodsCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath withType:(BOOL)select
{
    YMShoppingCartItem *item = self.itemArray[indexPath.row];
    item.isFavorate = select;
    
    BOOL ret;
    if (select) {
        ret = [[YMDataBase sharedDatabase] insertPdcToIntrestCartWithModel:item.goods];
        if (ret) {
            [self showCustomHUDView:@"收藏成功"];
        } else {
            [self showCustomHUDView:@"收藏失败"];
        }
    } else {
        ret = [[YMDataBase sharedDatabase] deleIntrestPdcWithGoods:item.goods];
        if (ret) {
            [self showCustomHUDView:@"取消收藏成功"];
        } else {
            [self showCustomHUDView:@"取消收藏失败"];
        }
    }
//    showAlert([NSString stringWithFormat:@"更新收藏状态%@:%@", ret?@"成功":@"失败",select?@"选择":@"取消"]);
}

#pragma mark 网络请求

- (void)startRequest
{
    if (![self getParameters]) {
        return;
    }
    
    self.params[kYM_SPECID] = self.spec_id;
    
    self.params[kYM_PAGENO] = [NSString stringWithFormat:@"%d", self.pageNum];
    self.params[kYM_PAGESIZE] = @"30";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsList"] parameters:self.params success:^(id responseObject) {
        [self.myRefreshView endRefreshing];
        
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *resp_data = respDict[kYM_RESPDATA];
                
                if (resp_data) {
                    NSMutableDictionary *pageNav = resp_data[@"page_nav"];
                    
                    PageItem *pageItem = [[PageItem alloc] init];
                    pageItem.current_page = [pageNav[@"current_page"] intValue];
                    pageItem.page_size = [pageNav[@"page_size"] intValue];
                    pageItem.total_num = [pageNav[@"total_num"] intValue];
                    pageItem.total_page = [pageNav[@"total_page"] intValue];
                    
                    if (pageItem.current_page==pageItem.total_page) {
                        self.lastPage = YES;
                    }
                    
                    NSArray *goodsList;
                    if ([resp_data[@"goods_list"] isKindOfClass:[NSArray class]]) {
                        goodsList = [YMGoods objectArrayWithKeyValuesArray:resp_data[@"goods_list"]];
                    }
                    
                    NSMutableArray *arrayM = [NSMutableArray array];
                    if (goodsList!=nil) {
                        for (int i=0; i<goodsList.count; i++)
                        {
                            YMShoppingCartItem *goodsItem = [[YMShoppingCartItem alloc] init];
                            goodsItem.isFavorate = [[YMDataBase sharedDatabase] isExistInIntrestCart:goodsList[i]];
                            goodsItem.size = CGSizeMake(g_screenWidth, rowHeight);
                            goodsItem.goods = goodsList[i];
                            [arrayM addObject:goodsItem];
                        }
                    }
                    
                    //..下拉刷新
                    if (self.myRefreshView == self.collectionView.mj_header) {
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:arrayM];
                        
                        [self.collectionView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                        }
                    } else if (self.myRefreshView == self.collectionView.mj_footer) {
                        [self.itemArray addObjectsFromArray:arrayM];
                        [self.collectionView reloadData];
                        [self.myRefreshView endRefreshing];
                        if (self.lastPage) {
                            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                    self.collectionView.hidden = NO;
                    _noItemImg.hidden = YES;
                    _noItemDesc.hidden = YES;

                } else {
                    [self.myRefreshView endRefreshing];
                    self.collectionView.hidden = YES;
                    _noItemImg.hidden = NO;
                    _noItemDesc.hidden = NO;
                }
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self.myRefreshView endRefreshing];
    }];
}

@end
