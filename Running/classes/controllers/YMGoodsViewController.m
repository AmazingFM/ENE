//
//  YMGoodsViewController.m
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMGoodsViewController.h"
#import "YMCollectionViewFlowLayout.h"

#import "YMCommon.h"
#import "YMLocalResource.h"
#import "YMGlobal.h"

#import "YMCategoryModel.h"
#import "NSObject+Property.h"

#import "YMCategory.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "MJRefreshComponent.h"

@interface YMGoodsViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *collectionDatas;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *parentlist;
@property (nonatomic, strong) NSMutableArray<NSArray *> *sublist;

@property (nonatomic, retain) MJRefreshComponent *myRefreshView;

@end

@implementation YMGoodsViewController
{
    NSInteger _selectIndex;
    BOOL _isScrollDown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectIndex = 0;
    _isScrollDown = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startSpecQuery];
}

#pragma mark - Getters
- (NSMutableArray *)parentlist
{
    if (!_parentlist) {
        _parentlist = [NSMutableArray array];
    }
    return _parentlist;
}

- (NSMutableArray *)sublist
{
    if (!_sublist) {
        _sublist = [NSMutableArray array];
    }
    return _sublist;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)collectionDatas
{
    if (!_collectionDatas) {
        _collectionDatas = [NSMutableArray array];
    }
    return _collectionDatas;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 55;
        _tableView.tableFooterView = [UIView new];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = rgba(243, 243, 243, 1);
        [_tableView registerClass:[LeftTableViewCell class] forCellReuseIdentifier:kCellIdentifier_Left];
    }
    return _tableView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        YMCollectionViewFlowLayout *flowlayout = [[YMCollectionViewFlowLayout alloc] init];
        //设置滚动方向
        [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //左右间距
        flowlayout.minimumInteritemSpacing = 2;
        //上下间距
        flowlayout.minimumLineSpacing = 2;
        flowlayout.headerReferenceSize = CGSizeMake(g_screenWidth, 30);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        //注册cell
        [self.collectionView registerClass:[YMCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier_CollectionView];
        //注册分区头标题
        [self.collectionView registerClass:[YMCollectionViewHeaderView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:@"CollectionViewHeaderView"];
        self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        [self.view addSubview:_collectionView];

    }
    return _collectionView;
}

- (void)refresh
{
    self.myRefreshView = self.collectionView.mj_header;
    
    [self startSpecQuery];
}

#pragma mark - UITableView DataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parentlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Left forIndexPath:indexPath];
    YMCategory *category = self.parentlist[indexPath.row];
    cell.name.text = category.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectIndex = indexPath.row;
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_selectIndex] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
    NSIndexPath* cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:_selectIndex];
    UICollectionViewLayoutAttributes* attr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:cellIndexPath];
    UIEdgeInsets insets = self.collectionView.scrollIndicatorInsets;
    
    CGRect rect = attr.frame;
    rect.size = self.collectionView.frame.size;
    rect.size.height -= insets.top + insets.bottom;
    CGFloat offset = (rect.origin.y + rect.size.height) - self.collectionView.contentSize.height;
    if ( offset > 0.0 ) rect = CGRectOffset(rect, 0, -offset);
    
    [self.collectionView scrollRectToVisible:rect animated:YES];
}

#pragma mark UICollectionView DataSource Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
//    return self.dataSource.count;
    return self.parentlist.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    YMCollectionCategoryModel *model = self.dataSource[section];
//    return model.subcategories.count;
    return self.sublist[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_CollectionView forIndexPath:indexPath];
    
    YMCategory *category = self.sublist[indexPath.section][indexPath.row];
    cell.model = category;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return CGSizeMake((g_screenWidth-80-4-4)/3, (g_screenWidth-80-4-4)/3+30 );
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reuseIdentifier = @"CollectionViewHeaderView";
    }
    
    YMCollectionViewHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        YMCategory *model = self.parentlist[indexPath.section];
        view.title.text = model.name;
    }
    return view;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(g_screenWidth, 30);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMCategory *category = self.sublist[indexPath.section][indexPath.row];
    if ([self.delegate respondsToSelector:@selector(goodsItemSelect:)]) {
        [self.delegate goodsItemSelect:category];
    }
}

