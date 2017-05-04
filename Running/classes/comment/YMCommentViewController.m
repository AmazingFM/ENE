//
//  YMCommentViewController.m
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMCommentViewController.h"
#import "YMRatingBar.h"
#import "YMTextView.h"
#import "YMImageLoadView.h"

#define MAX_LIMIT_NUMS 50 //来限制最大输入只能50个字符

@interface YMDoCommentCell()
{
    float goodsImageHeight;
    float textViewHeight;
    float imageLoadHeight;
    
    NSInteger commentScore;
}

@end

@implementation YMDoCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    
}

@end

@interface YMCommentViewController () <YMRatingBarDelegate, UITextViewDelegate>
{
    float goodsImageHeight;
    float textViewHeight;
    float imageLoadHeight;
    
    BOOL isAnoymous;
    NSInteger commentScore;
    
    BOOL isGoing;
    
    YMGoods *goods;
}

@property (nonatomic, retain) UIImageView *goodImageView;
@property (nonatomic, retain) YMRatingBar *ratingBar;
@property (nonatomic, retain) YMTextView *textView;
@property (nonatomic, retain) YMImageLoadView *imageLoadView;
@property (nonatomic, retain) UIButton *submitButton;

@property (nonatomic, retain) UILabel *countLabel;
@property (nonatomic, retain) UILabel *anoymousLabel;
@end

@implementation YMCommentViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        goodsImageHeight = 80;
        textViewHeight = 150;
        imageLoadHeight = 60;
        
        isAnoymous = NO;
        isGoing = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    goods = nil;//self.commentDict[@"goods"];
    self.navigationItem.title = @"评价";
    
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    self.view.backgroundColor = rgba(238, 238, 238, 1);
    
    CGFloat commentHeight = kYMBorderMargin+goodsImageHeight+kYMBorderMargin+textViewHeight+kYMBorderMargin+imageLoadHeight+10;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, kYMTopBarHeight, g_screenWidth, commentHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    float offsetx = kYMBorderMargin;
    float offsety = kYMBorderMargin;
    self.goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetx, offsety, goodsImageHeight, goodsImageHeight)];
    self.goodImageView.contentMode = UIViewContentModeScaleToFill;
    self.goodImageView.userInteractionEnabled = NO;
    self.goodImageView.backgroundColor = [UIColor grayColor];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:goods.goods_image1] placeholderImage:[UIImage imageNamed:@"default"]];
    
    self.ratingBar = [[YMRatingBar alloc] initWithFrame:CGRectMake(offsetx+goodsImageHeight+kYMBorderMargin, offsety, g_screenWidth-2*offsetx-goodsImageHeight-kYMBorderMargin, goodsImageHeight)];
    self.ratingBar.delegate = self;
    
    offsety += goodsImageHeight+kYMBorderMargin;
    self.textView = [[YMTextView alloc] initWithFrame:CGRectMake(offsetx, offsety, g_screenWidth-2*offsetx, textViewHeight)];
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.delegate = self;
    self.textView.layer.borderColor = rgba(238, 238, 238, 1).CGColor;
    self.textView.layer.borderWidth = 0.6f;
    self.textView.placeholder = @"写下购买体会和使用感受来供他人参考吧~";
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.returnKeyType = UIReturnKeyDone;
    
    CGRect textViewFrame = self.textView.frame;
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textViewFrame)-100-5, CGRectGetMaxY(textViewFrame)-30, 100, 30)];
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.font = [UIFont systemFontOfSize:14];
    self.countLabel.textColor = [UIColor grayColor];
    self.countLabel.text = @"0/50";
    
    
    offsety += textViewHeight+kYMBorderMargin;
    self.imageLoadView = [[YMImageLoadView alloc] initWithFrame:CGRectMake(offsetx, offsety, g_screenWidth-2*offsetx, imageLoadHeight) withMaxCount:4];
    
    offsety += kYMTopBarHeight+imageLoadHeight+kYMBorderMargin+10;
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.frame = CGRectMake(offsetx,offsety, g_screenWidth-2*kYMBorderMargin, kYMTableViewDefaultRowHeight);
    [self.submitButton setCornerRadius:5.f];
    self.submitButton.backgroundColor = [YMUtil colorWithHex:0xffcc02];
    [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = kYMBigFont;
    self.submitButton.tag = 1000;
    [self.submitButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    offsety += kYMTableViewDefaultRowHeight+kYMBorderMargin;
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.frame = CGRectMake(0,offsety,g_screenWidth, kYMTableViewDefaultRowHeight);
    [checkBtn setImage:[UIImage imageNamed:@"icon-checkoff"] forState:UIControlStateNormal];
    [checkBtn setImage:[UIImage imageNamed:@"icon-checkon"] forState:UIControlStateSelected];
    [checkBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [checkBtn setTitle:@"匿名评价" forState:UIControlStateNormal];
    checkBtn.titleLabel.font = kYMNormalFont;
    checkBtn.backgroundColor = [UIColor clearColor];
    checkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    checkBtn.tag = 1001;
    checkBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    checkBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    checkBtn.selected = isAnoymous;
    [checkBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:self.goodImageView];
    [backView addSubview:self.ratingBar];
    [backView addSubview:self.textView];
    [backView addSubview:self.countLabel];
    [backView addSubview:self.imageLoadView];
    
    [self.view addSubview:self.submitButton];
    [self.view addSubview:checkBtn];
}

- (void)buttonClick:(UIButton *)sender
{
    if (sender.tag==1000) {
        if (!isGoing) {
            [self submitComment];
            self.submitButton.enabled = NO;
        }
    } else if (sender.tag==1001) {
        sender.selected = !sender.selected;
        isAnoymous = sender.selected;
    }
}

- (void)submitComment
{
    isGoing = YES;
    self.submitButton.enabled = YES;
    isGoing = NO;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITextViewDelegate


- (void)textViewDidChange:(UITextView *)textView
{
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
    }
    
    //不让显示负数
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d",MIN(MAX_LIMIT_NUMS,existTextNum),MAX_LIMIT_NUMS];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

#pragma mark YMRatingBarDelegate
- (void)ratingBarValue:(NSInteger)score
{
    commentScore = score;
}


@end
