//
//  YMCommentItem.m
//  Running
//
//  Created by 张永明 on 2017/2/26.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMCommentItem.h"

@interface YMCommentItem()

@end

@implementation YMCommentItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _goods_id = @"";
        _sub_gid = @"";
        _order_id = @"";
        _user_id = @"";
        _user_name = @"";
        _evaluate_level = @"";
        _evaluate_desc = @"";
        _date = @"";
        _image_1 = @"";
        _image_2 = @"";
        _image_3 = @"";
        
        //test
        self.date = @"2017.02.13";
        self.user_name = @"用户1";
        self.evaluate_level = @"4";
        self.evaluate_desc = @"舒服舒服是覅偶尔物阜民丰；发的商品批发额地方可打开开发；而非开发商的福克斯的法律上岛咖啡上岛咖啡水电费渴望速度快foe贫困分明是";
        self.image_1 = @"http://energetic.oss-cn-shanghai.aliyuncs.com/IMG_0240.JPG";
    }
    return self;
}
@end
