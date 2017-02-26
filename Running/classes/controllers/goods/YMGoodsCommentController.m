//
//  YMGoodsCommentController.m
//  Running
//
//  Created by 张永明 on 2017/2/25.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMGoodsCommentController.h"

#import "YMRatingBar.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "MJRefreshComponent.h"

#import "YMCommentItem.h"

#import "YMUtil.h"

#define kTimeLabelWidth         100
#define kMaxImageCount          5
#define kImageWidth             60

#define kCommentCellImageTag    2000
#define kCommentCellIdentifier  @"kCommentCellIdentifier"

@interface YMCommentCellItem : NSObject
@property (nonatomic, retain) YMCommentItem *commentItem;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic) CGFloat cellHeight;
@end

@implementation YMCommentCellItem

- (void)setCommentItem:(YMCommentItem *)commentItem
{
    _commentItem = commentItem;
    
    CGFloat commentTextHeight = [YMUtil sizeOfString:commentItem.evaluate_desc withWidth:g_screenWidth-2*kYMBorderMargin font:kYMSecondNormalFont].height;
    
    self.cellHeight = kYMTableViewDefaultRowHeight+kYMBorderMargin*1.5+commentTextHeight+((commentItem.image_1.length==0)?0:kImageWidth);
}

- (CGFloat)cellHeight
{
    return _cellHeight;
}

@end

@interface YMCommentCell()
{
    float commentTextHeight;
    float userNameTextWidth;
}

@property (nonatomic, retain) UIImageView *headImageView;
@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) YMSimpleRatingBar *ratingBar;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) NSMutableArray<UIImageView *> *imageArr;

@property (nonatomic, retain) YMCommentCellItem *cellItem;
@end

@implementation YMCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        commentTextHeight = 0;
        userNameTextWidth = 0;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kYMBorderMargin, kYMTableViewDefaultRowHeight/4, kYMTableViewDefaultRowHeight/2, kYMTableViewDefaultRowHeight/2)];
        self.headImageView.layer.cornerRadius = kYMTableViewDefaultRowHeight/4;
        self.headImageView.layer.borderColor = rgba(238, 238, 238, 1).CGColor;
        self.headImageView.layer.borderWidth = 0.6f;
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.contentMode = UIViewContentModeScaleToFill;
        self.headImageView.userInteractionEnabled = NO;
        self.headImageView.backgroundColor = [UIColor grayColor];
        self.headImageView.image = [UIImage imageNamed:@"default"];
//        [self.headImageView sd_setImageWithURL:[] placeholderImage:[UIImage imageNamed:@"default"]];

        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kYMBorderMargin+kYMTableViewDefaultRowHeight/2+kYMBorderMargin, 0, userNameTextWidth, kYMTableViewDefaultRowHeight)];
        self.userNameLabel.backgroundColor = [UIColor clearColor];
        self.userNameLabel.textAlignment = NSTextAlignmentLeft;
        self.userNameLabel.font = kYMNormalFont;
        self.userNameLabel.textColor = [UIColor blackColor];
        
        self.ratingBar = [[YMSimpleRatingBar alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userNameLabel.frame)+kYMBorderMargin, 0, 200, kYMTableViewDefaultRowHeight) andStarSize:CGSizeMake(kYMTableViewDefaultRowHeight/3, kYMTableViewDefaultRowHeight/3)];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(g_screenWidth-kYMBorderMargin-kTimeLabelWidth, 0, kTimeLabelWidth, kYMTableViewDefaultRowHeight)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = kYMSmallFont;
        self.timeLabel.textColor = [UIColor grayColor];
        
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kYMBorderMargin, kYMTableViewDefaultRowHeight, g_screenWidth-2*kYMBorderMargin, commentTextHeight)];
        self.commentLabel.backgroundColor = [UIColor clearColor];
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        self.commentLabel.font = kYMSecondNormalFont;
        self.commentLabel.textColor = [UIColor grayColor];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;

        [self addSubview:self.headImageView];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.ratingBar];
        [self addSubview:self.timeLabel];
        [self addSubview:self.commentLabel];
        
        float offsetx = kYMBorderMargin;
        float offsety = kYMTableViewDefaultRowHeight+kYMBorderMargin+commentTextHeight;
        for (int i=0; i<kMaxImageCount; i++) {
            UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetx, offsety, kImageWidth, kImageWidth)];
            commentImageView.contentMode = UIViewContentModeScaleToFill;
            commentImageView.layer.borderColor = rgba(238, 238, 238, 1).CGColor;
            commentImageView.layer.borderWidth = 0.6f;

            commentImageView.userInteractionEnabled = NO;
            commentImageView.backgroundColor = [UIColor grayColor];
            commentImageView.tag = kCommentCellImageTag+i;
            [self addSubview:commentImageView];
            
            commentImageView.hidden = YES;
            offsetx += kImageWidth+kYMBorderMargin;
        }
    }
    return self;
}

