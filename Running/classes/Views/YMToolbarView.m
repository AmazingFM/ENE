//
//  YMToolbarView.m
//  Running
//
//  Created by freshment on 16/9/16.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMToolbarView.h"

#define kYMToolbarBtnTag  1000
#define kYMToolbarIconSize 18
#define kYMToolbarTitleSize 24

#define kYMToolbarBadgeRadius 5
@implementation YMToolbarItem
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _iconView=[[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-kYMToolbarIconSize)/2,0,kYMToolbarIconSize,kYMToolbarIconSize)];
        _iconView.contentMode = UIViewContentModeScaleToFill;
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,kYMToolbarTitleSize-4,frame.size.width,kYMToolbarTitleSize)];
        _titleLabel.font=[UIFont systemFontOfSize:12];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor=[UIColor clearColor];
        
        //新建小红点
        _badgeView = [[UILabel alloc]init];
        _badgeView.tag = 888;
        _badgeView.layer.cornerRadius = kYMToolbarBadgeRadius;//圆形
        _badgeView.backgroundColor = [UIColor redColor];//颜色：红色
        _badgeView.font=[UIFont systemFontOfSize:8];
        _badgeView.layer.masksToBounds=YES;
        _badgeView.textColor=[UIColor whiteColor];
        _badgeView.textAlignment=NSTextAlignmentCenter;
        _badgeView.adjustsFontSizeToFitWidth=YES;
        _badgeView.hidden = YES;

        [self addSubview:_iconView];
        [self addSubview:_titleLabel];
        [self addSubview:_badgeView];
    }
    return self;
}
-(void)setTitle:(NSString*)title withIcon:(NSString*)iconName{
    _titleLabel.text=title;
    _titleLabel.textColor = [UIColor blackColor];
    [_iconView setImage:[UIImage imageNamed:iconName]];
}

- (void)setBadgeValue:(NSString *)badgeValue{
    int bardge = [badgeValue intValue];
    
    CGRect viewFrame = self.frame;
    CGFloat x = ceilf((viewFrame.size.width+kYMToolbarIconSize)/2);
    CGFloat y = -kYMToolbarBadgeRadius+2;

    _badgeView.hidden = NO;
    if(bardge>0){
        if(bardge<10){
            _badgeView.text=[NSString stringWithFormat:@"%i",bardge];
            _badgeView.frame=CGRectMake(x,y,kYMToolbarBadgeRadius*2,kYMToolbarBadgeRadius*2);
        }else if(bardge<99){
            _badgeView.text=[NSString stringWithFormat:@"%i",bardge];
            _badgeView.frame=CGRectMake(x,y,kYMToolbarBadgeRadius*3,kYMToolbarBadgeRadius*2);
        }else {
            _badgeView.text=[NSString stringWithFormat:@"%i",bardge];
            _badgeView.frame=CGRectMake(x,y,kYMToolbarBadgeRadius*3,kYMToolbarBadgeRadius*2);
        }
    } else {
        _badgeView.hidden = YES;
    }
}
@end

@implementation YMToolbarView

-(id)initWithFrame:(CGRect)frame withTitles:(NSArray*)titles withIconNames:(NSArray*)iconNames{
    self=[super initWithFrame:frame];
    if(self){
        self.lineIndex = -1;
        float perWidth=frame.size.width/titles.count;
        for (int i=0;i<titles.count;i++) {
            YMToolbarItem* barItem=[[YMToolbarItem alloc] initWithFrame:CGRectMake(perWidth*i,5,perWidth,frame.size.height)];
            [barItem setTitle:titles[i] withIcon:iconNames[i]];
            [self addSubview:barItem];
            barItem.tag=kYMToolbarBtnTag+i;
        }
        UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGesture];
        self.titles = [[NSMutableArray alloc] initWithArray:titles];
    }
    return self;
}

- (void)addLine:(int)index
{
    self.lineIndex = index;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.lineIndex>=0) {
        float perWidth=self.frame.size.width/self.titles.count;
        CGSize size = self.frame.size;
        float offsetx = perWidth*self.lineIndex;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 0.5f);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        
        CGContextSetAllowsAntialiasing(context,YES);
        CGContextMoveToPoint(context, offsetx,0);
        
        CGContextAddLineToPoint(context,offsetx,size.height/2-5);
        CGContextAddLineToPoint(context, offsetx+5,size.height/2);
        CGContextAddLineToPoint(context, offsetx,size.height/2+5);
        
        CGContextAddLineToPoint(context, offsetx,size.height);
        CGContextStrokePath(context);
    }
}

-(void)handleTap:(UIGestureRecognizer*)gesture{
    CGPoint point=[gesture locationInView:self];
    int selectedIndex=point.x/(self.frame.size.width/self.titles.count);
    
    if(self.toolbarDelegate){
        if([self.toolbarDelegate respondsToSelector:@selector(toolbarSelectAtIndex:withTitle:)]){
            [self.toolbarDelegate toolbarSelectAtIndex:selectedIndex withTitle:self.titles[selectedIndex]];
        }else if([self.toolbarDelegate respondsToSelector:@selector(toolbarSelectAtIndex:)]){
            [self.toolbarDelegate toolbarSelectAtIndex:selectedIndex];
        }
    }
}

-(YMToolbarItem*)baritemWithIndex:(int)index{
    return (YMToolbarItem*)[self viewWithTag:kYMToolbarBtnTag+index];
}

//显示小红点
- (void)showBadgeOnItemIndex:(int)index withValue:(NSString *)value{
    YMToolbarItem* barItem = [self viewWithTag:kYMToolbarBtnTag+index];
    [barItem setBadgeValue:value];
}

@end
