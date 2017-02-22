//
//  YMVersionManager.h
//  Running
//
//  Created by 张永明 on 2017/1/17.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMVersionManager : NSObject

@property (nonatomic, retain) NSString *newestVersion;
@property (nonatomic, retain) NSString *updateLog;
@property (nonatomic) BOOL      forced;
@property (nonatomic, retain) NSString *downloadUrl;

+ (instancetype)sharedManager;
- (void)getVersionInfo;
@end
