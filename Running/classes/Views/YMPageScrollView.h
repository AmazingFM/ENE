//
//  YMPageScrollView.h
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMPageScrollViewDelegate <NSObject>

- (void)pageControlItemClick:(NSInteger)index;

@end

@interface YMPageScrollView : UIView

@property (nonatomic, weak) id<YMPageScrollViewDelegate> delegate;
- (void)setItems:(NSArray *)items;
@end
