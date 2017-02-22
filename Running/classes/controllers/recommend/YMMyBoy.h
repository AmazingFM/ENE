//
//  YMMyBoy.h
//  Running
//
//  Created by 张永明 on 16/10/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMMyBoy : NSObject

@property (nonatomic,copy) NSString *birthday;
@property (nonatomic,copy) NSString *contact_eml;
@property (nonatomic,copy) NSString *month_count;
@property (nonatomic,copy) NSString *nick_name;
@property (nonatomic,copy) NSString *remark_code;
@property (nonatomic,copy) NSString *sexual;
@property (nonatomic,copy) NSString *sum_count;
@property (nonatomic,copy) NSString *true_name;
@property (nonatomic,copy) NSString *user_icon;
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,copy) NSString *user_name;

@end

@interface ProfitItem : NSObject

@property (nonatomic,copy) NSString *date;
@property (nonatomic,copy) NSString *occur_amt;
@property (nonatomic,copy) NSString *occur_count;

@end


@interface YMMyProfit : NSObject

@property (nonatomic, copy) NSString *month_amt;
@property (nonatomic, copy) NSString *month_count;
@property (nonatomic, copy) NSString *sum_amt;
@property (nonatomic, copy) NSString *sum_count;
@property (nonatomic, retain) NSMutableArray<ProfitItem *> *profit_list;

@end
