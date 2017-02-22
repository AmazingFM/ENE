//
//  YMCellItems.m
//  Running
//
//  Created by freshment on 16/9/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCellItems.h"

#import "YMDataBase.h"
#import "YMUserManager.h"
#import "YMUtil.h"

@implementation YMBaseCellItem
-(NSString *)value{return _value;}
@end

@implementation YMFieldCellItem

- (void)setValue:(NSString *)value
{
    self.fieldText = value;
}

-(NSString *)value
{
    if(self.userInteractionDisabled){
        return @"";
    }else {
        return self.fieldText?:@"";
    }
}

@end

@implementation YMRadioCellItem

- (void)setValue:(NSString *)value
{
    if (value==nil||value.length==0) {
        _selectedIndex = -1;
        return;
    }
    
    _selectedIndex = [value intValue];
}

- (NSString *)value
{
    if (_selectedIndex==-1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%d", _selectedIndex];
}
@end

@implementation YMImageCellItem

@end

@implementation YMDateCellItem

- (NSString *)value
{
    if (self.showValue.length==0) {
        return @"";
    }
    
    return [YMUtil dateStringTransform:self.showValue fromFormat:@"yyyy-MM-dd" toFormat:@"yyyyMMdd"];
}

- (void)setValue:(NSString *)value
{
    if (value==nil || value.length==0) {
        self.showValue = @"";
        return;
    }
    
    self.showValue = [YMUtil dateStringTransform:value fromFormat:@"yyyyMMdd" toFormat:@"yyyy-MM-dd"];
}
@end


@implementation YMCellItems

@end

@implementation YMShoppingCartItem

- (void)setCount:(NSString *)count
{
    _count = count;
    
    [[YMDataBase sharedDatabase] updateCountInCartWithCartItem:self];
    
    NSString *num = [[YMDataBase sharedDatabase] getPdcNumInCart];
    [YMUserManager sharedInstance].shoppingNum = num;
}

- (void)setCountWith:(NSString *)count
{
    _count = count;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    [[YMDataBase sharedDatabase] updateSelectedStateWithCartItem:self];
}
@end

@implementation YMAddressItem

- (void)setAddress:(YMAddress *)address
{
    _address = address;
    
    CGFloat height = 0.f;
    CGSize tmpSize = [YMUtil sizeWithFont:_address.delivery_name withFont:kYMBigFont];
    height += tmpSize.height+10.f;
    
    tmpSize = [YMUtil sizeWithFont:_address.delivery_name withFont:kYMNormalFont];
    height += tmpSize.height*2+10.f;
    
    height += 1.f;
    
    tmpSize = [YMUtil sizeWithFont:_address.delivery_name withFont:kYMSmallFont];
    height += tmpSize.height+10.f;
    
    self.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
}

@end

