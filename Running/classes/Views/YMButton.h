//
//  YMButton.h
//  Running
//
//  Created by freshment on 16/9/26.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMButton : UIButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect;
- (CGRect)titleRectForContentRect:(CGRect)contentRect;

@end
