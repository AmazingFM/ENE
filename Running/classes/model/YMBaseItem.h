//
//  UPBaseItem.h
//  Running
//
//  Created by freshment on 16/9/20.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMBaseItem : NSObject

@end

@interface PageItem : NSObject
@property (nonatomic) int current_page;
@property (nonatomic) int page_size;
@property (nonatomic) int total_num;
@property (nonatomic) int total_page;
@end
