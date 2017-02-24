//
//  YMConfig.h
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMUtil.h"

@interface YMConfig : NSObject

@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *currentDate;
@property (nonatomic) int reqSeq;

+ (instancetype)sharedInstance;
- (NSString *)newReqSeqStr;//获取递增后的request序列号

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password andRemarkCode:(NSString *)remarkCode;
+ (void)changePassword:(NSString *)account andPassword:(NSString *)password;

+ (NSArray *)getOwnAccountAndPassword;
+ (BOOL)deleteOwnAccount;

@end
