//
//  YMMainSearchBar.m
//  Running
//
//  Created by 张永明 on 2017/5/4.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMSearchBar.h"

@implementation YMSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.0;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        _bgView = [[UIView alloc] initWithFrame:frame];
        _bgView.backgroundColor = [UIColor whiteColor];
        
        _titleLab=[[UILabel alloc] initWithFrame:frame];
        _titleLab.backgroundColor=[UIColor clearColor];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        _titleLab.font=[UIFont systemFontOfSize:15];
        _titleLab.textColor=[UIColor whiteColor];
        
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        singleRecognizer.numberOfTouchesRequired = 1; // 触点数
        [self addGestureRecognizer:singleRecognizer];
        
        [self addSubview:_bgView];
        [self addSubview:_titleLab];
    }
    return self;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder=placeholder;
    _titleLab.text=placeholder;
}

-(void)setBGViewAlpha:(float)alpha
{
    _bgView.alpha=alpha;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchBarAction)]){
        [self.delegate searchBarAction];
    }
}

@end
