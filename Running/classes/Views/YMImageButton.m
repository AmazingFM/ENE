//
//  YMImageButton.m
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMImageButton.h"

#import "YMCommon.h"
#import "UIImageView+AFNetworking.h"

@interface YMImageButton()
{
    NSString *_imageURL;
}
@end

@implementation YMImageButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_imageView setFrame:self.bounds];
}

- (void)setImage:(UIImage *)image
{
    [_imageView setImage:image];
}

- (void)setImageURL:(NSString *)url
{
    [self setImageURL:url withPlaceholder:[UIImage imageNamed:@"defaultMenu"]];//
}

- (void)setImageURL:(NSString *)url withPlaceholder:(UIImage *)holderImage
{
    [_imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:holderImage];
}
@end

@implementation YMImageTitleButton
{
    UILabel *_titleLabel;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.font=[UIFont systemFontOfSize:14];
        _titleLabel.backgroundColor=[UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    _titleLabel.text=title;
}

-(void)setTitleColor:(UIColor*)color{
    _titleLabel.textColor=color;
}

-(void)setTitleFrame:(CGRect)titleFrame imgFrame:(CGRect)imgFrame{
    _imageView.frame=imgFrame;
    _titleLabel.frame=titleFrame;
    _titleLabel.textColor=rgba(75,75,75,1);
}

@end
