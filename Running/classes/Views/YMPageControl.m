//
//  YMPageControl.m
//  Running
//
//  Created by 张永明 on 16/10/27.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMPageControl.h"

#define kPageControlSpace 15
#define kPageControlDotWidth 15

#define kPageControlTag 1000
@interface YMPageControl()
{
//    NSMutableArray *items;
    
//    int lastPos;
}
@end

@implementation YMPageControl

- (void)setNumberOfPages:(int)numberOfPages
{
    _numberOfPages = numberOfPages;
    
    CGFloat offsetx = (self.frame.size.width-kPageControlDotWidth*numberOfPages-kPageControlSpace*(numberOfPages-1))/2;
    CGFloat offsety = (self.frame.size.height-kPageControlDotWidth)/2;
    
    for (int i=0; i<numberOfPages; i++) {
        UIButton *dotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dotBtn.frame = CGRectMake(offsetx+(kPageControlDotWidth+kPageControlSpace)*i, offsety, kPageControlDotWidth, kPageControlDotWidth);
        dotBtn.backgroundColor = _currentPage==i?[UIColor whiteColor]:[UIColor blackColor];
        dotBtn.layer.cornerRadius = kPageControlDotWidth/2;
        dotBtn.layer.masksToBounds = YES;
        dotBtn.tag = kPageControlTag+i;
        
        [self addSubview:dotBtn];
    }
}

- (void)setCurrentPage:(int)currentPage
{
    if (_currentPage==currentPage) {
        return;
    } else {
        UIButton *dotBtn = [self viewWithTag:kPageControlTag+_currentPage];
        if (dotBtn) {
            [dotBtn setBackgroundColor:[UIColor blackColor]];
        }
        
        dotBtn = [self viewWithTag:kPageControlTag+currentPage];
        if (dotBtn) {
            [dotBtn setBackgroundColor:[UIColor whiteColor]];
        }
        _currentPage = currentPage;
    }
}

@end
