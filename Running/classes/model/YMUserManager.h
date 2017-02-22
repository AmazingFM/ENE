//
//  YMDataManager.h
//  Running
//
//  Created by freshment on 16/9/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YMUser.h"

@interface YMUserManager : NSObject

@property (nonatomic, retain) YMUser *user;
@property (nonatomic, copy) NSString *shoppingNum;

+ (instancetype)sharedInstance;
@end
