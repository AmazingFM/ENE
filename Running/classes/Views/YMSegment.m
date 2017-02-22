//
//  YMSegment.m
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMSegment.h"

#import "YMCommon.h"
#import "YMGlobal.h"

#define kYMItemFontSize 15.0f
#define kYMItemMargin 0.0f
#define kYMItemPadding 8.0f


@interface YMSegment ()
@property(nonatomic, strong) UIView *buttonStyle;
@property(nonatomic, assign) CGFloat maxWidth;
@property(nonatomic, strong) NSMutableArray *buttonList;
@property(nonatomic, strong) NSMutableArray *allItems;
@property(nonatomic, weak) UIButton *buttonSelected;
@property(nonatomic, assign) YMSegmentStyle segmentStyle;
@property(nonatomic, assign) CGFloat buttonStyleY;
@property(nonatomic, assign) CGFloat buttonStyleHeight;
@property(nonatomic, assign) BOOL buttonStyleMasksToBounds;
@property(nonatomic, assign) CGFloat buttonStyleCornerRadius;
@end

@implementation YMSegment

+ (YMSegment *)segmentWithFrame:(CGRect)frame style:(YMSegmentStyle)style {
    return [[YMSegment alloc] initWithFrame:frame style:style];
}

#pragma 初始化
- (id)init {
    if (self = [super init]) {
        self.segmentStyle = YMSegmentLineStyle;
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self=[super initWithCoder:coder])) {
        self.segmentStyle = YMSegmentLineStyle;
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self=[super initWithFrame:frame])) {
        self.segmentStyle = YMSegmentLineStyle;
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(YMSegmentStyle)style {
    if ([super initWithFrame:frame]) {
        self.segmentStyle = *(&(style));
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self buttonStyleFromSegmentStyle];
    self.itemDefaultColor = rgba(102.0f, 102.0f, 102.0f, 1.0f);//rgba(202.0f, 51.0f, 54.0f, 1.0f);//rgba(102.0f, 102.0f, 102.0f, 1.0f);
    self.itemStyleSelectedColor = rgba(202.0f, 51.0f, 54.0f, 1.0f);
    switch (self.segmentStyle) {
        case YMSegmentLineStyle:
            self.itemSelectedColor =  rgba(102.0f, 102.0f, 102.0f, 1.0f);
            break;
        case YMSegmentRectangleStyle:
            self.itemSelectedColor = rgba(250.0f, 250.0f, 250.0f, 1.0f);
            break;
        case YMSegmentTextStyle:
            self.itemSelectedColor = rgba(202.0f, 51.0f, 54.0f, 1.0f);
            break;
    }
    self.segmentBackgroundColor = rgba(238.0f, 238.0f, 238.0f, 0.3f);
    self.maxWidth = kYMItemMargin;
    self.buttonList = [NSMutableArray array];
    self.allItems = [NSMutableArray array];
    self.bounces = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.buttonStyle = [[UIView alloc] initWithFrame:CGRectMake(kYMItemMargin, self.buttonStyleY, 0, self.buttonStyleHeight)];
    self.buttonStyle.backgroundColor = self.itemStyleSelectedColor;
    self.buttonStyle.layer.masksToBounds = self.buttonStyleMasksToBounds;
    self.buttonStyle.layer.cornerRadius = self.buttonStyleCornerRadius;
    [self addSubview:self.buttonStyle];
}

- (void)setItemStyleSelectedColor:(UIColor *)itemStyleSelectedColor {
    _itemStyleSelectedColor = itemStyleSelectedColor;
}

- (void)setSegmentBackgroundColor:(UIColor *)segmentBackgroundColor {
    _backgroundColor = segmentBackgroundColor;
    self.backgroundColor = segmentBackgroundColor;
}

- (int)selectedItemIndex {
    if (self.buttonSelected) {
        return [self indexOfItemsWithItem:self.buttonSelected.titleLabel.text];
    }
    return -1;
}

- (NSString *)selectedItem {
    if (self.buttonSelected) {
        return self.buttonSelected.titleLabel.text;
    }
    return nil;
}

- (NSString *)version {
    return @"1.0.0";
}

#pragma 暴露给外部的
- (void)setItems:(NSArray *)items {
    if (!items || items.count == 0) {
        return;
    }
    for (int i = 0; i < self.subviews.count; i++) {
        if (self.subviews[i] != self.buttonStyle) {
            [self.subviews[i--] removeFromSuperview];
        }
    }
    self.buttonStyle.hidden = NO;
    self.maxWidth = kYMItemMargin;
    [self.allItems removeAllObjects];
    [self.allItems addObjectsFromArray:items];
    self.buttonList = nil;
    self.buttonList = [[NSMutableArray alloc] init];
    self.buttonSelected = nil;
    if (self.allItems && self.allItems.count > 0) {
        self.backgroundColor = self.backgroundColor;
        for (int i = 0; i < self.allItems.count; i++) {
            [self createItem:self.allItems[i]];
        }
        self.contentSize = CGSizeMake(self.maxWidth, -4);
        [self fiexButtonWidth];
    }
}

- (NSArray *)items {
    return self.allItems;
}

- (void)itemClickByIndex:(NSInteger)index {
    if (index < 0) {
        return;
    }
    UIButton *item = (UIButton *)self.buttonList[index];
    [self itemClick:item];
}

- (void)addItem:(NSString *)item {
    if (self.buttonList.count == 0) {
        self.buttonStyle.hidden = NO;
    }
    [self.allItems addObject:item];
    [self createItem:item];
    [self resetButtonsFrame];
    [self fiexButtonWidth];
}

- (void)removeItemAtIndex:(NSInteger)index {
    if (self.allItems.count == 0 || index < 0 || index >= self.allItems.count) {
        return;
    }
    [self.allItems removeObjectAtIndex:index];
    UIButton *button = self.buttonList[index];
    [self.buttonList removeObjectAtIndex:index];
    for (int i = 0; i < self.subviews.count; i++) {
        if (self.subviews[i] == button) {
            [self.subviews[i] removeFromSuperview];
        }
    }
    if (button == self.buttonSelected && self.buttonList.count > 0) {
        NSInteger _index = index;
        if (self.buttonList.count >= index && index > 0) {
            _index = index - 1;
        }
        [self itemClick:self.buttonList[_index]];
    }
    if (self.buttonList.count == 0) {
        self.buttonSelected = nil;
        self.buttonStyle.hidden = YES;
    }
    [self resetButtonsFrame];
    [self fiexButtonWidth];
}

- (void)removeItem:(NSString *)item {
    if (self.allItems.count == 0 || ![self.allItems containsObject:item]) {
        return;
    }
    for (NSInteger i = 0; i < self.allItems.count; i++) {
        if ([self.allItems[i] isEqualToString:item]) {
            [self removeItemAtIndex:i];
            return;
        }
    }
}

#pragma 私有的
- (void)buttonStyleFromSegmentStyle {
    switch (self.segmentStyle) {
        case YMSegmentLineStyle:
            self.buttonStyleY = self.frame.size.height - 3;
            self.buttonStyleHeight = 3.0f;
            break;
        case YMSegmentRectangleStyle:
            self.buttonStyleY = kYMItemPadding;
            self.buttonStyleHeight = self.frame.size.height - kYMItemPadding * 2;
            self.buttonStyleCornerRadius = 6.0f;
            self.buttonStyleMasksToBounds = YES;
            break;
        case YMSegmentTextStyle:
            self.buttonStyleY = 0;
            self.buttonStyleHeight = 0.0f;
            break;
    }
}

- (void)fiexButtonWidth {
    if (g_screenWidth - self.maxWidth > kYMItemMargin) {
        CGFloat bigButtonSumWidth = 0;
        int bigButtonCount = 0;
        self.maxWidth = kYMItemMargin;
        CGFloat width =
        (g_screenWidth - (self.buttonList.count + 1) * kYMItemMargin) /
        self.buttonList.count;
        for (int i = 0; i < self.buttonList.count; i++) {
            UIButton *button = self.buttonList[i];
            if (button.frame.size.width > width) {
                bigButtonCount++;
                bigButtonSumWidth += button.frame.size.width;
            }
        }
        width = (g_screenWidth - (self.buttonList.count + 1) * kYMItemMargin - bigButtonSumWidth) / (self.buttonList.count - bigButtonCount);
        for (int i = 0; i < self.buttonList.count; i++) {
            UIButton *button = self.buttonList[i];
            if (button.frame.size.width < width) {
                button.frame =
                CGRectMake(self.maxWidth, 0, width, self.frame.size.height);
                self.maxWidth += width + kYMItemMargin;
            } else {
                button.frame = CGRectMake(self.maxWidth, 0, button.frame.size.width, self.frame.size.height);
                self.maxWidth += button.frame.size.width + kYMItemMargin;
            }
            if (button == self.buttonSelected) {
                self.buttonStyle.frame = CGRectMake(button.frame.origin.x, self.buttonStyleY, button.frame.size.width, self.buttonStyleHeight);
            }
        }
        self.contentSize = CGSizeMake(self.maxWidth, -4);
    }
}

- (void)resetButtonsFrame {
    self.maxWidth = kYMItemMargin;
    
    for (int i = 0; i < self.allItems.count; i++) {
        CGFloat width = [self itemWidthFromSegmentStyle:self.allItems[i]];
        UIButton *button = self.buttonList[i];
        button.frame = CGRectMake(self.maxWidth, 0, width, self.frame.size.height);
        if (button == self.buttonSelected) {
            self.buttonStyle.frame = CGRectMake(self.maxWidth, self.buttonStyleY, width, self.buttonStyleHeight);
        }
        if (!self.buttonSelected) {
            [button setTitleColor:self.itemSelectedColor forState:0];
            [self itemClick:button];
        }
        self.maxWidth += width + kYMItemMargin;
    }
    
    self.contentSize = CGSizeMake(self.maxWidth, -4);
}

- (void)createItem:(NSString *)item {
    CGFloat itemWidth = [self itemWidthFromSegmentStyle:item];
    UIButton *buttonItem = [[UIButton alloc] initWithFrame:CGRectMake(self.maxWidth, 0, itemWidth, self.frame.size.height)];
    buttonItem.titleLabel.font = [UIFont systemFontOfSize:kYMItemFontSize];
    [buttonItem setTitle:item forState:UIControlStateNormal];
    [buttonItem setTitleColor:self.itemDefaultColor forState:UIControlStateNormal];
    [buttonItem addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    self.maxWidth += itemWidth + kYMItemMargin;
    [self.buttonList addObject:buttonItem];
    [self addSubview:buttonItem];
    if (!self.buttonSelected) {
        [buttonItem setTitleColor:self.itemSelectedColor forState:0];
        self.buttonStyle.frame = CGRectMake(buttonItem.frame.origin.x, self.buttonStyleY, buttonItem.frame.size.width, self.buttonStyleHeight);
        [self itemClick:buttonItem];
    }
}

- (CGFloat)itemWidthFromSegmentStyle:(NSString *)item {
    CGFloat itemWidth = [self textWidthWithFontSize:kYMItemFontSize Text:item];
    CGFloat resultItemWidht;
    switch (self.segmentStyle) {
        case YMSegmentLineStyle:
            resultItemWidht = itemWidth;
            break;
        case YMSegmentRectangleStyle:
            resultItemWidht = itemWidth + kYMItemPadding * 2;
            break;
        case YMSegmentTextStyle:
            resultItemWidht = itemWidth;
            break;
    }
    return resultItemWidht;
}

- (void)itemClick:(id)sender {
    UIButton *button = sender;
    if (self.buttonSelected != button) {
        [self.buttonSelected setTitleColor:self.itemDefaultColor forState:0];
        [button setTitleColor:self.itemSelectedColor forState:0];
        self.buttonSelected = button;
        if (self.itemClickBlock) {
            int selectedIndex = [self indexOfItemsWithItem:button.titleLabel.text];
            NSString *selectedItem = button.titleLabel.text;
            self.itemClickBlock(selectedItem, selectedIndex);
        }
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.buttonStyle.frame = CGRectMake(button.frame.origin.x, self.buttonStyleY, button.frame.size.width, self.buttonStyleHeight);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:
                              0.3 animations:^{
                                  CGFloat buttonX = button.frame.origin.x;
                                  CGFloat buttonWidth = button.frame.size.width;
                                  CGFloat scrollerWidth = self.contentSize.width;
                                  // 移动到中间
                                  if (scrollerWidth > g_screenWidth && // Scroller的宽度大于屏幕宽度
                                      buttonX > g_screenWidth / 2.0f - buttonWidth / 2.0f && //按钮的坐标大于屏幕中间位置
                                      scrollerWidth > buttonX + g_screenWidth / 2.0f + buttonWidth / 2.0f // Scroller的宽度大于按钮移动到中间坐标加上屏幕一半宽度加上按钮一半宽度
                                      ) {
                                      self.contentOffset = CGPointMake(button.frame.origin.x - g_screenWidth / 2.0f + button.frame.size.width / 2.0f, 0);
                                  } else if (buttonX < g_screenWidth / 2.0f - buttonWidth / 2.0f) { // 移动到开始
                                      self.contentOffset = CGPointMake(0, 0);
                                  } else if (scrollerWidth - buttonX < g_screenWidth / 2.0f + buttonWidth / 2.0f || // Scroller的宽度减去按钮的坐标小于屏幕的一半，移动到最后
                                             buttonX + buttonWidth + kYMItemMargin == scrollerWidth) {
                                      if (scrollerWidth > g_screenWidth) {
                                          self.contentOffset = CGPointMake(scrollerWidth - g_screenWidth, 0); // 移动到末尾
                                      }
                                  }
                              }];
                         }];
    }
}

- (int)indexOfItemsWithItem:(NSString *)item {
    for (int i = 0; i < self.allItems.count; i++) {
        if ([item isEqualToString:self.allItems[i]]) {
            return i;
        }
    }
    return -1;
}

- (CGFloat)textWidthWithFontSize:(CGFloat)fontSize Text:(NSString *)text {
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
    CGRect size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                     options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attr
                                     context:nil];
    return size.size.width;
}

@end
