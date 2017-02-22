//
//  YMDataBase.m
//  Running
//
//  Created by 张永明 on 16/9/21.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMDataBase.h"
#import "YMUserManager.h"

@implementation YMDataBase

- (id)init
{
    if (self = [super init]) {
        //初始化数据库对象 并打开
        _database = [FMDatabase databaseWithPath:[YMDataBase getDatabasePath]];
        //如果数据库打开失败返回空值
        if (![_database open]) {
            return nil;
        }
    }
    //如果数据库打开成功 创建表
    
    //创建购物车表
    NSString *sql1 = @"create table if not exists running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    //创建兴趣推荐表
    NSString *sql2 = @"create table if not exists running_intrest_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text,goods_name text,goods_image text)";

    BOOL is1 = [_database executeUpdate:sql1];
    BOOL is2 = [_database executeUpdate:sql2];
    
    if (is1 && is2) {
        NSLog(@"创建表成功！");
    }
    return self;
}

//获取数据库管理对象单例的方法
+ (YMDataBase *)sharedDatabase
{
    static YMDataBase *ymdatase = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        ymdatase = [[YMDataBase alloc]init];
    });
    
    return ymdatase;
}

//返回数据库的路径
+ (NSString *)getDatabasePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return [path stringByAppendingPathComponent:@"running.db"];
}

#pragma mark -- 购物车模块
/***********
 *购物车模块
 **************/
//向购物车中添加信息
- (BOOL)insertPdcToCartWithCartItem:(YMShoppingCartItem *)model
{
    if ([self isExistInCartWithGoods:model.goods]) {
        return YES;
    }
    
    //running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    /***************如果该产品在购物车中不存在，加入购物车*******************/
    NSString *sql = @"insert into running_cart(goods_id,goods_subid,goods_name,goods_image,selected,count) values (?,?,?,?,?,?)";
    
    BOOL isInsertOK = YES;
    [_database executeUpdate:sql,model.goods.goods_id,model.goods.sub_gid,model.goods.goods_name,model.goods.goods_image1_mid,[NSNumber numberWithBool:model.selected], [NSNumber numberWithInt:[model.count intValue]]];
    if (isInsertOK) {
        NSLog(@"%@-->插入成功",model.goods.goods_id);
        return YES;
    }  
    return NO;  
}

- (BOOL)insertPdcToCartWithGoods:(YMGoods *)goods
{
    if ([self isExistInCartWithGoods:goods]) {
        
        return YES;
    }
    
    //running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    /***************如果该产品在购物车中不存在，加入购物车*******************/
    NSString *sql = @"insert into running_cart(goods_id,goods_subid,goods_name,goods_image,selected,count) values (?,?,?,?,?,?)";
    
    BOOL isInsertOK = YES;
    [_database executeUpdate:sql,goods.goods_id,goods.sub_gid,goods.goods_name,goods.goods_image1_mid,[NSNumber numberWithBool:YES], [NSNumber numberWithInt:1]];
    if (isInsertOK) {
        NSLog(@"%@-->插入成功",goods.goods_id);
        return YES;
    }
    return NO;
}

- (BOOL)insertPdcToCartWithId:(NSString *)pdcSID andSubid:(NSString *)subid
{
    if ([self isExistInCart:pdcSID andSubid:subid]) {
        
        return YES;
    }
    
    //running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    /***************如果该产品在购物车中不存在，加入购物车*******************/
    NSString *sql = @"insert into running_cart(goods_id,goods_subid,selected,count) values (?,?,?,?)";
    
    BOOL isInsertOK = YES;
    [_database executeUpdate:sql,pdcSID,subid,[NSNumber numberWithBool:YES], [NSNumber numberWithInt:1]];
    if (isInsertOK) {
        NSLog(@"%@,%@-->插入成功",pdcSID, subid);
        return YES;
    }
    return NO;
}

//查询购物车中是否包含此产品记录
- (BOOL)isExistInCart:(NSString *)pdcSID andSubid:(NSString *)subid;
{
    //running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    NSString *sql = @"select * from running_cart where goods_id = ? and goods_subid = ?";
    FMResultSet *results = [_database executeQuery:sql, pdcSID, subid];
    
    while (results.next) {
        [results close];
        return YES;
    }
    [results close];
    return NO;
}

- (BOOL)isExistInCartWithGoods:(YMGoods *)model{
    return [self isExistInCart:model.goods_id andSubid:model.sub_gid];
}

