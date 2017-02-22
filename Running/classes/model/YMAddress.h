//
//  YMAddress.h
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMCommon.h"

#import "YMCity.h"

@interface YMAddress : NSObject
@property (nonatomic, copy) NSString *addressId;
@property (nonatomic, copy) NSString *delivery_name;
@property (nonatomic, copy) NSString *contact_no;
@property (nonatomic, copy) NSString *delivery_addr;
@property (nonatomic, copy) NSString *status;

@property (nonatomic, retain) YMCity *city;

- (NSDictionary *)dictInfo;
@end
