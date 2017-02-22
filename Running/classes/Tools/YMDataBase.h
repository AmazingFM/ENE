//
//  YMDataBase.h
//  Running
//
//  Created by 张永明 on 16/9/21.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

#import "YMCellItems.h"

@interface YMDataBase : NSObject
{
    FMDatabase *_database;
}

+ (instancetype)sharedDatabase;

+ (NSString *)getDatabasePath;

- (void)openDatabase;

- (void)closeDatabase;

- (BOOL)deleteDatabase;

/***********
 *购物车模块
 **************/
//向购物车中添加信息
- (BOOL)insertPdcToCartWithCartItem:(YMShoppingCartItem *)item;
- (BOOL)insertPdcToCartWithGoods:(YMGoods *)goods;
- (BOOL)insertPdcToCartWithId:(NSString *)pdcSID andSubid:(NSString *)subid;
//获取购物车列表
- (NSArray *)getAllpdcInCart;
- (NSString *)getPdcNumInCart;
//查询购物车中是否包含此产品记录
- (BOOL)isExistInCart:(NSString *)pdcSID andSubid:(NSString *)subid;
//购物车是否存在商品
- (BOOL)isExistInCartWithGoods:(YMGoods*)model;
//修改购物车中产品的数量
- (BOOL)updateCountInCart:(int)newCount pdc:(NSString *)pdcId andSubid:(NSString *)subid;
- (BOOL)updateCountInCartByOne:(NSString *)pdcId andSubid:(NSString *)subid;
- (BOOL)updateCountInCartWithCartItem:(YMShoppingCartItem *)item;
//修改购物车中产品的选中状态
- (BOOL)updateSelectedState:(BOOL)select pdc:(NSString *)pdcId andSubid:(NSString *)subid;
- (BOOL)updateSelectedStateWithCartItem:(YMShoppingCartItem *)item;
//删除购物车中得产品记录
- (BOOL)deletePdcInCartById:(NSString *)pdcId  andSubid:(NSString *)subid;
- (BOOL)deletePdcInCartByGoods:(YMGoods *)goods;
- (BOOL)deletePdcInCartWithList:(NSArray *)goodsList;

//向购物车(兴趣)中添加信息
- (BOOL)insertPdcToIntrestCartWithModel:(YMGoods *)model;
//获取购物车(兴趣)列表
- (NSArray *)getAllpdcInIntrestCart;
//购物车(兴趣)是否存在商品
- (BOOL)isExistInIntrestCart:(YMGoods *)model;
- (BOOL)isExistInIntrestCartWithId:(NSString *)pdcId andSubid:(NSString *)subid;

//删除兴趣购物车中得产品记录
- (BOOL)deleIntrestPdcWithGoods:(YMGoods*)goods;
- (BOOL)deleIntrestPdcWithId:(NSString *)pdcId  andSubid:(NSString *)subid;
- (BOOL)deleIntrestPdcInCartWithList:(NSArray *)goodsList;
@end
