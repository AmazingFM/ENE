//
//  YMImageButton.h
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMImageButton : UIControl
{
    UIImageView *_imageView;
}

- (void)setImage:(UIImage *)image;
- (void)setImageURL:(NSString *)url;
- (void)setImageURL:(NSString *)url withPlaceholder:(UIImage *)holderImage;

@end

@interface YMImageTitleButton : YMImageButton

- (void)setTitle:(NSString *)title;
- (void)setTitleFrame:(CGRect)titleFrame imgFrame:(CGRect)imgFrame;
- (void)setTitleColor:(UIColor *)titleColor;

@end
