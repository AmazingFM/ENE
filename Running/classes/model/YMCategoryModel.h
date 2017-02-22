//
//  YMCategoryModel.h
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMCategoryModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, retain) NSArray *spus;

@end

@interface YMGoodModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *goodId;
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, assign) NSInteger *praise_content;
@property (nonatomic, assign) NSInteger *month_saled;
@property (nonatomic, assign) float *min_price;

@end

@interface YMCollectionCategoryModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *subcategories;

@end

@interface YMSubCategoryModel : NSObject

@property (nonatomic, copy) NSString *icon_url;
@property (nonatomic, copy) NSString *name;

@end
