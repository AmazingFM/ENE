//
//  YMGoodsCommentController.m
//  Running
//
//  Created by 张永明 on 2017/2/25.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMGoodsCommentController.h"

#import "YMRatingBar.h"

@interface YMCommentItem()

@end

@implementation YMCommentItem
@end

#define kCommentCellBaseTag 1000
@interface YMCommentCell()

@property (nonatomic, retain) UIImageView *headImageView;
@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) YMSimpleRatingBar *ratingBar;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) NSMutableArray<UIImageView *> *imageArr;

@end

@implementation YMCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kYMBorderMargin, kYMTableViewDefaultRowHeight/4, kYMTableViewDefaultRowHeight/2, kYMTableViewDefaultRowHeight/2)];
        self.headImageView.contentMode = UIViewContentModeScaleToFill;
        self.headImageView.userInteractionEnabled = NO;
        self.headImageView.backgroundColor = [UIColor grayColor];
        self.headImageView.image = [UIImage imageNamed:@"default"];
//        [self.headImageView sd_setImageWithURL:[] placeholderImage:[UIImage imageNamed:@"default"]];

        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textViewFrame)-100-5, CGRectGetMaxY(textViewFrame)-30, 100, 30)];
        self.userNameLabel.backgroundColor = [UIColor clearColor];
        self.userNameLabel.textAlignment = NSTextAlignmentRight;
        self.userNameLabel.font = [UIFont systemFontOfSize:14];
        self.userNameLabel.textColor = [UIColor grayColor];
    }
}

- (void)setCommentItem:(YMCommentItem *)commentItem
{
    
}
@end


@interface YMGoodsCommentController ()

@end

@implementation YMGoodsCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
