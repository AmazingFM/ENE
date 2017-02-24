//
//  YMRatingBar.m
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMRatingBar.h"
#import "UIView+Util.h"
@interface YMRatingBar()
{
    CGFloat maxX;
    CGFloat minX;
    CGFloat minY;
    CGFloat maxY;
}

@property (weak, nonatomic)  UIImageView *firstStar;
@property (weak, nonatomic)  UIImageView *secondStar;
@property (weak, nonatomic)  UIImageView *thirdStar;
@property (weak, nonatomic)  UIImageView *forthStar;
@property (weak, nonatomic)  UIImageView *fifthStar;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSInteger score;


@end

#define kStartImageCount 5
#define kStartImagePadding 16
#define kStartImageWidth 25
#define kStarImageBaseTag 100
@implementation YMRatingBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    CGFloat offsetx = 10;

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(offsetx, 0, self.width-offsetx, self.height/2)];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.font = [UIFont systemFontOfSize:14];
    self.label.textColor = [UIColor blackColor];
    self.label.text = @"评分";
    [self addSubview:self.label];
    
    for (int i=0; i<kStartImageCount; i++) {
        UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-starempty"]];
        star.frame = CGRectMake(offsetx, self.height*3/4-kStartImageWidth/2, kStartImageWidth, kStartImageWidth);
        star.contentMode = UIViewContentModeScaleAspectFit;
        star.tag = kStarImageBaseTag+i;
        
        [self addSubview:star];
        offsetx += kStartImageWidth+kStartImagePadding;
    }
    
    self.score = 0;
    minX = 10-kStartImagePadding/2;
    maxX = minX+(kStartImageWidth+kStartImagePadding)*5;
    minY = self.height*3/4-kStartImageWidth/2-10;
    maxY = self.height*3/4+kStartImageWidth/2+10;
}

- (void)setImageWithIndex:(NSInteger)index
{
    for (int i=0; i<kStartImageCount; i++) {
        UIImageView *star = [self viewWithTag:kStarImageBaseTag+i];
        if (i<=index) {
            star.image = [UIImage imageNamed:@"icon-starfull"];
        } else {
            star.image = [UIImage imageNamed:@"icon-starempty"];
        }
    }
}

- (void)setImagesWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGFloat touchX = [touch locationInView:self].x;
    CGFloat touchY = [touch locationInView:self].y;
    
    if (touchX<minX || touchX>maxX || touchY<minY || touchY>maxY) {
        return;
    }
    
    NSInteger index = [self calculateIndex:touchX];
    
    self.score = index+1;//分数
    
    [self setImageWithIndex:index];
}

- (NSInteger)calculateIndex:(CGFloat)pointX
{
    CGFloat perWidth= kStartImageWidth+kStartImagePadding;
    return (pointX-minX)/perWidth;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setImagesWithTouches:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setImagesWithTouches:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ratingBarValue:)]) {
        [self.delegate ratingBarValue:self.score];
    }
}
@end
