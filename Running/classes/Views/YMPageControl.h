//
//  YMPageControl.h
//  Running
//
//  Created by 张永明 on 16/10/27.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMPageControl : UIView

@property (nonatomic) int numberOfPages;
@property (nonatomic) int currentPage;

- (void)setNumberOfPages:(int)numberOfPages;
- (void)setCurrentPage:(int)currentPage;

@end
