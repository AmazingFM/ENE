//
//  YMUser.h
//  Running
//
//  Created by freshment on 16/9/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMUser : NSObject<NSCopying>

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *user_icon;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *sexual;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *user_type;
@property (nonatomic, copy) NSString *user_name;

@property (nonatomic, copy) NSString *true_name;
@property (nonatomic, copy) NSString *contact_eml;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *remark_code;

@end
