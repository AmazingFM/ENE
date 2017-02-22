//
//  YMLocalResource.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMLocalResource : NSObject
+(instancetype)sharedResource;
+(id)loadLocalPlist:(NSString *)fileName;

-(NSString*)documentFilePathWithName:(NSString*)fileName;
-(BOOL)saveFileToDocument:(NSData*)data withName:(NSString*)fileName;
//载入本地配置，Document > NSBundle
-(id)loadConfigFile:(NSString*)fileName;

-(id)loadBundleFile:(NSString*)fileName;

@end
