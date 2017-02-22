//
//  YMButton.m
//  Running
//
//  Created by freshment on 16/9/26.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMButton.h"

@implementation YMButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, 30, 30);//图片的位置大小
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    
    return CGRectMake(0, 30, 30, 14);//文本的位置大小
}
@end
