//
//  YMDataManager.h
//  Running
//
//  Created by freshment on 16/9/24.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YMAddress.h"
#import "YMCity.h"

@interface YMDataManager : NSObject

@property (nonatomic) NSString *uuid;
@property (nonatomic) int reqSeq;

@property (nonatomic, retain) NSMutableArray<YMAddress *> *addressList;

@property (nonatomic, retain) NSMutableArray<YMCity *> *cityList;

+ (instancetype)shared;

- (void)initWithCitylist:(NSArray<YMCity *> *)cities;
- (void)initWithAddressList:(NSArray<YMAddress *> *)addressess;

- (void)readSeqFromDefaults;
- (void)writeSeqToDefaults;
- (NSString *)reqSeqStr;
- (NSString *)uuid;
@end
