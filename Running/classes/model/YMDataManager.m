//
//  YMDataManager.m
//  Running
//
//  Created by freshment on 16/9/24.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMDataManager.h"
#import "YMUtil.h"

@implementation YMDataManager

+ (instancetype)shared
{
    static YMDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMDataManager alloc] init];
    });
    return instance;
}

- (NSMutableArray<YMCity *> *)cityList
{
    if (_cityList==nil) {
        _cityList = [[NSMutableArray<YMCity *> alloc] init];
    }
    return _cityList;
}

- (NSMutableArray<YMAddress *> *)addressList
{
    if (_addressList==nil) {
        _addressList = [[NSMutableArray<YMAddress *> alloc] init];
    }
    return _addressList;
}

- (void)initWithCitylist:(NSArray<YMCity *> *)cities
{
    if (cities==nil) {
        return;
    }
    [self.cityList removeAllObjects];
    [self.cityList addObjectsFromArray:cities];
}

- (void)initWithAddressList:(NSArray<YMAddress *> *)addressess
{
    if (addressess==nil) {
        return;
    }
    [self.addressList removeAllObjects];
    [self.addressList addObjectsFromArray:addressess];
}

- (NSString *)uuid
{
    if (_uuid==nil) {
        _uuid = [YMUtil getUUID];
    }
    return _uuid;
}

- (NSString *)reqSeqStr
{
//    int bitCount = 1;
//    int num = _reqSeq;
//    while (num/10) {
//        bitCount++;
//        num = num/10;
//    }
//    
//    NSMutableString *mStr = [NSMutableString stringWithString:@"000000"];
//    [mStr replaceCharactersInRange:NSMakeRange(6-bitCount, bitCount) withString:[NSString stringWithFormat:@"%d", _reqSeq]];
    
    NSString *mStr = [NSString stringWithFormat:@"%06d", _reqSeq];
    
    return [NSString stringWithFormat:@"%@%@", [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMdd"],mStr];
}

- (void)readSeqFromDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *rq = [userDefaults stringForKey:@"reqSeq"];
    NSString *today = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMdd"];
    if (rq!=nil && rq.length>0) {
        NSString * rqDate = [rq substringToIndex:8];
        if ([rqDate isEqualToString:today]) {
            NSString *rqNum = [rq substringWithRange:NSMakeRange(8, 6)];
            _reqSeq = [rqNum intValue];
        } else {
            _reqSeq = 0;
        }
    } else {
        _reqSeq = 0;
    }
}

- (void)writeSeqToDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *reqSeq = [self reqSeqStr];
    [userDefaults setObject:reqSeq forKey:@"reqSeq"];
    [userDefaults synchronize];
}


@end
