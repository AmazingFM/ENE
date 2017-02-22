//
//  YMToolbarView.h
//  Running
//
//  Created by freshment on 16/9/16.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kYMToolbarIconTag  1001

@protocol  YMToolbarDelegate<NSObject>
@optional
-(void)toolbarSelectAtIndex:(int)selectIndex;
-(void)toolbarSelectAtIndex:(int)selectIndex withTitle:(NSString*)title;
@end

@interface YMToolbarItem : UIView
@property(nonatomic,strong)UIImageView* iconView;
@property(nonatomic,strong)UILabel*     titleLabel;
@property(nonatomic,strong)UILabel*     badgeView;
@end

@interface YMToolbarView : UIControl
@property(nonatomic,strong)NSArray* titles;
@property(nonatomic,strong)NSArray* iconNames;
@property(nonatomic,weak)id<YMToolbarDelegate> toolbarDelegate;
@property(nonatomic) int lineIndex;
-(id)initWithFrame:(CGRect)frame withTitles:(NSArray*)titles withIconNames:(NSArray*)iconNames;
-(YMToolbarItem*)baritemWithIndex:(int)index;
- (void)addLine:(int)index;

- (void)showBadgeOnItemIndex:(int)index withValue:(NSString *)value;//显示小红点

@end
