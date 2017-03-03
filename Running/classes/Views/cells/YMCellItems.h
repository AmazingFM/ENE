//
//  YMCellItems.h
//  Running
//
//  Created by freshment on 16/9/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "YMGoods.h"
#import "YMAddress.h"

typedef enum {
    YMFieldTypeUnlimited,       //不限制
    YMFieldTypeAmount,          //金额/价格，限数字和小数点
    YMFieldTypeNumber,          //数字,数量，限数字
    YMFieldTypeCharacterEn,     //数字,大小写
    YMFieldTypeCharater,        //大小写、汉字、数字
    YMFieldTypePassword,        //密码
}YMFieldType;

@interface YMBaseCellItem :NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, retain) UIColor *backColor;

@property (nonatomic, retain) NSIndexPath *indexPath;
-(NSString *)value;
@end

@interface YMFieldCellItem :YMBaseCellItem

@property(nonatomic,copy)NSString* fieldText;
@property(nonatomic,copy)NSString* placeholder;
@property(nonatomic)BOOL           secureTextEntry;
@property(nonatomic)BOOL           userInteractionDisabled;//屏蔽输入
@property(nonatomic)BOOL           showClear;//cancle标志
@property(nonatomic)int            actionLen;
@property(nonatomic)YMFieldType     fieldType;
@property(nonatomic) NSTextAlignment anchor;

@end

@interface YMRadioCellItem : YMBaseCellItem

@property (nonatomic, retain) NSArray *titleItems;
@property (nonatomic) int selectedIndex;

@end

@interface YMImageCellItem :YMBaseCellItem
@property(nonatomic) NSTextAlignment anchor;
@end


@interface YMDateCellItem :YMBaseCellItem

@property(nonatomic, copy) NSString *showValue;
@property(nonatomic) NSTextAlignment anchor;

@end

@interface YMCellItems : NSObject

@end

@interface YMShoppingCartItem : NSObject

@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL isInCart;
@property (nonatomic) BOOL isFavorate;

@property (nonatomic, copy) NSString *count;
@property (nonatomic, retain) YMGoods *goods;
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic) CGSize size;

- (void)setCountWith:(NSString *)count;
@end

@interface YMAddressItem : NSObject

@property (nonatomic, retain) YMAddress *address;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic) CGSize size;

@end