//获取购物车列表
- (NSArray *)getAllpdcInCart
{
    NSString *sql = @"select * from running_cart order by cartId desc";
    
    FMResultSet *results = [_database executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    while (results.next) {
        YMShoppingCartItem *item = [[YMShoppingCartItem alloc] init];
        item.selected = [results intForColumn:@"selected"];
//        item.count = [NSString stringWithFormat:@"%d", [results intForColumn:@"count"]];
        [item setCountWith:[NSString stringWithFormat:@"%d", [results intForColumn:@"count"]]];
        
        YMGoods *goods = [[YMGoods alloc] init];
        goods.goods_id = [results stringForColumn:@"goods_id"];
        goods.sub_gid = [results stringForColumn:@"goods_subid"];
        goods.goods_name = [results stringForColumn:@"goods_name"];
        goods.goods_image1_mid = [results stringForColumn:@"goods_image"];
        item.goods = goods;
        
        [arr addObject:item];
    }
    [results close];
    return arr;
}

- (NSString *)getPdcNumInCart
{
    NSString *sql = @"select * from running_cart order by cartId desc";
    
    FMResultSet *results = [_database executeQuery:sql];
    
    int nCount = 0;
    while (results.next) {
        nCount += [results intForColumn:@"count"];
    }
    [results close];
    return [NSString stringWithFormat:@"%d", nCount];
}

//修改购物车中产品的数量
- (BOOL)updateCountInCart:(int)newCount pdc:(NSString *)pdcId andSubid:(NSString *)subid
{
    //running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    if(![self isExistInCart:pdcId andSubid:subid])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"update running_cart set count = ? where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,[NSNumber numberWithInt:newCount],pdcId, subid];
    if (isOK) {
        return YES;
    }
    return NO;
}

- (BOOL)updateCountInCartByOne:(NSString *)pdcId andSubid:(NSString *)subid
{
    //running_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text, goods_name text, goods_image text, selected integer, count integer)";
    if(![self isExistInCart:pdcId andSubid:subid])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"update running_cart set count = (select count from running_cart where goods_id = ? and goods_subid = ?)+1 where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,pdcId, subid,pdcId, subid];
    if (isOK) {
        return YES;
    }
    return NO;
}

- (BOOL)updateCountInCartWithCartItem:(YMShoppingCartItem *)item
{
    if(![self isExistInCartWithGoods:item.goods])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"update running_cart set count = ? where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,item.count,item.goods.goods_id, item.goods.sub_gid];
    if (isOK) {
        return YES;
    }
    return NO;

}

//修改购物车中产品的选中状态
- (BOOL)updateSelectedState:(BOOL)select pdc:(NSString *)pdcId andSubid:(NSString *)subid;
{
    if(![self isExistInCart:pdcId andSubid:subid])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"update running_cart set selected = ? where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,[NSNumber numberWithBool:select],pdcId, subid];
    if (isOK) {
        return YES;
    }
    return NO;
}

- (BOOL)updateSelectedStateWithCartItem:(YMShoppingCartItem *)item
{
    if(![self isExistInCartWithGoods:item.goods])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"update running_cart set selected = ? where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,[NSNumber numberWithBool:item.selected],item.goods.goods_id, item.goods.sub_gid];
    if (isOK) {
        return YES;
    }
    return NO;

}

//删除购物车中得产品记录
- (BOOL)deletePdcInCartById:(NSString *)pdcId  andSubid:(NSString *)subid
{
    if(![self isExistInCart:pdcId andSubid:subid])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"delete from running_cart where goods_id = ? and goods_subid = ?";

    BOOL isOK = [_database executeUpdate:sqll,pdcId, subid];
    if (isOK) {
        return YES;
    }
    return NO;
}

- (BOOL)deletePdcInCartByGoods:(YMGoods *)goods
{
    if(![self isExistInCartWithGoods:goods])/********如果购物车中没有该产品*********/
    {
        return NO;
    }
    NSString *sqll = @"delete from running_cart where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,goods.goods_id, goods.sub_gid];
    
    
    NSString *num = [self getPdcNumInCart];
    [YMUserManager sharedInstance].shoppingNum = num;

    if (isOK) {
        return YES;
    }
    return NO;
}

- (BOOL)deletePdcInCartWithList:(NSArray *)goodsList
{
    [_database beginTransaction];
    BOOL isRollBack = NO;
    
    @try {
        for (YMGoods *goods in goodsList)
        {
            NSString *sql = @"delete from running_cart where goods_id = ? and goods_subid = ?";
            BOOL a = [_database executeUpdate:sql,goods.goods_id, goods.sub_gid];
            if (!a) {
                NSLog(@"删除失败");
            }
        }
        
    } @catch (NSException *exception) {
        isRollBack = YES;
        [_database rollback];
    } @finally {
        if (!isRollBack) {
            [_database commit];
        }
    }
    
    NSString *num = [self getPdcNumInCart];
    [YMUserManager sharedInstance].shoppingNum = num;
    
    return !isRollBack;
}

#pragma mark - 兴趣记录
/***************
 *兴趣记录部分
 *****************/
//向购物车(兴趣)中添加信息
- (BOOL)insertPdcToIntrestCartWithModel:(YMGoods *)model
{
//    @"create table if not exists running_intrest_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text,goods_name text,goods_image text)";

    if ([self isExistInIntrestCart:model]) {/***************如果该产品已存在于购物车,删掉*******/
        [self deleIntrestPdcWithGoods:model];
    }
    /***************加入购物车*******************/
    NSString *sql = @"insert into running_intrest_cart(goods_id,goods_subid,goods_name,goods_image) values (?,?,?,?)";
    BOOL isInsertOK = [_database executeUpdate:sql,model.goods_id,model.sub_gid, model.goods_name,model.goods_image1_mid];
    if (isInsertOK) {
        NSLog(@"添加收藏成功");
        return YES;
    }
    
    return NO;
}

//查询购物车（兴趣）中是否包含此产品记录
- (BOOL)isExistInIntrestCart:(YMGoods *)model
{
    NSString *sql = @"select * from running_intrest_cart where goods_id = ? and goods_subid = ?";
    FMResultSet *results = [_database executeQuery:sql,model.goods_id, model.sub_gid];
    
    while (results.next) {
        [results close];
        return YES;
    }
    [results close];
    return NO;
}

- (BOOL)isExistInIntrestCartWithId:(NSString *)pdcId andSubid:(NSString *)subid
{
    NSString *sql = @"select * from running_intrest_cart where goods_id = ? and goods_subid = ?";
    FMResultSet *results = [_database executeQuery:sql,pdcId,subid];
    
    while (results.next) {
        [results close];
        return YES;
    }
    [results close];
    return NO;
}

//广东省深圳市南山区南头街道南海大道西海明珠大厦F座11楼B11
//删除兴趣中某一条数据
- (BOOL)deleIntrestPdcWithGoods:(YMGoods*)model
{
    NSString *sqll = @"delete from running_intrest_cart where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll,model.goods_id, model.sub_gid];
    if (isOK) {
        NSLog(@"删除收藏成功");
        return YES;
    }
    NSLog(@"删除收藏失败");
    return NO;
}

- (BOOL)deleIntrestPdcWithId:(NSString *)pdcId  andSubid:(NSString *)subid
{
    NSString *sqll = @"delete from running_intrest_cart where goods_id = ? and goods_subid = ?";
    BOOL isOK = [_database executeUpdate:sqll, pdcId, subid];
    if (isOK) {
        NSLog(@"删除收藏成功");
        return YES;
    }
    NSLog(@"删除收藏失败");
    return NO;
}

- (BOOL)deleIntrestPdcInCartWithList:(NSArray *)goodsList
{
    [_database beginTransaction];
    BOOL isRollBack = NO;
    
    @try {
        for (YMGoods *goods in goodsList)
        {
            NSString *sql = @"delete from running_intrest_cart where goods_id = ? and goods_subid = ?";
            BOOL a = [_database executeUpdate:sql,goods.goods_id, goods.sub_gid];
            if (!a) {
                NSLog(@"删除失败");
            }
        }
        
    } @catch (NSException *exception) {
        isRollBack = YES;
        [_database rollback];
    } @finally {
        if (!isRollBack) {
            [_database commit];
        }
    }
    return !isRollBack;
}

//@"create table if not exists running_intrest_cart(cartId integer primary key autoincrement, goods_id text, goods_subid text,goods_name text,goods_image text)";
//获取购物车(兴趣)列表
- (NSArray *)getAllpdcInIntrestCart
{
    NSString *sql = @"select * from running_intrest_cart order by cartId desc";
    FMResultSet *results = [_database executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    while (results.next) {
        YMShoppingCartItem *item = [[YMShoppingCartItem alloc] init];
        item.isFavorate = YES;
        
        YMGoods *goods = [[YMGoods alloc] init];
        goods.goods_id = [results stringForColumn:@"goods_id"];
        goods.sub_gid = [results stringForColumn:@"goods_subid"];
        goods.goods_name = [results stringForColumn:@"goods_name"];
        goods.goods_image1_mid = [results stringForColumn:@"goods_image"];
        item.goods = goods;

        [arr addObject:item];
    }
    
    for (YMShoppingCartItem *item in arr) {
        if ([self isExistInCartWithGoods:item.goods]) {
            item.isInCart = YES;
        } else {
            item.isInCart = NO;
        }
    }
    
    return arr;
}

//清空数据库
- (BOOL)deleteDatabase
{
    NSString *sql1 = @"delete from running_intrest_cart";
    NSString *sql2 = @"delete from running_cart";
    BOOL isOK1 = [_database executeUpdate:sql1];
    BOOL isOK2 = [_database executeUpdate:sql2];
    if (isOK1 && isOK2) {
        return YES;
    }
    return NO;
}

//打开数据库
- (void)openDatabase
{
    [_database open];
}

//关闭数据库
- (void)closeDatabase
{
    if (_database) {
        [_database close];
    }
}
@end