- (void)setItem:(YMCommentCellItem *)commentCellItem
{
    _cellItem = commentCellItem;
    YMCommentItem *commentItem = self.cellItem.commentItem;

    userNameTextWidth = [YMUtil sizeWithFont:commentItem.user_name withFont:kYMNormalFont].width ;//commentItem.user_name;
    commentTextHeight = [YMUtil sizeOfString:commentItem.evaluate_desc withWidth:g_screenWidth-2*kYMBorderMargin font:kYMSecondNormalFont].height;
    
    CGRect rect = self.userNameLabel.frame;
    rect.size.width = userNameTextWidth;
    self.userNameLabel.frame = rect;
    self.userNameLabel.text = commentItem.user_name;
    
    rect = self.ratingBar.frame;
    rect.origin.x = CGRectGetMaxX(self.userNameLabel.frame)+kYMBorderMargin;
    self.ratingBar.frame = rect;
    [self.ratingBar setImageWithIndex:[commentItem.evaluate_level intValue]-1];
    
    self.timeLabel.text = commentItem.date;
    
    rect = self.commentLabel.frame;
    rect.size.height = commentTextHeight;
    self.commentLabel.frame = rect;
    self.commentLabel.text = commentItem.evaluate_desc;
    
    NSMutableArray *imageUrlArr = [NSMutableArray new];
    if (commentItem.image_1.length!=0) {
        [imageUrlArr addObject:commentItem.image_1];
    }
    if (commentItem.image_2.length!=0) {
        [imageUrlArr addObject:commentItem.image_2];
    }
    if (commentItem.image_3.length!=0) {
        [imageUrlArr addObject:commentItem.image_3];
    }
    
    float offsety = kYMTableViewDefaultRowHeight+kYMBorderMargin+commentTextHeight;
    for (int i=0; i<kMaxImageCount; i++) {
        UIImageView *commentImageView = [self viewWithTag:kCommentCellImageTag+i];
        
        rect = commentImageView.frame;
        rect.origin.y = offsety;
        commentImageView.frame = rect;
        
        if (i<imageUrlArr.count) {
            [commentImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlArr[i]]];
            commentImageView.hidden = NO;
        } else {
            commentImageView.hidden = YES;
        }
    }
}
@end


@interface YMGoodsCommentController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView* _tableView;
}
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL lastPage;
@property (nonatomic, retain) MJRefreshComponent *myRefreshView;

@property (nonatomic, retain) NSMutableArray<YMCommentCellItem *> *commentCellItems;
@end

@implementation YMGoodsCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgba(238, 238, 238, 1);
    
    [self test];
    
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, g_screenHeight-kYMTopBarHeight-44.f) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = rgba(210, 210, 210, 1);
    _tableView.backgroundColor=[UIColor clearColor];
    [_tableView registerClass:[YMCommentCell class] forCellReuseIdentifier:kCommentCellIdentifier];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    
    _tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    headview.backgroundColor = [UIColor redColor];
    _tableView.tableHeaderView = headview;
    
    _tableView.tableFooterView = [[UIView alloc] init];
    
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0, kYMPadding, 0, kYMPadding)];
    }
    
    [self.view addSubview:_tableView];
    
    [_tableView.mj_header beginRefreshing];
}

- (NSMutableArray<YMCommentCellItem *> *)commentCellItems
{
    if (_commentCellItems==nil) {
        _commentCellItems = [NSMutableArray new];
    }
    return _commentCellItems;
}

- (void)refresh
{
    self.myRefreshView = _tableView.mj_header;

    [_tableView.mj_footer resetNoMoreData];
    self.lastPage = NO;
    self.pageNum = 1;
    [self requestComments];
}

- (void)loadMoreData
{
    self.myRefreshView = _tableView.mj_footer;
    
    if (!self.lastPage) {
        self.pageNum++;
    }
    [self requestComments];
    
}

- (void)requestComments
{
    [self.myRefreshView endRefreshing];
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    _tableView.frame = CGRectMake(0,0,g_screenWidth, g_screenHeight-kYMTopBarHeight-44.f);
//}

#pragma mark UITableViewDelegate, UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentCellItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMCommentCellItem *cellItem = self.commentCellItems[indexPath.row];
    return cellItem.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
    YMCommentCellItem *cellItem = self.commentCellItems[indexPath.row];
    [cell setItem:cellItem];
    return cell;
}

//for Test
- (void)test {
    for (int i =0; i<5; i++) {
        YMCommentItem *commentItem = [[YMCommentItem alloc] init];
        YMCommentCellItem *cellItem = [[YMCommentCellItem alloc] init];
        cellItem.commentItem = commentItem;
        [self.commentCellItems addObject:cellItem];
    }
}
@end