//CollectionView分区标题即将展示
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    // 当前CollectionView滚动的方向向上，CollectionView是用户拖拽而产生滚动的（主要是判断CollectionView是用户拖拽而滚动的，还是点击TableView而滚动的）
    if (!_isScrollDown && collectionView.dragging) {
        [self selectRowAtIndexPath:indexPath.section];
    }
}

// CollectionView分区标题展示结束
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    // 当前CollectionView滚动的方向向下，CollectionView是用户拖拽而产生滚动的（主要是判断CollectionView是用户拖拽而滚动的，还是点击TableView而滚动的）
    if (_isScrollDown && collectionView.dragging) {
        [self selectRowAtIndexPath:indexPath.section+1];
    }
}

// 当拖动CollectionView的时候，处理TableView
- (void)selectRowAtIndexPath:(NSInteger)index
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark UICScrollView Delegate
// 标记一下CollectionView的滚动方向，是向上还是向下
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static float lastOffsetY = 0;
    if (self.collectionView == scrollView) {
        _isScrollDown = lastOffsetY<scrollView.contentOffset.y;
        lastOffsetY = scrollView.contentOffset.y;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0,0,80,self.view.frame.size.height);
    self.collectionView.frame = CGRectMake(2 + 80, 0, g_screenWidth - 80 - 4, self.view.frame.size.height);
}
#pragma mark 网络请求

- (void)startSpecQuery
{
//    if (![self getParameters]) {
//        return;
//    }
    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=SpecQuery"] parameters:parameters success:^(id responseObject) {
        [self.myRefreshView endRefreshing];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                id specObj = dataDict[@"spec_list"];
                if ([specObj isKindOfClass:[NSArray class]]) {
                    NSMutableDictionary *categoryDict = [NSMutableDictionary new];
                    NSArray<YMCategory *> *categorylist = [YMCategory objectArrayWithKeyValuesArray:specObj];
                    
                    [self.parentlist removeAllObjects];
                    [self.sublist removeAllObjects];
                    
                    for (YMCategory *category in categorylist) {
                        if ([category.level intValue]==2) {
                            [self.parentlist addObject:category];
                        }
                        
                        if ([category.level intValue]==3) {
                            NSMutableArray *subArr = categoryDict[category.parent_code];
                            if (subArr==nil) {
                                subArr = [NSMutableArray new];
                                categoryDict[category.parent_code] = subArr;
                            }
                            [subArr addObject:category];
                        }
                    }
                    
                    for (YMCategory *category in self.parentlist) {
                        [self.sublist addObject:categoryDict[category.code]];
                    }
                    
                    [self.tableView reloadData];
                    [self.collectionView reloadData];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                }
                
                
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        [self.myRefreshView endRefreshing];
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//            showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
//        });
    }];
}

@end


#define defaultColor rgba(249, 50, 61, 1)

@interface LeftTableViewCell()

@property (nonatomic, strong) UIView *yellowView;

@end

@implementation LeftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 40)];
        self.name.adjustsFontSizeToFitWidth = YES;
        self.name.font = kYMSmallFont;
        self.name.textColor = rgba(130, 130, 130, 1);
        self.name.highlightedTextColor = defaultColor;
        [self.contentView addSubview:self.name];
        
        self.yellowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 55)];
        self.yellowView.backgroundColor = defaultColor;
        [self.contentView addSubview:self.yellowView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.contentView.backgroundColor = selected ? [UIColor whiteColor] : rgba(243, 243, 243, 1);
    self.highlighted = selected;
    self.name.highlighted = selected;
    self.yellowView.hidden = !selected;
}
@end

@interface YMCollectionViewCell()

@property (nonatomic, retain) UIImageView *imageV;
@property (nonatomic, retain) UILabel *name;

@end

@implementation YMCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/6,self.frame.size.width/6,self.frame.size.width*2/3, self.frame.size.width*2/3)];
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageV];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(2, self.frame.size.width+2, self.frame.size.width-4, 20)];
        self.name.font = kYMSmallFont;
        self.name.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview: self.name];
    }
    return self;
}

- (void)setModel:(YMCategory *)model
{    
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"default"]];
    
    self.name.text = model.name;
}

@end

@implementation YMCollectionViewHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = rgba(255, 255, 255, 1);
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, g_screenWidth - 80, 20)];
        self.title.font = kYMTableHeaderFont;
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
    }
    return self;
}

@end

